// LEGACY: To be removed after full migration to Features structure.
using System;
using MediatR;
using YemenBooking.Application.DTOs;
using YemenBooking.Application.DTOs.Sections;
using YemenBooking.Core.Enums;

namespace YemenBooking.Application.Commands.CP.Sections
{
	public class CreateSectionCommand : IRequest<ResultDto<SectionDto>>
	{
		public SectionType Type { get; set; }
		public int DisplayOrder { get; set; }
		public SectionTarget Target { get; set; }
		public bool IsActive { get; set; } = true;
	}
}