// lib/features/admin_properties/domain/entities/property_image.dart

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
}

enum ProcessingStatus {
  uploading,
  processing,
  ready,
  failed,
  deleted,
}

class PropertyImage extends Equatable {
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
  final ImageCategory category;
  final List<String> tags;
  final ProcessingStatus processingStatus;
  final ImageThumbnails thumbnails;
  
  const PropertyImage({
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
    required this.category,
    this.tags = const [],
    required this.processingStatus,
    required this.thumbnails,
  });
  
  bool get isReady => processingStatus == ProcessingStatus.ready;
  String get sizeInMB => (size / (1024 * 1024)).toStringAsFixed(2);
  
  @override
  List<Object?> get props => [
    id, url, filename, size, mimeType, width, height,
    alt, uploadedAt, uploadedBy, order, isPrimary,
    propertyId, category, tags, processingStatus, thumbnails,
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