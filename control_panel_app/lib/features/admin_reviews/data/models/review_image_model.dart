// lib/features/admin_reviews/data/models/review_image_model.dart

import 'package:bookn_cp_app/features/admin_reviews/domain/entities/review_image.dart';

class ReviewImageModel extends ReviewImage {
  const ReviewImageModel({
    required super.id,
    required super.reviewId,
    required super.name,
    required super.url,
    required super.sizeBytes,
    required super.type,
    required super.category,
    required super.caption,
    required super.altText,
    required super.uploadedAt,
  });
  
  factory ReviewImageModel.fromJson(Map<String, dynamic> json) {
    return ReviewImageModel(
      id: json['id'] as String,
      reviewId: json['reviewId'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      sizeBytes: json['sizeBytes'] as int,
      type: json['type'] as String,
      category: _parseCategory(json['category']),
      caption: json['caption'] as String,
      altText: json['altText'] as String,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
    );
  }
  
  static ImageCategory _parseCategory(dynamic value) {
    if (value is int) {
      switch (value) {
        case 0: return ImageCategory.exterior;
        case 1: return ImageCategory.interior;
        case 2: return ImageCategory.room;
        case 3: return ImageCategory.facility;
        default: return ImageCategory.room;
      }
    }
    return ImageCategory.room;
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reviewId': reviewId,
      'name': name,
      'url': url,
      'sizeBytes': sizeBytes,
      'type': type,
      'category': category.index,
      'caption': caption,
      'altText': altText,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }
}