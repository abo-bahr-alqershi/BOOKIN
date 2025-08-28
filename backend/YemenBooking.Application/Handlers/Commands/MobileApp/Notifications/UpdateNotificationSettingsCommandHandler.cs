using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Notifications.Commands;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Interfaces.Services;

namespace YemenBooking.Application.Handlers.Commands.MobileApp.Notifications;

/// <summary>
/// معالج أمر تحديث إعدادات الإشعارات للمستخدم (موبايل)
/// </summary>
public class UpdateNotificationSettingsCommandHandler : IRequestHandler<UpdateNotificationSettingsCommand, UpdateNotificationSettingsResponse>
{
    private readonly IUserRepository _userRepository;
    private readonly ILogger<UpdateNotificationSettingsCommandHandler> _logger;

    public UpdateNotificationSettingsCommandHandler(IUserRepository userRepository, ILogger<UpdateNotificationSettingsCommandHandler> logger)
    {
        _userRepository = userRepository;
        _logger = logger;
    }

    public async Task<UpdateNotificationSettingsResponse> Handle(UpdateNotificationSettingsCommand request, CancellationToken cancellationToken)
    {
        _logger.LogInformation("تحديث إعدادات الإشعارات للمستخدم {UserId}", request.UserId);

        var user = await _userRepository.GetUserByIdAsync(request.UserId, cancellationToken);
        if (user == null)
            return new UpdateNotificationSettingsResponse { Success = false, Message = "المستخدم غير موجود" };

        // نحفظ الإعدادات بصيغة JSON في حقل SettingsJson الخاص بالمستخدم
        var settings = new
        {
            request.BookingNotifications,
            request.PromotionalNotifications,
            request.ReviewResponseNotifications,
            request.EmailNotifications,
            request.SmsNotifications,
            request.PushNotifications
        };
        user.SettingsJson = System.Text.Json.JsonSerializer.Serialize(settings);
        await _userRepository.UpdateUserAsync(user, cancellationToken);

        return new UpdateNotificationSettingsResponse { Success = true, Message = "تم التحديث بنجاح" };
    }
}
