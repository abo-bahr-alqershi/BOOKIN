using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Commands.Notifications;
using YemenBooking.Application.Queries.Notifications;
using System;

namespace YemenBooking.Api.Controllers.Admin
{
    /// <summary>
    /// متحكم بإشعارات النظام للمدراء
    /// Controller for system notifications by admins
    /// </summary>
    public class NotificationsController : BaseAdminController
    {
        public NotificationsController(IMediator mediator) : base(mediator) { }

        /// <summary>
        /// إنشاء إشعار جديد
        /// Create a new notification
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> CreateNotification([FromBody] CreateNotificationCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// جلب إشعارات النظام
        /// Get system notifications
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetSystemNotifications([FromQuery] GetSystemNotificationsQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// جلب إشعارات المستخدم
        /// Get user notifications
        /// </summary>
        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetUserNotifications(Guid userId, [FromQuery] GetUserNotificationsQuery query)
        {
            query.UserId = userId;
            var result = await _mediator.Send(query);
            return Ok(result);
        }
    }
} 