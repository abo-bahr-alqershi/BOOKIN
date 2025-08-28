// lib/features/admin_properties/data/models/property_image_model.dart

import '../../domain/entities/property_image.dart';

class PropertyImageModel extends PropertyImage {
  const PropertyImageModel({
    required String id,
    required String url,
    required String filename,
    required int size,
    required String mimeType,
    required int width,
    required int height,
    String? alt,
    required DateTime uploadedAt,
    required String uploadedBy,
    required int order,
    required bool isPrimary,
    String? propertyId,
    required ImageCategory category,
    List<String> tags = const [],
    required ProcessingStatus processingStatus,
    required ImageThumbnails thumbnails,
  }) : super(
    id: id,
    url: url,
    filename: filename,
    size: size,
    mimeType: mimeType,
    width: width,
    height: height,
    alt: alt,
    uploadedAt: uploadedAt,
    uploadedBy: uploadedBy,
    order: order,
    isPrimary: isPrimary,
    propertyId: propertyId,
    category: category,
    tags: tags,
    processingStatus: processingStatus,
    thumbnails: thumbnails,
  );
  
  factory PropertyImageModel.fromJson(Map<String, dynamic> json) {
    return PropertyImageModel(
      id: json['id'] as String,
      url: json['url'] as String,
      filename: json['filename'] as String,
      size: json['size'] as int,
      mimeType: json['mimeType'] as String,
      width: json['width'] as int,
      height: json['height'] as int,
      alt: json['alt'] as String?,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      uploadedBy: json['uploadedBy'] as String,
      order: json['order'] as int,
      isPrimary: json['isPrimary'] as bool,
      propertyId: json['propertyId'] as String?,
      category: _parseImageCategory(json['category']),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      processingStatus: _parseProcessingStatus(json['processingStatus']),
      thumbnails: ImageThumbnailsModel.fromJson(json['thumbnails']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'filename': filename,
      'size': size,
      'mimeType': mimeType,
      'width': width,
      'height': height,
      'alt': alt,
      'uploadedAt': uploadedAt.toIso8601String(),
      'uploadedBy': uploadedBy,
      'order': order,
      'isPrimary': isPrimary,
      'propertyId': propertyId,
      'category': _imageCategoryToString(category),
      'tags': tags,
      'processingStatus': _processingStatusToString(processingStatus),
      'thumbnails': (thumbnails as ImageThumbnailsModel).toJson(),
    };
  }
  
  static ImageCategory _parseImageCategory(String value) {
    switch (value.toLowerCase()) {
      case 'exterior':
        return ImageCategory.exterior;
      case 'interior':
        return ImageCategory.interior;
      case 'amenity':
        return ImageCategory.amenity;
      case 'floor_plan':
      case 'floorplan':
        return ImageCategory.floorPlan;
      case 'documents':
        return ImageCategory.documents;
      case 'avatar':
        return ImageCategory.avatar;
      case 'cover':
        return ImageCategory.cover;
      default:
        return ImageCategory.gallery;
    }
  }
  
  static String _imageCategoryToString(ImageCategory category) {
    switch (category) {
      case ImageCategory.exterior:
        return 'exterior';
      case ImageCategory.interior:
        return 'interior';
      case ImageCategory.amenity:
        return 'amenity';
      case ImageCategory.floorPlan:
        return 'floor_plan';
      case ImageCategory.documents:
        return 'documents';
      case ImageCategory.avatar:
        return 'avatar';
      case ImageCategory.cover:
        return 'cover';
      case ImageCategory.gallery:
        return 'gallery';
    }
  }
  
  static ProcessingStatus _parseProcessingStatus(String value) {
    switch (value.toLowerCase()) {
      case 'uploading':
        return ProcessingStatus.uploading;
      case 'processing':
        return ProcessingStatus.processing;
      case 'ready':
        return ProcessingStatus.ready;
      case 'failed':
        return ProcessingStatus.failed;
      case 'deleted':
        return ProcessingStatus.deleted;
      default:
        return ProcessingStatus.processing;
    }
  }
  
  static String _processingStatusToString(ProcessingStatus status) {
    switch (status) {
      case ProcessingStatus.uploading:
        return 'uploading';
      case ProcessingStatus.processing:
        return 'processing';
      case ProcessingStatus.ready:
        return 'ready';
      case ProcessingStatus.failed:
        return 'failed';
      case ProcessingStatus.deleted:
        return 'deleted';
    }
  }
}

class ImageThumbnailsModel extends ImageThumbnails {
  const ImageThumbnailsModel({
    required String small,
    required String medium,
    required String large,
    required String hd,
  }) : super(
    small: small,
    medium: medium,
    large: large,
    hd: hd,
  );
  
  factory ImageThumbnailsModel.fromJson(Map<String, dynamic> json) {
    return ImageThumbnailsModel(
      small: json['small'] as String,
      medium: json['medium'] as String,
      large: json['large'] as String,
      hd: json['hd'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'small': small,
      'medium': medium,
      'large': large,
      'hd': hd,
    };
  }
}