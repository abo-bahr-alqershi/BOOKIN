using MediatR;
using YemenBooking.Application.Commands.CP.Sections;
using YemenBooking.Application.DTOs;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Handlers.Commands.Sections
{
	public class AssignSectionItemsCommandHandler : IRequestHandler<AssignSectionItemsCommand, ResultDto>
	{
		private readonly ISectionRepository _repository;

		public AssignSectionItemsCommandHandler(ISectionRepository repository)
		{
			_repository = repository;
		}

		public async Task<ResultDto> Handle(AssignSectionItemsCommand request, CancellationToken cancellationToken)
		{
			if (request.PropertyIds.Count > 0)
			{
				await _repository.AssignPropertiesAsync(request.SectionId, request.PropertyIds, cancellationToken);
			}
			else if (request.UnitIds.Count > 0)
			{
				await _repository.AssignUnitsAsync(request.SectionId, request.UnitIds, cancellationToken);
			}
			else
			{
				// Clear items if both empty
				await _repository.AssignPropertiesAsync(request.SectionId, new List<Guid>(), cancellationToken);
			}
			return ResultDto.Ok();
		}
	}
}