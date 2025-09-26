using System;
using System.IO;
using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Commands.CP.UnitInSectionImages;
using YemenBooking.Application.Commands.Images;
using YemenBooking.Application.DTOs;
using YemenBooking.Application.Queries.CP.UnitInSectionImages;
using YemenBooking.Core.Enums;

namespace YemenBooking.Api.Controllers.Admin
{
    /// <summary>
    /// إدارة صور "وحدة في قسم"
    /// </summary>
    public class UnitInSectionImagesController : BaseAdminController
    {
        public UnitInSectionImagesController(IMediator mediator) : base(mediator) { }

        [HttpPost("unit-items/{unitInSectionId}/images/upload")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> Upload(Guid unitInSectionId, IFormFile file, IFormFile? videoThumbnail, [FromForm] string? category, [FromForm] string? alt, [FromForm] bool? isPrimary, [FromForm] int? order, [FromForm] string? tags)
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
            var cmd = new UploadUnitInSectionImageCommand
            {
                UnitInSectionId = unitInSectionId,
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

        [HttpGet("unit-items/{unitInSectionId}/images")]
        public async Task<IActionResult> Get(Guid unitInSectionId, [FromQuery] int? page, [FromQuery] int? limit)
        {
            var q = new GetUnitInSectionImagesQuery { UnitInSectionId = unitInSectionId, Page = page, Limit = limit };
            var result = await _mediator.Send(q);
            if (!result.Success) return BadRequest(result.Message);
            return Ok(result.Data);
        }

        [HttpPut("unit-items/{unitInSectionId}/images/{imageId}")]
        public async Task<IActionResult> Update(Guid unitInSectionId, Guid imageId, [FromBody] YemenBooking.Application.Commands.CP.UnitInSectionImages.UpdateUnitInSectionImageCommand command)
        {
            command.ImageId = imageId;
            var result = await _mediator.Send(command);
            if (!result.Success) return BadRequest(result.Message);
            return Ok(result.Data);
        }

        [HttpDelete("unit-items/{unitInSectionId}/images/{imageId}")]
        public async Task<IActionResult> Delete(Guid unitInSectionId, Guid imageId, [FromQuery] bool permanent = false)
        {
            var result = await _mediator.Send(new YemenBooking.Application.Commands.CP.UnitInSectionImages.DeleteUnitInSectionImageCommand { ImageId = imageId, Permanent = permanent });
            if (!result.Success) return BadRequest(result.Message);
            return NoContent();
        }

        [HttpPost("unit-items/{unitInSectionId}/images/reorder")]
        public async Task<IActionResult> Reorder(Guid unitInSectionId, [FromBody] YemenBooking.Api.Controllers.Images.ImagesController.ReorderImagesRequest request)
        {
            var assignments = request.ImageIds
                .ConvertAll(id => new ImageOrderAssignment { ImageId = Guid.Parse(id), DisplayOrder = request.ImageIds.IndexOf(id) + 1 });
            var result = await _mediator.Send(new YemenBooking.Application.Commands.CP.UnitInSectionImages.ReorderUnitInSectionImagesCommand { Assignments = assignments });
            if (!result.Success) return BadRequest(result.Message);
            return NoContent();
        }

        [HttpPost("unit-items/{unitInSectionId}/images/{imageId}/set-primary")]
        public async Task<IActionResult> SetPrimary(Guid unitInSectionId, Guid imageId)
        {
            var result = await _mediator.Send(new YemenBooking.Application.Commands.CP.UnitInSectionImages.UpdateUnitInSectionImageCommand { ImageId = imageId, IsPrimary = true });
            if (!result.Success) return BadRequest(result.Message);
            return NoContent();
        }
    }
}

