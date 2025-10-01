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
                // Determine if we are sending to a topic or a token
                // Treat the following as topics:
                // - Strings starting with "/topics/" or "topic:"
                // - User topics: "user_{id}"
                // - Role topics: "role_{roleName}"
                // - Global topics: "all" and "admins"
                bool isTopic = false;
                string? topic = null;
                string? token = null;

                if (!string.IsNullOrWhiteSpace(topicOrToken))
                {
                    var value = topicOrToken.Trim();
                    if (value.StartsWith("/topics/", StringComparison.OrdinalIgnoreCase))
                    {
                        isTopic = true;
                        topic = value.Substring("/topics/".Length);
                    }
                    else if (value.StartsWith("topic:", StringComparison.OrdinalIgnoreCase))
                    {
                        isTopic = true;
                        topic = value.Substring("topic:".Length);
                    }
                    else if (value.StartsWith("user_", StringComparison.OrdinalIgnoreCase))
                    {
                        isTopic = true;
                        topic = value; // Firebase accepts topic names without the "/topics/" prefix when using Topic property
                    }
                    else if (value.StartsWith("role_", StringComparison.OrdinalIgnoreCase))
                    {
                        isTopic = true;
                        topic = value;
                    }
                    else if (value.Equals("all", StringComparison.OrdinalIgnoreCase) ||
                             value.Equals("admins", StringComparison.OrdinalIgnoreCase))
                    {
                        isTopic = true;
                        topic = value.ToLowerInvariant();
                    }
                    else
                    {
                        token = value;
                    }
                }

                var androidConfig = new AndroidConfig
                {
                    Priority = Priority.High,
                    Notification = new AndroidNotification
                    {
                        // Must match app's AndroidNotificationDetails channel id
                        ChannelId = "yemen_booking_channel",
                    },
                };

                var apnsConfig = new ApnsConfig
                {
                    Aps = new Aps
                    {
                        ContentAvailable = false,
                        Alert = new ApsAlert
                        {
                            Title = title,
                            Body = body
                        },
                        Sound = "default",
                    },
                    Headers = new Dictionary<string, string>
                    {
                        // High priority for iOS
                        { "apns-priority", "10" }
                    }
                };

                var message = new Message
                {
                    Notification = new Notification
                    {
                        Title = title,
                        Body = body
                    },
                    Data = data,
                    Android = androidConfig,
                    Apns = apnsConfig,
                };

                if (isTopic && !string.IsNullOrWhiteSpace(topic))
                {
                    message.Topic = topic; // send to topic
                }
                else if (!string.IsNullOrWhiteSpace(token))
                {
                    message.Token = token; // send to device token
                }
                else
                {
                    _logger.LogWarning("لم يتم توفير Topic أو Token صالح لإشعار Firebase");
                    return false;
                }

                var response = await FirebaseMessaging.DefaultInstance.SendAsync(message, cancellationToken);
                _logger.LogInformation("تم إرسال إشعار Firebase بنجاح: {Response}", response);
                return true;
            }
            catch (FirebaseMessagingException fcmEx)
            {
                _logger.LogError(fcmEx, "FirebaseMessagingException أثناء إرسال الإشعار. Code: {Code}, HttpResponse: {HttpResponse}", fcmEx.ErrorCode, fcmEx.HttpResponse);
                return false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ في إرسال إشعار Firebase");
                return false;
            }
        }
    }
} 