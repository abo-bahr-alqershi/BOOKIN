using MediatR;
using YemenBooking.Application.DTOs;

namespace YemenBooking.Application.Commands.Users
{
    /// <summary>
    /// أمر لإنشاء حساب مستخدم جديد
    /// Command to create a new user account
    /// </summary>
    public class CreateUserCommand : IRequest<ResultDto<Guid>>
    {
        /// <summary>
        /// اسم المستخدم
        /// User name
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// البريد الإلكتروني للمستخدم
        /// User email
        /// </summary>
        public string Email { get; set; }

        /// <summary>
        /// كلمة المرور للمستخدم
        /// User password
        /// </summary>
        public string Password { get; set; }

        /// <summary>
        /// رقم هاتف المستخدم
        /// User phone number
        /// </summary>
        public string Phone { get; set; }

        /// <summary>
        /// صورة الملف الشخصي للمستخدم
        /// User profile image
        /// </summary>
        public string ProfileImage { get; set; }
    }
} 