using MediatR;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Commands.CP.Sections;
using YemenBooking.Application.Queries.CP.Sections;

namespace YemenBooking.Api.Controllers.Admin
{
	public class SectionsController : BaseAdminController
	{
		public SectionsController(IMediator mediator) : base(mediator) { }

		[HttpGet]
		public async Task<IActionResult> GetSections([FromQuery] GetSectionsQuery query)
		{
			var result = await _mediator.Send(query);
			return Ok(result);
		}

		[HttpPost]
		public async Task<IActionResult> CreateSection([FromBody] CreateSectionCommand command)
		{
			var result = await _mediator.Send(command);
			return Ok(result);
		}

		[HttpPut("{sectionId}")]
		public async Task<IActionResult> UpdateSection(Guid sectionId, [FromBody] UpdateSectionCommand command)
		{
			command.SectionId = sectionId;
			var result = await _mediator.Send(command);
			return Ok(result);
		}

		[HttpDelete("{sectionId}")]
		public async Task<IActionResult> DeleteSection(Guid sectionId)
		{
			var result = await _mediator.Send(new DeleteSectionCommand { SectionId = sectionId });
			return Ok(result);
		}

		[HttpPost("{sectionId}/assign-items")]
		public async Task<IActionResult> AssignItems(Guid sectionId, [FromBody] AssignSectionItemsCommand command)
		{
			command.SectionId = sectionId;
			var result = await _mediator.Send(command);
			return Ok(result);
		}
	}
}