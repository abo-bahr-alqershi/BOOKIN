using System;
using MediatR;
using YemenBooking.Application.DTOs;
using YemenBooking.Application.DTOs.Sections;
using YemenBooking.Core.Enums;

namespace YemenBooking.Application.Commands.CP.Sections
{
	public class UpdateSectionCommand : IRequest<ResultDto<SectionDto>>
	{
		public Guid SectionId { get; set; }
		public SectionType Type { get; set; }
		public int DisplayOrder { get; set; }
		public SectionTarget Target { get; set; }
		public bool IsActive { get; set; }
	}
}