// lib/features/admin_availability_pricing/data/models/pricing_rule_model.dart

import '../../domain/entities/pricing_rule.dart';
import '../../domain/entities/pricing.dart';
import 'package:intl/intl.dart';

class PricingRuleModel extends PricingRule {
  const PricingRuleModel({
    required super.id,
    required super.unitId,
    required super.startDate,
    required super.endDate,
    super.startTime,
    super.endTime,
    required super.priceAmount,
    required super.priceType,
    required super.pricingTier,
    super.percentageChange,
    super.minPrice,
    super.maxPrice,
    super.description,
    required super.currency,
  });

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
}

class UnitPricingModel extends UnitPricing {
  const UnitPricingModel({
    required super.unitId,
    required super.unitName,
    required super.basePrice,
    required super.currency,
    required super.calendar,
    required super.rules,
    required super.stats,
  });

  factory UnitPricingModel.fromJson(Map<String, dynamic> json) {
    final Map<String, PricingDay> calendar = {};
    if (json['calendar'] != null) {
      final dateFmt = DateFormat('yyyy-MM-dd');
      (json['calendar'] as Map<String, dynamic>).forEach((key, value) {
        String normalizedKey = key;
        try {
          final dt = DateTime.parse(key);
          normalizedKey = dateFmt.format(DateTime(dt.year, dt.month, dt.day));
        } catch (_) {
          if (key.length >= 10) normalizedKey = key.substring(0, 10);
        }
        calendar[normalizedKey] = PricingDayModel.fromJson(value);
      });
    }

    final List<PricingRule> rules = [];
    if (json['rules'] != null) {
      final String unitCurrency = json['currency'] as String;
      final String unitId = json['unitId'] as String;
      rules.addAll(
        (json['rules'] as List).map((e) {
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
        }).toList(),
      );
    }

    // If backend didn't provide per-day calendar, synthesize entries from rules
    // to ensure pricing colors and prices appear on the calendar.
    if (calendar.isEmpty && rules.isNotEmpty) {
      final dateFmt = DateFormat('yyyy-MM-dd');
      for (final rule in rules) {
        DateTime d = DateTime(rule.startDate.year, rule.startDate.month, rule.startDate.day);
        final DateTime end = DateTime(rule.endDate.year, rule.endDate.month, rule.endDate.day);
        while (!d.isAfter(end)) {
          final key = dateFmt.format(d);
          // Do not overwrite explicit backend calendar entries if any exist
          if (!calendar.containsKey(key)) {
            final priceType = PricingRuleModel._parsePriceType(rule.priceType);
            final colorCode = _colorFromTier(rule.pricingTier);
            calendar[key] = PricingDayModel(
              price: rule.priceAmount,
              priceType: priceType,
              colorCode: colorCode,
              percentageChange: rule.percentageChange,
              pricingTier: rule.pricingTier,
            );
          }
          d = d.add(const Duration(days: 1));
        }
      }
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
    required super.price,
    required super.priceType,
    required super.colorCode,
    super.percentageChange,
    super.pricingTier,
  });

  factory PricingDayModel.fromJson(Map<String, dynamic> json) {
    // Normalize keys from backend variants
    final tier = (json['pricingTier'] ?? json['pricing_tier'] ?? json['tier'])
        as String?;
    final priceNum = (json['priceAmount'] ?? json['price']) as num?;
    final price = (priceNum ?? 0).toDouble();
    final priceTypeStr =
        (json['priceType'] ?? json['type'] ?? 'custom') as String;
    final rawColor = (json['colorCode'] ??
        json['color_code'] ??
        json['hexColor'] ??
        json['hex'] ??
        json['color']);
    final colorCode = rawColor?.toString() ?? _colorFromTier(tier);
    return PricingDayModel(
      price: price,
      priceType: PricingRuleModel._parsePriceType(priceTypeStr),
      colorCode: colorCode,
      percentageChange: json['percentageChange'] != null
          ? (json['percentageChange'] as num).toDouble()
          : null,
      pricingTier: tier,
    );
  }
}

// Derive a stable fallback color when backend does not send explicit color code
String _colorFromTier(String? tier) {
  switch ((tier ?? 'normal').toString().toLowerCase()) {
    case 'peak':
      return '#F44336'; // red
    case 'high':
      return '#FF9800'; // orange
    case 'discount':
      return '#2196F3'; // blue
    case 'custom':
      return '#9C27B0'; // purple
    case 'normal':
    default:
      return '#4CAF50'; // green
  }
}

class PricingStatsModel extends PricingStats {
  const PricingStatsModel({
    required super.averagePrice,
    required super.minPrice,
    required super.maxPrice,
    required super.daysWithSpecialPricing,
    required super.potentialRevenue,
  });

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
