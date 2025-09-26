import 'package:equatable/equatable.dart';

class SectionImage extends Equatable {
  final String id;
  final String url;
  final String filename;
  final int size;
  final String mimeType;
  final int width;
  final int height;
  final String? alt;
  final DateTime uploadedAt;
  final String uploadedBy;
  final int order;
  final bool isPrimary;
  final String? propertyId;
  final String? unitId;
  final String? sectionId;
  final String? propertyInSectionId;
  final String? unitInSectionId;
  final List<String> tags;
  final String category; // keep as string to avoid cross-feature enums
  final String processingStatus;
  final SectionImageThumbnails thumbnails;
  final String mediaType; // image or video
  final String? videoThumbnail;
  final int? duration;

  const SectionImage({
    required this.id,
    required this.url,
    required this.filename,
    required this.size,
    required this.mimeType,
    required this.width,
    required this.height,
    this.alt,
    required this.uploadedAt,
    required this.uploadedBy,
    required this.order,
    required this.isPrimary,
    this.propertyId,
    this.unitId,
    this.sectionId,
    this.propertyInSectionId,
    this.unitInSectionId,
    this.tags = const [],
    this.category = 'gallery',
    this.processingStatus = 'ready',
    required this.thumbnails,
    this.mediaType = 'image',
    this.videoThumbnail,
    this.duration,
  });

  @override
  List<Object?> get props => [
        id,
        url,
        filename,
        size,
        mimeType,
        width,
        height,
        alt,
        uploadedAt,
        uploadedBy,
        order,
        isPrimary,
        propertyId,
        unitId,
        sectionId,
        propertyInSectionId,
        unitInSectionId,
        tags,
        category,
        processingStatus,
        thumbnails,
        mediaType,
        videoThumbnail,
        duration,
      ];
}

class SectionImageThumbnails extends Equatable {
  final String small;
  final String medium;
  final String large;
  final String hd;

  const SectionImageThumbnails({
    required this.small,
    required this.medium,
    required this.large,
    required this.hd,
  });

  @override
  List<Object?> get props => [small, medium, large, hd];
}

