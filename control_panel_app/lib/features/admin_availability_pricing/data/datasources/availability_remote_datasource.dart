// lib/features/admin_availability_pricing/data/datasources/availability_remote_datasource.dart

import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/availability_model.dart';
import '../models/unit_availability_model.dart';
import '../models/booking_conflict_model.dart';
import '../../domain/repositories/availability_repository.dart';

abstract class AvailabilityRemoteDataSource {
  Future<UnitAvailabilityModel> getMonthlyAvailability(
    String unitId,
    int year,
    int month,
  );
  
  Future<void> updateAvailability(AvailabilityModel availability);
  
  Future<void> bulkUpdateAvailability(
    String unitId,
    List<AvailabilityPeriod> periods,
    bool overwriteExisting,
  );
  
  Future<void> cloneAvailability({
    required String unitId,
    required DateTime sourceStartDate,
    required DateTime sourceEndDate,
    required DateTime targetStartDate,
    required int repeatCount,
  });
  
  Future<void> deleteAvailability({
    required String unitId,
    String? availabilityId,
    DateTime? startDate,
    DateTime? endDate,
    bool? forceDelete,
  });
  
  Future<CheckAvailabilityResponseModel> checkAvailability({
    required String unitId,
    required DateTime checkIn,
    required DateTime checkOut,
    int? adults,
    int? children,
    bool? includePricing,
  });
  
  Future<List<BookingConflictModel>> checkConflicts({
    required String unitId,
    required DateTime startDate,
    required DateTime endDate,
    String? startTime,
    String? endTime,
    required String checkType,
  });
}

class AvailabilityRemoteDataSourceImpl implements AvailabilityRemoteDataSource {
  final ApiClient apiClient;

  AvailabilityRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UnitAvailabilityModel> getMonthlyAvailability(
    String unitId,
    int year,
    int month,
  ) async {
    try {
      final response = await apiClient.get(
        '${ApiConstants.units}/$unitId/availability/$year/$month',
      );
      
      return UnitAvailabilityModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> updateAvailability(AvailabilityModel availability) async {
    try {
      await apiClient.post(
        '${ApiConstants.units}/${availability.unitId}/availability',
        data: availability.toJson(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> bulkUpdateAvailability(
    String unitId,
    List<AvailabilityPeriod> periods,
    bool overwriteExisting,
  ) async {
    try {
      final data = {
        'unitId': unitId,
        'periods': periods.map((p) => {
          'startDate': p.startDate.toIso8601String(),
          'endDate': p.endDate.toIso8601String(),
          'status': AvailabilityModel._statusToString(p.status),
          if (p.reason != null) 'reason': p.reason,
          if (p.notes != null) 'notes': p.notes,
          'overwriteExisting': p.overwriteExisting,
        }).toList(),
        'overwriteExisting': overwriteExisting,
      };
      
      await apiClient.post(
        '${ApiConstants.units}/$unitId/availability/bulk',
        data: data,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> cloneAvailability({
    required String unitId,
    required DateTime sourceStartDate,
    required DateTime sourceEndDate,
    required DateTime targetStartDate,
    required int repeatCount,
  }) async {
    try {
      await apiClient.post(
        '${ApiConstants.units}/$unitId/availability/clone',
        data: {
          'unitId': unitId,
          'sourceStartDate': sourceStartDate.toIso8601String(),
          'sourceEndDate': sourceEndDate.toIso8601String(),
          'targetStartDate': targetStartDate.toIso8601String(),
          'repeatCount': repeatCount,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> deleteAvailability({
    required String unitId,
    String? availabilityId,
    DateTime? startDate,
    DateTime? endDate,
    bool? forceDelete,
  }) async {
    try {
      if (availabilityId != null) {
        await apiClient.delete(
          '${ApiConstants.units}/$unitId/availability/$availabilityId',
          queryParameters: if (forceDelete != null) {'forceDelete': forceDelete},
        );
      } else if (startDate != null && endDate != null) {
        await apiClient.delete(
          '${ApiConstants.units}/$unitId/availability/${startDate.toIso8601String()}/${endDate.toIso8601String()}',
          queryParameters: if (forceDelete != null) {'forceDelete': forceDelete},
        );
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<CheckAvailabilityResponseModel> checkAvailability({
    required String unitId,
    required DateTime checkIn,
    required DateTime checkOut,
    int? adults,
    int? children,
    bool? includePricing,
  }) async {
    try {
      final response = await apiClient.get(
        '${ApiConstants.units}/$unitId/availability/check',
        queryParameters: {
          'checkIn': checkIn.toIso8601String(),
          'checkOut': checkOut.toIso8601String(),
          if (adults != null) 'adults': adults,
          if (children != null) 'children': children,
          if (includePricing != null) 'includePricing': includePricing,
        },
      );
      
      return CheckAvailabilityResponseModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<List<BookingConflictModel>> checkConflicts({
    required String unitId,
    required DateTime startDate,
    required DateTime endDate,
    String? startTime,
    String? endTime,
    required String checkType,
  }) async {
    try {
      final response = await apiClient.post(
        '${ApiConstants.units}/$unitId/availability/check-conflicts',
        data: {
          'unitId': unitId,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          if (startTime != null) 'startTime': startTime,
          if (endTime != null) 'endTime': endTime,
          'checkType': checkType,
        },
      );
      
      final List<dynamic> conflicts = response.data['conflicts'] ?? [];
      return conflicts
          .map((json) => BookingConflictModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}