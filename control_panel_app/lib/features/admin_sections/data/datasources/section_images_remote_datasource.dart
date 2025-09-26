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
    ProgressCallback? onSendProgress,
  });

  Future<List<SectionImageModel>> getImages(String sectionId, {int? page, int? limit});
  Future<bool> updateImage(String imageId, Map<String, dynamic> data);
  Future<bool> deleteImage(String sectionId, String imageId, {bool permanent});
  Future<bool> reorderImages(String sectionId, List<String> imageIds);
  Future<bool> setAsPrimaryImage(String sectionId, String imageId);
}

class SectionImagesRemoteDataSourceImpl implements SectionImagesRemoteDataSource {
  final ApiClient apiClient;
  SectionImagesRemoteDataSourceImpl({required this.apiClient});

  static String _endpoint(String sectionId) => '/api/admin/section-images/$sectionId';

  @override
  Future<SectionImageModel> uploadImage({
    required String sectionId,
    required String filePath,
    String? category,
    String? alt,
    bool isPrimary = false,
    int? order,
    List<String>? tags,
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
        if (posterPath != null) 'videoThumbnail': await MultipartFile.fromFile(posterPath),
      });
      final response = await apiClient.post(
        '${_endpoint(sectionId)}/upload',
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
      final response = await apiClient.get(_endpoint(sectionId), queryParameters: {
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
  Future<bool> deleteImage(String sectionId, String imageId, {bool permanent = false}) async {
    try {
      final response = await apiClient.delete('${_endpoint(sectionId)}/$imageId', queryParameters: {'permanent': permanent});
      return response.statusCode == 204 || (response.data is Map && response.data['success'] == true);
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to delete section image');
    }
  }

  @override
  Future<bool> reorderImages(String sectionId, List<String> imageIds) async {
    try {
      final response = await apiClient.post('${_endpoint(sectionId)}/reorder', data: {'imageIds': imageIds});
      return response.statusCode == 204 || (response.data is Map && response.data['success'] == true);
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to reorder section images');
    }
  }

  @override
  Future<bool> setAsPrimaryImage(String sectionId, String imageId) async {
    try {
      final response = await apiClient.post('${_endpoint(sectionId)}/$imageId/set-primary');
      return response.statusCode == 204 || (response.data is Map && response.data['success'] == true);
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to set primary section image');
    }
  }
}

