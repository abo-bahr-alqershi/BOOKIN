using MediatR;
using YemenBooking.Application.DTOs;

namespace YemenBooking.Application.Commands.Amenities;

/// <summary>
/// أمر لإنشاء مرفق جديد
/// Command to create a new amenity
/// </summary>
public class CreateAmenityCommand : IRequest<ResultDto<Guid>>
{
    /// <summary>
    /// اسم المرفق
    /// Amenity name
    /// </summary>
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// وصف المرفق
    /// Amenity description
    /// </summary>
    public string Description { get; set; } = string.Empty;

    /// <summary>
    /// أيقونة المرفق
    /// Amenity icon
    /// </summary>
    public string Icon { get; set; } = string.Empty;
} 