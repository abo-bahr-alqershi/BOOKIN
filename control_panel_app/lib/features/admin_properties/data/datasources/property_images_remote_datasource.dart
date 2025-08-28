// lib/features/admin_properties/data/datasources/property_images_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:bookn_cp_app/core/network/api_client.dart';
import 'package:bookn_cp_app/core/error/exceptions.dart';
import '../models/property_image_model.dart';

abstract class PropertyImagesRemoteDataSource {
  Future<PropertyImageModel> uploadImage({
    required String propertyId,
    required String filePath,
    String? category,
    String? alt,
    bool isPrimary = false,
    int? order,
    List<String>? tags,
  });
  
  Future<List<PropertyImageModel>> getPropertyImages(String propertyId);
  Future<bool> updateImage(String imageId, Map<String, dynamic> data);
  Future<bool> deleteImage(String imageId);
  Future<bool> reorderImages(String propertyId, List<String> imageIds);
  Future<bool> setAsPrimaryImage(String propertyId, String imageId);
}

class PropertyImagesRemoteDataSourceImpl implements PropertyImagesRemoteDataSource {
  final ApiClient apiClient;
  static const String _baseEndpoint = '/api/admin/properties';
  
  PropertyImagesRemoteDataSourceImpl({required this.apiClient});
  
  @override
  Future<PropertyImageModel> uploadImage({
    required String propertyId,
    required String filePath,
    String? category,
    String? alt,
    bool isPrimary = false,
    int? order,
    List<String>? tags,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        'propertyId': propertyId,
        if (category != null) 'category': category,
        if (alt != null) 'alt': alt,
        'isPrimary': isPrimary,
        if (order != null) 'order': order,
        if (tags != null && tags.isNotEmpty) 'tags': tags.join(','),
      });
      
      final response = await apiClient.post(
        '$_baseEndpoint/$propertyId/images/upload',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      
      if (response.data['success'] == true) {
        return PropertyImageModel.fromJson(response.data['data']);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to upload image');
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to upload image');
    }
  }
  
  @override
  Future<List<PropertyImageModel>> getPropertyImages(String propertyId) async {
    try {
      final response = await apiClient.get('$_baseEndpoint/$propertyId/images');
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => PropertyImageModel.fromJson(json)).toList();
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to get property images');
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to fetch property images');
    }
  }
  
  @override
  Future<bool> updateImage(String imageId, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.put(
        '/api/admin/images/$imageId',
        data: data,
      );
      
      return response.data['success'] == true;
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to update image');
    }
  }
  
  @override
  Future<bool> deleteImage(String imageId) async {
    try {
      final response = await apiClient.delete('/api/admin/images/$imageId');
      return response.data['success'] == true;
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to delete image');
    }
  }
  
  @override
  Future<bool> reorderImages(String propertyId, List<String> imageIds) async {
    try {
      final response = await apiClient.post(
        '$_baseEndpoint/$propertyId/images/reorder',
        data: {'imageIds': imageIds},
      );
      
      return response.data['success'] == true;
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to reorder images');
    }
  }
  
  @override
  Future<bool> setAsPrimaryImage(String propertyId, String imageId) async {
    try {
      final response = await apiClient.post(
        '$_baseEndpoint/$propertyId/images/$imageId/set-primary',
      );
      
      return response.data['success'] == true;
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to set primary image');
    }
  }
}