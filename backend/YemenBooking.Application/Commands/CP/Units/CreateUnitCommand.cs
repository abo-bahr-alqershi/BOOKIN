using MediatR;
using YemenBooking.Application.DTOs;
using YemenBooking.Core.Enums;
using System.ComponentModel.DataAnnotations;

namespace YemenBooking.Application.Commands.Units;

/// <summary>
/// أمر لإنشاء وحدة جديدة في الكيان
/// Command to create a new unit in a property
/// </summary>
public class CreateUnitCommand : IRequest<ResultDto<Guid>>
{
    /// <summary>
    /// مفتاح مؤقت للصور المرفوعة قبل الحفظ
    /// Temporary key for pre-saved image uploads
    /// </summary>
    public string? TempKey { get; set; }

    /// <summary>
    /// معرف الكيان
    /// Property ID
    /// </summary>
    [Required(ErrorMessage = "معرف الكيان مطلوب")]
    public Guid PropertyId { get; set; }

    /// <summary>
    /// معرف نوع الوحدة
    /// Unit type ID
    /// </summary>
    [Required(ErrorMessage = "معرف نوع الوحدة مطلوب")]
    public Guid UnitTypeId { get; set; }

    /// <summary>
    /// اسم الوحدة
    /// Unit name
    /// </summary>
    [Required(ErrorMessage = "اسم الوحدة مطلوب")]
    [StringLength(100, MinimumLength = 1, ErrorMessage = "اسم الوحدة يجب أن يكون بين 1 و 100 حرف")]
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// السعر الأساسي للوحدة
    /// Base price of the unit
    /// </summary>
    [Required(ErrorMessage = "السعر الأساسي مطلوب")]
    public MoneyDto BasePrice { get; set; }

    /// <summary>
    /// الميزات المخصصة للوحدة
    /// Custom features of the unit (JSON)
    /// </summary>
    public string CustomFeatures { get; set; } = string.Empty;

    /// <summary>
    /// طريقة حساب السعر
    /// Pricing calculation method (Hourly, Daily, Weekly, Monthly)
    /// </summary>
    [Required(ErrorMessage = "طريقة حساب السعر مطلوبة")]
    public PricingMethod PricingMethod { get; set; }

    /// <summary>
    /// قيم الحقول الديناميكية للوحدة
    /// Dynamic field values for the unit
    /// </summary>
    public List<FieldValueDto> FieldValues { get; set; } = new List<FieldValueDto>();

    /// <summary>
    /// الصور المرسلة مؤقتاً للوحدة
    /// </summary>
    public List<string> Images { get; set; } = new List<string>();
} 