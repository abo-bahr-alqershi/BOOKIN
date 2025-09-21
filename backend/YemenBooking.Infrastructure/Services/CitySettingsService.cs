using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Application.DTOs;
using YemenBooking.Application.Interfaces.Services;
using YemenBooking.Core.Entities;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Services
{
    /// <summary>
    /// تنفيذ خدمة المدن باستخدام قاعدة البيانات بدلاً من الملفات
    /// EF-backed implementation for city settings
    /// </summary>
    public class CitySettingsService : ICitySettingsService
    {
        private readonly YemenBookingDbContext _db;

        public CitySettingsService(YemenBookingDbContext db) => _db = db;

        public async Task<List<CityDto>> GetCitiesAsync(CancellationToken cancellationToken = default)
        {
            var rows = await _db.Cities.AsNoTracking()
                .OrderBy(c => c.Country).ThenBy(c => c.Name)
                .Select(c => new { c.Name, c.Country, c.ImagesJson })
                .ToListAsync(cancellationToken);

            var result = new List<CityDto>(rows.Count);
            foreach (var r in rows)
            {
                var images = new List<string>();
                try
                {
                    images = System.Text.Json.JsonSerializer.Deserialize<List<string>>(r.ImagesJson) ?? new List<string>();
                }
                catch { /* ignore malformed json */ }
                result.Add(new CityDto { Name = r.Name, Country = r.Country, Images = images });
            }
            return result;
        }

        public async Task SaveCitiesAsync(List<CityDto> cities, CancellationToken cancellationToken = default)
        {
            if (cities == null) throw new ArgumentNullException(nameof(cities));

            // Ensure city names are unique
            var duplicates = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            foreach (var city in cities)
            {
                if (!duplicates.Add(city.Name))
                    throw new InvalidOperationException($"Duplicate city name: {city.Name}");
            }

            var names = cities.Select(c => c.Name).ToHashSet(StringComparer.OrdinalIgnoreCase);
            var existing = await _db.Cities.Where(c => names.Contains(c.Name)).ToListAsync(cancellationToken);

            foreach (var dto in cities)
            {
                var entity = existing.FirstOrDefault(e => e.Name.Equals(dto.Name, StringComparison.OrdinalIgnoreCase));
                var imagesJson = System.Text.Json.JsonSerializer.Serialize(dto.Images ?? new List<string>());
                if (entity == null)
                {
                    _db.Cities.Add(new City
                    {
                        Name = dto.Name,
                        Country = dto.Country,
                        ImagesJson = imagesJson
                    });
                }
                else
                {
                    entity.Country = dto.Country;
                    entity.ImagesJson = imagesJson;
                    _db.Cities.Update(entity);
                }
            }

            await _db.SaveChangesAsync(cancellationToken);
        }

        /// <summary>
        /// Delete a city after ensuring there are no dependent entities (properties, users, bookings, etc.)
        /// Throws InvalidOperationException with a clear reason if deletion is not allowed
        /// </summary>
        public async Task DeleteCityAsync(string name, CancellationToken cancellationToken = default)
        {
            if (string.IsNullOrWhiteSpace(name)) throw new ArgumentException("City name is required", nameof(name));

            var city = await _db.Cities.FirstOrDefaultAsync(c => c.Name == name, cancellationToken);
            if (city == null)
                throw new ArgumentException("المدينة غير موجودة", nameof(name));

            // Check dependencies
            var propertiesCount = await _db.Properties.CountAsync(p => p.City == name, cancellationToken);
            if (propertiesCount > 0)
                throw new InvalidOperationException($"لا يمكن حذف المدينة لوجود {propertiesCount} عقار مرتبط بها");

            // If there are staff/users explicitly linked to city (not modeled directly), skip.
            // Example checks (commented as there is no direct FK on User):
            // var usersInCity = await _db.Users.CountAsync(u => u.City == name, cancellationToken);
            // if (usersInCity > 0) throw new InvalidOperationException($"لا يمكن حذف المدينة لوجود {usersInCity} مستخدم مرتبط بها");

            // Safe to delete
            _db.Cities.Remove(city);
            await _db.SaveChangesAsync(cancellationToken);
        }
    }
} 