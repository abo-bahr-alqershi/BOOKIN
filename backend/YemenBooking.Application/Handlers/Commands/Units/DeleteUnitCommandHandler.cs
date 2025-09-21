using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Commands.Units;
using YemenBooking.Application.DTOs;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Interfaces.Services;
using YemenBooking.Core.Interfaces;
using YemenBooking.Core.Events;
using System.Collections.Generic;

namespace YemenBooking.Application.Handlers.Commands.Units
{
    /// <summary>
    /// معالج أمر حذف الوحدة
    /// </summary>
    public class DeleteUnitCommandHandler : IRequestHandler<DeleteUnitCommand, ResultDto<bool>>
    {
        private readonly IUnitRepository _unitRepository;
        private readonly IPropertyRepository _propertyRepository;
        private readonly ICurrentUserService _currentUserService;
        private readonly IAuditService _auditService;
        private readonly ILogger<DeleteUnitCommandHandler> _logger;
        private readonly IUnitFieldValueRepository _valueRepository;
        private readonly IUnitTypeFieldRepository _fieldRepository;
        private readonly IMediator _mediator;
        private readonly IIndexingService _indexingService;

        public DeleteUnitCommandHandler(
            IUnitRepository unitRepository,
            IPropertyRepository propertyRepository,
            ICurrentUserService currentUserService,
            IAuditService auditService,
            IUnitFieldValueRepository valueRepository,
            IUnitTypeFieldRepository fieldRepository,
            IMediator mediator,
            ILogger<DeleteUnitCommandHandler> logger,
            IIndexingService indexingService)
        {
            _unitRepository = unitRepository;
            _propertyRepository = propertyRepository;
            _currentUserService = currentUserService;
            _auditService = auditService;
            _valueRepository = valueRepository;
            _fieldRepository = fieldRepository;
            _mediator = mediator;
            _logger = logger;
            _indexingService = indexingService;
        }

        public async Task<ResultDto<bool>> Handle(DeleteUnitCommand request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("بدء حذف الوحدة: UnitId={UnitId}", request.UnitId);

            // التحقق من المدخلات
            if (request.UnitId == Guid.Empty)
                return ResultDto<bool>.Failed("معرف الوحدة مطلوب");

            // التحقق من الوجود
            var unit = await _unitRepository.GetUnitByIdAsync(request.UnitId, cancellationToken);
            if (unit == null)
                return ResultDto<bool>.Failed("الوحدة غير موجودة");

            // التحقق من الصلاحيات (مالك الكيان أو مسؤول)
            var property = await _propertyRepository.GetPropertyByIdAsync(unit.PropertyId, cancellationToken);
            if (property == null)
                return ResultDto<bool>.Failed("الكيان المرتبط بالوحدة غير موجود");
            if (_currentUserService.Role != "Admin" && property.OwnerId != _currentUserService.UserId)
                return ResultDto<bool>.Failed("غير مصرح لك بحذف هذه الوحدة");

            // التحقق من عدم وجود حجوزات نشطة أو مستقبلية أو مدفوعات مرتبطة بالحجوزات
            var hasActive = await _unitRepository.CheckActiveBookingsAsync(request.UnitId, cancellationToken);
            if (hasActive)
                return ResultDto<bool>.Failed("لا يمكن حذف الوحدة لوجود حجوزات نشطة أو مستقبلية مرتبطة بها");

            // جلب قيم الحقول الديناميكية قبل الحذف
            var dynamicValues = await _valueRepository.GetValuesByUnitIdAsync(request.UnitId, cancellationToken);

            // تنفيذ الحذف
            bool removed = await _unitRepository.DeleteUnitAsync(request.UnitId, cancellationToken);
            if (!removed)
                return ResultDto<bool>.Failed("فشل حذف الوحدة");

            // فهرسة مباشرة + نشر حدث لضمان الاتساق
            try
            {
                await _indexingService.OnUnitDeletedAsync(request.UnitId, unit.PropertyId, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "تعذر الفهرسة المباشرة بعد حذف الوحدة {UnitId}", request.UnitId);
            }
            // فهرسة مباشرة للحقول الديناميكية
            try
            {
                foreach (var value in dynamicValues)
                {
                    var def = await _fieldRepository.GetByIdAsync(value.UnitTypeFieldId, cancellationToken);
                    if (def == null) continue;
                    await _indexingService.OnDynamicFieldChangedAsync(
                        property.Id,
                        // value.Id,
                        def.FieldName,
                        // def.FieldTypeId,
                        value.FieldValue,
                        // request.UnitId,
                        false,
                        cancellationToken
                    );
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "فشلت الفهرسة المباشرة للحقول الديناميكية بعد حذف الوحدة: {UnitId}", request.UnitId);
            }

            // تسجيل التدقيق
            await _auditService.LogBusinessOperationAsync(
                "DeleteUnit",
                $"تم حذف الوحدة {request.UnitId}",
                request.UnitId,
                "Unit",
                _currentUserService.UserId,
                null,
                cancellationToken);

            _logger.LogInformation("اكتمل حذف الوحدة بنجاح: UnitId={UnitId}", request.UnitId);
            return ResultDto<bool>.Succeeded(true, "تم حذف الوحدة بنجاح");
        }
    }
} 