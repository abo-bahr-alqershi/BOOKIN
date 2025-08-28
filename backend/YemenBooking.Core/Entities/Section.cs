namespace YemenBooking.Core.Entities;

using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using YemenBooking.Core.Enums;

/// <summary>
/// كيان قسم العرض في الواجهة
/// Section entity for grouping content on home screens and lists
/// </summary>
[Display(Name = "كيان القسم")]
public class Section : BaseEntity<Guid>
{
	/// <summary>
	/// نوع القسم
	/// </summary>
	[Display(Name = "نوع القسم")]
	public SectionType Type { get; set; }

	/// <summary>
	/// ترتيب عرض القسم
	/// </summary>
	[Display(Name = "ترتيب القسم")]
	public int DisplayOrder { get; set; }

	/// <summary>
	/// هل القسم يستهدف الكيانات أم الوحدات
	/// </summary>
	[Display(Name = "هدف القسم")] 
	public SectionTarget Target { get; set; }

	/// <summary>
	/// عناصر الربط مع الكيانات أو الوحدات
	/// </summary>
	[Display(Name = "عناصر القسم")]
	public virtual ICollection<SectionItem> Items { get; set; } = new List<SectionItem>();
}