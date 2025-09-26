import 'package:equatable/equatable.dart';
import '../../../domain/entities/section_image.dart';

abstract class UnitInSectionImagesState extends Equatable { const UnitInSectionImagesState(); @override List<Object?> get props=>[]; }
class UnitInSectionImagesInitial extends UnitInSectionImagesState { const UnitInSectionImagesInitial(); }
class UnitInSectionImagesLoading extends UnitInSectionImagesState { const UnitInSectionImagesLoading(); }
class UnitInSectionImagesError extends UnitInSectionImagesState { final String message; const UnitInSectionImagesError(this.message); @override List<Object?> get props=>[message]; }
class UnitInSectionImagesLoaded extends UnitInSectionImagesState { final List<SectionImage> images; final String? unitInSectionId; final Set<String>? selected; final bool isSelectionMode; const UnitInSectionImagesLoaded({required this.images, this.unitInSectionId, this.selected, this.isSelectionMode=false}); @override List<Object?> get props=>[images,unitInSectionId,selected,isSelectionMode]; }
class UnitInSectionImageUploading extends UnitInSectionImagesState { final List<SectionImage> current; final String? fileName; final double? progress; final int? total; final int? index; const UnitInSectionImageUploading({required this.current,this.fileName,this.progress,this.total,this.index}); @override List<Object?> get props=>[current,fileName,progress,total,index]; }
class UnitInSectionImageUploaded extends UnitInSectionImagesState { final SectionImage uploaded; final List<SectionImage> all; const UnitInSectionImageUploaded({required this.uploaded,required this.all}); @override List<Object?> get props=>[uploaded,all]; }
class MultipleUnitInSectionImagesUploaded extends UnitInSectionImagesState { final List<SectionImage> uploaded; final List<SectionImage> all; const MultipleUnitInSectionImagesUploaded({required this.uploaded,required this.all}); }
class UnitInSectionImageUpdating extends UnitInSectionImagesState { final List<SectionImage> current; final String imageId; const UnitInSectionImageUpdating({required this.current, required this.imageId}); @override List<Object?> get props=>[current,imageId]; }
class UnitInSectionImageDeleting extends UnitInSectionImagesState { final List<SectionImage> current; final String imageId; const UnitInSectionImageDeleting({required this.current, required this.imageId}); @override List<Object?> get props=>[current,imageId]; }
class UnitInSectionImageDeleted extends UnitInSectionImagesState { final List<SectionImage> remaining; const UnitInSectionImageDeleted({required this.remaining}); }
class MultipleUnitInSectionImagesDeleted extends UnitInSectionImagesState { final List<SectionImage> remaining; const MultipleUnitInSectionImagesDeleted({required this.remaining}); }
class UnitInSectionImagesReordering extends UnitInSectionImagesState { final List<SectionImage> current; const UnitInSectionImagesReordering({required this.current}); }
class UnitInSectionImagesReordered extends UnitInSectionImagesState { final List<SectionImage> reordered; const UnitInSectionImagesReordered({required this.reordered}); }

