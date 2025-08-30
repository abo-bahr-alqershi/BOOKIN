// lib/features/admin_availability_pricing/data/models/unit_availability_model.dart

import '../../domain/entities/unit_availability.dart';
import '../../domain/entities/availability.dart';

class UnitAvailabilityModel extends UnitAvailability {
  const UnitAvailabilityModel({
    required String unitId,
    required String unitName,
    required Map<String, AvailabilityStatusDetail> calendar,
    required List<AvailabilityPeriod> periods,
    required AvailabilityStats stats,
  }) : super(
          unitId: unitId,
          unitName: unitName,
          calendar: calendar,
          periods: periods,
          stats: stats,
        );

  factory UnitAvailabilityModel.fromJson(Map<String, dynamic> json) {
    final Map<String, AvailabilityStatusDetail> calendar = {};
    if (json['calendar'] != null) {
      (json['calendar'] as Map<String, dynamic>).forEach((key, value) {
        calendar[key] = AvailabilityStatusDetailModel.fromJson(value);
      });
    }

    final List<AvailabilityPeriod> periods = [];
    if (json['periods'] != null) {
      periods.addAll(
        (json['periods'] as List)
            .map((e) => AvailabilityPeriodModel.fromJson(e))
            .toList(),
      );
    }

    return UnitAvailabilityModel(
      unitId: json['unitId'] as String,
      unitName: json['unitName'] as String,
      calendar: calendar,
      periods: periods,
      stats: AvailabilityStatsModel.fromJson(json['stats']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> calendarJson = {};
    calendar.forEach((key, value) {
      calendarJson[key] = (value as AvailabilityStatusDetailModel).toJson();
    });

    return {
      'unitId': unitId,
      'unitName': unitName,
      'calendar': calendarJson,
      'periods': periods
          .map((e) => (e as AvailabilityPeriodModel).toJson())
          .toList(),
      'stats': (stats as AvailabilityStatsModel).toJson(),
    };
  }
}

class AvailabilityStatusDetailModel extends AvailabilityStatusDetail {
  const AvailabilityStatusDetailModel({
    required AvailabilityStatus status,
    String? reason,
    String? bookingId,
    required String colorCode,
  }) : super(
          status: status,
          reason: reason,
          bookingId: bookingId,
          colorCode: colorCode,
        );

  factory AvailabilityStatusDetailModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityStatusDetailModel(
      status: _parseStatus(json['status'] as String),
      reason: json['reason'] as String?,
      bookingId: json['bookingId'] as String?,
      colorCode: json['colorCode'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': _statusToString(status),
      if (reason != null) 'reason': reason,
      if (bookingId != null) 'bookingId': bookingId,
      'colorCode': colorCode,
    };
  }

  static AvailabilityStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return AvailabilityStatus.available;
      case 'unavailable':
        return AvailabilityStatus.unavailable;
      case 'maintenance':
        return AvailabilityStatus.maintenance;
      case 'blocked':
        return AvailabilityStatus.blocked;
      case 'booked':
        return AvailabilityStatus.booked;
      default:
        return AvailabilityStatus.available;
    }
  }

  static String _statusToString(AvailabilityStatus status) {
    switch (status) {
      case AvailabilityStatus.available:
        return 'available';
      case AvailabilityStatus.unavailable:
        return 'unavailable';
      case AvailabilityStatus.maintenance:
        return 'maintenance';
      case AvailabilityStatus.blocked:
        return 'blocked';
      case AvailabilityStatus.booked:
        return 'booked';
    }
  }
}

class AvailabilityPeriodModel extends AvailabilityPeriod {
  const AvailabilityPeriodModel({
    required DateTime startDate,
    required DateTime endDate,
    required AvailabilityStatus status,
    String? reason,
    String? notes,
    required bool overwriteExisting,
  }) : super(
          startDate: startDate,
          endDate: endDate,
          status: status,
          reason: reason,
          notes: notes,
          overwriteExisting: overwriteExisting,
        );

  factory AvailabilityPeriodModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityPeriodModel(
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: AvailabilityStatusDetailModel._parseStatus(json['status'] as String),
      reason: json['reason'] as String?,
      notes: json['notes'] as String?,
      overwriteExisting: json['overwriteExisting'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': AvailabilityStatusDetailModel._statusToString(status),
      if (reason != null) 'reason': reason,
      if (notes != null) 'notes': notes,
      'overwriteExisting': overwriteExisting,
    };
  }
}

class AvailabilityStatsModel extends AvailabilityStats {
  const AvailabilityStatsModel({
    required int totalDays,
    required int availableDays,
    required int bookedDays,
    required int blockedDays,
    required double occupancyRate,
  }) : super(
          totalDays: totalDays,
          availableDays: availableDays,
          bookedDays: bookedDays,
          blockedDays: blockedDays,
          occupancyRate: occupancyRate,
        );

  factory AvailabilityStatsModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityStatsModel(
      totalDays: json['totalDays'] as int,
      availableDays: json['availableDays'] as int,
      bookedDays: json['bookedDays'] as int,
      blockedDays: json['blockedDays'] as int,
      occupancyRate: (json['occupancyRate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalDays': totalDays,
      'availableDays': availableDays,
      'bookedDays': bookedDays,
      'blockedDays': blockedDays,
      'occupancyRate': occupancyRate,
    };
  }
}

class CheckAvailabilityResponseModel extends CheckAvailabilityResponse {
  CheckAvailabilityResponseModel({
    required bool isAvailable,
    required String status,
    required List<BlockedPeriod> blockedPeriods,
    required List<AvailablePeriod> availablePeriods,
    required AvailabilityDetails details,
    required List<String> messages,
  }) : super(
          isAvailable: isAvailable,
          status: status,
          blockedPeriods: blockedPeriods,
          availablePeriods: availablePeriods,
          details: details,
          messages: messages,
        );

  factory CheckAvailabilityResponseModel.fromJson(Map<String, dynamic> json) {
    return CheckAvailabilityResponseModel(
      isAvailable: json['isAvailable'] as bool,
      status: json['status'] as String,
      blockedPeriods: (json['blockedPeriods'] as List)
          .map((e) => BlockedPeriodModel.fromJson(e))
          .toList(),
      availablePeriods: (json['availablePeriods'] as List)
          .map((e) => AvailablePeriodModel.fromJson(e))
          .toList(),
      details: AvailabilityDetailsModel.fromJson(json['details']),
      messages: List<String>.from(json['messages'] ?? []),
    );
  }
}

class BlockedPeriodModel extends BlockedPeriod {
  BlockedPeriodModel({
    required DateTime startDate,
    required DateTime endDate,
    required String status,
    required String reason,
    required String notes,
  }) : super(
          startDate: startDate,
          endDate: endDate,
          status: status,
          reason: reason,
          notes: notes,
        );

  factory BlockedPeriodModel.fromJson(Map<String, dynamic> json) {
    return BlockedPeriodModel(
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: json['status'] as String,
      reason: json['reason'] as String,
      notes: json['notes'] as String,
    );
  }
}

class AvailablePeriodModel extends AvailablePeriod {
  AvailablePeriodModel({
    required DateTime startDate,
    required DateTime endDate,
    double? price,
    String? currency,
  }) : super(
          startDate: startDate,
          endDate: endDate,
          price: price,
          currency: currency,
        );

  factory AvailablePeriodModel.fromJson(Map<String, dynamic> json) {
    return AvailablePeriodModel(
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      currency: json['currency'] as String?,
    );
  }
}

class AvailabilityDetailsModel extends AvailabilityDetails {
  AvailabilityDetailsModel({
    required String unitId,
    required String unitName,
    required String unitType,
    required int maxAdults,
    required int maxChildren,
    required int totalNights,
    required bool isMultiDays,
    required bool isRequiredToDetermineTheHour,
  }) : super(
          unitId: unitId,
          unitName: unitName,
          unitType: unitType,
          maxAdults: maxAdults,
          maxChildren: maxChildren,
          totalNights: totalNights,
          isMultiDays: isMultiDays,
          isRequiredToDetermineTheHour: isRequiredToDetermineTheHour,
        );

  factory AvailabilityDetailsModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityDetailsModel(
      unitId: json['unitId'] as String,
      unitName: json['unitName'] as String,
      unitType: json['unitType'] as String,
      maxAdults: json['maxAdults'] as int,
      maxChildren: json['maxChildren'] as int,
      totalNights: json['totalNights'] as int,
      isMultiDays: json['isMultiDays'] as bool,
      isRequiredToDetermineTheHour: json['isRequiredToDetermineTheHour'] as bool,
    );
  }
}