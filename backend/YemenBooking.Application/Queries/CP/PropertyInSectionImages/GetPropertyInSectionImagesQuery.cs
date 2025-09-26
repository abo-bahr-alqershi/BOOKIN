using System;
using MediatR;
using YemenBooking.Application.DTOs;

namespace YemenBooking.Application.Queries.CP.PropertyInSectionImages
{
    public class GetPropertyInSectionImagesQuery : IRequest<ResultDto<PaginatedResultDto<ImageDto>>>
    {
        public Guid PropertyInSectionId { get; set; }
        public int? Page { get; set; }
        public int? Limit { get; set; }
    }
}

