// lib/features/admin_reviews/data/datasources/reviews_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:bookn_cp_app/core/network/api_client.dart';
import 'package:bookn_cp_app/core/error/exceptions.dart';
import 'package:bookn_cp_app/services/local_storage_service.dart';
import 'package:bookn_cp_app/core/constants/storage_constants.dart';
import '../models/review_model.dart';
import '../models/review_response_model.dart';

abstract class ReviewsRemoteDataSource {
  Future<List<ReviewModel>> getAllReviews({
    String? status,
    double? minRating,
    double? maxRating,
    bool? hasImages,
    String? propertyId,
    String? unitId,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    int? pageNumber,
    int? pageSize,
  });
  
  // Not available in backend; kept for interface compatibility but unused
  Future<ReviewModel> getReviewDetails(String reviewId);
  Future<bool> approveReview(String reviewId);
  // Currently not supported by backend (no endpoint). Keep for future.
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
  final LocalStorageService localStorage;
  
  ReviewsRemoteDataSourceImpl({required this.apiClient, required this.localStorage});
  
  @override
  Future<List<ReviewModel>> getAllReviews({
    String? status,
    double? minRating,
    double? maxRating,
    bool? hasImages,
    String? propertyId,
    String? unitId,
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
      if (unitId != null) queryParams['unitId'] = unitId;
      if (userId != null) queryParams['userId'] = userId;
      // Align with backend query contract: ReviewedAfter/ReviewedBefore
      if (startDate != null) queryParams['reviewedAfter'] = startDate.toIso8601String();
      if (endDate != null) queryParams['reviewedBefore'] = endDate.toIso8601String();
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
    // Not supported by backend; use repository cache fallback.
    throw ServerException('Get review details is not supported by backend');
  }
  
  @override
  Future<bool> approveReview(String reviewId) async {
    try {
      final String? adminId = localStorage.getData(StorageConstants.userId)?.toString();
      if (adminId == null || adminId.isEmpty) {
        throw ServerException('AdminId is missing');
      }
      final response = await apiClient.post(
        '/api/admin/reviews/$reviewId/approve',
        data: {
          // Matches ApproveReviewCommand AdminId
          'adminId': adminId,
        },
      );
      
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to approve review');
    }
  }
  
  @override
  Future<bool> rejectReview(String reviewId) async {
    // Not supported by backend as of now
    throw ServerException('Reject review is not supported by backend');
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
          // Matches RespondToReviewCommand fields
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