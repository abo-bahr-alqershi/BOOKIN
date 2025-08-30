using System;
using MediatR;
using YemenBooking.Application.DTOs;

namespace YemenBooking.Application.Commands.Reviews
{
    /// <summary>
    /// أمر لإضافة رد على تقييم
    /// Command to add a response to a review
    /// </summary>
    public class RespondToReviewCommand : IRequest<ResultDto<ReviewResponseDto>>
    {
        public Guid ReviewId { get; set; }
        public string Text { get; set; } = string.Empty;
    }
}

