// lib/features/admin_properties/data/datasources/amenities_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:bookn_cp_app/core/network/api_client.dart';
import 'package:bookn_cp_app/core/error/exceptions.dart';
import 'package:bookn_cp_app/core/models/paginated_result.dart';
import '../models/amenity_model.dart';

abstract class AmenitiesRemoteDataSource {
  Future<PaginatedResult<AmenityModel>> getAllAmenities({
    int? pageNumber,
    int? pageSize,
    String? searchTerm,
    String? propertyId,
    bool? isAssigned,
    bool? isFree,
  });
  Future<AmenityModel> getAmenityById(String amenityId);
  Future<String> createAmenity(Map<String, dynamic> data);
  Future<bool> updateAmenity(String amenityId, Map<String, dynamic> data);
  Future<bool> deleteAmenity(String amenityId);
  Future<bool> assignAmenityToProperty(String amenityId, String propertyId, Map<String, dynamic> data);
  Future<List<AmenityModel>> getPropertyAmenities(String propertyId);
}

class AmenitiesRemoteDataSourceImpl implements AmenitiesRemoteDataSource {
  final ApiClient apiClient;
  static const String _baseEndpoint = '/api/admin/amenities';
  
  AmenitiesRemoteDataSourceImpl({required this.apiClient});
  
  @override
  Future<PaginatedResult<AmenityModel>> getAllAmenities({
    int? pageNumber,
    int? pageSize,
    String? searchTerm,
    String? propertyId,
    bool? isAssigned,
    bool? isFree,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (pageNumber != null) 'pageNumber': pageNumber,
        if (pageSize != null) 'pageSize': pageSize,
        if (searchTerm != null) 'searchTerm': searchTerm,
        if (propertyId != null) 'propertyId': propertyId,
        if (isAssigned != null) 'isAssigned': isAssigned,
        if (isFree != null) 'isFree': isFree,
      };
      
      final response = await apiClient.get(
        _baseEndpoint,
        queryParameters: queryParams,
      );
      
      return PaginatedResult<AmenityModel>.fromJson(
        response.data,
        (json) => AmenityModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to fetch amenities');
    }
  }
  
  @override
  Future<AmenityModel> getAmenityById(String amenityId) async {
    try {
      final response = await apiClient.get('$_baseEndpoint/$amenityId');
      final root = response.data['data'] is Map<String, dynamic>
          ? response.data['data']
          : response.data;
      if (response.data['success'] == true || response.data['isSuccess'] == true || root is Map<String, dynamic>) {
        return AmenityModel.fromJson(root as Map<String, dynamic>);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to get amenity');
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to fetch amenity');
    }
  }
  
  @override
  Future<String> createAmenity(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post(_baseEndpoint, data: data);
      if (response.data['success'] == true || response.data['isSuccess'] == true) {
        return (response.data['data'] ?? response.data['id'] ?? '').toString();
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to create amenity');
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to create amenity');
    }
  }
  
  @override
  Future<bool> updateAmenity(String amenityId, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.put(
        '$_baseEndpoint/$amenityId',
        data: data,
      );
      return response.data['success'] == true || response.data['isSuccess'] == true;
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to update amenity');
    }
  }
  
  @override
  Future<bool> deleteAmenity(String amenityId) async {
    try {
      final response = await apiClient.delete('$_baseEndpoint/$amenityId');
      return response.data['success'] == true || response.data['isSuccess'] == true;
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to delete amenity');
    }
  }
  
  @override
  Future<bool> assignAmenityToProperty(
    String amenityId,
    String propertyId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await apiClient.post(
        '$_baseEndpoint/$amenityId/assign/property/$propertyId',
        data: data,
      );
      return response.data['success'] == true || response.data['isSuccess'] == true;
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to assign amenity to property');
    }
  }
  
  @override
  Future<List<AmenityModel>> getPropertyAmenities(String propertyId) async {
    try {
      // لا يوجد مسار مباشر لجلب مرافق الكيان
      // نستخدم تفاصيل الكيان والتي تتضمن قائمة amenities
      final response = await apiClient.get('/api/admin/Properties/$propertyId/details', queryParameters: {
        'includeUnits': false,
      });
      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        if ((map['success'] == true || map['isSuccess'] == true) && map['data'] is Map<String, dynamic>) {
          final data = map['data'] as Map<String, dynamic>;
          final List<dynamic> list = (data['amenities'] as List?) ?? const [];
          return list.map((j) => AmenityModel.fromJson(j as Map<String, dynamic>)).toList();
        }
      }
        throw ServerException(response.data['message'] ?? 'Failed to get property amenities');
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to fetch property amenities');
    }
  }
}