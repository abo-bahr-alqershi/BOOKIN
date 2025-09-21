import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/models/paginated_result.dart';
import '../models/amenity_model.dart';

abstract class AmenitiesRemoteDataSource {
  Future<String> createAmenity({
    required String name,
    required String description,
    required String icon,
  });

  Future<bool> updateAmenity({
    required String amenityId,
    String? name,
    String? description,
    String? icon,
  });

  Future<bool> deleteAmenity(String amenityId);

  Future<PaginatedResult<AmenityModel>> getAllAmenities({
    int? pageNumber,
    int? pageSize,
    String? searchTerm,
    String? propertyId,
    bool? isAssigned,
    bool? isFree,
  });

  Future<bool> assignAmenityToProperty({
    required String amenityId,
    required String propertyId,
    bool isAvailable = true,
    double? extraCost,
    String? description,
  });

  Future<AmenityStatsModel> getAmenityStats();

  Future<bool> toggleAmenityStatus(String amenityId);

  Future<List<AmenityModel>> getPopularAmenities({int limit = 10});
}

class AmenitiesRemoteDataSourceImpl implements AmenitiesRemoteDataSource {
  final ApiClient apiClient;
  static const String _baseEndpoint = '/api/admin/amenities';

  AmenitiesRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<String> createAmenity({
    required String name,
    required String description,
    required String icon,
  }) async {
    try {
      final response = await apiClient.post(
        _baseEndpoint,
        data: {
          'name': name,
          'description': description,
          'icon': icon,
        },
      );

      if (response.data['isSuccess'] == true || response.data['success'] == true) {
        return (response.data['data'] ?? response.data['id'] ?? '').toString();
      } else {
        throw ServerException(
           response.data['message'] ?? 'Failed to create amenity',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
         e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  @override
  Future<bool> updateAmenity({
    required String amenityId,
    String? name,
    String? description,
    String? icon,
  }) async {
    try {
      final response = await apiClient.put(
        '$_baseEndpoint/$amenityId',
        data: {
          if (name != null) 'name': name,
          if (description != null) 'description': description,
          if (icon != null) 'icon': icon,
        },
      );

      if (response.data['isSuccess'] == true || response.data['success'] == true) {
        return true;
      } else {
        throw ServerException(
           response.data['message'] ?? 'Failed to update amenity',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
         e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  @override
  Future<bool> deleteAmenity(String amenityId) async {
    try {
      final response = await apiClient.delete('$_baseEndpoint/$amenityId');

      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        if (map['isSuccess'] == true || map['success'] == true) return true;
        // Surface backend reason on conflict
        if (response.statusCode == 409 || map['errorCode'] == 'AMENITY_DELETE_CONFLICT') {
          throw ServerException(map['message'] ?? 'Deletion conflict');
        }
      }
      if (response.statusCode == 200 || response.statusCode == 204) return true;
      throw ServerException(response.data['message'] ?? 'Failed to delete amenity');
    } on DioException catch (e) {
      final data = e.response?.data;
      if (e.response?.statusCode == 409 && data is Map<String, dynamic>) {
        throw ServerException(data['message'] ?? 'Deletion conflict');
      }
      throw ServerException(e.response?.data['message'] ?? 'Network error occurred');
    }
  }

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
      final queryParams = <String, dynamic>{};
      if (pageNumber != null) queryParams['pageNumber'] = pageNumber;
      if (pageSize != null) queryParams['pageSize'] = pageSize;
      if (searchTerm != null && searchTerm.isNotEmpty) {
        queryParams['searchTerm'] = searchTerm;
      }
      if (propertyId != null) queryParams['propertyId'] = propertyId;
      if (isAssigned != null) queryParams['isAssigned'] = isAssigned;
      if (isFree != null) queryParams['isFree'] = isFree;

      final response = await apiClient.get(
        _baseEndpoint,
        queryParameters: queryParams,
      );

      if (response.data != null) {
        final root = response.data['items'] == null && response.data['data'] is Map
            ? response.data['data']
            : response.data;
        final items = (root['items'] as List? ?? [])
            .map((json) => AmenityModel.fromJson(json))
            .toList();

        return PaginatedResult<AmenityModel>(
          items: items,
          totalCount: root['totalCount'] ?? items.length,
          pageNumber: root['pageNumber'] ?? 1,
          pageSize: root['pageSize'] ?? items.length,
        );
      } else {
        throw const ServerException( 'Invalid response format');
      }
    } on DioException catch (e) {
      throw ServerException(
         e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  @override
  Future<bool> assignAmenityToProperty({
    required String amenityId,
    required String propertyId,
    bool isAvailable = true,
    double? extraCost,
    String? description,
  }) async {
    try {
      final response = await apiClient.post(
        '$_baseEndpoint/$amenityId/assign/property/$propertyId',
        data: {
          'isAvailable': isAvailable,
          if (extraCost != null) 'extraCost': extraCost,
          if (description != null) 'description': description,
        },
      );

      if (response.data['isSuccess'] == true) {
        return true;
      } else {
        throw ServerException(
           response.data['message'] ?? 'Failed to assign amenity',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
         e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  @override
  Future<AmenityStatsModel> getAmenityStats() async {
    try {
      final response = await apiClient.get('$_baseEndpoint/stats');

      if (response.data['isSuccess'] == true || response.data['success'] == true) {
        return AmenityStatsModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
           response.data['message'] ?? 'Failed to get stats',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
         e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  @override
  Future<bool> toggleAmenityStatus(String amenityId) async {
    try {
      final response = await apiClient.post(
        '$_baseEndpoint/$amenityId/toggle-status',
      );

      if (response.data['isSuccess'] == true || response.data['success'] == true) {
        return true;
      } else {
        throw ServerException(
           response.data['message'] ?? 'Failed to toggle status',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
         e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  @override
  Future<List<AmenityModel>> getPopularAmenities({int limit = 10}) async {
    try {
      final response = await apiClient.get(
        '$_baseEndpoint/popular',
        queryParameters: {'limit': limit},
      );

      if (response.data['isSuccess'] == true || response.data['success'] == true) {
        return (response.data['data'] as List? ?? [])
            .map((json) => AmenityModel.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          
              response.data['message'] ?? 'Failed to get popular amenities',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
         e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }
}