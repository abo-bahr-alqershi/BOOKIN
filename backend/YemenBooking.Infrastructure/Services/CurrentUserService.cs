using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using Microsoft.AspNetCore.Http;
using YemenBooking.Core.Entities;
using YemenBooking.Application.Interfaces.Services;
using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Infrastructure.Services
{
    /// <summary>
    /// خدمة المستخدم الحالي التي تستخرج معلومات المستخدم من HttpContext
    /// Implementation of ICurrentUserService that extracts user information from HttpContext
    /// </summary>
    public class CurrentUserService : ICurrentUserService
    {
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly IUserRepository _userRepository;

        /// <summary>
        /// مُنشئ خدمة المستخدم الحالي مع حقن HttpContextAccessor و IUserRepository
        /// Constructor for CurrentUserService with injected HttpContextAccessor and IUserRepository
        /// </summary>
        public CurrentUserService(IHttpContextAccessor httpContextAccessor, IUserRepository userRepository)
        {
            _httpContextAccessor = httpContextAccessor;
            _userRepository = userRepository;
        }

        private ClaimsPrincipal? User => _httpContextAccessor.HttpContext?.User;

        /// <summary>
        /// معرّف المستخدم الحالي
        /// Identifier of the current user
        /// </summary>
        public Guid UserId
        {
            get
            {
                var idClaim = User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                return Guid.TryParse(idClaim, out var id) ? id : Guid.Empty;
            }
        }

        /// <summary>
        /// اسم المستخدم الحالي
        /// Username of the current user
        /// </summary>
        public string Username => User?.Identity?.Name ?? string.Empty;

        /// <summary>
        /// الدور الخاص بالمستخدم الحالي
        /// Role of the current user
        /// </summary>
        public string Role => User?.FindFirst(ClaimTypes.Role)?.Value ?? string.Empty;

        /// <summary>
        /// نوع الحساب الموحّد (Admin, Owner, Staff, Customer)
        /// </summary>
        public string AccountRole => User?.FindFirst("accountRole")?.Value ?? string.Empty;

        /// <summary>
        /// هل المستخدم الحالي مدير
        /// Is the current user an admin
        /// </summary>
        public bool IsAdmin => UserRoles.Contains("Admin");

        /// <summary>
        /// قائمة الأذونات الخاصة بالمستخدم الحالي
        /// Permissions of the current user
        /// </summary>
        public IEnumerable<string> Permissions =>
            User?.FindAll("permission")?.Select(c => c.Value) ?? Enumerable.Empty<string>();

        /// <summary>
        /// قائمة الأدوار الخاصة بالمستخدم الحالي
        /// User roles of the current user
        /// </summary>
        public IEnumerable<string> UserRoles =>
            User?.FindAll(ClaimTypes.Role)?.Select(c => c.Value) ?? Enumerable.Empty<string>();

        /// <summary>
        /// معرف التتبّع لربط الطلبات
        /// Correlation identifier for tracing
        /// </summary>
        public string CorrelationId => User?.FindFirst("correlationId")?.Value ?? Guid.NewGuid().ToString();

        /// <summary>
        /// معرف الكيان المرتبط بالمستخدم (إن وجد)
        /// Property ID related to the user (if owner or staff)
        /// </summary>
        public Guid? PropertyId
        {
            get
            {
                var propIdClaim = User?.FindFirst("propertyId")?.Value;
                return Guid.TryParse(propIdClaim, out var pid) ? pid : (Guid?)null;
            }
        }

        /// <summary>
        /// اسم الكيان المرتبط بالمستخدم (إن وجد)
        /// Property name related to the user (if owner or staff)
        /// </summary>
        public string? PropertyName => User?.FindFirst("propertyName")?.Value;

        /// <summary>
        /// عملة العقار المرتبط بالمستخدم (إن وجدت)
        /// </summary>
        public string? PropertyCurrency => User?.FindFirst("propertyCurrency")?.Value;

        /// <summary>
        /// معرف موظف الكيان المرتبط بالمستخدم (إن وجد)
        /// Property ID related to the user (if owner or staff)
        /// </summary>
        public Guid? StaffId
        {
            get
            {
                var staffIdClaim = User?.FindFirst("staffId")?.Value;
                return Guid.TryParse(staffIdClaim, out var sid) ? sid : (Guid?)null;
            }
        }

        /// <summary>
        /// التحقق مما إذا كان المستخدم الحالي موظفاً في الكيان المحدد
        /// Checks if the current user is staff of the specified property
        /// </summary>
        public bool IsStaffInProperty(Guid propertyId)
        {
            var userPropertyId = PropertyId;
            return userPropertyId.HasValue && userPropertyId.Value == propertyId &&
                   (UserRoles.Contains("Staff") || UserRoles.Contains("PropertyManager"));
        }

        /// <summary>
        /// جلب بيانات المستخدم الحالي من قاعدة البيانات بناءً على المعرف من HttpContext
        /// </summary>
        public async Task<User> GetCurrentUserAsync(CancellationToken cancellationToken = default)
        {
            // التحقق من وجود هوية مصدقة
            if (User == null || UserId == Guid.Empty)
                throw new UnauthorizedAccessException("المستخدم غير مصدق عليه");

            // جلب الكيان من قاعدة البيانات
            var user = await _userRepository.GetUserByIdAsync(UserId, cancellationToken);
            if (user == null)
                throw new UnauthorizedAccessException($"المستخدم بالمعرف {UserId} غير موجود");

            return user;
        }

        public Task<bool> IsInRoleAsync(string role)
        {
            var hasRole = UserRoles != null && UserRoles.Contains(role);
            return Task.FromResult(hasRole);
        }
    }
} 