using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using YemenBooking.Application.Commands.Images;
using YemenBooking.Application.DTOs;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Entities;
using YemenBooking.Application.Interfaces.Services;
using YemenBooking.Core.Interfaces;
using System.Collections.Generic;

namespace YemenBooking.Application.Handlers.Commands.Images
{
    /// <summary>
    /// معالج أمر تحديث بيانات الصورة
    /// Handler for UpdateImageCommand to update image metadata
    /// </summary>
    public class UpdateImageCommandHandler : IRequestHandler<UpdateImageCommand, ResultDto<ImageDto>>
    {
        private readonly IPropertyImageRepository _imageRepository;
        private readonly IUnitOfWork _unitOfWork;

        public UpdateImageCommandHandler(
            IPropertyImageRepository imageRepository,
            IUnitOfWork unitOfWork)
        {
            _imageRepository = imageRepository;
            _unitOfWork = unitOfWork;
        }

        public async Task<ResultDto<ImageDto>> Handle(UpdateImageCommand request, CancellationToken cancellationToken)
        {
            // جلب الصورة الحالية
            var image = await _imageRepository.GetPropertyImageByIdAsync(request.ImageId, cancellationToken);
            if (image == null)
                return ResultDto<ImageDto>.Failure("الصورة غير موجودة");

            // تحديث الحقول
            if (request.Alt != null)
                image.AltText = request.Alt;
            if (request.IsPrimary.HasValue)
                image.IsMain = request.IsPrimary.Value;
            if (request.Order.HasValue)
                image.DisplayOrder = request.Order.Value;
            if (request.Tags != null)
                image.Tags = System.Text.Json.JsonSerializer.Serialize(request.Tags);
            if (request.Category.HasValue)
                image.Category = request.Category.Value;

            await _unitOfWork.ExecuteInTransactionAsync(async () =>
            {
                var updated = await _imageRepository.UpdatePropertyImageAsync(image, cancellationToken);
            }, cancellationToken);

            // تحويل إلى DTO
            var dto = new ImageDto
            {
                Id = image.Id,
                Url = image.Url,
                // extract filename from URL
                Filename = System.IO.Path.GetFileName(new Uri(image.Url).LocalPath),
                Size = image.SizeBytes,
                MimeType = image.Type,
                Width = 0,
                Height = 0,
                Alt = image.AltText,
                UploadedAt = image.UploadedAt,
                UploadedBy = image.CreatedBy ?? Guid.Empty,
                Order = image.DisplayOrder,
                IsPrimary = image.IsMain,
                PropertyId = image.PropertyId,
                UnitId = image.UnitId,
                Category = image.Category,
                Tags = System.Text.Json.JsonSerializer.Deserialize<List<string>>(image.Tags) ?? new List<string>(),
                ProcessingStatus = image.Status.ToString(),
                Thumbnails = new ImageThumbnailsDto
                {
                    Small = image.Sizes,
                    Medium = image.Sizes,
                    Large = image.Sizes,
                    Hd = image.Sizes
                },
                MediaType = (image.Type?.StartsWith("video/", StringComparison.OrdinalIgnoreCase) ?? false) ? "video" : "image",
                Duration = null,
                VideoThumbnail = null
            };

            return ResultDto<ImageDto>.Ok(dto);
        }
    }
} 