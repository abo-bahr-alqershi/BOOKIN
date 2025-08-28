using System;
using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Core.Interfaces;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;
using YemenBooking.Infrastructure.Repositories;

namespace YemenBooking.Infrastructure.UnitOfWork
{
    /// <summary>
    /// تنفيذ وحدة العمل للتحكم في المعاملات
    /// </summary>
    public class UnitOfWork : IUnitOfWork
    {
        private readonly YemenBookingDbContext _context;

        public UnitOfWork(YemenBookingDbContext context)
        {
            _context = context;
        }

        public IUserRepository Users => new UserRepository(_context);

        public IRepository<T> Repository<T>() where T : class
            => new BaseRepository<T>(_context);

        public async Task BeginTransactionAsync(CancellationToken cancellationToken = default)
            => await _context.Database.BeginTransactionAsync(cancellationToken);

        public async Task CommitTransactionAsync(CancellationToken cancellationToken = default)
            => await _context.Database.CommitTransactionAsync(cancellationToken);

        public async Task RollbackTransactionAsync(CancellationToken cancellationToken = default)
            => await _context.Database.RollbackTransactionAsync(cancellationToken);

        public async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
            => await _context.SaveChangesAsync(cancellationToken);

        public async Task<T> ExecuteInTransactionAsync<T>(Func<Task<T>> operation, CancellationToken cancellationToken = default)
        {
            await BeginTransactionAsync(cancellationToken);
            try
            {
                var result = await operation();
                await CommitTransactionAsync(cancellationToken);
                return result;
            }
            catch
            {
                await RollbackTransactionAsync(cancellationToken);
                throw;
            }
        }

        public async Task ExecuteInTransactionAsync(Func<Task> operation, CancellationToken cancellationToken = default)
        {
            await BeginTransactionAsync(cancellationToken);
            try
            {
                await operation();
                await CommitTransactionAsync(cancellationToken);
            }
            catch
            {
                await RollbackTransactionAsync(cancellationToken);
                throw;
            }
        }

        public void Dispose()
        {
            _context.Dispose();
        }
    }
}
