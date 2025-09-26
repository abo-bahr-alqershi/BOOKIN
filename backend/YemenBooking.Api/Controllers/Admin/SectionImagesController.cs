using System;
using System.IO;
using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Commands.CP.SectionImages;
using YemenBooking.Application.Commands.Images;
using YemenBooking.Application.DTOs;
using YemenBooking.Application.Queries.CP.SectionImages;
using YemenBooking.Core.Enums;

namespace YemenBooking.Api.Controllers.Admin
{
    /// <summary>
    /// إدارة صور الأقسام (مفصولة عن باقي الصور)
    /// </summary>
    public class SectionImagesController : BaseAdminController
    {
        public SectionImagesController(IMediator mediator) : base(mediator) { }

        /// <summary>
        /// رفع صورة لقسم محدد (multipart/form-data)
        /// </summary>
        [HttpPost("{sectionId}/upload")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> Upload(Guid sectionId, IFormFile file, IFormFile? videoThumbnail, [FromForm] string? category, [FromForm] string? alt, [FromForm] bool? isPrimary, [FromForm] int? order, [FromForm] string? tags)
        {
            if (file == null || file.Length == 0) return BadRequest("file is required");

            using var ms = new MemoryStream();
            await file.CopyToAsync(ms);
            FileUploadRequest? poster = null;
            if (videoThumbnail != null)
            {
                using var ps = new MemoryStream();
                await videoThumbnail.CopyToAsync(ps);
                poster = new FileUploadRequest
                {
                    FileName = videoThumbnail.FileName,
                    FileContent = ps.ToArray(),
                    ContentType = videoThumbnail.ContentType
                };
            }

            var cmd = new UploadSectionImageCommand
            {
                SectionId = sectionId,
                File = new FileUploadRequest
                {
                    FileName = file.FileName,
                    FileContent = ms.ToArray(),
                    ContentType = file.ContentType
                },
                VideoThumbnail = poster,
                Name = Path.GetFileNameWithoutExtension(file.FileName),
                Extension = Path.GetExtension(file.FileName),
                Category = Enum.TryParse<ImageCategory>(category, true, out var cat) ? cat : ImageCategory.Gallery,
                Alt = alt,
                IsPrimary = isPrimary,
                Order = order,
                Tags = string.IsNullOrWhiteSpace(tags) ? null : new System.Collections.Generic.List<string>(tags.Split(new[] { ',', ' ' }, StringSplitOptions.RemoveEmptyEntries))
            };

            var result = await _mediator.Send(cmd);
            if (!result.Success) return BadRequest(result.Message);
            return Ok(result);
        }

        /// <summary>
        /// الحصول على صور قسم
        /// </summary>
        [HttpGet("{sectionId}")]
        public async Task<IActionResult> Get(Guid sectionId, [FromQuery] int? page, [FromQuery] int? limit)
        {
            var q = new GetSectionImagesQuery { SectionId = sectionId, Page = page, Limit = limit };
            var result = await _mediator.Send(q);
            if (!result.Success) return BadRequest(result.Message);
            return Ok(result.Data);
        }

        /// <summary>
        /// تحديث بيانات صورة
        /// </summary>
        [HttpPut("{sectionId}/{imageId}")]
        public async Task<IActionResult> Update(Guid sectionId, Guid imageId, [FromBody] YemenBooking.Application.Commands.CP.SectionImages.UpdateSectionImageCommand command)
        {
            command.ImageId = imageId;
            var result = await _mediator.Send(command);
            if (!result.Success) return BadRequest(result.Message);
            return Ok(result.Data);
        }

        /// <summary>
        /// حذف صورة
        /// </summary>
        [HttpDelete("{sectionId}/{imageId}")]
        public async Task<IActionResult> Delete(Guid sectionId, Guid imageId, [FromQuery] bool permanent = false)
        {
            var result = await _mediator.Send(new DeleteImageCommand { ImageId = imageId, Permanent = permanent });
            if (!result.Success) return BadRequest(result.Message);
            return NoContent();
        }

        /// <summary>
        /// إعادة ترتيب الصور
        /// </summary>
        [HttpPost("{sectionId}/reorder")]
        public async Task<IActionResult> Reorder(Guid sectionId, [FromBody] YemenBooking.Api.Controllers.Images.ImagesController.ReorderImagesRequest request)
        {
            var assignments = request.ImageIds
                .ConvertAll(id => new ImageOrderAssignment { ImageId = Guid.Parse(id), DisplayOrder = request.ImageIds.IndexOf(id) + 1 });
            var result = await _mediator.Send(new YemenBooking.Application.Commands.CP.SectionImages.ReorderSectionImagesCommand { Assignments = assignments });
            if (!result.Success) return BadRequest(result.Message);
            return NoContent();
        }

        /// <summary>
        /// تعيين صورة كرئيسية
        /// </summary>
        [HttpPost("{sectionId}/{imageId}/set-primary")]
        public async Task<IActionResult> SetPrimary(Guid sectionId, Guid imageId)
        {
            // استخدام أمر التحديث المتخصص لتفعيل الرئيسية
            var result = await _mediator.Send(new YemenBooking.Application.Commands.CP.SectionImages.UpdateSectionImageCommand { ImageId = imageId, IsPrimary = true });
            if (!result.Success) return BadRequest(result.Message);
            return NoContent();
        }
    }
}

