// lib/features/admin_availability_pricing/data/models/pricing_rule_model.dart

import '../../domain/entities/pricing_rule.dart';
import '../../domain/entities/pricing.dart';

class PricingRuleModel extends PricingRule {
  const PricingRuleModel({
    required String id,
    required DateTime startDate,
    required DateTime endDate,
    required double price,
    required PriceType priceType,
    required String description,
    required String currency,
    PricingTier? pricingTier,
    double? percentageChange,
    bool isActive = true,
  }) : super(
          id: id,
          startDate: startDate,
          endDate: endDate,
          price: price,
          priceType: priceType,
          description: description,
          currency: currency,
          pricingTier: pricingTier,
          percentageChange: percentageChange,
          isActive: isActive,
        );

  factory PricingRuleModel.fromJson(Map<String, dynamic> json) {
    return PricingRuleModel(
      id: json['id'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      price: (json['price'] as num).toDouble(),
      priceType: _parsePriceType(json['priceType'] as String),
      description: json['description'] as String,
      currency: json['currency'] as String,
      pricingTier: json['pricingTier'] != null
          ? _parsePricingTier(json['pricingTier'] as String)
          : null,
      percentageChange: json['percentageChange'] != null
          ? (json['percentageChange'] as num).toDouble()
          : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'price': price,
      'priceType': _priceTypeToString(priceType),
      'description': description,
      'currency': currency,
      if (pricingTier != null) 'pricingTier': _pricingTierToString(pricingTier!),
      if (percentageChange != null) 'percentageChange': percentageChange,
      'isActive': isActive,
    };
  }

  static PriceType _parsePriceType(String type) {
    switch (type.toLowerCase()) {
      case 'base':
        return PriceType.base;
      case 'weekend':
        return PriceType.weekend;
      case 'seasonal':
        return PriceType.seasonal;
      case 'holiday':
        return PriceType.holiday;
      case 'special_event':
      case 'specialevent':
        return PriceType.specialEvent;
      default:
        return PriceType.custom;
    }
  }

  static String _priceTypeToString(PriceType type) {
    switch (type) {
      case PriceType.base:
        return 'base';
      case PriceType.weekend:
        return 'weekend';
      case PriceType.seasonal:
        return 'seasonal';
      case PriceType.holiday:
        return 'holiday';
      case PriceType.specialEvent:
        return 'special_event';
      case PriceType.custom:
        return 'custom';
    }
  }

  static PricingTier _parsePricingTier(String tier) {
    switch (tier.toLowerCase()) {
      case 'normal':
        return PricingTier.normal;
      case 'high':
        return PricingTier.high;
      case 'peak':
        return PricingTier.peak;
      case 'discount':
        return PricingTier.discount;
      default:
        return PricingTier.custom;
    }
  }

  static String _pricingTierToString(PricingTier tier) {
    switch (tier) {
      case PricingTier.normal:
        return 'normal';
      case PricingTier.high:
        return 'high';
      case PricingTier.peak:
        return 'peak';
      case PricingTier.discount:
        return 'discount';
      case PricingTier.custom:
        return 'custom';
    }
  }
}

class UnitPricingModel extends UnitPricing {
  const UnitPricingModel({
    required String unitId,
    required String unitName,
    required double basePrice,
    required String currency,
    required Map<String, PricingDay> calendar,
    required List<PricingRule> rules,
    required PricingStats stats,
  }) : super(
          unitId: unitId,
          unitName: unitName,
          basePrice: basePrice,
          currency: currency,
          calendar: calendar,
          rules: rules,
          stats: stats,
        );

  factory UnitPricingModel.fromJson(Map<String, dynamic> json) {
    final Map<String, PricingDay> calendar = {};
    if (json['calendar'] != null) {
      (json['calendar'] as Map<String, dynamic>).forEach((key, value) {
        calendar[key] = PricingDayModel.fromJson(value);
      });
    }

    final List<PricingRule> rules = [];
    if (json['rules'] != null) {
      rules.addAll(
        (json['rules'] as List)
            .map((e) => PricingRuleModel.fromJson(e))
            .toList(),
      );
    }

    return UnitPricingModel(
      unitId: json['unitId'] as String,
      unitName: json['unitName'] as String,
      basePrice: (json['basePrice'] as num).toDouble(),
      currency: json['currency'] as String,
      calendar: calendar,
      rules: rules,
      stats: PricingStatsModel.fromJson(json['stats']),
    );
  }
}

class PricingDayModel extends PricingDay {
  const PricingDayModel({
    required double price,
    required PriceType priceType,
    required String colorCode,
    double? percentageChange,
  }) : super(
          price: price,
          priceType: priceType,
          colorCode: colorCode,
          percentageChange: percentageChange,
        );

  factory PricingDayModel.fromJson(Map<String, dynamic> json) {
    return PricingDayModel(
      price: (json['price'] as num).toDouble(),
      priceType: PricingRuleModel._parsePriceType(json['priceType'] as String),
      colorCode: json['colorCode'] as String,
      percentageChange: json['percentageChange'] != null
          ? (json['percentageChange'] as num).toDouble()
          : null,
    );
  }
}

class PricingStatsModel extends PricingStats {
  const PricingStatsModel({
    required double averagePrice,
    required double minPrice,
    required double maxPrice,
    required int daysWithSpecialPricing,
    required double potentialRevenue,
  }) : super(
          averagePrice: averagePrice,
          minPrice: minPrice,
          maxPrice: maxPrice,
          daysWithSpecialPricing: daysWithSpecialPricing,
          potentialRevenue: potentialRevenue,
        );

  factory PricingStatsModel.fromJson(Map<String, dynamic> json) {
    return PricingStatsModel(
      averagePrice: (json['averagePrice'] as num).toDouble(),
      minPrice: (json['minPrice'] as num).toDouble(),
      maxPrice: (json['maxPrice'] as num).toDouble(),
      daysWithSpecialPricing: json['daysWithSpecialPricing'] as int,
      potentialRevenue: (json['potentialRevenue'] as num).toDouble(),
    );
  }
}