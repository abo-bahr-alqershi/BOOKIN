using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Enums;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Repositories;

/// <summary>
/// تنفيذ مستودع صور الكيانات
/// Property image repository implementation
/// </summary>
public class PropertyImageRepository : BaseRepository<PropertyImage>, IPropertyImageRepository
{
    public PropertyImageRepository(YemenBookingDbContext context) : base(context) { }

    public async Task<PropertyImage> CreatePropertyImageAsync(PropertyImage propertyImage, CancellationToken cancellationToken = default)
    {
        await _dbSet.AddAsync(propertyImage, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);
        return propertyImage;
    }

    public async Task<PropertyImage?> GetPropertyImageByIdAsync(Guid imageId, CancellationToken cancellationToken = default)
        => await _dbSet
            .Include(pi => pi.Property)
            .Include(pi => pi.Unit)
            .FirstOrDefaultAsync(pi => pi.Id == imageId && !pi.IsDeleted, cancellationToken);

    public async Task<PropertyImage> UpdatePropertyImageAsync(PropertyImage propertyImage, CancellationToken cancellationToken = default)
    {
        _dbSet.Update(propertyImage);
        await _context.SaveChangesAsync(cancellationToken);
        return propertyImage;
    }

    public async Task<bool> DeletePropertyImageAsync(Guid imageId, CancellationToken cancellationToken = default)
    {
        var image = await GetPropertyImageByIdAsync(imageId, cancellationToken);
        if (image == null) return false;

        // Soft delete
        image.IsDeleted = true;
        image.DeletedAt = DateTime.UtcNow;
        
        _dbSet.Update(image);
        await _context.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<IEnumerable<PropertyImage>> GetByPropertyIdAsync(Guid propertyId, CancellationToken cancellationToken = default)
        => await GetImagesByPropertyAsync(propertyId, cancellationToken);

    public async Task<IEnumerable<PropertyImage>> GetImagesByPropertyAsync(Guid propertyId, CancellationToken cancellationToken = default)
        => await _dbSet
            .Where(pi =>
                (!pi.PropertyId.HasValue && propertyId == Guid.Empty)
                || (pi.PropertyId.HasValue && pi.PropertyId.Value == propertyId)
                && !pi.IsDeleted)
            .OrderBy(pi => pi.DisplayOrder)
            .ThenBy(pi => pi.CreatedAt)
            .ToListAsync(cancellationToken);

    public async Task<IEnumerable<PropertyImage>> GetImagesByUnitAsync(Guid unitId, CancellationToken cancellationToken = default)
        => await _dbSet
            .Where(pi =>
                (!pi.UnitId.HasValue && unitId == Guid.Empty)
                || (pi.UnitId.HasValue && pi.UnitId.Value == unitId)
                && !pi.IsDeleted)
            .OrderBy(pi => pi.DisplayOrder)
            .ThenBy(pi => pi.CreatedAt)
            .ToListAsync(cancellationToken);

    public async Task<PropertyImage?> GetMainImageByPropertyAsync(Guid propertyId, CancellationToken cancellationToken = default)
        => await _dbSet
            .FirstOrDefaultAsync(pi => pi.PropertyId == propertyId && pi.IsMainImage && !pi.IsDeleted, cancellationToken);

    public async Task<PropertyImage?> GetMainImageByUnitAsync(Guid unitId, CancellationToken cancellationToken = default)
        => await _dbSet
            .FirstOrDefaultAsync(pi => pi.UnitId == unitId && pi.IsMainImage && !pi.IsDeleted, cancellationToken);

    public async Task<bool> AssignImageToPropertyAsync(Guid imageId, Guid propertyId, CancellationToken cancellationToken = default)
    {
        var image = await GetByIdAsync(imageId, cancellationToken);
        if (image == null) return false;

        image.PropertyId = propertyId;
        image.UnitId = null; // Remove from unit if assigned
        image.UpdatedAt = DateTime.UtcNow;

        _dbSet.Update(image);
        await _context.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<bool> AssignImageToUnitAsync(Guid imageId, Guid unitId, CancellationToken cancellationToken = default)
    {
        var image = await GetByIdAsync(imageId, cancellationToken);
        if (image == null) return false;

        image.UnitId = unitId;
        image.PropertyId = null; // Remove from property if assigned
        image.UpdatedAt = DateTime.UtcNow;

        _dbSet.Update(image);
        await _context.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<bool> UnassignImageAsync(Guid imageId, CancellationToken cancellationToken = default)
    {
        var image = await GetByIdAsync(imageId, cancellationToken);
        if (image == null) return false;

        image.PropertyId = null;
        image.UnitId = null;
        image.UpdatedAt = DateTime.UtcNow;

        _dbSet.Update(image);
        await _context.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<bool> UpdateMainImageStatusAsync(Guid imageId, bool isMain, CancellationToken cancellationToken = default)
    {
        var image = await GetByIdAsync(imageId, cancellationToken);
        if (image == null) return false;

        // If setting as main, remove main status from other images in the same property/unit
        if (isMain)
        {
            if (image.PropertyId.HasValue)
            {
                var otherMainImages = await _dbSet
                    .Where(pi => pi.PropertyId == image.PropertyId && pi.Id != imageId && pi.IsMainImage)
                    .ToListAsync(cancellationToken);

                foreach (var otherImage in otherMainImages)
                {
                    otherImage.IsMainImage = false;
                    otherImage.UpdatedAt = DateTime.UtcNow;
                }
            }

            if (image.UnitId.HasValue)
            {
                var otherMainImages = await _dbSet
                    .Where(pi => pi.UnitId == image.UnitId && pi.Id != imageId && pi.IsMainImage)
                    .ToListAsync(cancellationToken);

                foreach (var otherImage in otherMainImages)
                {
                    otherImage.IsMainImage = false;
                    otherImage.UpdatedAt = DateTime.UtcNow;
                }
            }
        }

        image.IsMainImage = isMain;
        image.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<IEnumerable<PropertyImage>> GetImagesByCategoryAsync(ImageCategory category, CancellationToken cancellationToken = default)
        => await _dbSet
            .Where(pi => pi.Category == category && !pi.IsDeleted)
            .OrderBy(pi => pi.CreatedAt)
            .ToListAsync(cancellationToken);

    /// <inheritdoc />
    public async Task<IEnumerable<PropertyImage>> GetImagesByPathAsync(IEnumerable<string> paths, CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Where(pi => paths.Contains(pi.Url))
            .ToListAsync(cancellationToken);
    }
}
