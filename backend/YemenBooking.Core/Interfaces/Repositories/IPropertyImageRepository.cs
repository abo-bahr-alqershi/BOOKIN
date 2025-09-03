using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Enums;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع صور الكيانات
/// Property Image repository interface
/// </summary>
public interface IPropertyImageRepository : IRepository<PropertyImage>
{
    /// <summary>
    /// إنشاء صورة كيان جديدة
    /// Create a new property image
    /// </summary>
    Task<PropertyImage> CreatePropertyImageAsync(PropertyImage propertyImage, CancellationToken cancellationToken = default);

    /// <summary>
    /// الحصول على الصور لعقار معين
    /// Get images by property id (alias)
    /// </summary>
    Task<IEnumerable<PropertyImage>> GetByPropertyIdAsync(Guid propertyId, CancellationToken cancellationToken = default);

    /// <summary>
    /// الحصول على صورة الكيان بناء على المعرف
    /// Get property image by ID
    /// </summary>
    Task<PropertyImage?> GetPropertyImageByIdAsync(Guid imageId, CancellationToken cancellationToken = default);

    /// <summary>
    /// تحديث صورة الكيان
    /// Update property image
    /// </summary>
    Task<PropertyImage> UpdatePropertyImageAsync(PropertyImage propertyImage, CancellationToken cancellationToken = default);

    /// <summary>
    /// حذف صورة الكيان
    /// Delete property image
    /// </summary>
    Task<bool> DeletePropertyImageAsync(Guid imageId, CancellationToken cancellationToken = default);

    /// <summary>
    /// الحصول على صور الكيان بناء على معرف الكيان
    /// Get property images by property ID
    /// </summary>
    Task<IEnumerable<PropertyImage>> GetImagesByPropertyAsync(Guid propertyId, CancellationToken cancellationToken = default);

    /// <summary>
    /// الحصول على صور الوحدة بناء على معرف الوحدة
    /// Get unit images by unit ID
    /// </summary>
    Task<IEnumerable<PropertyImage>> GetImagesByUnitAsync(Guid unitId, CancellationToken cancellationToken = default);

    /// <summary>
    /// الحصول على الصورة الرئيسية للكيان
    /// Get main image for property
    /// </summary>
    Task<PropertyImage?> GetMainImageByPropertyAsync(Guid propertyId, CancellationToken cancellationToken = default);

    /// <summary>
    /// الحصول على الصورة الرئيسية للوحدة
    /// Get main image for unit
    /// </summary>
    Task<PropertyImage?> GetMainImageByUnitAsync(Guid unitId, CancellationToken cancellationToken = default);

    /// <summary>
    /// تعيين صورة إلى كيان
    /// Assign image to property
    /// </summary>
    Task<bool> AssignImageToPropertyAsync(Guid imageId, Guid propertyId, CancellationToken cancellationToken = default);

    /// <summary>
    /// تعيين صورة إلى وحدة
    /// Assign image to unit
    /// </summary>
    Task<bool> AssignImageToUnitAsync(Guid imageId, Guid unitId, CancellationToken cancellationToken = default);

    /// <summary>
    /// إلغاء تعيين الصورة من الكيان أو الوحدة
    /// Unassign image from property or unit
    /// </summary>
    Task<bool> UnassignImageAsync(Guid imageId, CancellationToken cancellationToken = default);

    /// <summary>
    /// تحديث حالة الصورة الرئيسية
    /// Update main image status
    /// </summary>
    Task<bool> UpdateMainImageStatusAsync(Guid imageId, bool isMain, CancellationToken cancellationToken = default);

    /// <summary>
    /// الحصول على صور بحسب الفئة
    /// Get images by category
    /// </summary>
    Task<IEnumerable<PropertyImage>> GetImagesByCategoryAsync(ImageCategory category, CancellationToken cancellationToken = default);

    /// <summary>
    /// جلب صور بناءً على مساراتها المخزنة
    /// Fetch images by their stored path values
    /// </summary>
    Task<IEnumerable<PropertyImage>> GetImagesByPathAsync(IEnumerable<string> paths, CancellationToken cancellationToken = default);

    /// <summary>
    /// الحصول على صور بحسب المفتاح المؤقت
    /// Get images by temporary key
    /// </summary>
    Task<IEnumerable<PropertyImage>> GetImagesByTempKeyAsync(string tempKey, CancellationToken cancellationToken = default);
}
