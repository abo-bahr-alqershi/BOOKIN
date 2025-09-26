using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using YemenBooking.Application.DTOs;
using YemenBooking.Application.Queries.CP.UnitInSectionImages;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Handlers.Queries.UnitInSectionImages
{
    public class GetUnitInSectionImagesQueryHandler : IRequestHandler<GetUnitInSectionImagesQuery, ResultDto<PaginatedResultDto<ImageDto>>>
    {
        private readonly IUnitInSectionImageRepository _repository;
        public GetUnitInSectionImagesQueryHandler(IUnitInSectionImageRepository repository)
        {
            _repository = repository;
        }

        public async Task<ResultDto<PaginatedResultDto<ImageDto>>> Handle(GetUnitInSectionImagesQuery request, CancellationToken cancellationToken)
        {
            var list = await _repository.GetByUnitInSectionIdAsync(request.UnitInSectionId, cancellationToken);
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

