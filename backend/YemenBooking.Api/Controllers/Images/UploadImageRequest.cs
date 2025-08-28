using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace YemenBooking.Api.Controllers.Images
{
    /// <summary>
    /// طلب رفع صورة يجمع كل الحقول ضمن نموذج واحد
    /// DTO to wrap form data for image upload
    /// </summary>
    public class UploadImageRequest
    {
        [FromForm(Name = "file")]
        public IFormFile File { get; set; } = null!;

        [FromForm(Name = "category")]
        public string Category { get; set; } = string.Empty;

        [FromForm(Name = "propertyId")]
        public string? PropertyId { get; set; }

        [FromForm(Name = "unitId")]
        public string? UnitId { get; set; }

        [FromForm(Name = "alt")]
        public string? Alt { get; set; }

        [FromForm(Name = "isPrimary")]
        public bool? IsPrimary { get; set; }

        [FromForm(Name = "order")]
        public int? Order { get; set; }

        [FromForm(Name = "tags")]
        public string? Tags { get; set; }
    }
} 