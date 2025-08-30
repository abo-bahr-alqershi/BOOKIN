// lib/features/admin_availability_pricing/data/datasources/pricing_remote_datasource.dart

import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/pricing_rule_model.dart';
import '../models/seasonal_pricing_model.dart';
import '../../domain/repositories/pricing_repository.dart';

abstract class PricingRemoteDataSource {
  Future<UnitPricingModel> getMonthlyPricing(
    String unitId,
    int year,
    int month,
  );
  
  Future<void> updatePricing(Map<String, dynamic> data);
  
  Future<void> bulkUpdatePricing(
    String unitId,
    List<PricingPeriod> periods,
    bool overwriteExisting,
  );
  
  Future<void> copyPricing(Map<String, dynamic> data);
  
  Future<void> deletePricing({
    required String unitId,
    String? pricingId,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  Future<List<SeasonalPricingModel>> getSeasonalPricing(String unitId);
  
  Future<void> applySeasonalPricing(Map<String, dynamic> data);
  
  Future<PricingBreakdownModel> getPricingBreakdown({
    required String unitId,
    required DateTime checkIn,
    required DateTime checkOut,
  });
}

class PricingRemoteDataSourceImpl implements PricingRemoteDataSource {
  final ApiClient apiClient;

  PricingRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UnitPricingModel> getMonthlyPricing(
    String unitId,
    int year,
    int month,
  ) async {
    try {
      final response = await apiClient.get(
        '${ApiConstants.units}/$unitId/pricing/$year/$month',
      );
      
      return UnitPricingModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> updatePricing(Map<String, dynamic> data) async {
    try {
      await apiClient.post(
        '${ApiConstants.units}/${data['unitId']}/pricing',
        data: data,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> bulkUpdatePricing(
    String unitId,
    List<PricingPeriod> periods,
    bool overwriteExisting,
  ) async {
    try {
      final data = {
        'unitId': unitId,
        'periods': periods.map((p) => {
          'startDate': p.startDate.toIso8601String(),
          'endDate': p.endDate.toIso8601String(),
          'priceType': PricingRuleModel._priceTypeToString(p.priceType),
          'price': p.price,
          if (p.currency != null) 'currency': p.currency,
          'tier': PricingRuleModel._pricingTierToString(p.tier),
          if (p.percentageChange != null) 'percentageChange': p.percentageChange,
          if (p.minPrice != null) 'minPrice': p.minPrice,
          if (p.maxPrice != null) 'maxPrice': p.maxPrice,
          if (p.description != null) 'description': p.description,
          'overwriteExisting': p.overwriteExisting,
        }).toList(),
        'overwriteExisting': overwriteExisting,
      };
      
      await apiClient.post(
        '${ApiConstants.units}/$unitId/pricing/bulk',
        data: data,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> copyPricing(Map<String, dynamic> data) async {
    try {
      await apiClient.post(
        '${ApiConstants.units}/${data['unitId']}/pricing/copy',
        data: data,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> deletePricing({
    required String unitId,
    String? pricingId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      if (pricingId != null) {
        await apiClient.delete(
          '${ApiConstants.units}/$unitId/pricing/$pricingId',
        );
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<List<SeasonalPricingModel>> getSeasonalPricing(String unitId) async {
    try {
      final response = await apiClient.get(
        '${ApiConstants.units}/$unitId/pricing/templates',
      );
      
      final List<dynamic> seasons = response.data['seasons'] ?? [];
      return seasons
          .map((json) => SeasonalPricingModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> applySeasonalPricing(Map<String, dynamic> data) async {
    try {
      await apiClient.post(
        '${ApiConstants.units}/${data['unitId']}/pricing/apply-template',
        data: data,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<PricingBreakdownModel> getPricingBreakdown({
    required String unitId,
    required DateTime checkIn,
    required DateTime checkOut,
  }) async {
    try {
      final response = await apiClient.get(
        '${ApiConstants.units}/$unitId/pricing/breakdown',
        queryParameters: {
          'checkIn': checkIn.toIso8601String(),
          'checkOut': checkOut.toIso8601String(),
        },
      );
      
      return PricingBreakdownModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

class PricingBreakdownModel extends PricingBreakdown {
  PricingBreakdownModel({
    required DateTime checkIn,
    required DateTime checkOut,
    required String currency,
    required List<DayPrice> days,
    required int totalNights,
    required double subTotal,
    double? discount,
    double? taxes,
    required double total,
  }) : super(
          checkIn: checkIn,
          checkOut: checkOut,
          currency: currency,
          days: days,
          totalNights: totalNights,
          subTotal: subTotal,
          discount: discount,
          taxes: taxes,
          total: total,
        );

  factory PricingBreakdownModel.fromJson(Map<String, dynamic> json) {
    return PricingBreakdownModel(
      checkIn: DateTime.parse(json['checkIn'] as String),
      checkOut: DateTime.parse(json['checkOut'] as String),
      currency: json['currency'] as String,
      days: (json['days'] as List)
          .map((e) => DayPriceModel.fromJson(e))
          .toList(),
      totalNights: json['totalNights'] as int,
      subTotal: (json['subTotal'] as num).toDouble(),
      discount: json['discount'] != null
          ? (json['discount'] as num).toDouble()
          : null,
      taxes: json['taxes'] != null
          ? (json['taxes'] as num).toDouble()
          : null,
      total: (json['total'] as num).toDouble(),
    );
  }
}

class DayPriceModel extends DayPrice {
  DayPriceModel({
    required DateTime date,
    required double price,
    required PriceType priceType,
    String? description,
  }) : super(
          date: date,
          price: price,
          priceType: priceType,
          description: description,
        );

  factory DayPriceModel.fromJson(Map<String, dynamic> json) {
    return DayPriceModel(
      date: DateTime.parse(json['date'] as String),
      price: (json['price'] as num).toDouble(),
      priceType: PricingRuleModel._parsePriceType(json['priceType'] as String),
      description: json['description'] as String?,
    );
  }
}