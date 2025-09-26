import 'package:equatable/equatable.dart';

enum ImageCategory {
  exterior,
  interior,
  amenity,
  floorPlan,
  documents,
  avatar,
  cover,
  gallery,
  video,
}

enum ProcessingStatus {
  uploading,
  processing,
  ready,
  failed,
  deleted,
}

enum MediaType {
  image,
  video,
}

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
  final ImageCategory category; // keep as string to avoid cross-feature enums
  final ProcessingStatus processingStatus;
  final ImageThumbnails thumbnails;
  final MediaType mediaType; // image or video
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
    this.category = ImageCategory.gallery,
    this.processingStatus = ProcessingStatus.ready,
    required this.thumbnails,
    this.mediaType = MediaType.image,
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

class ImageThumbnails extends Equatable {
  final String small;
  final String medium;
  final String large;
  final String hd;

  const ImageThumbnails({
    required this.small,
    required this.medium,
    required this.large,
    required this.hd,
  });

  @override
  List<Object> get props => [small, medium, large, hd];
}
