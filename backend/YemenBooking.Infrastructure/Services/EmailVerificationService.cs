using System;
using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Application.Interfaces.Services;

namespace YemenBooking.Infrastructure.Services
{
    /// <summary>
    /// خدمة التحقق من البريد الإلكتروني
    /// Stub implementation of IEmailVerificationService
    /// </summary>
    public class EmailVerificationService : IEmailVerificationService
    {
        public Task<bool> SendVerificationEmailAsync(string email, string verificationCode)
        {
            throw new NotImplementedException("EmailVerificationService.SendVerificationEmailAsync is not implemented yet.");
        }

        public Task<bool> VerifyCodeAsync(string email, string verificationCode)
        {
            throw new NotImplementedException("EmailVerificationService.VerifyCodeAsync is not implemented yet.");
        }

        public string GenerateVerificationCode()
        {
            // Generate a simple 6-digit numeric code
            var rng = new Random();
            return rng.Next(100000, 999999).ToString();
        }

        public Task<bool> IsCodeExpiredAsync(string email, string verificationCode)
        {
            throw new NotImplementedException("EmailVerificationService.IsCodeExpiredAsync is not implemented yet.");
        }

        public Task<bool> DeleteVerificationCodeAsync(string email, string verificationCode)
        {
            throw new NotImplementedException("EmailVerificationService.DeleteVerificationCodeAsync is not implemented yet.");
        }

        public Task<bool> RecordSendAttemptAsync(string email, CancellationToken cancellationToken = default)
        {
            throw new NotImplementedException("EmailVerificationService.RecordSendAttemptAsync is not implemented yet.");
        }
    }
}