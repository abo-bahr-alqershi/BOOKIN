namespace YemenBooking.Core.Entities;

using System;
using System.ComponentModel.DataAnnotations;
using YemenBooking.Core.Enums;

/// <summary>
/// كيان صورة الكيان
/// Property Image entity
/// </summary>
[Display(Name = "كيان صورة الكيان")]
public class PropertyImage : BaseEntity<Guid>
{
    /// <summary>
    /// معرف الكيان (قابل للتمرير إلى NULL)
    /// Property identifier (nullable)
    /// </summary>
    [Display(Name = "معرف الكيان")]
    public Guid? PropertyId { get; set; }
    
    /// <summary>
    /// معرف الوحدة (قابل للتمرير إلى NULL)
    /// Unit identifier (nullable)
    /// </summary>
    [Display(Name = "معرف الوحدة")]
    public Guid? UnitId { get; set; }
    
    /// <summary>
    /// اسم الصورة
    /// Image name
    /// </summary>
    [Display(Name = "اسم الصورة")]
    public string Name { get; set; }
    
    /// <summary>
    /// رابط الصورة
    /// Image URL
    /// </summary>
    [Display(Name = "رابط الصورة")]
    public string Url { get; set; }
    
    /// <summary>
    /// حجم الصورة بالبايت
    /// Image size in bytes
    /// </summary>
    [Display(Name = "حجم الصورة بالبايت")]
    public long SizeBytes { get; set; }
    
    /// <summary>
    /// نوع الصورة
    /// Image type
    /// </summary>
    [Display(Name = "نوع الصورة")]
    public string Type { get; set; }
    
    /// <summary>
    /// فئة الصورة
    /// Image category
    /// </summary>
    [Display(Name = "فئة الصورة")]
    public ImageCategory Category { get; set; }
    
    /// <summary>
    /// تسمية توضيحية للصورة
    /// Image caption
    /// </summary>
    [Display(Name = "تسمية توضيحية للصورة")]
    public string Caption { get; set; }
    
    /// <summary>
    /// نص بديل للصورة
    /// Image alt text
    /// </summary>
    [Display(Name = "نص بديل للصورة")]
    public string AltText { get; set; }
    
    /// <summary>
    /// وسوم الصورة (JSON)
    /// Image tags (JSON)
    /// </summary>
    [Display(Name = "وسوم الصورة")]
    public string Tags { get; set; }

    /// <summary>
    /// أحجام الصورة (JSON)
    /// Image sizes (JSON) - mapping keys to URLs for different sizes (e.g. thumbnail, medium, large)
    /// </summary>
    [Display(Name = "أحجام الصورة")]
    public string Sizes { get; set; }

    /// <summary>
    /// هل هي الصورة الرئيسية
    /// Is main image
    /// </summary>
    [Display(Name = "هل هي الصورة الرئيسية")]
    public bool IsMain { get; set; }
    
    /// <summary>
    /// ترتيب العرض
    /// Sort order
    /// </summary>
    [Display(Name = "ترتيب العرض")]
    public int SortOrder { get; set; }
    
    /// <summary>
    /// عدد المشاهدات
    /// Number of views
    /// </summary>
    [Display(Name = "عدد المشاهدات")]
    public int Views { get; set; }
    
    /// <summary>
    /// عدد التنزيلات
    /// Number of downloads
    /// </summary>
    [Display(Name = "عدد التنزيلات")]
    public int Downloads { get; set; }
    
    /// <summary>
    /// تاريخ الرفع
    /// Upload date
    /// </summary>
    [Display(Name = "تاريخ الرفع")]
    public DateTime UploadedAt { get; set; }
    
    /// <summary>
    /// ترتيب العرض
    /// Display order
    /// </summary>
    [Display(Name = "ترتيب العرض")]
    public int DisplayOrder { get; set; }
    
    /// <summary>
    /// حالة الصورة
    /// Image status
    /// </summary>
    [Display(Name = "حالة الصورة")]
    public ImageStatus Status { get; set; }
    
    /// <summary>
    /// هل هي الصورة الرئيسية
    /// Is main image
    /// </summary>
    [Display(Name = "هل هي الصورة الرئيسية")]
    public bool IsMainImage { get; set; }
    
    /// <summary>
    /// الكيان المرتبط بالصورة (قابل للتمرير إلى NULL)
    /// Property associated with the image (nullable)
    /// </summary>
    [Display(Name = "الكيان المرتبط بالصورة")]
    public virtual Property? Property { get; set; }
    
    /// <summary>
    /// الوحدة المرتبطة بالصورة (قابل للتمرير إلى NULL)
    /// Unit associated with the image (nullable)
    /// </summary>
    [Display(Name = "الوحدة المرتبطة بالصورة")]
    public virtual Unit? Unit { get; set; }
}