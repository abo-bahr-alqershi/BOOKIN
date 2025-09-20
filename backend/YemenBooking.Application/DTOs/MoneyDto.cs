using System.ComponentModel.DataAnnotations;

namespace YemenBooking.Application.DTOs;

/// <summary>
/// DTO للمبالغ المالية والعملات
/// DTO for monetary amounts and currencies
/// </summary>
public class MoneyDto
{
    /// <summary>
    /// المبلغ المالي
    /// Monetary amount
    /// </summary>
    [Required(ErrorMessage = "المبلغ المالي مطلوب")]
    public decimal Amount { get; set; }
    
    /// <summary>
    /// رمز العملة
    /// Currency code
    /// </summary>
    [Required(ErrorMessage = "رمز العملة مطلوب")]
    [StringLength(3, MinimumLength = 3, ErrorMessage = "رمز العملة يجب أن يكون 3 أحرف")]
    public string Currency { get; set; } = "YER";
    
    /// <summary>
    /// سعر الصرف
    /// سعر الصرف
    /// Exchange rate
    /// </summary>
    public decimal ExchangeRate { get; set; }

    /// <summary>
    /// المبلغ المنسق للعرض
    /// Formatted amount for display
    /// </summary>
    public string FormattedAmount => $"{Amount:N2} {Currency}";
}