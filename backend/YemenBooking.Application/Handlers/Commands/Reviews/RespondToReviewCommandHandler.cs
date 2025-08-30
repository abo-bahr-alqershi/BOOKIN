using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Commands.Reviews;
using YemenBooking.Application.DTOs;
using YemenBooking.Application.Interfaces.Services;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Handlers.Commands.Reviews
{
    /// <summary>
    /// معالج أمر إضافة رد على تقييم
    /// </summary>
    public class RespondToReviewCommandHandler : IRequestHandler<RespondToReviewCommand, ResultDto<ReviewResponseDto>>
    {
        private readonly IReviewRepository _reviewRepository;
        private readonly IReviewResponseRepository _responseRepository;
        private readonly ICurrentUserService _currentUserService;
        private readonly IAuditService _auditService;
        private readonly ILogger<RespondToReviewCommandHandler> _logger;

        public RespondToReviewCommandHandler(
            IReviewRepository reviewRepository,
            IReviewResponseRepository responseRepository,
            ICurrentUserService currentUserService,
            IAuditService auditService,
            ILogger<RespondToReviewCommandHandler> logger)
        {
            _reviewRepository = reviewRepository;
            _responseRepository = responseRepository;
            _currentUserService = currentUserService;
            _auditService = auditService;
            _logger = logger;
        }

        public async Task<ResultDto<ReviewResponseDto>> Handle(RespondToReviewCommand request, CancellationToken cancellationToken)
        {
            if (request.ReviewId == Guid.Empty || string.IsNullOrWhiteSpace(request.Text))
                return ResultDto<ReviewResponseDto>.Failed("ReviewId and Text are required");

            var review = await _reviewRepository.GetReviewByIdAsync(request.ReviewId, cancellationToken);
            if (review == null)
                return ResultDto<ReviewResponseDto>.Failed("التقييم غير موجود");

            // Only Admin or property staff can respond
            var isAuthorized = _currentUserService.Role == "Admin" ||
                               (_currentUserService.PropertyId.HasValue && _currentUserService.PropertyId.Value == review.PropertyId);
            if (!isAuthorized)
                return ResultDto<ReviewResponseDto>.Failed("غير مصرح لك بالرد على هذا التقييم");

            var entity = new ReviewResponse
            {
                Id = Guid.NewGuid(),
                ReviewId = request.ReviewId,
                Text = request.Text.Trim(),
                RespondedAt = DateTime.UtcNow,
                CreatedBy = _currentUserService.UserId
            };

            entity = await _responseRepository.CreateAsync(entity, cancellationToken);

            await _auditService.LogBusinessOperationAsync(
                "CreateReviewResponse",
                $"تم إضافة رد على التقييم {request.ReviewId}",
                entity.Id,
                nameof(ReviewResponse),
                _currentUserService.UserId,
                null,
                cancellationToken);

            var dto = new ReviewResponseDto
            {
                Id = entity.Id,
                ReviewId = entity.ReviewId,
                Text = entity.Text,
                RespondedAt = entity.RespondedAt,
                CreatedBy = entity.CreatedBy
            };

            return ResultDto<ReviewResponseDto>.Ok(dto, "تم إضافة الرد بنجاح");
        }
    }
}

