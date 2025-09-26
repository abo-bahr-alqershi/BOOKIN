using MediatR;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Application.DTOs;
using YemenBooking.Application.DTOs.PropertySearch;
using YemenBooking.Application.Queries.MobileApp.Sections;
using YemenBooking.Core.Enums;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Handlers.Queries.MobileApp.Sections
{
	public class GetSectionItemsQueryHandler : IRequestHandler<GetSectionItemsQuery, PaginatedResult<object>>
	{
		private readonly ISectionRepository _sections;
		private readonly IPropertyRepository _properties;
		private readonly IUnitRepository _units;

		public GetSectionItemsQueryHandler(
			ISectionRepository sections,
			IPropertyRepository properties,
			IUnitRepository units)
		{
			_sections = sections;
			_properties = properties;
			_units = units;
		}

		public async Task<PaginatedResult<object>> Handle(GetSectionItemsQuery request, CancellationToken cancellationToken)
		{
			if (request.PageNumber <= 0) request.PageNumber = 1;
			if (request.PageSize <= 0) request.PageSize = 10;

			var section = await _sections.GetByIdAsync(request.SectionId, cancellationToken);
			if (section == null)
				return PaginatedResult<object>.Empty(request.PageNumber, request.PageSize);

            // Use rich tables instead of legacy SectionItems
            if (section.Target == SectionTarget.Properties)
            {
                var allItems = (await _sections.GetPropertyItemsAsync(request.SectionId, cancellationToken)).ToList();
                var total = allItems.Count;
                if (total == 0)
                    return PaginatedResult<object>.Empty(request.PageNumber, request.PageSize);

                var pagedItems = allItems
                    .OrderBy(i => i.DisplayOrder)
                    .Skip((request.PageNumber - 1) * request.PageSize)
                    .Take(request.PageSize)
                    .ToList();

                // Map to existing property search dto for client compatibility
                var resultItems = pagedItems.Select(p => new PropertySearchItemDto
                {
                    Id = p.PropertyId,
                    Name = p.PropertyName,
                    Description = p.ShortDescription ?? string.Empty,
                    City = p.City,
                    Address = p.Address,
                    StarRating = p.StarRating,
                    AverageRating = p.AverageRating,
                    ReviewCount = p.ReviewsCount,
                    MinPrice = p.BasePrice,
                    Currency = p.Currency,
                    MainImageUrl = p.MainImageUrl,
                    ImageUrls = string.IsNullOrWhiteSpace(p.AdditionalImages) ? new List<string>() : System.Text.Json.JsonSerializer.Deserialize<List<string>>(p.AdditionalImages) ?? new List<string>(),
                    Amenities = new List<string>(),
                    PropertyType = p.PropertyType,
                    DistanceKm = null,
                    IsAvailable = true,
                    AvailableUnitsCount = 0,
                    MaxCapacity = 0,
                    IsFeatured = p.IsFeatured,
                    LastUpdated = DateTime.UtcNow
                }).Cast<object>().ToList();

                return PaginatedResult<object>.Create(resultItems, request.PageNumber, request.PageSize, total);
            }
            else
            {
                var allItems = (await _sections.GetUnitItemsAsync(request.SectionId, cancellationToken)).ToList();
                var total = allItems.Count;
                if (total == 0)
                    return PaginatedResult<object>.Empty(request.PageNumber, request.PageSize);

                var pagedItems = allItems
                    .OrderBy(i => i.DisplayOrder)
                    .Skip((request.PageNumber - 1) * request.PageSize)
                    .Take(request.PageSize)
                    .ToList();

                var resultItems = pagedItems.Select(u => new
                {
                    Id = u.UnitId,
                    Name = u.UnitName,
                    PropertyId = u.PropertyId,
                    UnitTypeId = u.UnitTypeId,
                    IsAvailable = u.IsAvailable,
                    MaxCapacity = u.MaxCapacity,
                    MainImageUrl = u.MainImageUrl,
                    ImageUrls = string.IsNullOrWhiteSpace(u.AdditionalImages) ? new List<string>() : System.Text.Json.JsonSerializer.Deserialize<List<string>>(u.AdditionalImages) ?? new List<string>(),
                    Badge = u.Badge,
                    BadgeColor = u.BadgeColor,
                    DiscountPercentage = u.DiscountPercentage,
                    DiscountedPrice = u.DiscountedPrice
                }).Cast<object>().ToList();

                return PaginatedResult<object>.Create(resultItems, request.PageNumber, request.PageSize, total);
            }
		}
	}
}