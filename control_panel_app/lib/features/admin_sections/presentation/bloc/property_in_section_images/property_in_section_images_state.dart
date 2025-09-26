import 'package:equatable/equatable.dart';
import '../../../domain/entities/section_image.dart';

abstract class PropertyInSectionImagesState extends Equatable { const PropertyInSectionImagesState(); @override List<Object?> get props=>[]; }
class PropertyInSectionImagesInitial extends PropertyInSectionImagesState { const PropertyInSectionImagesInitial(); }
class PropertyInSectionImagesLoading extends PropertyInSectionImagesState { const PropertyInSectionImagesLoading(); }
class PropertyInSectionImagesError extends PropertyInSectionImagesState { final String message; const PropertyInSectionImagesError(this.message); @override List<Object?> get props=>[message]; }
class PropertyInSectionImagesLoaded extends PropertyInSectionImagesState { final List<SectionImage> images; final String? propertyInSectionId; final Set<String>? selected; final bool isSelectionMode; const PropertyInSectionImagesLoaded({required this.images, this.propertyInSectionId, this.selected, this.isSelectionMode=false}); @override List<Object?> get props=>[images,propertyInSectionId,selected,isSelectionMode]; }
class PropertyInSectionImageUploading extends PropertyInSectionImagesState { final List<SectionImage> current; final String? fileName; final double? progress; final int? total; final int? index; const PropertyInSectionImageUploading({required this.current,this.fileName,this.progress,this.total,this.index}); @override List<Object?> get props=>[current,fileName,progress,total,index]; }
class PropertyInSectionImageUploaded extends PropertyInSectionImagesState { final SectionImage uploaded; final List<SectionImage> all; const PropertyInSectionImageUploaded({required this.uploaded,required this.all}); @override List<Object?> get props=>[uploaded,all]; }
class MultiplePropertyInSectionImagesUploaded extends PropertyInSectionImagesState { final List<SectionImage> uploaded; final List<SectionImage> all; const MultiplePropertyInSectionImagesUploaded({required this.uploaded,required this.all}); }
class PropertyInSectionImageUpdating extends PropertyInSectionImagesState { final List<SectionImage> current; final String imageId; const PropertyInSectionImageUpdating({required this.current, required this.imageId}); @override List<Object?> get props=>[current,imageId]; }
class PropertyInSectionImageDeleting extends PropertyInSectionImagesState { final List<SectionImage> current; final String imageId; const PropertyInSectionImageDeleting({required this.current, required this.imageId}); @override List<Object?> get props=>[current,imageId]; }
class PropertyInSectionImageDeleted extends PropertyInSectionImagesState { final List<SectionImage> remaining; const PropertyInSectionImageDeleted({required this.remaining}); }
class MultiplePropertyInSectionImagesDeleted extends PropertyInSectionImagesState { final List<SectionImage> remaining; const MultiplePropertyInSectionImagesDeleted({required this.remaining}); }
class PropertyInSectionImagesReordering extends PropertyInSectionImagesState { final List<SectionImage> current; const PropertyInSectionImagesReordering({required this.current}); }
class PropertyInSectionImagesReordered extends PropertyInSectionImagesState { final List<SectionImage> reordered; const PropertyInSectionImagesReordered({required this.reordered}); }

