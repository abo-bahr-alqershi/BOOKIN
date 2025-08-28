using MediatR;
using YemenBooking.Application.DTOs;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Queries.CP.Pricing;

public class GetUnitPricingQuery : IRequest<ResultDto<UnitPricingDto>>
{
    public Guid UnitId { get; set; }
    public int Year { get; set; }
    public int Month { get; set; }
}

public class UnitPricingDto
{
    public Guid UnitId { get; set; }
    public string UnitName { get; set; }
    public decimal BasePrice { get; set; }
    public string Currency { get; set; }
    public Dictionary<DateTime, PricingDayDto> Calendar { get; set; }
    public List<PricingRuleDto> Rules { get; set; }
    public PricingStatsDto Stats { get; set; }
}

public class PricingDayDto
{
    public decimal Price { get; set; }
    public string PriceType { get; set; }
    public string ColorCode { get; set; }
    public decimal? PercentageChange { get; set; }
}

public class PricingRuleDto
{
    public Guid Id { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public decimal Price { get; set; }
    public string PriceType { get; set; }
    public string Description { get; set; }
}

public class PricingStatsDto
{
    public decimal AveragePrice { get; set; }
    public decimal MinPrice { get; set; }
    public decimal MaxPrice { get; set; }
    public int DaysWithSpecialPricing { get; set; }
    public decimal PotentialRevenue { get; set; }
}

public class GetUnitPricingQueryHandler : IRequestHandler<GetUnitPricingQuery, ResultDto<UnitPricingDto>>
{
    private readonly IPricingRuleRepository _pricingRepository;
    private readonly IUnitRepository _unitRepository;

    public GetUnitPricingQueryHandler(
        IPricingRuleRepository pricingRepository,
        IUnitRepository unitRepository)
    {
        _pricingRepository = pricingRepository;
        _unitRepository = unitRepository;
    }

    public async Task<ResultDto<UnitPricingDto>> Handle(GetUnitPricingQuery request, CancellationToken cancellationToken)
    {
        var unit = await _unitRepository.GetByIdAsync(request.UnitId);
        if (unit == null)
            return ResultDto<UnitPricingDto>.Failure("الوحدة غير موجودة");

        var calendar = await _pricingRepository.GetPricingCalendarAsync(
            request.UnitId,
            request.Year,
            request.Month);

        var startOfMonth = new DateTime(request.Year, request.Month, 1);
        var endOfMonth = startOfMonth.AddMonths(1).AddDays(-1);

        var rules = await _pricingRepository.GetByDateRangeAsync(
            request.UnitId,
            startOfMonth,
            endOfMonth);

        var basePrice = unit.BasePrice.Amount;

        var dto = new UnitPricingDto
        {
            UnitId = unit.Id,
            UnitName = unit.Name,
            BasePrice = basePrice,
            Currency = unit.BasePrice.Currency,
            Calendar = calendar.ToDictionary(
                kvp => kvp.Key,
                kvp => new PricingDayDto
                {
                    Price = kvp.Value,
                    PriceType = GetPriceType(kvp.Value, basePrice),
                    ColorCode = GetPriceColorCode(kvp.Value, basePrice),
                    PercentageChange = CalculatePercentageChange(kvp.Value, basePrice)
                }),
            Rules = rules.Select(r => new PricingRuleDto
            {
                Id = r.Id,
                StartDate = r.StartDate,
                EndDate = r.EndDate,
                Price = r.PriceAmount,
                PriceType = r.PriceType,
                Description = r.Description
            }).ToList(),
            Stats = CalculatePricingStats(calendar.Values.ToList(), basePrice)
        };

        return ResultDto<UnitPricingDto>.Ok(dto);
    }

    private string GetPriceType(decimal price, decimal basePrice)
    {
        if (price == basePrice) return "Base";
        if (price > basePrice) return "Peak";
        return "Off-Peak";
    }

    private string GetPriceColorCode(decimal price, decimal basePrice)
    {
        var percentage = ((price - basePrice) / basePrice) * 100;
        
        if (percentage > 20) return "#DC2626";      // Dark Red
        if (percentage > 10) return "#F59E0B";      // Orange
        if (percentage > 0) return "#FBBF24";       // Yellow
        if (percentage == 0) return "#10B981";      // Green
        if (percentage > -10) return "#60A5FA";     // Light Blue
        return "#3B82F6";                           // Blue
    }

    private decimal? CalculatePercentageChange(decimal price, decimal basePrice)
    {
        if (basePrice == 0) return null;
        return ((price - basePrice) / basePrice) * 100;
    }

    private PricingStatsDto CalculatePricingStats(List<decimal> prices, decimal basePrice)
    {
        if (!prices.Any())
            return new PricingStatsDto();

        return new PricingStatsDto
        {
            AveragePrice = prices.Average(),
            MinPrice = prices.Min(),
            MaxPrice = prices.Max(),
            DaysWithSpecialPricing = prices.Count(p => p != basePrice),
            PotentialRevenue = prices.Sum()
        };
    }
}