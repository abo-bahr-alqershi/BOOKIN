import 'package:dio/dio.dart';
import 'package:bookn_cp_app/core/network/api_client.dart';
import 'package:bookn_cp_app/core/error/exceptions.dart';
import 'package:bookn_cp_app/core/constants/app_constants.dart';
import 'package:bookn_cp_app/core/utils/video_utils.dart';
import '../models/section_image_model.dart';

abstract class SectionImagesRemoteDataSource {
  Future<SectionImageModel> uploadImage({
    required String sectionId,
    required String filePath,
    String? category,
    String? alt,
    bool isPrimary,
    int? order,
    List<String>? tags,
    String? tempKey,
    ProgressCallback? onSendProgress,
  });

  Future<List<SectionImageModel>> getImages(String sectionId, {int? page, int? limit});
  Future<List<SectionImageModel>> getImagesByTempKey(String tempKey, {int? page, int? limit});
  Future<bool> updateImage(String imageId, Map<String, dynamic> data);
  Future<bool> deleteImage(String imageId, {bool permanent});
  Future<bool> reorderImages(List<String> imageIds, {String? tempKey});
  Future<bool> setAsPrimaryImage(String imageId, {String? tempKey});
}

class SectionImagesRemoteDataSourceImpl implements SectionImagesRemoteDataSource {
  final ApiClient apiClient;
  SectionImagesRemoteDataSourceImpl({required this.apiClient});

  static const String _imagesEndpoint = '/api/images';

  @override
  Future<SectionImageModel> uploadImage({
    required String sectionId,
    required String filePath,
    String? category,
    String? alt,
    bool isPrimary = false,
    int? order,
    List<String>? tags,
    String? tempKey,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      String? posterPath;
      if (AppConstants.isVideoFile(filePath)) {
        posterPath = await VideoUtils.generateVideoThumbnail(filePath);
      }
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        if (category != null) 'category': category,
        if (alt != null) 'alt': alt,
        'isPrimary': isPrimary,
        if (order != null) 'order': order,
        if (tags != null && tags.isNotEmpty) 'tags': tags.join(','),
        if (tempKey != null) 'tempKey': tempKey,
        if (sectionId.isNotEmpty) 'sectionId': sectionId,
        if (posterPath != null) 'videoThumbnail': await MultipartFile.fromFile(posterPath),
      });
      final response = await apiClient.post(
        '$_imagesEndpoint/upload',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
        onSendProgress: onSendProgress,
      );
      final data = response.data is Map<String, dynamic> ? response.data : null;
      if (data != null) {
        final payload = data['data'] ?? data['image'] ?? data;
        return SectionImageModel.fromJson(Map<String, dynamic>.from(payload));
      }
      throw ServerException('Invalid response');
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to upload section image');
    }
  }

  @override
  Future<List<SectionImageModel>> getImages(String sectionId, {int? page, int? limit}) async {
    try {
      final response = await apiClient.get(_imagesEndpoint, queryParameters: {
        'sectionId': sectionId,
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      });
      final data = response.data is Map<String, dynamic> ? response.data : null;
      if (data != null) {
        final items = (data['items'] as List?) ?? (data['images'] as List?) ?? const [];
        return items.map((e) => SectionImageModel.fromJson(Map<String, dynamic>.from(e))).toList();
      }
      throw ServerException('Invalid response');
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to load section images');
    }
  }

  @override
  Future<List<SectionImageModel>> getImagesByTempKey(String tempKey, {int? page, int? limit}) async {
    try {
      final response = await apiClient.get(_imagesEndpoint, queryParameters: {
        'tempKey': tempKey,
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      });
      final data = response.data is Map<String, dynamic> ? response.data : null;
      if (data != null) {
        final items = (data['items'] as List?) ?? (data['images'] as List?) ?? const [];
        return items.map((e) => SectionImageModel.fromJson(Map<String, dynamic>.from(e))).toList();
      }
      throw ServerException('Invalid response');
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to load section images');
    }
  }

  @override
  Future<bool> updateImage(String imageId, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.put('/api/images/$imageId', data: data);
      return response.data is Map && (response.data['success'] == true || response.statusCode == 200);
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to update section image');
    }
  }

  @override
  Future<bool> deleteImage(String imageId, {bool permanent = false}) async {
    try {
      final response = await apiClient.delete('/api/images/$imageId', queryParameters: {'permanent': permanent});
      return response.statusCode == 204 || (response.data is Map && response.data['success'] == true);
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to delete section image');
    }
  }

  @override
  Future<bool> reorderImages(List<String> imageIds, {String? tempKey}) async {
    try {
      final payload = {
        'imageIds': imageIds,
        if (tempKey != null) 'tempKey': tempKey,
      };
      final response = await apiClient.post('$_imagesEndpoint/reorder', data: payload);
      return response.statusCode == 204 || (response.data is Map && response.data['success'] == true);
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to reorder section images');
    }
  }

  @override
  Future<bool> setAsPrimaryImage(String imageId, {String? tempKey}) async {
    try {
      final body = {
        if (tempKey != null) 'tempKey': tempKey,
      };
      final response = await apiClient.post('$_imagesEndpoint/$imageId/set-primary', data: body);
      return response.statusCode == 204 || (response.data is Map && response.data['success'] == true);
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to set primary section image');
    }
  }
}

