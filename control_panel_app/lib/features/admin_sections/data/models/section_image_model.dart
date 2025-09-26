import '../../domain/entities/section_image.dart';

class SectionImageModel extends SectionImage {
  const SectionImageModel({
    required super.id,
    required super.url,
    required super.filename,
    required super.size,
    required super.mimeType,
    required super.width,
    required super.height,
    super.alt,
    required super.uploadedAt,
    required super.uploadedBy,
    required super.order,
    required super.isPrimary,
    super.propertyId,
    super.unitId,
    super.sectionId,
    super.propertyInSectionId,
    super.unitInSectionId,
    super.tags = const [],
    super.category = 'gallery',
    super.processingStatus = 'ready',
    required super.thumbnails,
    super.mediaType = 'image',
    super.videoThumbnail,
    super.duration,
  });

  factory SectionImageModel.fromJson(Map<String, dynamic> json) {
    return SectionImageModel(
      id: (json['id'] ?? json['imageId'] ?? '').toString(),
      url: (json['url'] ?? json['imageUrl'] ?? '').toString(),
      filename: (json['filename'] ?? json['name'] ?? 'image.jpg').toString(),
      size: (json['size'] as num?)?.toInt() ?? 0,
      mimeType: (json['mimeType'] ?? json['type'] ?? 'image/jpeg').toString(),
      width: (json['width'] as num?)?.toInt() ?? 0,
      height: (json['height'] as num?)?.toInt() ?? 0,
      alt: json['alt']?.toString(),
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.tryParse(json['uploadedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      uploadedBy: (json['uploadedBy'] ?? '').toString(),
      order: (json['order'] as num?)?.toInt() ?? 0,
      isPrimary: json['isPrimary'] == true || json['isMain'] == true,
      propertyId: json['propertyId']?.toString(),
      unitId: json['unitId']?.toString(),
      sectionId: json['sectionId']?.toString(),
      propertyInSectionId: json['propertyInSectionId']?.toString(),
      unitInSectionId: json['unitInSectionId']?.toString(),
      tags: (json['tags'] is List)
          ? (json['tags'] as List).map((e) => e.toString()).toList()
          : <String>[],
      category: (json['category'] ?? 'gallery').toString(),
      processingStatus: (json['processingStatus'] ?? 'ready').toString(),
      thumbnails: SectionImageThumbnailsModel.fromJson(
          (json['thumbnails'] as Map?)?.cast<String, dynamic>() ?? {}),
      mediaType: (json['mediaType'] ?? 'image').toString(),
      videoThumbnail: json['videoThumbnail']?.toString(),
      duration: (json['duration'] as num?)?.toInt(),
    );
  }
}

class SectionImageThumbnailsModel extends SectionImageThumbnails {
  const SectionImageThumbnailsModel({
    required super.small,
    required super.medium,
    required super.large,
    required super.hd,
  });

  factory SectionImageThumbnailsModel.fromJson(Map<String, dynamic> json) {
    final fallback = (json['medium'] ?? json['small'] ?? json['large'] ?? '').toString();
    return SectionImageThumbnailsModel(
      small: (json['small'] ?? fallback).toString(),
      medium: (json['medium'] ?? fallback).toString(),
      large: (json['large'] ?? fallback).toString(),
      hd: (json['hd'] ?? json['large'] ?? fallback).toString(),
    );
  }
}