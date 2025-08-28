using System;
using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using YemenBooking.Application.Commands.Images;
using YemenBooking.Application.Queries.Images;
using YemenBooking.Application.DTOs;
using Microsoft.AspNetCore.Http;
using System.IO;
using System.Linq;
using System.Collections.Generic;
using YemenBooking.Core.Enums;

namespace YemenBooking.Api.Controllers.Images
{
    /// <summary>
    /// متحكم لإدارة الصور الشاملة (رفع، تعديل، حذف، استعلام)
    /// Controller for comprehensive image management
    /// </summary>
    [Authorize]
    [ApiController]
    [Route("api/images")]
    public class ImagesController : ControllerBase
    {
        private readonly IMediator _mediator;

        public ImagesController(IMediator mediator) => _mediator = mediator;

        /// <summary>
        /// رفع صورة واحدة
        /// Accept multipart/form-data and return UploadImageResponse
        /// </summary>
        [HttpPost("upload")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> UploadImage([FromForm] UploadImageRequest request)
        {
            using var ms = new MemoryStream();
            await request.File.CopyToAsync(ms);
            var fileBytes = ms.ToArray();

            var command = new UploadImageCommand
            {
                File = new FileUploadRequest
                {
                    FileName = request.File.FileName,
                    FileContent = fileBytes,
                    ContentType = request.File.ContentType
                },
                Name = Path.GetFileNameWithoutExtension(request.File.FileName),
                Extension = Path.GetExtension(request.File.FileName),
                Category = Enum.TryParse<ImageCategory>(request.Category, true, out var cat) ? cat : ImageCategory.Gallery,
                PropertyId = string.IsNullOrEmpty(request.PropertyId) ? (Guid?)null : Guid.Parse(request.PropertyId),
                UnitId = string.IsNullOrEmpty(request.UnitId) ? (Guid?)null : Guid.Parse(request.UnitId),
                Alt = request.Alt,
                IsPrimary = request.IsPrimary,
                Order = request.Order,
                Tags = string.IsNullOrEmpty(request.Tags) ? null : System.Text.Json.JsonSerializer.Deserialize<List<string>>(request.Tags)
            };

            var result = await _mediator.Send(command);
            if (!result.Success)
                return BadRequest(new { success = false, error = result.Message });

            // إعداد URL كامل للواجهة الأمامية
            var image = result.Data!;
            var baseUrl = $"{Request.Scheme}://{Request.Host}";
            if (!image.Url.StartsWith("http", StringComparison.OrdinalIgnoreCase))
            {
                image.Url = baseUrl + (image.Url.StartsWith("/") ? image.Url : "/" + image.Url);
            }
            
            return Ok(new { success = true, taskId = image.Id, image });
        }


        /// <summary>
        /// الحصول على قائمة الصور
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetImages([FromQuery] GetImagesQuery query)
        {
            var result = await _mediator.Send(query);
            if (!result.Success)
                return BadRequest(result.Message);

            var data = result.Data!;
            var baseUrl = $"{Request.Scheme}://{Request.Host}";
            foreach (var img in data.Items)
            {
                // Ensure absolute Url for the main image
                if (!img.Url.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                    img.Url = baseUrl + (img.Url.StartsWith("/") ? img.Url : "/" + img.Url);
                // Only generate thumbnails if the DTO provided a thumbnail path
                if (img.Thumbnails != null && !string.IsNullOrEmpty(img.Thumbnails.Small))
                {
                    // Generate thumbnail URL by appending _thumb before extension
                    var uri = new Uri(img.Url);
                    var path = uri.AbsolutePath; // e.g. "/uploads/.../file.png"
                    var folder = Path.GetDirectoryName(path)?.Replace("\\", "/") ?? string.Empty;
                    var fileName = Path.GetFileNameWithoutExtension(path);
                    var ext = Path.GetExtension(path);
                    var thumbRelative = folder + "/" + fileName + "_thumb" + ext;
                    var thumbUrl = baseUrl + (thumbRelative.StartsWith("/") ? thumbRelative : "/" + thumbRelative);
                    img.Thumbnails.Small = baseUrl + (img.Thumbnails.Small.StartsWith("/") ? img.Thumbnails.Small : "/" + img.Thumbnails.Small);
                    img.Thumbnails.Medium = baseUrl + (img.Thumbnails.Medium.StartsWith("/") ? img.Thumbnails.Medium : "/" + img.Thumbnails.Medium);
                    img.Thumbnails.Large = baseUrl + (img.Thumbnails.Large.StartsWith("/") ? img.Thumbnails.Large : "/" + img.Thumbnails.Large);
                    img.Thumbnails.Hd = baseUrl + (img.Thumbnails.Hd.StartsWith("/") ? img.Thumbnails.Hd : "/" + img.Thumbnails.Hd);
                }
            }
            return Ok(new
            {
                images = data.Items,
                total = data.Total,
                page = data.Page,
                limit = data.Limit,
                totalPages = data.TotalPages
            });
        }

        // /// <summary>
        // /// الحصول على قائمة الصور مؤقت فقط للعرض
        // /// </summary>
        // [HttpGet]
        // public async Task<IActionResult> GetImages([FromQuery] GetImagesQuery query)
        // {
        //     // Temporary stub: return images from Uploads/Review folder
        //     var reviewFolder = System.IO.Path.Combine(System.IO.Directory.GetCurrentDirectory(), "Uploads", "Review");
        //     var files = System.IO.Directory.Exists(reviewFolder) ? System.IO.Directory.GetFiles(reviewFolder, "*.png") : new string[0];
        //     var images = files.Select(filePath =>
        //     {
        //         var fileName = System.IO.Path.GetFileName(filePath);
        //         var url = $"{Request.Scheme}://{Request.Host}/uploads/Review/{fileName}";
        //         var fileInfo = new System.IO.FileInfo(filePath);
        //         return new ImageDto
        //         {
        //             Id = Guid.NewGuid(),
        //             Url = url,
        //             Filename = fileName,
        //             Size = fileInfo.Length
        //         };
        //     }).ToList();
        //     return Ok(new
        //     {
        //         images = images,
        //         total = images.Count,
        //         page = 1,
        //         limit = images.Count,
        //         totalPages = 1
        //     });
        // }

        /// <summary>
        /// الحصول على صورة بواسطة المعرف
        /// </summary>
        [HttpGet("{id}")]
        public async Task<IActionResult> GetImageById([FromRoute] Guid id)
        {
            var result = await _mediator.Send(new GetImageByIdQuery { ImageId = id });
            if (!result.Success)
                return NotFound(result.Message);

            return Ok(result.Data);
        }

        /// <summary>
        /// تحديث بيانات الصورة
        /// </summary>
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateImage([FromRoute] Guid id, [FromBody] UpdateImageCommand command)
        {
            command.ImageId = id;
            var result = await _mediator.Send(command);
            if (!result.Success)
                return BadRequest(result.Message);

            return Ok(result.Data);
        }

        /// <summary>
        /// حذف صورة واحدة
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteImage([FromRoute] Guid id, [FromQuery] bool permanent = false)
        {
            var command = new DeleteImageCommand { ImageId = id, Permanent = permanent };
            var result = await _mediator.Send(command);
            if (!result.Success)
                return BadRequest(result.Message);

            return NoContent();
        }

        /// <summary>
        /// حذف صور متعددة
        /// </summary>
        [HttpPost("bulk-delete")]
        public async Task<IActionResult> DeleteImages([FromBody] DeleteImagesCommand command)
        {
            var result = await _mediator.Send(command);
            if (!result.Success)
                return BadRequest(result.Message);

            return NoContent();
        }

        // Model for front-end reorder payload
        public class ReorderImagesRequest
        {
            public List<string> ImageIds { get; set; } = new List<string>();
            public string? PropertyId { get; set; }
            public string? UnitId { get; set; }
        }

        /// <summary>
        /// إعادة ترتيب الصور
        /// </summary>
        [HttpPost("reorder")]
        public async Task<IActionResult> ReorderImages([FromBody] ReorderImagesRequest request)
        {
            var assignments = request.ImageIds
                .Select((id, idx) => new ImageOrderAssignment
                {
                    ImageId = Guid.Parse(id),
                    DisplayOrder = idx + 1
                })
                .ToList();

            var command = new ReorderImagesCommand { Assignments = assignments };
            var result = await _mediator.Send(command);
            if (!result.Success)
                return BadRequest(result.Message);

            return NoContent();
        }

        /// <summary>
        /// تعيين صورة كرئيسية
        /// </summary>
        [HttpPost("{id}/set-primary")]
        public async Task<IActionResult> SetPrimaryImage([FromRoute] Guid id, [FromBody] SetPrimaryImageCommand command)
        {
            command.ImageId = id;
            var result = await _mediator.Send(command);
            if (!result.Success)
                return BadRequest(result.Message);

            return NoContent();
        }

        /// <summary>
        /// الحصول على إحصائيات الصور
        /// </summary>
        [HttpGet("statistics")]
        public async Task<IActionResult> GetImageStatistics([FromQuery] GetImageStatisticsQuery query)
        {
            var result = await _mediator.Send(query);
            if (!result.Success)
                return BadRequest(result.Message);

            return Ok(result.Data);
        }

        /// <summary>
        /// البحث المتقدم في الصور
        /// </summary>
        [HttpPost("search")]
        public async Task<IActionResult> SearchImages([FromBody] SearchImagesQuery query)
        {
            var result = await _mediator.Send(query);
            if (!result.Success)
                return BadRequest(result.Message);

            var data = result.Data!;
            return Ok(new
            {
                images = data.Items,
                total = data.Total,
                page = data.Page,
                limit = data.Limit,
                totalPages = data.TotalPages
            });
        }

        /// <summary>
        /// تتبع تقدم رفع الصورة
        /// </summary>
        [HttpGet("upload-progress/{taskId}")]
        public async Task<IActionResult> GetUploadProgress([FromRoute] string taskId)
        {
            var result = await _mediator.Send(new GetUploadProgressQuery { TaskId = taskId });
            if (!result.Success)
                return BadRequest(result.Message);

            return Ok(result.Data);
        }

        /// <summary>
        /// الحصول على رابط التنزيل المؤقت
        /// </summary>
        [HttpGet("{id}/download")]
        public async Task<IActionResult> GetDownloadUrl([FromRoute] Guid id, [FromQuery] string size = null)
        {
            var result = await _mediator.Send(new GetDownloadUrlQuery { ImageId = id, Size = size });
            if (!result.Success)
                return BadRequest(result.Message);

            return Ok(new { url = result.Data });
        }

        /// <summary>
        /// تحسين الصورة (ضغط وإنشاء مصغرات)
        /// </summary>
        [HttpPost("{id}/optimize")]
        public async Task<IActionResult> OptimizeImage([FromRoute] Guid id, [FromBody] OptimizeImageCommand command)
        {
            command.ImageId = id;
            var result = await _mediator.Send(command);
            if (!result.Success)
                return BadRequest(result.Message);

            return Ok(result.Data);
        }

        /// <summary>
        /// إنشاء مصغرات إضافية
        /// </summary>
        [HttpPost("{id}/thumbnails")]
        public async Task<IActionResult> GenerateThumbnails([FromRoute] Guid id, [FromBody] GenerateThumbnailsCommand command)
        {
            command.ImageId = id;
            var result = await _mediator.Send(command);
            if (!result.Success)
                return BadRequest(result.Message);

            return Ok(result.Data);
        }

        /// <summary>
        /// نسخ الصورة لكيان أو وحدة أخرى
        /// </summary>
        [HttpPost("{id}/copy")]
        public async Task<IActionResult> CopyImage([FromRoute] Guid id, [FromBody] CopyImageCommand command)
        {
            command.ImageId = id;
            var result = await _mediator.Send(command);
            if (!result.Success)
                return BadRequest(result.Message);

            return Ok(result.Data);
        }
    }
} 