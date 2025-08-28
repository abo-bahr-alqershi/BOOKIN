namespace YemenBooking.Core.Entities;

using System;
using System.ComponentModel.DataAnnotations;

/// <summary>
/// عنصر داخل القسم يربط القسم بكيان أو وحدة
/// Section join entity linking a section to a property or unit
/// </summary>
[Display(Name = "عنصر القسم")]
public class SectionItem : BaseEntity<Guid>
{
	/// <summary>
	/// معرف القسم
	/// </summary>
	[Display(Name = "معرف القسم")]
	public Guid SectionId { get; set; }

	/// <summary>
	/// معرف الكيان (اختياري)
	/// </summary>
	[Display(Name = "معرف الكيان")]
	public Guid? PropertyId { get; set; }

	/// <summary>
	/// معرف الوحدة (اختياري)
	/// </summary>
	[Display(Name = "معرف الوحدة")]
	public Guid? UnitId { get; set; }

	/// <summary>
	/// ترتيب العنصر داخل القسم
	/// </summary>
	[Display(Name = "ترتيب العنصر")]
	public int SortOrder { get; set; } = 0;

	/// <summary>
	/// القسم المرتبط
	/// </summary>
	[Display(Name = "القسم المرتبط")]
	public virtual Section Section { get; set; }

	/// <summary>
	/// الكيان المرتبط (إن وجد)
	/// </summary>
	[Display(Name = "الكيان المرتبط")]
	public virtual Property? Property { get; set; }

	/// <summary>
	/// الوحدة المرتبطة (إن وجدت)
	/// </summary>
	[Display(Name = "الوحدة المرتبطة")]
	public virtual Unit? Unit { get; set; }
}