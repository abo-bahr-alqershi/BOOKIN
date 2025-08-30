using System;

namespace YemenBooking.Application.DTOs
{
    /// <summary>
    /// DTO لردود التقييمات
    /// Review response DTO
    /// </summary>
    public class ReviewResponseDto
    {
        public Guid Id { get; set; }
        public Guid ReviewId { get; set; }
        public string Text { get; set; } = string.Empty;
        public DateTime RespondedAt { get; set; }
        public Guid? CreatedBy { get; set; }
        public Guid? UpdatedBy { get; set; }
    }
}

