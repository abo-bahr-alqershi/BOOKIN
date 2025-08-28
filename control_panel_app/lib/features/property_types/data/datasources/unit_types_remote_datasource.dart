import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/models/paginated_result.dart';
import '../../../../core/models/result_dto.dart';
import '../../../../core/network/api_client.dart';
import '../models/unit_type_model.dart';

abstract class UnitTypesRemoteDataSource {
  Future<PaginatedResult<UnitTypeModel>> getUnitTypesByPropertyType({
    required String propertyTypeId,
    required int pageNumber,
    required int pageSize,
  });
  
  Future<UnitTypeModel> getUnitTypeById(String id);
  
  Future<String> createUnitType({
    required String propertyTypeId,
    required String name,
    required int maxCapacity,
    required String icon,
    required bool isHasAdults,
    required bool isHasChildren,
    required bool isMultiDays,
    required bool isRequiredToDetermineTheHour,
  });
  
  Future<bool> updateUnitType({
    required String unitTypeId,
    required String name,
    required int maxCapacity,
    required String icon,
    required bool isHasAdults,
    required bool isHasChildren,
    required bool isMultiDays,
    required bool isRequiredToDetermineTheHour,
  });
  
  Future<bool> deleteUnitType(String unitTypeId);
}

class UnitTypesRemoteDataSourceImpl implements UnitTypesRemoteDataSource {
  final ApiClient apiClient;
  static const String _baseEndpoint = '${ApiConstants.baseUrl}/api/admin/unit-types';

  UnitTypesRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<PaginatedResult<UnitTypeModel>> getUnitTypesByPropertyType({
    required String propertyTypeId,
    required int pageNumber,
    required int pageSize,
  }) async {
    try {
      final response = await apiClient.get(
        '$_baseEndpoint/property-type/$propertyTypeId',
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );
      
      return PaginatedResult<UnitTypeModel>.fromJson(
        response.data,
        (json) => UnitTypeModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Server error occurred');
    }
  }

  @override
  Future<UnitTypeModel> getUnitTypeById(String id) async {
    try {
      final response = await apiClient.get('$_baseEndpoint/$id');
      final result = ResultDto.fromJson(response.data, null);
      
      if (result.isSuccess && result.data != null) {
        return UnitTypeModel.fromJson(result.data);
      } else {
        throw ServerException(result.message ?? 'Failed to get unit type');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Server error occurred');
    }
  }

  @override
  Future<String> createUnitType({
    required String propertyTypeId,
    required String name,
    required int maxCapacity,
    required String icon,
    required bool isHasAdults,
    required bool isHasChildren,
    required bool isMultiDays,
    required bool isRequiredToDetermineTheHour,
  }) async {
    try {
      final response = await apiClient.post(
        _baseEndpoint,
        data: {
          'propertyTypeId': propertyTypeId,
          'name': name,
          'maxCapacity': maxCapacity,
          'icon': icon,
          'isHasAdults': isHasAdults,
          'isHasChildren': isHasChildren,
          'isMultiDays': isMultiDays,
          'isRequiredToDetermineTheHour': isRequiredToDetermineTheHour,
        },
      );
      
      final result = ResultDto.fromJson(response.data, null);
      
      if (result.isSuccess && result.data != null) {
        return result.data as String;
      } else {
        throw ServerException(result.message ?? 'Failed to create unit type');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Server error occurred');
    }
  }

  @override
  Future<bool> updateUnitType({
    required String unitTypeId,
    required String name,
    required int maxCapacity,
    required String icon,
    required bool isHasAdults,
    required bool isHasChildren,
    required bool isMultiDays,
    required bool isRequiredToDetermineTheHour,
  }) async {
    try {
      final response = await apiClient.put(
        '$_baseEndpoint/$unitTypeId',
        data: {
          'unitTypeId': unitTypeId,
          'name': name,
          'maxCapacity': maxCapacity,
          'icon': icon,
          'isHasAdults': isHasAdults,
          'isHasChildren': isHasChildren,
          'isMultiDays': isMultiDays,
          'isRequiredToDetermineTheHour': isRequiredToDetermineTheHour,
        },
      );
      
      final result = ResultDto.fromJson(response.data, null);
      return result.isSuccess;
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Server error occurred');
    }
  }

  @override
  Future<bool> deleteUnitType(String unitTypeId) async {
    try {
      final response = await apiClient.delete('$_baseEndpoint/$unitTypeId');
      final result = ResultDto.fromJson(response.data, null);
      return result.isSuccess;
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Server error occurred');
    }
  }
}