using System;

namespace YemenBooking.Application.DTOs.Users
{
    /// <summary>
    /// DTO لبيانات المستخدم
    /// DTO for user data
    /// </summary>
    public class UserDto
    {
        /// <summary>
        /// المعرف الفريد للمستخدم
        /// User unique identifier
        /// </summary>
        public Guid Id { get; set; }

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
        /// رقم هاتف المستخدم
        /// User phone number
        /// </summary>
        public string Phone { get; set; }

        /// <summary>
        /// صورة الملف الشخصي للمستخدم
        /// User profile image
        /// </summary>
        public string ProfileImage { get; set; }

        /// <summary>
        /// تاريخ إنشاء حساب المستخدم
        /// User account creation date
        /// </summary>
        public DateTime CreatedAt { get; set; }

        /// <summary>
        /// حالة تفعيل الحساب
        /// Account activation status
        /// </summary>
        public bool IsActive { get; set; }

        /// <summary>
        /// إعدادات المستخدم بصيغة JSON
        /// User settings JSON
        /// </summary>
        public string SettingsJson { get; set; } = "{}";

        /// <summary>
        /// قائمة المفضلة للمستخدم بصيغة JSON
        /// User favorites JSON
        /// </summary>
        public string FavoritesJson { get; set; } = "[]";
    }
} 