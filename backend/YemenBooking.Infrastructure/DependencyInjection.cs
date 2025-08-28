using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using YemenBooking.Application.Interfaces.Services;
using YemenBooking.Infrastructure.Services;

namespace YemenBooking.Infrastructure;

/// <summary>
/// إعداد حقن التبعيات للبنية التحتية
/// Infrastructure dependency injection setup
/// </summary>
public static class DependencyInjection
{
	/// <summary>
	/// إضافة خدمات البنية التحتية
	/// Add infrastructure services
	/// </summary>
	public static IServiceCollection AddInfrastructureServices(this IServiceCollection services, IConfiguration configuration)
	{
		// إضافة خدمات أخرى
		services.AddHttpClient<ICurrencyExchangeService, CurrencyExchangeService>();
		services.AddScoped<IEmailVerificationService, EmailVerificationService>();
		services.AddScoped<IFileUploadService, FileUploadService>();
		services.AddScoped<IPasswordResetService, PasswordResetService>();
		services.AddScoped<IPaymentService, PaymentService>();

		return services;
	}
}