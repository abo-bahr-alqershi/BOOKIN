using MediatR;
using YemenBooking.Application.Commands.CP.Sections;
using YemenBooking.Application.DTOs;
using YemenBooking.Application.DTOs.Sections;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Handlers.Commands.Sections
{
	public class UpdateSectionCommandHandler : IRequestHandler<UpdateSectionCommand, ResultDto<SectionDto>>
	{
		private readonly ISectionRepository _repository;

		public UpdateSectionCommandHandler(ISectionRepository repository)
		{
			_repository = repository;
		}

		public async Task<ResultDto<SectionDto>> Handle(UpdateSectionCommand request, CancellationToken cancellationToken)
		{
			var entity = await _repository.GetByIdAsync(request.SectionId, cancellationToken);
			if (entity == null) return ResultDto<SectionDto>.Failure("Section not found");
			entity.Type = request.Type;
			entity.DisplayOrder = request.DisplayOrder;
			entity.Target = request.Target;
			entity.IsActive = request.IsActive;
			await _repository.UpdateAsync(entity, cancellationToken);
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