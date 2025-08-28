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

			// احصل على كل العناصر (يمكن لاحقاً تحسينها إلى استعلام موجه بالترقيم في المستودع)
			var allItems = (await _sections.GetItemsAsync(request.SectionId, cancellationToken)).ToList();
			var total = allItems.Count;
			if (total == 0)
				return PaginatedResult<object>.Empty(request.PageNumber, request.PageSize);

			var pagedItems = allItems
				.OrderBy(i => i.SortOrder)
				.Skip((request.PageNumber - 1) * request.PageSize)
				.Take(request.PageSize)
				.ToList();

			List<object> resultItems;
			if (section.Target == SectionTarget.Properties)
			{
				var propertyIds = pagedItems.Where(i => i.PropertyId.HasValue).Select(i => i.PropertyId!.Value).Distinct().ToList();
				if (propertyIds.Count == 0)
					return PaginatedResult<object>.Empty(request.PageNumber, request.PageSize);

				// استعلام واحد مع تضمين الصور والمرافق لأن العدد في الصفحة محدود
				var propsQuery = _properties
					.GetQueryable()
					.AsNoTracking()
					.Where(p => propertyIds.Contains(p.Id))
					.Include(p => p.Images)
					.Include(p => p.Amenities)
						.ThenInclude(pa => pa.PropertyTypeAmenity)
						.ThenInclude(pta => pta.Amenity);

				var props = await propsQuery.Select(p => new PropertySearchItemDto
				{
					Id = p.Id,
					Name = p.Name,
					Description = p.Description,
					City = p.City,
					Address = p.Address,
					StarRating = p.StarRating,
					AverageRating = p.AverageRating,
					ReviewCount = 0, // يمكن تحسينه لاحقاً بجلب عدد المراجعات
					MinPrice = p.BasePricePerNight,
					Currency = p.Currency,
					// الصورة الرئيسية: أول صورة معنونة كـ IsMain أو IsMainImage أو حسب SortOrder
					MainImageUrl = p.Images
						.OrderBy(img => img.SortOrder)
						.Where(img => img.IsMain || img.IsMainImage)
						.Select(img => img.Url)
						.FirstOrDefault() ?? p.Images
							.OrderBy(img => img.SortOrder)
							.Select(img => img.Url)
							.FirstOrDefault(),
					// كل الروابط (يمكن تقييد العدد إذا لزم)
					ImageUrls = p.Images
						.OrderBy(img => img.SortOrder)
						.Select(img => img.Url)
						.ToList(),
					// أسماء المرافق المتاحة
					Amenities = p.Amenities
						.Where(a => a.IsAvailable && a.PropertyTypeAmenity.Amenity != null)
						.Select(a => a.PropertyTypeAmenity.Amenity.Name)
						.Distinct()
						.ToList(),
					PropertyType = p.TypeId.ToString(), // لاحقاً يمكن جلب الاسم عبر Include للنوع
					DistanceKm = null,
					IsAvailable = true, // تبسيط - يمكن حساب التوفر الحقيقي لاحقاً
					AvailableUnitsCount = 0,
					MaxCapacity = 0,
					IsFeatured = p.IsFeatured,
					LastUpdated = p.UpdatedAt
				}).ToListAsync(cancellationToken);

				// المحافظة على ترتيب العناصر حسب SortOrder
				var dict = props.ToDictionary(p => p.Id, p => (object)p);
				resultItems = pagedItems
					.Where(i => i.PropertyId.HasValue && dict.ContainsKey(i.PropertyId!.Value))
					.Select(i => dict[i.PropertyId!.Value])
					.ToList();
			}
			else // Units
			{
				var unitIds = pagedItems.Where(i => i.UnitId.HasValue).Select(i => i.UnitId!.Value).Distinct().ToList();
				if (unitIds.Count == 0)
					return PaginatedResult<object>.Empty(request.PageNumber, request.PageSize);

				var unitsQuery = _units.GetQueryable().AsNoTracking().Where(u => unitIds.Contains(u.Id));
				var units = await unitsQuery.Select(u => new
				{
					u.Id,
					u.Name,
					u.PropertyId,
					u.UnitTypeId,
					u.IsAvailable,
					u.MaxCapacity
				}).ToListAsync(cancellationToken);

				var dict = units.ToDictionary(u => u.Id, u => (object)u);
				resultItems = pagedItems
					.Where(i => i.UnitId.HasValue && dict.ContainsKey(i.UnitId!.Value))
					.Select(i => dict[i.UnitId!.Value])
					.ToList();
			}

			return PaginatedResult<object>.Create(resultItems, request.PageNumber, request.PageSize, total);
		}
	}
}