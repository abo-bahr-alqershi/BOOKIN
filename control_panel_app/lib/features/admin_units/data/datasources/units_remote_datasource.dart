import 'package:bookn_cp_app/core/error/exceptions.dart';
import 'package:bookn_cp_app/core/network/api_client.dart';
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
  final ApiClient apiClient;
  
  UnitsRemoteDataSourceImpl({required this.apiClient});

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

      final response = await apiClient.get(
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
      final response = await apiClient.get('/api/admin/Units/$unitId/details');
      return UnitModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<String> createUnit(Map<String, dynamic> unitData) async {
    try {
      // إضافة logging لمعرفة البيانات المرسلة
      print('🔵 POST Request to: /api/admin/Units');
      print('📦 Data: $unitData');
      
      final response = await apiClient.post('/api/admin/Units', data: unitData);
      
      // التحقق من استجابة السيرفر
      print('✅ Server Response: ${response.data}');
      
      // تحسين استخراج ID
      if (response.data is Map && response.data.containsKey('data')) {
        return response.data['data'].toString();
      } else if (response.data is String) {
        return response.data;
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      // تحسين معالجة الأخطاء
      print('❌ Error Status: ${e.response?.statusCode}');
      print('❌ Error Data: ${e.response?.data}');
      
      throw _handleDioError(e);
    }
  }

  @override
  Future<bool> updateUnit(String unitId, Map<String, dynamic> unitData) async {
    try {
      final response = await apiClient.put('/api/admin/Units/$unitId', data: unitData);
      return response.data['success'] ?? false;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<bool> deleteUnit(String unitId) async {
    try {
      final response = await apiClient.delete('/api/admin/Units/$unitId');
      return response.data['success'] ?? false;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<UnitTypeModel>> getUnitTypesByProperty(String propertyTypeId) async {
    try {
      final response = await apiClient.get(
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
      final response = await apiClient.get(
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
      final response = await apiClient.post(
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
      // إظهار تفاصيل الخطأ من السيرفر
      final responseData = error.response?.data;
      String message = 'حدث خطأ في الخادم';
      
      if (responseData is Map) {
        // معالجة أخطاء validation
        if (responseData.containsKey('errors')) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          final errorMessages = <String>[];
          
          errors.forEach((field, fieldErrors) {
            if (fieldErrors is List) {
              for (final fieldError in fieldErrors) {
                errorMessages.add('$field: $fieldError');
              }
            } else {
              errorMessages.add('$field: $fieldErrors');
            }
          });
          
          message = errorMessages.join(', ');
        } else {
          message = responseData['message'] ?? 
                    responseData['error'] ?? 
                    responseData['title'] ?? 
                    message;
        }
      } else if (responseData is String) {
        message = responseData;
      }
      
      print('Server Error Message: $message');
      return ServerException(message);
    } else if (error.type == DioExceptionType.connectionTimeout) {
      return const ServerException('انتهت مهلة الاتصال');
    } else if (error.type == DioExceptionType.connectionError) {
      return const ServerException('لا يوجد اتصال بالإنترنت');
    } else {
      return ServerException('حدث خطأ غير متوقع: ${error.message}');
    }
  }
}