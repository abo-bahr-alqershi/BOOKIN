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
  
  // دالة للتحقق من صحة URL
  static String _validateUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://via.placeholder.com/400x300?text=No+Image';
    }
    
    // التحقق من أن URL يبدأ بـ http أو https
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      // إذا كان URL نسبي، أضف البروتوكول والدومين
      if (url.startsWith('/')) {
        // استبدل هذا بـ base URL الخاص بك
        return 'https://your-api-domain.com$url';
      }
      // إذا كان مجرد اسم ملف أو placeholder
      return 'https://via.placeholder.com/400x300?text=$url';
    }
    
    return url;
  }
  
  factory PropertyImageModel.fromJson(Map<String, dynamic> json) {
    // معالجة آمنة للـ tags
    List<String> parsedTags = [];
    if (json['tags'] != null) {
      if (json['tags'] is List) {
        parsedTags = (json['tags'] as List).map((e) => e.toString()).toList();
      } else if (json['tags'] is String) {
        // إذا كان tags عبارة عن string، نحاول تحويله إلى قائمة
        final tagsString = json['tags'] as String;
        if (tagsString.isNotEmpty) {
          // نحاول فصل الـ tags بفاصلة أو مسافة
          parsedTags = tagsString.split(RegExp(r'[,\s]+'))
              .where((tag) => tag.isNotEmpty)
              .toList();
        }
      }
    }
    
    // معالجة آمنة للـ URL
    final url = _validateUrl(json['url'] ?? json['imageUrl']);
    
    return PropertyImageModel(
      id: (json['id'] ?? json['imageId'] ?? DateTime.now().millisecondsSinceEpoch.toString()) as String,
      url: url,
      filename: (json['filename'] ?? json['name'] ?? 'image.jpg') as String,
      size: (json['size'] as num?)?.toInt() ?? 0,
      mimeType: (json['mimeType'] ?? json['type'] ?? 'image/jpeg') as String,
      width: (json['width'] as num?)?.toInt() ?? 0,
      height: (json['height'] as num?)?.toInt() ?? 0,
      alt: json['alt'] as String?,
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.tryParse(json['uploadedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      uploadedBy: (json['uploadedBy'] ?? json['ownerId'] ?? '') as String,
      order: (json['order'] as num?)?.toInt() ?? 0,
      isPrimary: (json['isPrimary'] as bool?) ?? false,
      propertyId: json['propertyId'] as String?,
      category: _parseImageCategory((json['category'] ?? 'gallery').toString()),
      tags: parsedTags,
      processingStatus: _parseProcessingStatus((json['processingStatus'] ?? 'ready').toString()),
      thumbnails: _parseThumbnails(json['thumbnails'], url),
    );
  }
  
  static ImageThumbnails _parseThumbnails(dynamic thumbnailsData, String fallbackUrl) {
    if (thumbnailsData == null) {
      return ImageThumbnailsModel(
        small: fallbackUrl,
        medium: fallbackUrl,
        large: fallbackUrl,
        hd: fallbackUrl,
      );
    }
    
    if (thumbnailsData is Map<String, dynamic>) {
      return ImageThumbnailsModel.fromJson(thumbnailsData, fallbackUrl);
    }
    
    if (thumbnailsData is String) {
      // إذا كانت thumbnails عبارة عن URL واحد، نستخدمه لكل الأحجام
      final validUrl = _validateUrl(thumbnailsData);
      return ImageThumbnailsModel(
        small: validUrl,
        medium: validUrl,
        large: validUrl,
        hd: validUrl,
      );
    }
    
    return ImageThumbnailsModel(
      small: fallbackUrl,
      medium: fallbackUrl,
      large: fallbackUrl,
      hd: fallbackUrl,
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
  
  factory ImageThumbnailsModel.fromJson(Map<String, dynamic> json, [String? fallbackUrl]) {
    final fallback = fallbackUrl ?? 'https://via.placeholder.com/400x300?text=No+Image';
    return ImageThumbnailsModel(
      small: PropertyImageModel._validateUrl(json['small'] ?? json['s'] ?? fallback),
      medium: PropertyImageModel._validateUrl(json['medium'] ?? json['m'] ?? fallback),
      large: PropertyImageModel._validateUrl(json['large'] ?? json['l'] ?? fallback),
      hd: PropertyImageModel._validateUrl(json['hd'] ?? json['xl'] ?? fallback),
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