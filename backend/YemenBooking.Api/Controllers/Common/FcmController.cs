using System;
using System.Linq;
using System.Threading.Tasks;
using FirebaseAdmin.Messaging;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Authorization; // added for Authorize attribute
using YemenBooking.Application.Interfaces.Services;

namespace YemenBooking.Api.Controllers.Common
{
    /// <summary>
    /// متحكم لتسجيل رموز Firebase للمستخدمين
    /// Controller for registering user FCM tokens and topic subscription
    /// </summary>
    [ApiController]
    [Authorize]
    [Route("api/fcm")]
    public class FcmController : ControllerBase
    {
        private readonly ILogger<FcmController> _logger;
        private readonly ICurrentUserService _currentUser;

        public FcmController(ILogger<FcmController> logger, ICurrentUserService currentUser)
        {
            _logger = logger;
            _currentUser = currentUser;
        }

        /// <summary>
        /// تسجيل رمز FCM لمستخدم والاشتراك بموضوع الرسائل الخاص به
        /// Register FCM token and subscribe to user topic
        /// </summary>
        [HttpPost("register")]
        public async Task<IActionResult> RegisterToken([FromBody] RegisterFcmTokenRequest request)
        {
            try
            {
                var tokenArr = new[] { request.Token };

                // اشتراك موضوع المستخدم
                var userTopic = $"user_{request.UserId}";
                await FirebaseMessaging.DefaultInstance.SubscribeToTopicAsync(tokenArr, userTopic);
                _logger.LogInformation("Subscribed FCM token to topic {Topic} for user {UserId}", userTopic, request.UserId);

                // اشتراك موضوع الجميع
                await FirebaseMessaging.DefaultInstance.SubscribeToTopicAsync(tokenArr, "all");
                _logger.LogInformation("Subscribed FCM token to topic {Topic} for user {UserId}", "all", request.UserId);

                // اشتراك مواضيع الأدوار
                var roleTopics = (_currentUser.UserRoles ?? Enumerable.Empty<string>())
                    .Where(r => !string.IsNullOrWhiteSpace(r))
                    .Select(r => $"role_{r.Trim().ToLowerInvariant()}")
                    .Distinct()
                    .ToArray();

                foreach (var roleTopic in roleTopics)
                {
                    await FirebaseMessaging.DefaultInstance.SubscribeToTopicAsync(tokenArr, roleTopic);
                    _logger.LogInformation("Subscribed FCM token to topic {Topic} for user {UserId}", roleTopic, request.UserId);
                }

                return Ok();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ في تسجيل رمز FCM أو الاشتراك في الموضوع");
                return StatusCode(500, "خطأ في الخادم أثناء تسجيل الرمز");
            }
        }

        /// <summary>
        /// إلغاء تسجيل رمز FCM لمستخدم وإلغاء الاشتراك من موضوع الرسائل الخاص به
        /// Unregister FCM token and unsubscribe from user topic
        /// </summary>
        [HttpPost("unregister")]
        public async Task<IActionResult> UnregisterToken([FromBody] RegisterFcmTokenRequest request)
        {
            try
            {
                var tokenArr = new[] { request.Token };

                // إلغاء الاشتراك من موضوع المستخدم
                var userTopic = $"user_{request.UserId}";
                await FirebaseMessaging.DefaultInstance.UnsubscribeFromTopicAsync(tokenArr, userTopic);
                _logger.LogInformation("Unsubscribed FCM token from topic {Topic} for user {UserId}", userTopic, request.UserId);

                // إلغاء الاشتراك من موضوع الجميع
                await FirebaseMessaging.DefaultInstance.UnsubscribeFromTopicAsync(tokenArr, "all");
                _logger.LogInformation("Unsubscribed FCM token from topic {Topic} for user {UserId}", "all", request.UserId);

                // إلغاء الاشتراك من مواضيع الأدوار
                var roleTopics = (_currentUser.UserRoles ?? Enumerable.Empty<string>())
                    .Where(r => !string.IsNullOrWhiteSpace(r))
                    .Select(r => $"role_{r.Trim().ToLowerInvariant()}")
                    .Distinct()
                    .ToArray();

                foreach (var roleTopic in roleTopics)
                {
                    await FirebaseMessaging.DefaultInstance.UnsubscribeFromTopicAsync(tokenArr, roleTopic);
                    _logger.LogInformation("Unsubscribed FCM token from topic {Topic} for user {UserId}", roleTopic, request.UserId);
                }

                return Ok();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ في إلغاء تسجيل رمز FCM أو إلغاء الاشتراك في الموضوع");
                return StatusCode(500, "خطأ في الخادم أثناء إلغاء تسجيل الرمز");
            }
        }
    }

    /// <summary>
    /// نموذج طلب لتسجيل/إلغاء تسجيل رموز FCM
    /// Request model for registering/unregistering FCM tokens
    /// </summary>
    public class RegisterFcmTokenRequest
    {
        /// <summary>
        /// رمز جهاز FCM
        /// FCM device token
        /// </summary>
        public string Token { get; set; } = string.Empty;

        /// <summary>
        /// معرف المستخدم
        /// User identifier
        /// </summary>
        public Guid UserId { get; set; }

        /// <summary>
        /// نوع الجهاز (web, mobile, etc.)
        /// Device type
        /// </summary>
        public string DeviceType { get; set; } = string.Empty;
    }
} 