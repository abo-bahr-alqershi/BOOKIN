using System;
using System.Collections.Generic;
using System.Linq;
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
    /// تنفيذ خدمة العملات باستخدام قاعدة البيانات بدلاً من الملفات
    /// EF-backed implementation for currency settings
    /// </summary>
    public class CurrencySettingsService : ICurrencySettingsService
    {
        private readonly YemenBookingDbContext _db;

        public CurrencySettingsService(YemenBookingDbContext db) => _db = db;

        public async Task<List<CurrencyDto>> GetCurrenciesAsync(CancellationToken cancellationToken = default)
        {
            var list = await _db.Currencies
                .AsNoTracking()
                .OrderByDescending(c => c.IsDefault)
                .ThenBy(c => c.Code)
                .Select(c => new CurrencyDto
                {
                    Code = c.Code,
                    ArabicCode = c.ArabicCode,
                    Name = c.Name,
                    ArabicName = c.ArabicName,
                    IsDefault = c.IsDefault,
                    ExchangeRate = c.ExchangeRate,
                    LastUpdated = c.LastUpdated
                })
                .ToListAsync(cancellationToken);
            return list;
        }

        public async Task SaveCurrenciesAsync(List<CurrencyDto> currencies, CancellationToken cancellationToken = default)
        {
            if (currencies == null) throw new ArgumentNullException(nameof(currencies));

            if (currencies.Count(c => c.IsDefault) != 1)
                throw new InvalidOperationException("Exactly one default currency must be specified.");
            var existing = await _db.Currencies.AsNoTracking().ToListAsync(cancellationToken);
                var existingDefault = existing.FirstOrDefault(c => c.IsDefault);
                var incomingDefault = currencies.First(c => c.IsDefault);
                if (existingDefault != null && existingDefault.Code != incomingDefault.Code)
                    throw new InvalidOperationException("Default currency cannot be changed once initialized.");

            // Upsert currencies
            var codes = currencies.Select(c => c.Code.ToUpperInvariant()).ToHashSet();
            var entities = await _db.Currencies.Where(c => codes.Contains(c.Code)).ToListAsync(cancellationToken);

            foreach (var dto in currencies)
            {
                var code = dto.Code.ToUpperInvariant();
                var entity = entities.FirstOrDefault(e => e.Code == code);
                if (dto.IsDefault)
                    dto.ExchangeRate = null; // default has null exchange rate

                if (entity == null)
                {
                    entity = new Currency
                    {
                        Code = code,
                        ArabicCode = dto.ArabicCode,
                        Name = dto.Name,
                        ArabicName = dto.ArabicName,
                        IsDefault = dto.IsDefault,
                        ExchangeRate = dto.ExchangeRate,
                        LastUpdated = dto.IsDefault ? null : DateTime.UtcNow
                    };
                    _db.Currencies.Add(entity);
                }
                else
                {
                    var exchangeChanged = entity.ExchangeRate != dto.ExchangeRate;
                    entity.ArabicCode = dto.ArabicCode;
                    entity.Name = dto.Name;
                    entity.ArabicName = dto.ArabicName;
                    entity.IsDefault = dto.IsDefault;
                    entity.ExchangeRate = dto.ExchangeRate;
                    if (!dto.IsDefault && exchangeChanged)
                        entity.LastUpdated = DateTime.UtcNow;
                    _db.Currencies.Update(entity);
            }
            }

            // Ensure only one default
            var defaults = await _db.Currencies.Where(c => c.IsDefault).ToListAsync(cancellationToken);
            if (defaults.Count > 1)
                throw new InvalidOperationException("Only one default currency is allowed.");

            await _db.SaveChangesAsync(cancellationToken);
        }
    }
} 