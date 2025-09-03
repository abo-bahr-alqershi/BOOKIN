// lib/features/admin_units/presentation/bloc/unit_images/unit_images_event.dart

import 'package:equatable/equatable.dart';

abstract class UnitImagesEvent extends Equatable {
  const UnitImagesEvent();

  @override
  List<Object?> get props => [];
}

class LoadUnitImagesEvent extends UnitImagesEvent {
  final String? unitId;

  const LoadUnitImagesEvent({this.unitId});

  @override
  List<Object?> get props => [unitId];
}

class UploadUnitImageEvent extends UnitImagesEvent {
  final String? unitId;
  final String filePath;
  final String? category;
  final String? alt;
  final bool isPrimary;
  final int? order;
  final List<String>? tags;

  const UploadUnitImageEvent({
    this.unitId,
    required this.filePath,
    this.category,
    this.alt,
    this.isPrimary = false,
    this.order,
    this.tags,
  });

  @override
  List<Object?> get props => [unitId, filePath, category, alt, isPrimary, order, tags];
}

class UploadMultipleUnitImagesEvent extends UnitImagesEvent {
  final String? unitId;
  final List<String> filePaths;
  final String? category;
  final List<String>? tags;

  const UploadMultipleUnitImagesEvent({
    this.unitId,
    required this.filePaths,
    this.category,
    this.tags,
  });

  @override
  List<Object?> get props => [unitId, filePaths, category, tags];
}

class UpdateUnitImageEvent extends UnitImagesEvent {
  final String imageId;
  final Map<String, dynamic> data;

  const UpdateUnitImageEvent({
    required this.imageId,
    required this.data,
  });

  @override
  List<Object?> get props => [imageId, data];
}

class DeleteUnitImageEvent extends UnitImagesEvent {
  final String imageId;

  const DeleteUnitImageEvent({required this.imageId});

  @override
  List<Object?> get props => [imageId];
}

class DeleteMultipleUnitImagesEvent extends UnitImagesEvent {
  final List<String> imageIds;

  const DeleteMultipleUnitImagesEvent({required this.imageIds});

  @override
  List<Object?> get props => [imageIds];
}

class ReorderUnitImagesEvent extends UnitImagesEvent {
  final String? unitId;
  final List<String> imageIds;

  const ReorderUnitImagesEvent({
    this.unitId,
    required this.imageIds,
  });

  @override
  List<Object?> get props => [unitId, imageIds];
}

class SetPrimaryUnitImageEvent extends UnitImagesEvent {
  final String? unitId;
  final String imageId;

  const SetPrimaryUnitImageEvent({
    this.unitId,
    required this.imageId,
  });

  @override
  List<Object?> get props => [unitId, imageId];
}

class ClearUnitImagesEvent extends UnitImagesEvent {
  const ClearUnitImagesEvent();
}

class RefreshUnitImagesEvent extends UnitImagesEvent {
  final String unitId;

  const RefreshUnitImagesEvent({required this.unitId});

  @override
  List<Object?> get props => [unitId];
}

class ToggleUnitImageSelectionEvent extends UnitImagesEvent {
  final String imageId;

  const ToggleUnitImageSelectionEvent({required this.imageId});

  @override
  List<Object?> get props => [imageId];
}

class SelectAllUnitImagesEvent extends UnitImagesEvent {
  const SelectAllUnitImagesEvent();
}

class DeselectAllUnitImagesEvent extends UnitImagesEvent {
  const DeselectAllUnitImagesEvent();
}
