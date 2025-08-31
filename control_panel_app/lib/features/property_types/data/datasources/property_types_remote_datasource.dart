import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/models/paginated_result.dart';
import '../../../../core/models/result_dto.dart';
import '../../../../core/network/api_client.dart';
import '../models/property_type_model.dart';

abstract class PropertyTypesRemoteDataSource {
  Future<PaginatedResult<PropertyTypeModel>> getAllPropertyTypes({
    required int pageNumber,
    required int pageSize,
  });
  
  Future<PropertyTypeModel> getPropertyTypeById(String id);
  
  Future<String> createPropertyType({
    required String name,
    required String description,
    required String defaultAmenities,
    required String icon,
  });
  
  Future<bool> updatePropertyType({
    required String propertyTypeId,
    required String name,
    required String description,
    required String defaultAmenities,
    required String icon,
  });
  
  Future<bool> deletePropertyType(String propertyTypeId);
}

class PropertyTypesRemoteDataSourceImpl implements PropertyTypesRemoteDataSource {
  final ApiClient apiClient;
  static const String _baseEndpoint = '${ApiConstants.baseUrl}/api/admin/property-types';

  PropertyTypesRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<PaginatedResult<PropertyTypeModel>> getAllPropertyTypes({
    required int pageNumber,
    required int pageSize,
  }) async {
    try {
      final response = await apiClient.get(
        _baseEndpoint,
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );
      // The backend may return either a bare paginated object or an envelope { success, data, ... }
      dynamic body = response.data;
      if (body is Map<String, dynamic> && body.containsKey('success')) {
        final result = ResultDto<Map<String, dynamic>>.fromJson(body, (j) => j);
        if (!result.isSuccess || result.data == null) {
          throw ServerException(result.message ?? 'Failed to fetch property types');
        }
        body = result.data;
      }

      if (body is Map<String, dynamic>) {
        return PaginatedResult<PropertyTypeModel>.fromJson(
          body,
          (json) => PropertyTypeModel.fromJson(json as Map<String, dynamic>),
        );
      }

      if (body is List) {
        // Fallback: list without pagination
        final items = body
            .map<PropertyTypeModel>((e) => e is Map<String, dynamic>
                ? PropertyTypeModel.fromJson(e)
                : PropertyTypeModel(
                    id: '',
                    name: e?.toString() ?? '',
                    description: '',
                    defaultAmenities: '',
                    icon: 'home',
                  ))
            .toList();
        return PaginatedResult<PropertyTypeModel>(
          items: items,
          pageNumber: pageNumber,
          pageSize: pageSize,
          totalCount: items.length,
        );
      }

      throw ServerException('Unexpected response format for property types');
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Server error occurred');
    }
  }

  @override
  Future<PropertyTypeModel> getPropertyTypeById(String id) async {
    try {
      final response = await apiClient.get('$_baseEndpoint/$id');
      final result = ResultDto.fromJson(response.data, null);
      
      if (result.isSuccess && result.data != null) {
        return PropertyTypeModel.fromJson(result.data);
      } else {
        throw ServerException(result.message ?? 'Failed to get property type');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Server error occurred');
    }
  }

  @override
  Future<String> createPropertyType({
    required String name,
    required String description,
    required String defaultAmenities,
    required String icon,
  }) async {
    try {
      final response = await apiClient.post(
        _baseEndpoint,
        data: {
          'name': name,
          'description': description,
          'defaultAmenities': defaultAmenities,
          'icon': icon,
        },
      );
      
      final result = ResultDto.fromJson(response.data, null);
      
      if (result.isSuccess && result.data != null) {
        return result.data as String;
      } else {
        throw ServerException(result.message ?? 'Failed to create property type');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Server error occurred');
    }
  }

  @override
  Future<bool> updatePropertyType({
    required String propertyTypeId,
    required String name,
    required String description,
    required String defaultAmenities,
    required String icon,
  }) async {
    try {
      final response = await apiClient.put(
        '$_baseEndpoint/$propertyTypeId',
        data: {
          'propertyTypeId': propertyTypeId,
          'name': name,
          'description': description,
          'defaultAmenities': defaultAmenities,
          'icon': icon,
        },
      );
      
      final result = ResultDto.fromJson(response.data, null);
      return result.isSuccess;
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Server error occurred');
    }
  }

  @override
  Future<bool> deletePropertyType(String propertyTypeId) async {
    try {
      final response = await apiClient.delete('$_baseEndpoint/$propertyTypeId');
      final result = ResultDto.fromJson(response.data, null);
      return result.isSuccess;
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Server error occurred');
    }
  }
}