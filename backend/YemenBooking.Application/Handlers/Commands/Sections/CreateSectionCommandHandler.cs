using MediatR;
using YemenBooking.Application.Commands.CP.Sections;
using YemenBooking.Application.DTOs;
using YemenBooking.Application.DTOs.Sections;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Handlers.Commands.Sections
{
	public class CreateSectionCommandHandler : IRequestHandler<CreateSectionCommand, ResultDto<SectionDto>>
	{
		private readonly ISectionRepository _repository;

		public CreateSectionCommandHandler(ISectionRepository repository)
		{
			_repository = repository;
		}

		public async Task<ResultDto<SectionDto>> Handle(CreateSectionCommand request, CancellationToken cancellationToken)
		{
			var entity = new Section
			{
				Type = request.Type,
				DisplayOrder = request.DisplayOrder,
				Target = request.Target,
				IsActive = request.IsActive
			};
			entity = await _repository.CreateAsync(entity, cancellationToken);
			var dto = new SectionDto
			{
				Id = entity.Id,
				Type = entity.Type,
				DisplayOrder = entity.DisplayOrder,
				Target = entity.Target,
				IsActive = entity.IsActive
			};
			return ResultDto<SectionDto>.Ok(dto);
		}
	}
}