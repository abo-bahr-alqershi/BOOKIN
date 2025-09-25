using System;
using System.Collections.Generic;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using YemenBooking.Application.Queries.Images;
using YemenBooking.Application.DTOs;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Enums;

namespace YemenBooking.Application.Handlers.Queries.Images
{
    /// <summary>
    /// معالج استعلام الحصول على صورة واحدة بواسطة المعرف
    /// Handler for GetImageByIdQuery to retrieve a single image by its ID
    /// </summary>
    public class GetImageByIdQueryHandler : IRequestHandler<GetImageByIdQuery, ResultDto<ImageDto>>
    {
        private readonly IPropertyImageRepository _imageRepository;

        public GetImageByIdQueryHandler(IPropertyImageRepository imageRepository)
        {
            _imageRepository = imageRepository;
        }

        public async Task<ResultDto<ImageDto>> Handle(GetImageByIdQuery request, CancellationToken cancellationToken)
        {
            // جلب الصورة من المستودع
            var image = await _imageRepository.GetPropertyImageByIdAsync(request.ImageId, cancellationToken);
            if (image == null)
                return ResultDto<ImageDto>.Failure("الصورة غير موجودة");

            // تحويل الكيان إلى DTO
            var dto = new ImageDto
            {
                Id = image.Id,
                Url = image.Url,
                Filename = image.Name,
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
                Tags = string.IsNullOrWhiteSpace(image.Tags)
                    ? new List<string>()
                    : JsonSerializer.Deserialize<List<string>>(image.Tags)!,
                ProcessingStatus = image.Status.ToString(),
                Thumbnails = new ImageThumbnailsDto
                {
                    Small = image.Sizes,
                    Medium = image.Sizes,
                    Large = image.Sizes,
                    Hd = image.Sizes
                },
                MediaType = string.IsNullOrWhiteSpace(image.MediaType)
                    ? ((image.Type?.StartsWith("video/", StringComparison.OrdinalIgnoreCase) ?? false) ? "video" : "image")
                    : image.MediaType,
                Duration = image.DurationSeconds,
                VideoThumbnail = string.IsNullOrWhiteSpace(image.VideoThumbnailUrl) ? null : image.VideoThumbnailUrl
            };

            return ResultDto<ImageDto>.Ok(dto);
        }
    }
} 