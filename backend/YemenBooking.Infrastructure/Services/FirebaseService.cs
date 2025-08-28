using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using FirebaseAdmin.Messaging;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Interfaces.Services;

namespace YemenBooking.Infrastructure.Services
{
    /// <summary>
    /// تنفيذ خدمة Firebase للإشعارات باستخدام FirebaseAdmin SDK
    /// Firebase notification service implementation using Admin SDK
    /// </summary>
    public class FirebaseService : IFirebaseService
    {
        private readonly ILogger<FirebaseService> _logger;

        public FirebaseService(ILogger<FirebaseService> logger)
        {
            _logger = logger;
        }

        public async Task<bool> SendNotificationAsync(string topicOrToken, string title, string body, IReadOnlyDictionary<string, string>? data = null, CancellationToken cancellationToken = default)
        {
            try
            {
                var message = new Message
                {
                    Token = topicOrToken,
                    Notification = new Notification
                    {
                        Title = title,
                        Body = body
                    },
                    Data = data
                };

                var response = await FirebaseMessaging.DefaultInstance.SendAsync(message, cancellationToken);
                _logger.LogInformation("تم إرسال إشعار Firebase بنجاح: {Response}", response);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ في إرسال إشعار Firebase");
                return false;
            }
        }
    }
} 