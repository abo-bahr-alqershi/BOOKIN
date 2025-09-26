using System;
using System.IO;
using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Commands.CP.PropertyInSectionImages;
using YemenBooking.Application.Commands.Images;
using YemenBooking.Application.DTOs;
using YemenBooking.Application.Queries.CP.PropertyInSectionImages;
using YemenBooking.Core.Enums;

namespace YemenBooking.Api.Controllers.Admin
{
    /// <summary>
    /// إدارة صور "عقار في قسم"
    /// </summary>
    public class PropertyInSectionImagesController : BaseAdminController
    {
        public PropertyInSectionImagesController(IMediator mediator) : base(mediator) { }

        [HttpPost("section-items/{propertyInSectionId}/images/upload")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> Upload(Guid propertyInSectionId, IFormFile file, IFormFile? videoThumbnail, [FromForm] string? category, [FromForm] string? alt, [FromForm] bool? isPrimary, [FromForm] int? order, [FromForm] string? tags)
        {
            if (file == null || file.Length == 0) return BadRequest("file is required");
            using var ms = new MemoryStream();
            await file.CopyToAsync(ms);
            FileUploadRequest? poster = null;
            if (videoThumbnail != null)
            {
                using var ps = new MemoryStream();
                await videoThumbnail.CopyToAsync(ps);
                poster = new FileUploadRequest { FileName = videoThumbnail.FileName, FileContent = ps.ToArray(), ContentType = videoThumbnail.ContentType };
            }
            var cmd = new UploadPropertyInSectionImageCommand
            {
                PropertyInSectionId = propertyInSectionId,
                File = new FileUploadRequest { FileName = file.FileName, FileContent = ms.ToArray(), ContentType = file.ContentType },
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

        [HttpGet("section-items/{propertyInSectionId}/images")]
        public async Task<IActionResult> Get(Guid propertyInSectionId, [FromQuery] int? page, [FromQuery] int? limit)
        {
            var q = new GetPropertyInSectionImagesQuery { PropertyInSectionId = propertyInSectionId, Page = page, Limit = limit };
            var result = await _mediator.Send(q);
            if (!result.Success) return BadRequest(result.Message);
            return Ok(result.Data);
        }

        [HttpPut("section-items/{propertyInSectionId}/images/{imageId}")]
        public async Task<IActionResult> Update(Guid propertyInSectionId, Guid imageId, [FromBody] YemenBooking.Application.Commands.CP.PropertyInSectionImages.UpdatePropertyInSectionImageCommand command)
        {
            command.ImageId = imageId;
            var result = await _mediator.Send(command);
            if (!result.Success) return BadRequest(result.Message);
            return Ok(result.Data);
        }

        [HttpDelete("section-items/{propertyInSectionId}/images/{imageId}")]
        public async Task<IActionResult> Delete(Guid propertyInSectionId, Guid imageId, [FromQuery] bool permanent = false)
        {
            var result = await _mediator.Send(new YemenBooking.Application.Commands.CP.PropertyInSectionImages.DeletePropertyInSectionImageCommand { ImageId = imageId, Permanent = permanent });
            if (!result.Success) return BadRequest(result.Message);
            return NoContent();
        }

        [HttpPost("section-items/{propertyInSectionId}/images/reorder")]
        public async Task<IActionResult> Reorder(Guid propertyInSectionId, [FromBody] YemenBooking.Api.Controllers.Images.ImagesController.ReorderImagesRequest request)
        {
            var assignments = request.ImageIds
                .ConvertAll(id => new ImageOrderAssignment { ImageId = Guid.Parse(id), DisplayOrder = request.ImageIds.IndexOf(id) + 1 });
            var result = await _mediator.Send(new ReorderImagesCommand { Assignments = assignments });
            if (!result.Success) return BadRequest(result.Message);
            return NoContent();
        }

        [HttpPost("section-items/{propertyInSectionId}/images/{imageId}/set-primary")]
        public async Task<IActionResult> SetPrimary(Guid propertyInSectionId, Guid imageId)
        {
            var result = await _mediator.Send(new SetPrimaryImageCommand { ImageId = imageId });
            if (!result.Success) return BadRequest(result.Message);
            return NoContent();
        }
    }
}

