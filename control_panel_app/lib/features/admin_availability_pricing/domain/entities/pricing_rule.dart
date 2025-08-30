// lib/features/admin_availability_pricing/domain/entities/pricing_rule.dart

import 'package:equatable/equatable.dart';
import 'pricing.dart';

class PricingRule extends Equatable {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final double price;
  final PriceType priceType;
  final String description;
  final String currency;
  final PricingTier? pricingTier;
  final double? percentageChange;
  final bool isActive;

  const PricingRule({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.price,
    required this.priceType,
    required this.description,
    required this.currency,
    this.pricingTier,
    this.percentageChange,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        startDate,
        endDate,
        price,
        priceType,
        description,
        currency,
        pricingTier,
        percentageChange,
        isActive,
      ];
}

class UnitPricing extends Equatable {
  final String unitId;
  final String unitName;
  final double basePrice;
  final String currency;
  final Map<String, PricingDay> calendar;
  final List<PricingRule> rules;
  final PricingStats stats;

  const UnitPricing({
    required this.unitId,
    required this.unitName,
    required this.basePrice,
    required this.currency,
    required this.calendar,
    required this.rules,
    required this.stats,
  });

  @override
  List<Object> get props => [
        unitId,
        unitName,
        basePrice,
        currency,
        calendar,
        rules,
        stats,
      ];
}

class PricingDay extends Equatable {
  final double price;
  final PriceType priceType;
  final String colorCode;
  final double? percentageChange;

  const PricingDay({
    required this.price,
    required this.priceType,
    required this.colorCode,
    this.percentageChange,
  });

  @override
  List<Object?> get props => [price, priceType, colorCode, percentageChange];
}

class PricingStats extends Equatable {
  final double averagePrice;
  final double minPrice;
  final double maxPrice;
  final int daysWithSpecialPricing;
  final double potentialRevenue;

  const PricingStats({
    required this.averagePrice,
    required this.minPrice,
    required this.maxPrice,
    required this.daysWithSpecialPricing,
    required this.potentialRevenue,
  });

  @override
  List<Object> get props => [
        averagePrice,
        minPrice,
        maxPrice,
        daysWithSpecialPricing,
        potentialRevenue,
      ];
}