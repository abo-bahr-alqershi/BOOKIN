// lib/features/admin_reviews/data/datasources/reviews_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:bookn_cp_app/core/network/api_client.dart';
import 'package:bookn_cp_app/core/error/exceptions.dart';
import '../models/review_model.dart';
import '../models/review_response_model.dart';

abstract class ReviewsRemoteDataSource {
  Future<List<ReviewModel>> getAllReviews({
    String? status,
    double? minRating,
    double? maxRating,
    bool? hasImages,
    String? propertyId,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    int? pageNumber,
    int? pageSize,
  });
  
  Future<ReviewModel> getReviewDetails(String reviewId);
  Future<bool> approveReview(String reviewId);
  Future<bool> rejectReview(String reviewId);
  Future<bool> deleteReview(String reviewId);
  Future<ReviewResponseModel> respondToReview({
    required String reviewId,
    required String responseText,
    required String respondedBy,
  });
  Future<List<ReviewResponseModel>> getReviewResponses(String reviewId);
  Future<bool> deleteReviewResponse(String responseId);
}

class ReviewsRemoteDataSourceImpl implements ReviewsRemoteDataSource {
  final ApiClient apiClient;
  
  ReviewsRemoteDataSourceImpl({required this.apiClient});
  
  @override
  Future<List<ReviewModel>> getAllReviews({
    String? status,
    double? minRating,
    double? maxRating,
    bool? hasImages,
    String? propertyId,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    int? pageNumber,
    int? pageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (status != null) queryParams['status'] = status;
      if (minRating != null) queryParams['minRating'] = minRating;
      if (maxRating != null) queryParams['maxRating'] = maxRating;
      if (hasImages != null) queryParams['hasImages'] = hasImages;
      if (propertyId != null) queryParams['propertyId'] = propertyId;
      if (userId != null) queryParams['userId'] = userId;
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
      if (pageNumber != null) queryParams['pageNumber'] = pageNumber;
      if (pageSize != null) queryParams['pageSize'] = pageSize;
      
      final response = await apiClient.get(
        '/api/admin/reviews',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => ReviewModel.fromJson(json)).toList();
      }
      throw ServerException('Failed to load reviews');
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error occurred');
    }
  }
  
  @override
  Future<ReviewModel> getReviewDetails(String reviewId) async {
    try {
      final response = await apiClient.get('/api/admin/reviews/$reviewId');
      
      if (response.statusCode == 200) {
        return ReviewModel.fromJson(response.data['data']);
      }
      throw ServerException('Failed to load review details');
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error occurred');
    }
  }
  
  @override
  Future<bool> approveReview(String reviewId) async {
    try {
      final response = await apiClient.post(
        '/api/admin/reviews/$reviewId/approve',
      );
      
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to approve review');
    }
  }
  
  @override
  Future<bool> rejectReview(String reviewId) async {
    try {
      final response = await apiClient.post(
        '/api/admin/reviews/$reviewId/reject',
      );
      
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to reject review');
    }
  }
  
  @override
  Future<bool> deleteReview(String reviewId) async {
    try {
      final response = await apiClient.delete('/api/admin/reviews/$reviewId');
      
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete review');
    }
  }
  
  @override
  Future<ReviewResponseModel> respondToReview({
    required String reviewId,
    required String responseText,
    required String respondedBy,
  }) async {
    try {
      final response = await apiClient.post(
        '/api/admin/reviews/$reviewId/respond',
        data: {
          'responseText': responseText,
          'ownerId': respondedBy,
        },
      );
      
      if (response.statusCode == 200) {
        return ReviewResponseModel.fromJson(response.data['data']);
      }
      throw ServerException('Failed to add response');
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to respond to review');
    }
  }
  
  @override
  Future<List<ReviewResponseModel>> getReviewResponses(String reviewId) async {
    try {
      final response = await apiClient.get(
        '/api/admin/reviews/$reviewId/responses',
      );
      
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => ReviewResponseModel.fromJson(json)).toList();
      }
      throw ServerException('Failed to load responses');
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error occurred');
    }
  }
  
  @override
  Future<bool> deleteReviewResponse(String responseId) async {
    try {
      final response = await apiClient.delete(
        '/api/admin/reviews/responses/$responseId',
      );
      
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete response');
    }
  }
}