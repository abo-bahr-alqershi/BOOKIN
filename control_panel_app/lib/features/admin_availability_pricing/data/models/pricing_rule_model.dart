// lib/features/admin_availability_pricing/data/models/pricing_rule_model.dart

import '../../domain/entities/pricing_rule.dart';
import '../../domain/entities/pricing.dart';

class PricingRuleModel extends PricingRule {
  const PricingRuleModel({
    required String id,
    required String unitId,
    required DateTime startDate,
    required DateTime endDate,
    String? startTime,
    String? endTime,
    required double priceAmount,
    required String priceType,
    required String pricingTier,
    double? percentageChange,
    double? minPrice,
    double? maxPrice,
    String? description,
    required String currency,
  }) : super(
          id: id,
          unitId: unitId,
          startDate: startDate,
          endDate: endDate,
          startTime: startTime,
          endTime: endTime,
          priceAmount: priceAmount,
          priceType: priceType,
          pricingTier: pricingTier,
          percentageChange: percentageChange,
          minPrice: minPrice,
          maxPrice: maxPrice,
          description: description,
          currency: currency,
        );

  factory PricingRuleModel.fromJson(Map<String, dynamic> json) {
    return PricingRuleModel(
      id: json['id'] as String,
      unitId: json['unitId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      // Backend may send either "priceAmount" or "price"
      priceAmount: ((json['priceAmount'] ?? json['price']) as num).toDouble(),
      priceType: json['priceType'] as String,
      // Backend may send either "pricingTier" or compact "tier"; default to normal
      pricingTier: (json['pricingTier'] ?? json['tier'] ?? 'normal') as String,
      percentageChange: json['percentageChange'] != null
          ? (json['percentageChange'] as num).toDouble()
          : null,
      minPrice: json['minPrice'] != null
          ? (json['minPrice'] as num).toDouble()
          : null,
      maxPrice: json['maxPrice'] != null
          ? (json['maxPrice'] as num).toDouble()
          : null,
      description: json['description'] as String?,
      // If rule currency is missing, expect caller to inject parent currency; else fallback to empty string
      currency: (json['currency'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unitId': unitId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
      'priceAmount': priceAmount,
      'priceType': priceType,
      'pricingTier': pricingTier,
      if (percentageChange != null) 'percentageChange': percentageChange,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (description != null) 'description': description,
      'currency': currency,
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
      final String unitCurrency = json['currency'] as String;
      final String unitId = json['unitId'] as String;
      rules.addAll(
        (json['rules'] as List)
            .map((e) {
              final map = Map<String, dynamic>.from(e as Map);
              // Ensure unitId and currency are present on each rule to satisfy domain entity
              map.putIfAbsent('unitId', () => unitId);
              map.putIfAbsent('currency', () => unitCurrency);
              // Normalize possible backend alias for pricing tier
              if (!map.containsKey('pricingTier') && map.containsKey('tier')) {
                map['pricingTier'] = map['tier'];
              }
              // Normalize price key if backend used "price"
              if (!map.containsKey('priceAmount') && map.containsKey('price')) {
                map['priceAmount'] = map['price'];
              }
              return PricingRuleModel.fromJson(map);
            })
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