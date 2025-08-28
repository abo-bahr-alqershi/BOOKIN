using System;
using System.Threading;
using System.Threading.Tasks;
using System.Collections.Generic;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Commands.Amenities;
using YemenBooking.Application.DTOs;
using YemenBooking.Core.Interfaces;
using YemenBooking.Application.Interfaces.Services;
using YemenBooking.Core.Entities;

namespace YemenBooking.Application.Handlers.Commands.Amenities
{
    /// <summary>
    /// معالج أمر إنشاء المرفق
    /// </summary>
    public class CreateAmenityCommandHandler : IRequestHandler<CreateAmenityCommand, ResultDto<Guid>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICurrentUserService _currentUserService;
        private readonly IAuditService _auditService;
        private readonly ILogger<CreateAmenityCommandHandler> _logger;

        public CreateAmenityCommandHandler(
            IUnitOfWork unitOfWork,
            ICurrentUserService currentUserService,
            IAuditService auditService,
            ILogger<CreateAmenityCommandHandler> logger)
        {
            _unitOfWork = unitOfWork;
            _currentUserService = currentUserService;
            _auditService = auditService;
            _logger = logger;
        }

        /// <summary>
        /// تنفيذ منطق إنشاء المرفق
        /// </summary>
        public async Task<ResultDto<Guid>> Handle(CreateAmenityCommand request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("بدء معالجة أمر إنشاء المرفق: {Name}", request.Name);

            try
            {
                // التحقق من صحة المدخلات
                var inputValidation = await ValidateInputAsync(request);
                if (!inputValidation.IsSuccess)
                    return inputValidation;

                // التحقق من الصلاحيات
                var authorizationValidation = await ValidateAuthorizationAsync();
                if (!authorizationValidation.IsSuccess)
                    return authorizationValidation;

                // التحقق من قواعد العمل
                var businessValidation = await ValidateBusinessRulesAsync(request, cancellationToken);
                if (!businessValidation.IsSuccess)
                    return businessValidation;

                // التنفيذ: إنشاء المرفق
                var amenity = new Amenity
                {
                    Id = Guid.NewGuid(),
                    Name = request.Name.Trim(),
                    Description = request.Description.Trim(),
                    CreatedAt = DateTime.UtcNow
                };

                await _unitOfWork.Repository<Amenity>().AddAsync(amenity, cancellationToken);
                await _unitOfWork.SaveChangesAsync(cancellationToken);

                // الآثار الجانبية: تسجيل العملية في السجل
                await _auditService.LogActivityAsync(
                    nameof(Amenity),
                    amenity.Id.ToString(),
                    "CREATE",
                    "تم إنشاء المرفق بنجاح",
                    null,
                    amenity,
                    cancellationToken);

                _logger.LogInformation("تم إنشاء المرفق بالمعرف {AmenityId}", amenity.Id);

                return ResultDto<Guid>.Succeeded(amenity.Id, "تم إنشاء المرفق بنجاح");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ في معالجة أمر إنشاء المرفق: {Name}", request.Name);
                return ResultDto<Guid>.Failed("حدث خطأ أثناء إنشاء المرفق");
            }
        }

        /// <summary>
        /// التحقق من صحة المدخلات
        /// </summary>
        private Task<ResultDto<Guid>> ValidateInputAsync(CreateAmenityCommand request)
        {
            var errors = new List<string>();

            if (string.IsNullOrWhiteSpace(request.Name))
                errors.Add("اسم المرفق مطلوب");
            else if (request.Name.Length > 50)
                errors.Add("اسم المرفق لا يجب أن يتجاوز 50 حرفًا");

            if (!string.IsNullOrWhiteSpace(request.Description) && request.Description.Length > 200)
                errors.Add("وصف المرفق لا يجب أن يتجاوز 200 حرفًا");

            if (errors.Count > 0)
                return Task.FromResult(ResultDto<Guid>.Failed(errors, "بيانات المدخلات غير صحيحة"));

            return Task.FromResult(ResultDto<Guid>.Succeeded(Guid.Empty));
        }

        /// <summary>
        /// التحقق من الصلاحيات
        /// </summary>
        private Task<ResultDto<Guid>> ValidateAuthorizationAsync()
        {
            if (_currentUserService.Role != "Admin")
                return Task.FromResult(ResultDto<Guid>.Failed("غير مصرح لك بإنشاء مرافق"));

            return Task.FromResult(ResultDto<Guid>.Succeeded(Guid.Empty));
        }

        /// <summary>
        /// التحقق من قواعد العمل
        /// </summary>
        private async Task<ResultDto<Guid>> ValidateBusinessRulesAsync(CreateAmenityCommand request, CancellationToken cancellationToken)
        {
            var exists = await _unitOfWork.Repository<Amenity>()
                .ExistsAsync(a => a.Name.ToLower() == request.Name.Trim().ToLower(), cancellationToken);

            if (exists)
                return ResultDto<Guid>.Failed("مرفق بنفس الاسم موجود مسبقًا");

            return ResultDto<Guid>.Succeeded(Guid.Empty);
        }
    }
} 