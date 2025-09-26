import 'package:equatable/equatable.dart';

abstract class PropertyInSectionImagesEvent extends Equatable { const PropertyInSectionImagesEvent(); @override List<Object?> get props=>[]; }

class LoadPropertyInSectionImagesEvent extends PropertyInSectionImagesEvent { final String propertyInSectionId; final int? page; final int? limit; const LoadPropertyInSectionImagesEvent({required this.propertyInSectionId,this.page,this.limit}); @override List<Object?> get props=>[propertyInSectionId,page,limit]; }
class UploadPropertyInSectionImageEvent extends PropertyInSectionImagesEvent { final String propertyInSectionId; final String filePath; final String? category; final String? alt; final bool isPrimary; final int? order; final List<String>? tags; const UploadPropertyInSectionImageEvent({required this.propertyInSectionId, required this.filePath, this.category, this.alt, this.isPrimary=false, this.order, this.tags}); }
class UploadMultiplePropertyInSectionImagesEvent extends PropertyInSectionImagesEvent { final String propertyInSectionId; final List<String> filePaths; final String? category; final List<String>? tags; const UploadMultiplePropertyInSectionImagesEvent({required this.propertyInSectionId, required this.filePaths, this.category, this.tags}); }
class UpdatePropertyInSectionImageEvent extends PropertyInSectionImagesEvent { final String imageId; final Map<String,dynamic> data; const UpdatePropertyInSectionImageEvent({required this.imageId, required this.data}); }
class DeletePropertyInSectionImageEvent extends PropertyInSectionImagesEvent { final String imageId; final bool permanent; const DeletePropertyInSectionImageEvent({required this.imageId,this.permanent=false}); }
class DeleteMultiplePropertyInSectionImagesEvent extends PropertyInSectionImagesEvent { final List<String> imageIds; const DeleteMultiplePropertyInSectionImagesEvent(this.imageIds); }
class ReorderPropertyInSectionImagesEvent extends PropertyInSectionImagesEvent { final List<String> imageIds; const ReorderPropertyInSectionImagesEvent(this.imageIds); }
class SetPrimaryPropertyInSectionImageEvent extends PropertyInSectionImagesEvent { final String imageId; const SetPrimaryPropertyInSectionImageEvent(this.imageId); }
class ToggleSelectPropertyInSectionImageEvent extends PropertyInSectionImagesEvent { final String imageId; const ToggleSelectPropertyInSectionImageEvent(this.imageId); }
class SelectAllPropertyInSectionImagesEvent extends PropertyInSectionImagesEvent { const SelectAllPropertyInSectionImagesEvent(); }
class ClearPropertyInSectionSelectionEvent extends PropertyInSectionImagesEvent { const ClearPropertyInSectionSelectionEvent(); }

