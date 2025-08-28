namespace YemenBooking.Application.DTOs;

using System;

/// <summary>
/// بيانات نقل قيمة حقل الوحدة
/// DTO for UnitFieldValue entity
/// </summary>
public class UnitFieldValueDto
{
    /// <summary>
    /// معرف القيمة
    /// ValueId
    /// </summary>
    public Guid ValueId { get; set; }

    /// <summary>
    /// معرف الوحدة
    /// UnitId
    /// </summary>
    public Guid UnitId { get; set; }

    /// <summary>
    /// معرف الحقل
    /// FieldId
    /// </summary>
    public Guid FieldId { get; set; }

    /// <summary>
    /// اسم الحقل
    /// FieldName
    /// </summary>
    public string FieldName { get; set; }

    /// <summary>
    /// الاسم المعروض للحقل
    /// DisplayName
    /// </summary>
    public string DisplayName { get; set; }

    /// <summary>
    /// قيمة الحقل (سلسلة نصية)
    /// Field value as string
    /// </summary>
    public string Value { get; set; }

    /// <summary>
    /// نوع الحقل (نصي، رقم، تاريخ ...)
    /// Field type (text, number, date ...)
    /// </summary>
    public string FieldType { get; set; }

    // احتفاظ بالخاصية القديمة للتوافق العكسي
    public string FieldValue
    {
        get => Value;
        set => Value = value;
    }

    /// <summary>
    /// معلومات الحقل الديناميكي
    /// Field (UnitTypeFieldDto)
    /// </summary>
    public UnitTypeFieldDto Field { get; set; }

    /// <summary>
    /// تاريخ الإنشاء
    /// CreatedAt
    /// </summary>
    public DateTime CreatedAt { get; set; }

    /// <summary>
    /// تاريخ التحديث
    /// UpdatedAt
    /// </summary>
    public DateTime UpdatedAt { get; set; }
} 