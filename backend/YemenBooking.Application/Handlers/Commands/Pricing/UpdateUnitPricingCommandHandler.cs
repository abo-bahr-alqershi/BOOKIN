using MediatR;
using YemenBooking.Application.Commands.CP.Pricing;
using YemenBooking.Application.DTOs;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Handlers.PricingRules.Commands;

public class UpdateUnitPricingCommandHandler : IRequestHandler<UpdateUnitPricingCommand, ResultDto>
{
    private readonly IPricingRuleRepository _repository;

    public UpdateUnitPricingCommandHandler(IPricingRuleRepository repository)
    {
        _repository = repository;
    }

    public async Task<ResultDto> Handle(UpdateUnitPricingCommand request, CancellationToken cancellationToken)
    {
        try
        {
            if (request.EndDate <= request.StartDate)
                return ResultDto.Failure("تاريخ النهاية يجب أن يكون بعد تاريخ البداية");

            if (request.OverwriteExisting)
            {
                await _repository.DeleteRangeAsync(request.UnitId, request.StartDate, request.EndDate);
            }

            var rule = new PricingRule
            {
                Id = Guid.NewGuid(),
                UnitId = request.UnitId,
                PriceType = request.PriceType,
                StartDate = request.StartDate,
                EndDate = request.EndDate,
                StartTime = request.StartTime,
                EndTime = request.EndTime,
                PriceAmount = request.Price,
                Currency = request.Currency,
                PricingTier = request.PricingTier,
                PercentageChange = request.PercentageChange,
                MinPrice = request.MinPrice,
                MaxPrice = request.MaxPrice,
                Description = request.Description,
                CreatedAt = DateTime.UtcNow
            };

            await _repository.AddAsync(rule);
            await _repository.SaveChangesAsync(cancellationToken);
            return ResultDto.Ok();
        }
        catch (Exception ex)
        {
            return ResultDto.Failure($"حدث خطأ: {ex.Message}");
        }
    }
}