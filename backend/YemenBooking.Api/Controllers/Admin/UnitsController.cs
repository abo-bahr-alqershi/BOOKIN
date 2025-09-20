using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Commands.Dashboard;
using YemenBooking.Application.Commands.Units;
using YemenBooking.Application.Queries.Units;
using YemenBooking.Application.Commands.CP.Sections;
using System.Linq;

namespace YemenBooking.Api.Controllers.Admin
{
    /// <summary>
    /// متحكم بتحديث توفر الوحدات للمدراء
    /// Controller for bulk updating unit availability by admins
    /// </summary>
    public class UnitsController : BaseAdminController
    {
        public UnitsController(IMediator mediator) : base(mediator) { }

        /// <summary>
        /// جلب جميع الوحدات مع الصفحات والفلاتر
        /// Get all units with pagination and filters
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetAllUnits([FromQuery] SearchUnitsQuery query)
        {
            var result = await _mediator.Send(query);
            var baseUrl = $"{Request.Scheme}://{Request.Host}";
            foreach (var img in result.Items.Select(i => i.Images).SelectMany(i => i))
            {
                // Ensure absolute Url for the image
                if (!img.Url.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                    img.Url = baseUrl + (img.Url.StartsWith("/") ? img.Url : "/" + img.Url);
                {
                    // Ensure absolute Url for the main image
                    if (!img.Url.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                        img.Url = baseUrl + (img.Url.StartsWith("/") ? img.Url : "/" + img.Url);
                }
            }
            return Ok(result);
        }

        /// <summary>
        /// إنشاء وحدة جديدة
        /// Create a new unit
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> CreateUnit([FromBody] CreateUnitCommand command)
        {
            if (!ModelState.IsValid)
            {
                var errors = ModelState
                    .Where(x => x.Value.Errors.Count > 0)
                    .ToDictionary(
                        kvp => kvp.Key,
                        kvp => kvp.Value.Errors.Select(e => e.ErrorMessage).ToArray()
                    );
                
                return BadRequest(new
                {
                    type = "https://tools.ietf.org/html/rfc9110#section-15.5.1",
                    title = "One or more validation errors occurred.",
                    status = 400,
                    errors = errors,
                    traceId = HttpContext.TraceIdentifier
                });
            }

            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// تحديث بيانات وحدة
        /// Update an existing unit
        /// </summary>
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateUnit(Guid id, [FromBody] UpdateUnitCommand command)
        {
            command.UnitId = id;
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// حذف وحدة
        /// Delete a unit
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteUnit(Guid id)
        {
            var command = new DeleteUnitCommand { UnitId = id };
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// إضافة الوحدة إلى أقسام متعددة
        /// Add unit to multiple sections
        /// </summary>
        [HttpPost("{id}/sections")]
        public async Task<IActionResult> AddUnitToSections(Guid id, [FromBody] AddUnitToSectionsCommand command)
        {
            command.UnitId = id;
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// جلب بيانات وحدة بواسطة المعرف
        /// Get unit details by ID
        /// </summary>
        [HttpGet("{id}")]
        public async Task<IActionResult> GetUnitById(Guid id)
        {
            var query = new GetUnitByIdQuery { UnitId = id };
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// الحصول على تفاصيل الوحدة
        /// Get unit details including dynamic fields
        /// </summary>
        [HttpGet("{unitId}/details")]
        public async Task<IActionResult> GetUnitDetails(Guid unitId, [FromQuery] bool includeDynamicFields = true)
        {
            var query = new GetUnitDetailsQuery { UnitId = unitId, IncludeDynamicFields = includeDynamicFields };
            var result = await _mediator.Send(query);
            return Ok(result);
        }

    }
} 