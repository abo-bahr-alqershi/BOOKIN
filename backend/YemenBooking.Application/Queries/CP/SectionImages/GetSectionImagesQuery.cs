using System;
using MediatR;
using YemenBooking.Application.DTOs;

namespace YemenBooking.Application.Queries.CP.SectionImages
{
    /// <summary>
    /// استعلام للحصول على صور قسم محدد (مع ترقيم صفحات اختياري)
    /// </summary>
    public class GetSectionImagesQuery : IRequest<ResultDto<PaginatedResultDto<ImageDto>>>
    {
        public Guid SectionId { get; set; }
        public int? Page { get; set; }
        public int? Limit { get; set; }
    }
}

