using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Commands.MobileApp.Bookings;
using YemenBooking.Core.Interfaces;
using YemenBooking.Application.Interfaces.Services;
using YemenBooking.Core.Enums;
using YemenBooking.Application.DTOs;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Events;
using YemenBooking.Application.Interfaces.Services;

namespace YemenBooking.Application.Handlers.Commands.MobileApp.Booking;

/// <summary>
/// معالج أمر إلغاء الحجز للعميل عبر تطبيق الجوال
/// </summary>
public class CancelBookingCommandHandler : IRequestHandler<CancelBookingCommand, ResultDto<CancelBookingResponse>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IAuditService _auditService;
    private readonly ILogger<CancelBookingCommandHandler> _logger;
    private readonly IBookingRepository _bookingRepository;
    private readonly IUnitRepository _unitRepository;
    private readonly IUnitAvailabilityRepository _availabilityRepository;
    private readonly IMediator _mediator;
    private readonly IIndexingService _indexingService;


    public CancelBookingCommandHandler(
        IUnitOfWork unitOfWork,
        IAuditService auditService,
        ILogger<CancelBookingCommandHandler> logger,
        IBookingRepository bookingRepository,
        IUnitRepository unitRepository,
        IUnitAvailabilityRepository availabilityRepository,
        IMediator mediator,
        IIndexingService indexingService)
    {
        _unitOfWork = unitOfWork;
        _auditService = auditService;
        _logger = logger;
        _bookingRepository = bookingRepository;
        _unitRepository = unitRepository;
        _availabilityRepository = availabilityRepository;
        _mediator = mediator;
        _indexingService = indexingService;
    }

    /// <inheritdoc />
    public async Task<ResultDto<CancelBookingResponse>> Handle(CancelBookingCommand request, CancellationToken cancellationToken)
    {
        _logger.LogInformation("بدء إلغاء الحجز {BookingId} من قبل المستخدم {UserId}", request.BookingId, request.UserId);

        var bookingRepo = _unitOfWork.Repository<Core.Entities.Booking>();
        var booking = await bookingRepo.GetByIdAsync(request.BookingId);
        if (booking == null)
        {
            return new ResultDto<CancelBookingResponse> { Success = false, Message = "الحجز غير موجود" };
        }

        if (booking.UserId != request.UserId)
        {
            return new ResultDto<CancelBookingResponse> { Success = false, Message = "غير مصرح بإلغاء هذا الحجز" };
        }

        booking.Status = BookingStatus.Cancelled;
        booking.CancellationReason = request.CancellationReason;
        booking.UpdatedAt = DateTime.UtcNow;

        await _unitOfWork.SaveChangesAsync(cancellationToken);

        // تحديث مباشر لفهرس الإتاحة
        try
        {
            var bookingToUpdate = await _bookingRepository.GetByIdAsync(request.BookingId, cancellationToken);
            if (bookingToUpdate != null)
            {
                var from = DateTime.UtcNow.Date;
                var to = from.AddMonths(6);
                var periods = await _availabilityRepository.GetByDateRangeAsync(bookingToUpdate.UnitId, from, to);
                var availableRanges = periods
                    .Where(a => a.Status == "Available")
                    .Select(p => (p.StartDate, p.EndDate))
                    .ToList();

                var unit = await _unitRepository.GetByIdAsync(bookingToUpdate.UnitId, cancellationToken);
                var propertyId = unit?.PropertyId ?? Guid.Empty;

                await _indexingService.OnAvailabilityChangedAsync(bookingToUpdate.UnitId, propertyId, availableRanges, cancellationToken);
            }
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "تعذرت الفهرسة المباشرة للإتاحة بعد إلغاء الحجز {BookingId}", request.BookingId);
        }
        await _auditService.LogBusinessOperationAsync(
            "CancelBooking",
            $"تم إلغاء الحجز {booking.Id}",
            booking.Id,
            "Booking",
            request.UserId,
            null,
            cancellationToken);

        return new ResultDto<CancelBookingResponse>
        {
            Success = true,
            Message = "تم إلغاء الحجز بنجاح",
            Data = new CancelBookingResponse
            {
                RefundAmount = 0 // TODO: حساب المبلغ المسترد بناءً على سياسة الإلغاء
            }
        };
    }
}
