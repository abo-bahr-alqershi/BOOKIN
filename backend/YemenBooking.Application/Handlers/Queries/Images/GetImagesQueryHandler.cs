using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Application.Queries.Images;
using YemenBooking.Application.DTOs;
using YemenBooking.Core.Interfaces.Repositories;
using System.Collections.Generic;
using YemenBooking.Core.Enums;
using System.Text.Json;

namespace YemenBooking.Application.Handlers.Queries.Images
{
    /// <summary>
    /// معالج استعلام الحصول على قائمة الصور مع الفلاتر والصفحات
    /// Handler for GetImagesQuery to retrieve images list with filtering, sorting, and pagination
    /// </summary>
    public class GetImagesQueryHandler : IRequestHandler<GetImagesQuery, ResultDto<PaginatedResultDto<ImageDto>>>
    {
        private readonly IPropertyImageRepository _imageRepository;

        public GetImagesQueryHandler(IPropertyImageRepository imageRepository)
        {
            _imageRepository = imageRepository;
        }

        public async Task<ResultDto<PaginatedResultDto<ImageDto>>> Handle(GetImagesQuery request, CancellationToken cancellationToken)
        {
            // 1. بناء الاستعلام مع الفلاتر
            var query = _imageRepository.GetQueryable().AsNoTracking();

            if (!string.IsNullOrWhiteSpace(request.TempKey))
                query = query.Where(i => i.TempKey == request.TempKey);

            if (request.PropertyId.HasValue && !request.UnitId.HasValue)
                query = query.Where(i => i.PropertyId == request.PropertyId.Value);
            if (request.UnitId.HasValue)
                query = query.Where(i => i.UnitId == request.UnitId.Value);
            if (request.Category.HasValue)
                query = query.Where(i => i.Category == request.Category.Value);
            if (!string.IsNullOrWhiteSpace(request.Search))
            {
                var term = request.Search.Trim().ToLower();
                query = query.Where(i => i.Name.ToLower().Contains(term)
                    || i.Caption.ToLower().Contains(term)
                    || i.AltText.ToLower().Contains(term)
                    || i.Tags.ToLower().Contains(term));
            }

            // 2. تطبيق الفرز
            var sortBy = request.SortBy?.Trim().ToLower();
            var ascending = string.Equals(request.SortOrder, "asc", StringComparison.OrdinalIgnoreCase);
            query = sortBy switch
            {
                "uploadedat" => ascending ? query.OrderBy(i => i.UploadedAt) : query.OrderByDescending(i => i.UploadedAt),
                "order" => ascending ? query.OrderBy(i => i.DisplayOrder) : query.OrderByDescending(i => i.DisplayOrder),
                "filename" => ascending ? query.OrderBy(i => i.Name) : query.OrderByDescending(i => i.Name),
                _ => query.OrderByDescending(i => i.UploadedAt),
            };

            // 3. تطبيق الترقيم
            var page = request.Page.GetValueOrDefault(1);
            var limit = request.Limit.GetValueOrDefault(10);
            var totalCount = await query.CountAsync(cancellationToken);
            var items = await query.Skip((page - 1) * limit).Take(limit).ToListAsync(cancellationToken);

            // 4. تحويل إلى DTO
            var dtos = items.Select(i => new ImageDto
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
                IsPrimary = i.IsMain,
                PropertyId = i.PropertyId,
                UnitId = i.UnitId,
                Category = i.Category,
                Tags = string.IsNullOrWhiteSpace(i.Tags) ? new List<string>() : JsonSerializer.Deserialize<List<string>>(i.Tags) ?? new List<string>(),
                ProcessingStatus = i.Status.ToString(),
                Thumbnails = new ImageThumbnailsDto
                {
                    Small = i.Sizes,
                    Medium = i.Sizes,
                    Large = i.Sizes,
                    Hd = i.Sizes
                }
            }).ToList();

            // 5. إعداد نتيجة الترقيم
            var totalPages = (int)Math.Ceiling(totalCount / (double)limit);
            var paged = new PaginatedResultDto<ImageDto>
            {
                Items = dtos,
                Total = totalCount,
                Page = page,
                Limit = limit,
                TotalPages = totalPages
            };

            return ResultDto<PaginatedResultDto<ImageDto>>.Ok(paged);
        }
    }
} 