using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Application.DTOs;

namespace YemenBooking.Application.Interfaces.Services
{
    /// <summary>
    /// Service for managing currency settings (read and save)
    /// </summary>
    public interface ICurrencySettingsService
    {
        /// <summary>
        /// Get the list of currencies
        /// </summary>
        Task<List<CurrencyDto>> GetCurrenciesAsync(CancellationToken cancellationToken = default);

        /// <summary>
        /// Save or update the list of currencies
        /// </summary>
        Task SaveCurrenciesAsync(List<CurrencyDto> currencies, CancellationToken cancellationToken = default);
    }
} 