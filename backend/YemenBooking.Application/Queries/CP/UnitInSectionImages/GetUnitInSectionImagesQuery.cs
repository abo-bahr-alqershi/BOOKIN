using System;
using MediatR;
using YemenBooking.Application.DTOs;

namespace YemenBooking.Application.Queries.CP.UnitInSectionImages
{
    public class GetUnitInSectionImagesQuery : IRequest<ResultDto<PaginatedResultDto<ImageDto>>>
    {
        public Guid UnitInSectionId { get; set; }
        public int? Page { get; set; }
        public int? Limit { get; set; }
    }
}

