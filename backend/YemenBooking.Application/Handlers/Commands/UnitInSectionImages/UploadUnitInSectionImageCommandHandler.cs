using System;
using System.IO;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Commands.CP.UnitInSectionImages;
using YemenBooking.Application.DTOs;
using YemenBooking.Application.Interfaces.Services;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Enums;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Handlers.Commands.UnitInSectionImages
{
    public class UploadUnitInSectionImageCommandHandler : IRequestHandler<UploadUnitInSectionImageCommand, ResultDto<ImageDto>>
    {
        private readonly IFileStorageService _fileStorageService;
        private readonly ICurrentUserService _currentUserService;
        private readonly IAuditService _auditService;
        private readonly ILogger<UploadUnitInSectionImageCommandHandler> _logger;
        private readonly IUnitInSectionImageRepository _repository;

        public UploadUnitInSectionImageCommandHandler(
            IFileStorageService fileStorageService,
            ICurrentUserService currentUserService,
            IAuditService auditService,
            ILogger<UploadUnitInSectionImageCommandHandler> logger,
            IUnitInSectionImageRepository repository)
        {
            _fileStorageService = fileStorageService;
            _currentUserService = currentUserService;
            _auditService = auditService;
            _logger = logger;
            _repository = repository;
        }

        public async Task<ResultDto<ImageDto>> Handle(UploadUnitInSectionImageCommand request, CancellationToken cancellationToken)
        {
            var folderPath = $"unit-items/{request.UnitInSectionId}";
            var stream = new MemoryStream(request.File.FileContent);
            var fileName = request.Name + request.Extension;
            var upload = await _fileStorageService.UploadFileAsync(stream, fileName, request.File.ContentType, folderPath, cancellationToken);
            if (!upload.IsSuccess || string.IsNullOrWhiteSpace(upload.FileUrl))
                return ResultDto<ImageDto>.Failed("فشل رفع الملف");

            await _auditService.LogBusinessOperationAsync(
                operation: "UploadUnitInSectionImage",
                entityName: nameof(UnitInSectionImage),
                entityId: request.UnitInSectionId.ToString(),
                userId: _currentUserService.UserId,
                metadata: new { request.Name, request.Category, request.IsPrimary, request.Order });

            var thumbnails = new ImageThumbnailsDto { Small = upload.FileUrl!, Medium = upload.FileUrl!, Large = upload.FileUrl!, Hd = upload.FileUrl! };

            var entity = new UnitInSectionImage
            {
                Id = Guid.NewGuid(),
                UnitInSectionId = request.UnitInSectionId,
                Name = fileName,
                Url = upload.FileUrl!,
                SizeBytes = upload.FileSizeBytes,
                Type = request.File.ContentType,
                Category = request.Category,
                Caption = request.Alt ?? string.Empty,
                AltText = request.Alt ?? string.Empty,
                Tags = JsonSerializer.Serialize(request.Tags ?? new System.Collections.Generic.List<string>()),
                Sizes = thumbnails.Medium,
                IsMainImage = request.IsPrimary ?? false,
                DisplayOrder = request.Order ?? 0,
                Status = ImageStatus.Approved,
                UploadedAt = upload.UploadedAt,
                CreatedBy = _currentUserService.UserId,
                UpdatedAt = upload.UploadedAt,
                MediaType = (request.File.ContentType?.StartsWith("video/", StringComparison.OrdinalIgnoreCase) ?? false) ? "video" : "image",
                DurationSeconds = null,
                VideoThumbnailUrl = null
            };

            if (request.VideoThumbnail != null)
            {
                var posterUpload = await _fileStorageService.UploadFileAsync(
                    request.VideoThumbnail.FileContent,
                    request.VideoThumbnail.FileName,
                    request.VideoThumbnail.ContentType,
                    folderPath,
                    cancellationToken);
                if (posterUpload.IsSuccess && !string.IsNullOrWhiteSpace(posterUpload.FileUrl))
                {
                    entity.VideoThumbnailUrl = posterUpload.FileUrl;
                    entity.MediaType = "video";
                }
            }

            await _repository.CreateAsync(entity, cancellationToken);

            var dto = new ImageDto
            {
                Id = entity.Id,
                Url = entity.Url,
                Filename = entity.Name,
                Size = entity.SizeBytes,
                MimeType = entity.Type,
                Width = 0,
                Height = 0,
                Alt = entity.AltText,
                UploadedAt = entity.UploadedAt,
                UploadedBy = entity.CreatedBy ?? Guid.Empty,
                Order = entity.DisplayOrder,
                IsPrimary = entity.IsMainImage,
                Category = entity.Category,
                Tags = string.IsNullOrWhiteSpace(entity.Tags) ? new System.Collections.Generic.List<string>() : JsonSerializer.Deserialize<System.Collections.Generic.List<string>>(entity.Tags) ?? new System.Collections.Generic.List<string>(),
                ProcessingStatus = entity.Status.ToString(),
                Thumbnails = thumbnails,
                MediaType = entity.MediaType,
                Duration = entity.DurationSeconds,
                VideoThumbnail = entity.VideoThumbnailUrl
            };

            return ResultDto<ImageDto>.Ok(dto);
        }
    }
}

