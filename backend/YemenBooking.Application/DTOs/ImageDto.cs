using System;
using System.Collections.Generic;
using YemenBooking.Core.Enums;

namespace YemenBooking.Application.DTOs
{
    /// <summary>
    /// بيانات الصورة الأساسية
    /// Image data transfer object matching the front-end Image type
    /// </summary>
    public class ImageDto
    {
        /// <summary>
        /// معرف فريد للصورة
        /// Unique image identifier
        /// </summary>
        public Guid Id { get; set; }

        /// <summary>
        /// رابط الصورة
        /// Image URL
        /// </summary>
        public string Url { get; set; } = string.Empty;

        /// <summary>
        /// اسم الملف
        /// File name
        /// </summary>
        public string Filename { get; set; } = string.Empty;

        /// <summary>
        /// حجم الملف بالبايت
        /// File size in bytes
        /// </summary>
        public long Size { get; set; }

        /// <summary>
        /// نوع الملف (MIME type)
        /// File MIME type
        /// </summary>
        public string MimeType { get; set; } = string.Empty;

        /// <summary>
        /// عرض الصورة
        /// Image width
        /// </summary>
        public int Width { get; set; }

        /// <summary>
        /// ارتفاع الصورة
        /// Image height
        /// </summary>
        public int Height { get; set; }

        /// <summary>
        /// النص البديل للصورة
        /// Alt text
        /// </summary>
        public string? Alt { get; set; }

        /// <summary>
        /// تاريخ رفع الصورة
        /// Upload date
        /// </summary>
        public DateTime UploadedAt { get; set; }

        /// <summary>
        /// معرف المستخدم الذي رفع الصورة
        /// User ID who uploaded the image
        /// </summary>
        public Guid UploadedBy { get; set; }

        /// <summary>
        /// ترتيب العرض
        /// Display order
        /// </summary>
        public int Order { get; set; }

        /// <summary>
        /// هل الصورة رئيسية
        /// Is primary image
        /// </summary>
        public bool IsPrimary { get; set; }

        /// <summary>
        /// معرف الكيان المرتبط (اختياري)
        /// Associated property ID (optional)
        /// </summary>
        public Guid? PropertyId { get; set; }

        /// <summary>
        /// معرف الوحدة المرتبطة (اختياري)
        /// Associated unit ID (optional)
        /// </summary>
        public Guid? UnitId { get; set; }

        /// <summary>
        /// فئة الصورة
        /// Image category
        /// </summary>
        public ImageCategory Category { get; set; }

        /// <summary>
        /// العلامات المرتبطة بالصورة
        /// Image tags
        /// </summary>
        public List<string> Tags { get; set; } = new List<string>();

        /// <summary>
        /// حالة معالجة الصورة
        /// Processing status as string
        /// </summary>
        public string ProcessingStatus { get; set; } = string.Empty;

        /// <summary>
        /// مصغرات الصور بأحجام مختلفة
        /// Image thumbnails in various sizes
        /// </summary>
        public ImageThumbnailsDto Thumbnails { get; set; } = new ImageThumbnailsDto();
    }

    /// <summary>
    /// مصغرات الصور بأحجام مختلفة
    /// Thumbnails DTO
    /// </summary>
    public class ImageThumbnailsDto
    {
        /// <summary>
        /// مصغرة صغيرة (150x150)
        /// Small thumbnail
        /// </summary>
        public string Small { get; set; } = string.Empty;

        /// <summary>
        /// مصغرة متوسطة (300x300)
        /// Medium thumbnail
        /// </summary>
        public string Medium { get; set; } = string.Empty;

        /// <summary>
        /// مصغرة كبيرة (600x600)
        /// Large thumbnail
        /// </summary>
        public string Large { get; set; } = string.Empty;

        /// <summary>
        /// صورة عالية الجودة (HD)
        /// High quality thumbnail
        /// </summary>
        public string Hd { get; set; } = string.Empty;
    }
} 