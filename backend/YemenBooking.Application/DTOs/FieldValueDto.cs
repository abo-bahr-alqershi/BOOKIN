namespace YemenBooking.Application.DTOs;
using System;
using System.ComponentModel.DataAnnotations;

/// <summary>
/// بيانات نقل قيمة حقل عام
/// DTO for field value updates (generic)
/// </summary>
public class FieldValueDto
{
    /// <summary>
    /// معرف الحقل
    /// FieldId
    /// </summary>
    [Required(ErrorMessage = "معرف الحقل مطلوب")]
    public Guid FieldId { get; set; }

    /// <summary>
    /// قيمة الحقل
    /// FieldValue
    /// </summary>
    [Required(ErrorMessage = "قيمة الحقل مطلوبة")]
    public string FieldValue { get; set; }
} 