using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Application.DTOs;
using YemenBooking.Application.Queries.CP.SectionImages;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Handlers.Queries.SectionImages
{
    public class GetSectionImagesQueryHandler : IRequestHandler<GetSectionImagesQuery, ResultDto<PaginatedResultDto<ImageDto>>>
    {
        private readonly ISectionImageRepository _sectionImageRepository;

        public GetSectionImagesQueryHandler(ISectionImageRepository sectionImageRepository)
        {
            _sectionImageRepository = sectionImageRepository;
        }

        public async Task<ResultDto<PaginatedResultDto<ImageDto>>> Handle(GetSectionImagesQuery request, CancellationToken cancellationToken)
        {
            var list = await _sectionImageRepository.GetBySectionIdAsync(request.SectionId, cancellationToken);

            var page = request.Page.GetValueOrDefault(1);
            var limit = request.Limit.GetValueOrDefault(20);
            var total = list.Count();
            var items = list
                .OrderBy(i => i.DisplayOrder)
                .ThenBy(i => i.UploadedAt)
                .Skip((page - 1) * limit)
                .Take(limit)
                .Select(i => new ImageDto
                {
                    Id = i.Id,
                    Url = i.Url,
                    Filename = i.Name,
                    Size = i.SizeBytes,
                    MimeType = i.Type,
                    Width = 0,
                    Height = 0,
                    Alt = i.AltText,
                    UploadedAt = i.UploadedAt,
                    UploadedBy = i.CreatedBy ?? Guid.Empty,
                    Order = i.DisplayOrder,
                    IsPrimary = i.IsMainImage,
                    Category = i.Category,
                    Tags = string.IsNullOrWhiteSpace(i.Tags) ? new System.Collections.Generic.List<string>() : System.Text.Json.JsonSerializer.Deserialize<System.Collections.Generic.List<string>>(i.Tags) ?? new System.Collections.Generic.List<string>(),
                    ProcessingStatus = i.Status.ToString(),
                    Thumbnails = new ImageThumbnailsDto { Small = i.Sizes ?? string.Empty, Medium = i.Sizes ?? string.Empty, Large = i.Sizes ?? string.Empty, Hd = i.Sizes ?? string.Empty },
                    MediaType = string.IsNullOrWhiteSpace(i.MediaType) ? "image" : i.MediaType,
                    Duration = i.DurationSeconds,
                    VideoThumbnail = string.IsNullOrWhiteSpace(i.VideoThumbnailUrl) ? null : i.VideoThumbnailUrl
                })
                .ToList();

            var result = new PaginatedResultDto<ImageDto>
            {
                Items = items,
                Total = total,
                Page = page,
                Limit = limit,
                TotalPages = (int)Math.Ceiling(total / (double)limit)
            };

            return ResultDto<PaginatedResultDto<ImageDto>>.Ok(result);
        }
    }
}

