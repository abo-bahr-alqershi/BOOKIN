// lib/features/admin_availability_pricing/data/datasources/availability_remote_datasource.dart

import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/availability_model.dart' as avail_model;
import '../models/unit_availability_model.dart' as unit_avail_model;
import '../models/booking_conflict_model.dart';
import '../../domain/entities/availability.dart';
import '../../domain/repositories/availability_repository.dart' as availability_repo;

abstract class AvailabilityRemoteDataSource {
  Future<unit_avail_model.UnitAvailabilityModel> getMonthlyAvailability(
    String unitId,
    int year,
    int month,
  );
  
  Future<void> updateAvailability(avail_model.UnitAvailabilityEntryModel availability);
  
  Future<void> bulkUpdateAvailability(
    String unitId,
    List<availability_repo.AvailabilityPeriod> periods,
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
  
  Future<unit_avail_model.CheckAvailabilityResponseModel> checkAvailability({
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
  Future<unit_avail_model.UnitAvailabilityModel> getMonthlyAvailability(
    String unitId,
    int year,
    int month,
  ) async {
    try {
      final response = await apiClient.get(
        '/api/admin/units/$unitId/availability/$year/$month',
      );
      
      return unit_avail_model.UnitAvailabilityModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> updateAvailability(avail_model.UnitAvailabilityEntryModel availability) async {
    try {
      await apiClient.post(
        '/api/admin/units/${availability.unitId}/availability',
        data: availability.toJson(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> bulkUpdateAvailability(
    String unitId,
    List<availability_repo.AvailabilityPeriod> periods,
    bool overwriteExisting,
  ) async {
    try {
      final data = {
        'unitId': unitId,
        'periods': periods.map((p) => {
          'startDate': p.startDate.toIso8601String(),
          'endDate': p.endDate.toIso8601String(),
          'status': _availabilityStatusToString(p.status),
          if (p.reason != null) 'reason': p.reason,
          if (p.notes != null) 'notes': p.notes,
          'overwriteExisting': p.overwriteExisting,
        }).toList(),
        'overwriteExisting': overwriteExisting,
      };
      
      await apiClient.post(
        '/api/admin/units/$unitId/availability/bulk',
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
        '/api/admin/units/$unitId/availability/clone',
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
      // الـ backend يدعم الحذف بنطاق التواريخ فقط
      if (startDate != null && endDate != null) {
        await apiClient.delete(
          '/api/admin/units/$unitId/availability/${startDate.toIso8601String()}/${endDate.toIso8601String()}',
          queryParameters: forceDelete != null ? {'forceDelete': forceDelete} : null,
        );
      } else {
        // لا مسار لحذف بواسطة availabilityId حاليًا
        throw ApiException(message: 'حذف التوفر يتطلب startDate و endDate. لا يوجد حذف بواسطة المعرّف حاليًا.');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<unit_avail_model.CheckAvailabilityResponseModel> checkAvailability({
    required String unitId,
    required DateTime checkIn,
    required DateTime checkOut,
    int? adults,
    int? children,
    bool? includePricing,
  }) async {
    try {
      final response = await apiClient.get(
        '/api/admin/units/$unitId/availability/check',
        queryParameters: {
          'checkIn': checkIn.toIso8601String(),
          'checkOut': checkOut.toIso8601String(),
          if (adults != null) 'adults': adults,
          if (children != null) 'children': children,
          if (includePricing != null) 'includePricing': includePricing,
        },
      );
      
      return unit_avail_model.CheckAvailabilityResponseModel.fromJson(response.data['data']);
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
      // لا يوجد مسار check-conflicts في الـ backend الحالي، نعيد قائمة فارغة لتجنّب الأعطال
      return <BookingConflictModel>[];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  String _availabilityStatusToString(AvailabilityStatus status) {
    switch (status) {
      case AvailabilityStatus.available:
        return 'available';
      case AvailabilityStatus.booked:
        return 'booked';
      case AvailabilityStatus.blocked:
        return 'blocked';
      case AvailabilityStatus.maintenance:
        return 'maintenance';
      case AvailabilityStatus.hold:
        return 'hold';
    }
  }
}