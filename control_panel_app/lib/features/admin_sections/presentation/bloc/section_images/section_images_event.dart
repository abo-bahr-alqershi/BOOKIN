import 'package:equatable/equatable.dart';

abstract class SectionImagesEvent extends Equatable { const SectionImagesEvent(); @override List<Object?> get props=>[]; }

class LoadSectionImagesEvent extends SectionImagesEvent { final String sectionId; final int? page; final int? limit; const LoadSectionImagesEvent({required this.sectionId,this.page,this.limit}); @override List<Object?> get props=>[sectionId,page,limit]; }
class UploadSectionImageEvent extends SectionImagesEvent { final String sectionId; final String filePath; final String? category; final String? alt; final bool isPrimary; final int? order; final List<String>? tags; const UploadSectionImageEvent({required this.sectionId, required this.filePath, this.category, this.alt, this.isPrimary=false, this.order, this.tags}); }
class UploadMultipleSectionImagesEvent extends SectionImagesEvent { final String sectionId; final List<String> filePaths; final String? category; final List<String>? tags; const UploadMultipleSectionImagesEvent({required this.sectionId, required this.filePaths, this.category, this.tags}); }
class UpdateSectionImageEvent extends SectionImagesEvent { final String imageId; final Map<String,dynamic> data; const UpdateSectionImageEvent({required this.imageId, required this.data}); }
class DeleteSectionImageEvent extends SectionImagesEvent { final String imageId; final bool permanent; const DeleteSectionImageEvent({required this.imageId,this.permanent=false}); }
class DeleteMultipleSectionImagesEvent extends SectionImagesEvent { final List<String> imageIds; const DeleteMultipleSectionImagesEvent(this.imageIds); }
class ReorderSectionImagesEvent extends SectionImagesEvent { final List<String> imageIds; const ReorderSectionImagesEvent(this.imageIds); }
class SetPrimarySectionImageEvent extends SectionImagesEvent { final String imageId; const SetPrimarySectionImageEvent(this.imageId); }
class ToggleSelectSectionImageEvent extends SectionImagesEvent { final String imageId; const ToggleSelectSectionImageEvent(this.imageId); }
class SelectAllSectionImagesEvent extends SectionImagesEvent { const SelectAllSectionImagesEvent(); }
class ClearSectionSelectionEvent extends SectionImagesEvent { const ClearSectionSelectionEvent(); }

