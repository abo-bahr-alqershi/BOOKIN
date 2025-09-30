using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Commands.Notifications;
using YemenBooking.Application.DTOs;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Handlers.Commands.Notifications
{
    /// <summary>
    /// معالج بث الإشعارات للمستخدمين المستهدفين
    /// </summary>
    public class BroadcastNotificationCommandHandler : IRequestHandler<BroadcastNotificationCommand, ResultDto<int>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IUserRepository _userRepository;
        private readonly ILogger<BroadcastNotificationCommandHandler> _logger;

        public BroadcastNotificationCommandHandler(
            IUnitOfWork unitOfWork,
            IUserRepository userRepository,
            ILogger<BroadcastNotificationCommandHandler> logger)
        {
            _unitOfWork = unitOfWork;
            _userRepository = userRepository;
            _logger = logger;
        }

        public async Task<ResultDto<int>> Handle(BroadcastNotificationCommand request, CancellationToken cancellationToken)
        {
            if (string.IsNullOrWhiteSpace(request.Title) || string.IsNullOrWhiteSpace(request.Message) || string.IsNullOrWhiteSpace(request.Type))
                return ResultDto<int>.Failed("النوع والعنوان والمحتوى مطلوبة");

            // Resolve recipients
            var recipients = Enumerable.Empty<User>();
            if (request.TargetAllUsers)
            {
                recipients = await _userRepository.GetAllUsersAsync(cancellationToken);
            }
            else if (request.TargetUserIds != null && request.TargetUserIds.Length > 0)
            {
                var ids = request.TargetUserIds.Distinct().ToArray();
                var queryable = _userRepository.GetQueryable();
                recipients = queryable.Where(u => ids.Contains(u.Id)).ToList();
            }
            else if (request.TargetRoles != null && request.TargetRoles.Length > 0)
            {
                var roleNames = request.TargetRoles.Where(r => !string.IsNullOrWhiteSpace(r)).Select(r => r.Trim()).ToArray();
                var queryable = _userRepository.GetQueryable();
                recipients = queryable.Where(u => u.UserRoles.Any(ur => ur.Role != null && roleNames.Contains(ur.Role.Name))).ToList();
            }
            else
            {
                return ResultDto<int>.Failed("لم يتم تحديد المستلمين");
            }

            var now = DateTime.UtcNow;
            var notifications = recipients.Select(u => new Notification
            {
                RecipientId = u.Id,
                Type = request.Type,
                Title = request.Title,
                Message = request.Message,
                Priority = request.Priority,
                Status = request.ScheduledFor.HasValue ? "PENDING" : "PENDING",
                ScheduledFor = request.ScheduledFor,
                CreatedAt = now
            }).ToList();

            await _unitOfWork.Repository<Notification>().AddRangeAsync(notifications, cancellationToken);
            var inserted = notifications.Count;
            await _unitOfWork.SaveChangesAsync(cancellationToken);

            _logger.LogInformation("تم إنشاء {Count} إشعار للبث", inserted);
            return ResultDto<int>.Succeeded(inserted, $"تم إنشاء {inserted} إشعار");
        }
    }
}

