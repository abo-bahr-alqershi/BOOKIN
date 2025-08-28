using MediatR;
using YemenBooking.Application.DTOs;
using YemenBooking.Application.DTOs.Sections;
using YemenBooking.Application.Queries.CP.Sections;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Handlers.Queries.Sections
{
	public class GetSectionsQueryHandler : IRequestHandler<GetSectionsQuery, PaginatedResult<SectionDto>>
	{
		private readonly ISectionRepository _repository;

		public GetSectionsQueryHandler(ISectionRepository repository)
		{
			_repository = repository;
		}

		public async Task<PaginatedResult<SectionDto>> Handle(GetSectionsQuery request, CancellationToken cancellationToken)
		{
			var (items, total) = await _repository.GetPagedAsync(request.PageNumber, request.PageSize, request.Target, request.Type, cancellationToken);
			var dtoItems = items.Select(s => new SectionDto
			{
				Id = s.Id,
				Type = s.Type,
				DisplayOrder = s.DisplayOrder,
				Target = s.Target,
				IsActive = s.IsActive
			});
			return new PaginatedResult<SectionDto>
			{
				Items = dtoItems.ToList(),
				TotalCount = total,
				PageNumber = request.PageNumber,
				PageSize = request.PageSize
			};
		}
	}
}