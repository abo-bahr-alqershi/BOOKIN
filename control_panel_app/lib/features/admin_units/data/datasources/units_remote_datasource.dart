import 'package:dio/dio.dart';
import '../models/unit_model.dart';
import '../models/unit_type_model.dart';
import '../../domain/entities/unit_type.dart';

abstract class UnitsRemoteDataSource {
  Future<List<UnitModel>> getUnits({
    int? pageNumber,
    int? pageSize,
    String? propertyId,
    String? unitTypeId,
    bool? isAvailable,
    double? minPrice,
    double? maxPrice,
    String? searchQuery,
  });

  Future<UnitModel> getUnitDetails(String unitId);

  Future<String> createUnit(Map<String, dynamic> unitData);

  Future<bool> updateUnit(String unitId, Map<String, dynamic> unitData);

  Future<bool> deleteUnit(String unitId);

  Future<List<UnitTypeModel>> getUnitTypesByProperty(String propertyTypeId);

  Future<List<UnitTypeField>> getUnitFields(String unitTypeId);

  Future<bool> assignUnitToSections(String unitId, List<String> sectionIds);
}

class UnitsRemoteDataSourceImpl implements UnitsRemoteDataSource {
  final Dio dio;

  UnitsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<UnitModel>> getUnits({
    int? pageNumber,
    int? pageSize,
    String? propertyId,
    String? unitTypeId,
    bool? isAvailable,
    double? minPrice,
    double? maxPrice,
    String? searchQuery,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (pageNumber != null) queryParams['pageNumber'] = pageNumber;
      if (pageSize != null) queryParams['pageSize'] = pageSize;
      if (propertyId != null) queryParams['propertyId'] = propertyId;
      if (unitTypeId != null) queryParams['unitTypeId'] = unitTypeId;
      if (isAvailable != null) queryParams['isAvailable'] = isAvailable;
      if (minPrice != null) queryParams['minPrice'] = minPrice;
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
      if (searchQuery != null) queryParams['nameContains'] = searchQuery;

      final response = await dio.get(
        '/api/admin/Units',
        queryParameters: queryParams,
      );

      final List<dynamic> items = response.data['items'] ?? [];
      return items.map((json) => UnitModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UnitModel> getUnitDetails(String unitId) async {
    try {
      final response = await dio.get('/api/admin/Units/$unitId/details');
      return UnitModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<String> createUnit(Map<String, dynamic> unitData) async {
    try {
      final response = await dio.post('/api/admin/Units', data: unitData);
      return response.data['data'] as String;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<bool> updateUnit(String unitId, Map<String, dynamic> unitData) async {
    try {
      final response = await dio.put('/api/admin/Units/$unitId', data: unitData);
      return response.data['success'] ?? false;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<bool> deleteUnit(String unitId) async {
    try {
      final response = await dio.delete('/api/admin/Units/$unitId');
      return response.data['success'] ?? false;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<UnitTypeModel>> getUnitTypesByProperty(String propertyTypeId) async {
    try {
      final response = await dio.get(
        '/api/admin/unit-types/property-type/$propertyTypeId',
      );
      final List<dynamic> items = response.data['items'] ?? [];
      return items.map((json) => UnitTypeModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<UnitTypeField>> getUnitFields(String unitTypeId) async {
    try {
      final response = await dio.get(
        '/api/admin/unit-type-fields/unit-type/$unitTypeId',
      );
      final List<dynamic> items = response.data ?? [];
      return items.map((json) => UnitTypeFieldModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<bool> assignUnitToSections(String unitId, List<String> sectionIds) async {
    try {
      final response = await dio.post(
        '/api/admin/units/$unitId/sections',
        data: {'sectionIds': sectionIds},
      );
      return response.data['success'] ?? false;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    if (error.response != null) {
      final message = error.response?.data['message'] ?? 'حدث خطأ في الخادم';
      return Exception(message);
    } else if (error.type == DioExceptionType.connectionTimeout) {
      return Exception('انتهت مهلة الاتصال');
    } else if (error.type == DioExceptionType.connectionError) {
      return Exception('لا يوجد اتصال بالإنترنت');
    } else {
      return Exception('حدث خطأ غير متوقع');
    }
  }
}