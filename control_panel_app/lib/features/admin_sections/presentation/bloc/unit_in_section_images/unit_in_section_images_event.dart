import 'package:equatable/equatable.dart';

abstract class UnitInSectionImagesEvent extends Equatable { const UnitInSectionImagesEvent(); @override List<Object?> get props=>[]; }

class LoadUnitInSectionImagesEvent extends UnitInSectionImagesEvent { final String unitInSectionId; final int? page; final int? limit; const LoadUnitInSectionImagesEvent({required this.unitInSectionId,this.page,this.limit}); @override List<Object?> get props=>[unitInSectionId,page,limit]; }
class UploadUnitInSectionImageEvent extends UnitInSectionImagesEvent { final String unitInSectionId; final String filePath; final String? category; final String? alt; final bool isPrimary; final int? order; final List<String>? tags; final String? tempKey; const UploadUnitInSectionImageEvent({required this.unitInSectionId, required this.filePath, this.category, this.alt, this.isPrimary=false, this.order, this.tags, this.tempKey}); }
class UploadMultipleUnitInSectionImagesEvent extends UnitInSectionImagesEvent { final String unitInSectionId; final List<String> filePaths; final String? category; final List<String>? tags; const UploadMultipleUnitInSectionImagesEvent({required this.unitInSectionId, required this.filePaths, this.category, this.tags}); }
class UpdateUnitInSectionImageEvent extends UnitInSectionImagesEvent { final String imageId; final Map<String,dynamic> data; const UpdateUnitInSectionImageEvent({required this.imageId, required this.data}); }
class DeleteUnitInSectionImageEvent extends UnitInSectionImagesEvent { final String imageId; final bool permanent; const DeleteUnitInSectionImageEvent({required this.imageId,this.permanent=false}); }
class DeleteMultipleUnitInSectionImagesEvent extends UnitInSectionImagesEvent { final List<String> imageIds; const DeleteMultipleUnitInSectionImagesEvent(this.imageIds); }
class ReorderUnitInSectionImagesEvent extends UnitInSectionImagesEvent { final List<String> imageIds; const ReorderUnitInSectionImagesEvent(this.imageIds); }
class SetPrimaryUnitInSectionImageEvent extends UnitInSectionImagesEvent { final String imageId; const SetPrimaryUnitInSectionImageEvent(this.imageId); }
class ToggleSelectUnitInSectionImageEvent extends UnitInSectionImagesEvent { final String imageId; const ToggleSelectUnitInSectionImageEvent(this.imageId); }
class SelectAllUnitInSectionImagesEvent extends UnitInSectionImagesEvent { const SelectAllUnitInSectionImagesEvent(); }
class ClearUnitInSectionSelectionEvent extends UnitInSectionImagesEvent { const ClearUnitInSectionSelectionEvent(); }

