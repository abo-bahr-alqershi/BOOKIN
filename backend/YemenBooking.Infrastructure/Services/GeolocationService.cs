using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Interfaces.Services;
using System.Net.Http;
using System.Text.Json;
using System.Globalization;
using Microsoft.Extensions.Options;
using YemenBooking.Infrastructure.Settings;

namespace YemenBooking.Infrastructure.Services
{
    /// <summary>
    /// تنفيذ خدمة تحديد الموقع الجغرافي
    /// Geolocation service implementation
    /// </summary>
    public class GeolocationService : IGeolocationService
    {
        private readonly ILogger<GeolocationService> _logger;
        private readonly HttpClient _httpClient;
        private readonly GeolocationSettings _settings;

        public GeolocationService(ILogger<GeolocationService> logger, HttpClient httpClient, IOptions<GeolocationSettings> options)
        {
            _logger = logger;
            _httpClient = httpClient;
            _settings = options.Value;
        }

        /// <inheritdoc />
        public async Task<(double Latitude, double Longitude)> GetCoordinatesAsync(string address, CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("الحصول على الإحداثيات من العنوان: {Address}", address);
            try
            {
                var url = $"{_settings.GeocodingApiUrl}/search?format=json&q={Uri.EscapeDataString(address)}&limit=1";
                var response = await _httpClient.GetStringAsync(url);
                var elements = JsonSerializer.Deserialize<JsonElement[]>(response);
                if (elements != null && elements.Length > 0)
                {
                    var first = elements[0];
                    var lat = double.Parse(first.GetProperty("lat").GetString()!, CultureInfo.InvariantCulture);
                    var lon = double.Parse(first.GetProperty("lon").GetString()!, CultureInfo.InvariantCulture);
                    return (lat, lon);
                }
                return (0, 0);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ أثناء الحصول على الإحداثيات");
                throw;
            }
        }

        /// <inheritdoc />
        public async Task<string> GetAddressAsync(double latitude, double longitude, CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("الحصول على العنوان من الإحداثيات: {Latitude},{Longitude}", latitude, longitude);
            try
            {
                var url = $"{_settings.GeocodingApiUrl}/reverse?format=json&lat={latitude.ToString(CultureInfo.InvariantCulture)}&lon={longitude.ToString(CultureInfo.InvariantCulture)}";
                var response = await _httpClient.GetStringAsync(url);
                var doc = JsonDocument.Parse(response);
                if (doc.RootElement.TryGetProperty("display_name", out var name))
                    return name.GetString()!;
                return string.Empty;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ أثناء الحصول على العنوان");
                throw;
            }
        }

        /// <inheritdoc />
        public Task<double> CalculateDistanceAsync(double lat1, double lon1, double lat2, double lon2, CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("حساب المسافة بين نقطتين: {Lat1},{Lon1} و {Lat2},{Lon2}", lat1, lon1, lat2, lon2);
            double ToRadians(double deg) => deg * Math.PI / 180.0;
            var R = 6371.0; // Earth radius in km
            var dLat = ToRadians(lat2 - lat1);
            var dLon = ToRadians(lon2 - lon1);
            var a = Math.Pow(Math.Sin(dLat / 2), 2) + Math.Cos(ToRadians(lat1)) * Math.Cos(ToRadians(lat2)) * Math.Pow(Math.Sin(dLon / 2), 2);
            var c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
            var distance = R * c;
            return Task.FromResult(distance);
        }

        /// <inheritdoc />
        public async Task<IEnumerable<object>> FindNearbyPlacesAsync(double latitude, double longitude, double radiusKm, string placeType = "all", CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("العثور على الأماكن القريبة من: {Latitude},{Longitude} بنصف قطر: {RadiusKm} كم (Type: {PlaceType})", latitude, longitude, radiusKm, placeType);
            try
            {
                var radius = (int)(radiusKm * 1000);
                var filter = placeType.ToLower() == "all" ? "" : $"[amenity={placeType.ToLower()}]";
                var query = $"[out:json];node(around:{radius},{latitude.ToString(CultureInfo.InvariantCulture)},{longitude.ToString(CultureInfo.InvariantCulture)}){filter};out;";
                var url = $"https://overpass-api.de/api/interpreter?data={Uri.EscapeDataString(query)}";
                var response = await _httpClient.GetStringAsync(url);
                var doc = JsonDocument.Parse(response);
                var list = new List<object>();
                if (doc.RootElement.TryGetProperty("elements", out var elements))
                {
                    foreach (var el in elements.EnumerateArray())
                    {
                        var id = el.GetProperty("id").GetInt64();
                        var lat = el.GetProperty("lat").GetDouble();
                        var lon = el.GetProperty("lon").GetDouble();
                        var tags = el.TryGetProperty("tags", out var t) ? t : default;
                        list.Add(new { Id = id, Latitude = lat, Longitude = lon, Tags = tags });
                    }
                }
                return list;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ أثناء العثور على الأماكن القريبة");
                return Array.Empty<object>();
            }
        }

        /// <inheritdoc />
        public Task<bool> ValidateCoordinatesAsync(double latitude, double longitude, CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("التحقق من صحة الإحداثيات: {Latitude},{Longitude}", latitude, longitude);
            var isValid = latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180;
            return Task.FromResult(isValid);
        }

        /// <inheritdoc />
        public async Task<string> GetTimezoneAsync(double latitude, double longitude, CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("الحصول على معلومات المنطقة الزمنية للإحداثيات: {Latitude},{Longitude}", latitude, longitude);
            try
            {
                var timestamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
                var url = $"{_settings.TimezoneApiUrl}?key={_settings.ApiKey}&format=json&by=position&lat={latitude.ToString(CultureInfo.InvariantCulture)}&lng={longitude.ToString(CultureInfo.InvariantCulture)}&time={timestamp}";
                var response = await _httpClient.GetStringAsync(url);
                var doc = JsonDocument.Parse(response);
                if (doc.RootElement.TryGetProperty("zoneName", out var zone))
                    return zone.GetString()!;
                if (doc.RootElement.TryGetProperty("zone_name", out var zone2))
                    return zone2.GetString()!;
                return string.Empty;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ أثناء الحصول على معلومات المنطقة الزمنية");
                throw;
            }
        }
    }
} 