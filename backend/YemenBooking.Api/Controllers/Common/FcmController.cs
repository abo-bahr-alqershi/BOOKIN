using System;
using System.Threading.Tasks;
using FirebaseAdmin.Messaging;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Authorization; // added for Authorize attribute

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

        public FcmController(ILogger<FcmController> logger)
        {
            _logger = logger;
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
                var topic = $"user_{request.UserId}";
                // الاشتراك بالموضوع
                await FirebaseMessaging.DefaultInstance.SubscribeToTopicAsync(
                    new[] { request.Token }, topic);

                _logger.LogInformation("Subscribed FCM token to topic {Topic} for user {UserId}", topic, request.UserId);
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
                var topic = $"user_{request.UserId}";
                // إلغاء الاشتراك من الموضوع
                await FirebaseMessaging.DefaultInstance.UnsubscribeFromTopicAsync(
                    new[] { request.Token }, topic);

                _logger.LogInformation("Unsubscribed FCM token from topic {Topic} for user {UserId}", topic, request.UserId);
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