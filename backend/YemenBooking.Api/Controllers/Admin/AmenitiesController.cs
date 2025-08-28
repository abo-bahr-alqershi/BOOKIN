using MediatR;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Commands.Amenities;
using YemenBooking.Application.Queries.Amenities;

namespace YemenBooking.Api.Controllers.Admin
{
    /// <summary>
    /// متحكم بإدارة المرافق للمدراء
    /// Controller for managing amenities by admins
    /// </summary>
    public class AmenitiesController : BaseAdminController
    {
        public AmenitiesController(IMediator mediator) : base(mediator) { }

        /// <summary>
        /// إنشاء مرفق جديد
        /// Create a new amenity
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> CreateAmenity([FromBody] CreateAmenityCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// تحديث مرفق موجود
        /// Update an existing amenity
        /// </summary>
        [HttpPut("{amenityId}")]
        public async Task<IActionResult> UpdateAmenity(Guid amenityId, [FromBody] UpdateAmenityCommand command)
        {
            command.AmenityId = amenityId;
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// حذف مرفق
        /// Delete an amenity
        /// </summary>
        [HttpDelete("{amenityId}")]
        public async Task<IActionResult> DeleteAmenity(Guid amenityId)
        {
            var command = new DeleteAmenityCommand { AmenityId = amenityId };
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// جلب جميع المرافق مع الصفحات
        /// Get all amenities with pagination
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetAllAmenities([FromQuery] GetAllAmenitiesQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// إسناد مرفق لكيان
        /// Assign an amenity to a property
        /// </summary>
        [HttpPost("{amenityId}/assign/property/{propertyId}")]
        public async Task<IActionResult> AssignAmenityToProperty(Guid amenityId, Guid propertyId, [FromBody] AssignAmenityToPropertyCommand command)
        {
            command.AmenityId = amenityId;
            command.PropertyId = propertyId;
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// تخصيص مرفق لنوع الكيان
        /// Assign an amenity to a property type
        /// </summary>
        [HttpPost("{amenityId}/assign/property-type/{propertyTypeId}")]
        public async Task<IActionResult> AssignAmenityToPropertyType(Guid amenityId, Guid propertyTypeId, [FromBody] AssignAmenityToPropertyTypeCommand command)
        {
            command.AmenityId = amenityId;
            command.PropertyTypeId = propertyTypeId;
            var result = await _mediator.Send(command);
            return Ok(result);
        }
    }
} 