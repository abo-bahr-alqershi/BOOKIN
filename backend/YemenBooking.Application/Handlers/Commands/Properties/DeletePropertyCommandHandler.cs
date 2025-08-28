using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Commands.Properties;
using YemenBooking.Application.DTOs;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Interfaces.Services;
using YemenBooking.Core.Interfaces;

namespace YemenBooking.Application.Handlers.Commands.Properties
{
    /// <summary>
    /// معالج أمر حذف الكيان
    /// </summary>
    public class DeletePropertyCommandHandler : IRequestHandler<DeletePropertyCommand, ResultDto<bool>>
    {
        private readonly IPropertyRepository _propertyRepository;
        private readonly ICurrentUserService _currentUserService;
        private readonly IAuditService _auditService;
        private readonly IIndexingService _indexingService;
        private readonly ILogger<DeletePropertyCommandHandler> _logger;
        private readonly IMediator _mediator;

        public DeletePropertyCommandHandler(
            IPropertyRepository propertyRepository,
            ICurrentUserService currentUserService,
            IAuditService auditService,
            IIndexingService indexingService,
            ILogger<DeletePropertyCommandHandler> logger,
            IMediator mediator)
        {
            _propertyRepository = propertyRepository;
            _currentUserService = currentUserService;
            _auditService = auditService;
            _indexingService = indexingService;
            _logger = logger;
            _mediator = mediator;
        }

        public async Task<ResultDto<bool>> Handle(DeletePropertyCommand request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("بدء حذف الكيان: PropertyId={PropertyId}", request.PropertyId);

            if (request.PropertyId == Guid.Empty)
                return ResultDto<bool>.Failed("معرف الكيان مطلوب");

            var property = await _propertyRepository.GetPropertyByIdAsync(request.PropertyId, cancellationToken);
            if (property == null)
                return ResultDto<bool>.Failed("الكيان غير موجود");

            // التحقق من الصلاحيات (مالك الكيان أو مسؤول)
            if (_currentUserService.Role != "Admin" && property.OwnerId != _currentUserService.UserId)
                return ResultDto<bool>.Failed("غير مصرح لك بحذف هذا الكيان");

            // التحقق من عدم وجود حجوزات نشطة أو مستقبلية
            bool hasActiveBookings = await _propertyRepository.CheckActiveBookingsAsync(request.PropertyId, cancellationToken);
            if (hasActiveBookings)
                return ResultDto<bool>.Failed("لا يمكن حذف الكيان لوجود حجوزات نشطة أو مستقبلية");

            var success = await _propertyRepository.DeletePropertyAsync(request.PropertyId, cancellationToken);
            if (!success)
                return ResultDto<bool>.Failed("فشل حذف الكيان");

            // تسجيل العملية في سجل التدقيق
            await _auditService.LogBusinessOperationAsync(
                "DeleteProperty",
                $"تم حذف الكيان {request.PropertyId}",
                request.PropertyId,
                "Property",
                _currentUserService.UserId,
                null,
                cancellationToken);

            // استدعاء الفهرسة المباشرة لضمان حذف العقار من الفهرس
            try
            {
                await _indexingService.OnPropertyDeletedAsync(request.PropertyId, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "تعذر الفهرسة المباشرة للعقار {PropertyId}", request.PropertyId);
            }

            

            _logger.LogInformation("اكتمل حذف الكيان: PropertyId={PropertyId}", request.PropertyId);
            return ResultDto<bool>.Succeeded(true, "تم حذف الكيان بنجاح");
        }
    }
} 