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
  static const String _imagesEndpoint = '/api/images';
  
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
        '$_imagesEndpoint/upload',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      
      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        if (map['success'] == true && map['image'] != null) {
          return PropertyImageModel.fromJson(map['image']);
        }
        // بعض البيئات قد ترجع تحت data
        if (map['success'] == true && map['data'] != null) {
          final data = map['data'];
          if (data is Map<String, dynamic> && data.containsKey('url')) {
            return PropertyImageModel.fromJson(data);
          }
        }
      }
      throw ServerException(response.data['message'] ?? 'Failed to upload image');
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to upload image');
    }
  }
  
  @override
  Future<List<PropertyImageModel>> getPropertyImages(String propertyId) async {
    try {
      final response = await apiClient.get('$_imagesEndpoint', queryParameters: {
        'propertyId': propertyId,
      });
      
      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        final List<dynamic> list = (map['images'] as List?) ?? (map['items'] as List?) ?? const [];
        return list.map((json) => PropertyImageModel.fromJson(json)).toList();
      }
      throw ServerException('Invalid response when fetching images');
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to fetch property images');
    }
  }
  
  @override
  Future<bool> updateImage(String imageId, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.put(
        '$_imagesEndpoint/$imageId',
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
      final response = await apiClient.delete('$_imagesEndpoint/$imageId');
      return response.data['success'] == true;
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to delete image');
    }
  }
  
  @override
  Future<bool> reorderImages(String propertyId, List<String> imageIds) async {
    try {
      // لا يوجد مسار لإعادة الترتيب دفعة واحدة في الـ backend الحالي.
      // نقوم بتطبيق الترتيب عبر تحديث كل صورة على حدة.
      int order = 0;
      for (final id in imageIds) {
        await apiClient.put(
          '$_imagesEndpoint/$id',
          data: {'order': order},
        );
        order++;
      }
      return true;
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to reorder images');
    }
  }
  
  @override
  Future<bool> setAsPrimaryImage(String propertyId, String imageId) async {
    try {
      // لا يوجد مسار صريح لتعيين الرئيسية؛ سنقوم بالتحديث المباشر للصورة
      final response = await apiClient.put(
        '$_imagesEndpoint/$imageId',
        data: {'isPrimary': true, 'propertyId': propertyId},
      );
      return response.data['success'] == true;
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to set primary image');
    }
  }
}