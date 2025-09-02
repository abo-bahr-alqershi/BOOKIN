// lib/features/admin_properties/presentation/bloc/property_images/property_images_event.dart

import 'package:equatable/equatable.dart';

abstract class PropertyImagesEvent extends Equatable {
  const PropertyImagesEvent();

  @override
  List<Object?> get props => [];
}

class LoadPropertyImagesEvent extends PropertyImagesEvent {
  final String propertyId;

  const LoadPropertyImagesEvent({required this.propertyId});

  @override
  List<Object?> get props => [propertyId];
}

class UploadPropertyImageEvent extends PropertyImagesEvent {
  final String propertyId;
  final String filePath;
  final String? category;
  final String? alt;
  final bool isPrimary;
  final int? order;
  final List<String>? tags;

  const UploadPropertyImageEvent({
    required this.propertyId,
    required this.filePath,
    this.category,
    this.alt,
    this.isPrimary = false,
    this.order,
    this.tags,
  });

  @override
  List<Object?> get props => [propertyId, filePath, category, alt, isPrimary, order, tags];
}

class UploadMultipleImagesEvent extends PropertyImagesEvent {
  final String propertyId;
  final List<String> filePaths;
  final String? category;
  final List<String>? tags;

  const UploadMultipleImagesEvent({
    required this.propertyId,
    required this.filePaths,
    this.category,
    this.tags,
  });

  @override
  List<Object?> get props => [propertyId, filePaths, category, tags];
}

class UpdatePropertyImageEvent extends PropertyImagesEvent {
  final String imageId;
  final Map<String, dynamic> data;

  const UpdatePropertyImageEvent({
    required this.imageId,
    required this.data,
  });

  @override
  List<Object?> get props => [imageId, data];
}

class DeletePropertyImageEvent extends PropertyImagesEvent {
  final String imageId;

  const DeletePropertyImageEvent({required this.imageId});

  @override
  List<Object?> get props => [imageId];
}

class DeleteMultipleImagesEvent extends PropertyImagesEvent {
  final List<String> imageIds;

  const DeleteMultipleImagesEvent({required this.imageIds});

  @override
  List<Object?> get props => [imageIds];
}

class ReorderImagesEvent extends PropertyImagesEvent {
  final String propertyId;
  final List<String> imageIds;

  const ReorderImagesEvent({
    required this.propertyId,
    required this.imageIds,
  });

  @override
  List<Object?> get props => [propertyId, imageIds];
}

class SetPrimaryImageEvent extends PropertyImagesEvent {
  final String propertyId;
  final String imageId;

  const SetPrimaryImageEvent({
    required this.propertyId,
    required this.imageId,
  });

  @override
  List<Object?> get props => [propertyId, imageId];
}

class ClearPropertyImagesEvent extends PropertyImagesEvent {
  const ClearPropertyImagesEvent();
}

class RefreshPropertyImagesEvent extends PropertyImagesEvent {
  final String propertyId;

  const RefreshPropertyImagesEvent({required this.propertyId});

  @override
  List<Object?> get props => [propertyId];
}

class ToggleImageSelectionEvent extends PropertyImagesEvent {
  final String imageId;

  const ToggleImageSelectionEvent({required this.imageId});

  @override
  List<Object?> get props => [imageId];
}

class SelectAllImagesEvent extends PropertyImagesEvent {
  const SelectAllImagesEvent();
}

class DeselectAllImagesEvent extends PropertyImagesEvent {
  const DeselectAllImagesEvent();
}