import 'package:equatable/equatable.dart';
import '../../../domain/entities/section_image.dart';

abstract class SectionImagesState extends Equatable { const SectionImagesState(); @override List<Object?> get props=>[]; }
class SectionImagesInitial extends SectionImagesState { const SectionImagesInitial(); }
class SectionImagesLoading extends SectionImagesState { const SectionImagesLoading(); }
class SectionImagesError extends SectionImagesState { final String message; const SectionImagesError(this.message); @override List<Object?> get props=>[message]; }
class SectionImagesLoaded extends SectionImagesState { final List<SectionImage> images; final String? sectionId; final Set<String>? selected; final bool isSelectionMode; const SectionImagesLoaded({required this.images, this.sectionId, this.selected, this.isSelectionMode=false}); @override List<Object?> get props=>[images,sectionId,selected,isSelectionMode]; }
class SectionImageUploading extends SectionImagesState { final List<SectionImage> current; final String? fileName; final double? progress; final int? total; final int? index; const SectionImageUploading({required this.current,this.fileName,this.progress,this.total,this.index}); @override List<Object?> get props=>[current,fileName,progress,total,index]; }
class SectionImageUploaded extends SectionImagesState { final SectionImage uploaded; final List<SectionImage> all; const SectionImageUploaded({required this.uploaded,required this.all}); @override List<Object?> get props=>[uploaded,all]; }
class MultipleSectionImagesUploaded extends SectionImagesState { final List<SectionImage> uploaded; final List<SectionImage> all; const MultipleSectionImagesUploaded({required this.uploaded,required this.all}); }
class SectionImageUpdating extends SectionImagesState { final List<SectionImage> current; final String imageId; const SectionImageUpdating({required this.current, required this.imageId}); @override List<Object?> get props=>[current,imageId]; }
class SectionImageDeleted extends SectionImagesState { final List<SectionImage> remaining; const SectionImageDeleted({required this.remaining}); }
class MultipleSectionImagesDeleted extends SectionImagesState { final List<SectionImage> remaining; const MultipleSectionImagesDeleted({required this.remaining}); }
class SectionImagesReordering extends SectionImagesState { final List<SectionImage> current; const SectionImagesReordering({required this.current}); }
class SectionImagesReordered extends SectionImagesState { final List<SectionImage> reordered; const SectionImagesReordered({required this.reordered}); }

