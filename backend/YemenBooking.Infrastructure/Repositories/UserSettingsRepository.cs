using System;
using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Repositories
{
    public class UserSettingsRepository : BaseRepository<UserSettings>, IUserSettingsRepository
    {
        public UserSettingsRepository(YemenBookingDbContext context) : base(context) { }

        public Task<bool> CreateOrUpdateAsync(UserSettings userSettings, CancellationToken cancellationToken = default)
        {
            throw new NotImplementedException();
        }

        public Task<bool> DeleteAsync(Guid id, CancellationToken cancellationToken = default)
        {
            throw new NotImplementedException();
        }

        public Task<bool> DeleteByUserIdAsync(Guid userId, CancellationToken cancellationToken = default)
        {
            throw new NotImplementedException();
        }

        public Task<UserSettings> CreateAsync(UserSettings userSettings, CancellationToken cancellationToken = default)
        {
            throw new NotImplementedException();
        }

        public Task<bool> ExistsAsync(Guid userId, CancellationToken cancellationToken = default)
        {
            throw new NotImplementedException();
        }

        public Task<UserSettings?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
        {
            return base.GetByIdAsync(id, cancellationToken);
        }

        public Task<UserSettings?> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken = default)
        {
            throw new NotImplementedException();
        }

        public Task<UserSettings> UpdateAsync(UserSettings userSettings, CancellationToken cancellationToken = default)
        {
            throw new NotImplementedException();
        }

        Task<UserSettings> IUserSettingsRepository.CreateOrUpdateAsync(UserSettings userSettings, CancellationToken cancellationToken)
        {
            throw new NotImplementedException();
        }
    }
}
