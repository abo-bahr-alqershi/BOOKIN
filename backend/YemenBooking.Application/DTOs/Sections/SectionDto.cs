using System;
using System.Collections.Generic;
using YemenBooking.Core.Enums;

namespace YemenBooking.Application.DTOs.Sections
{
	public class SectionDto
	{
		public Guid Id { get; set; }
		public SectionType Type { get; set; }
		public int DisplayOrder { get; set; }
		public SectionTarget Target { get; set; }
		public bool IsActive { get; set; }
		public IEnumerable<SectionItemDto> Items { get; set; } = new List<SectionItemDto>();
	}

	public class SectionItemDto
	{
		public Guid Id { get; set; }
		public Guid SectionId { get; set; }
		public Guid? PropertyId { get; set; }
		public Guid? UnitId { get; set; }
		public int SortOrder { get; set; }
	}
}