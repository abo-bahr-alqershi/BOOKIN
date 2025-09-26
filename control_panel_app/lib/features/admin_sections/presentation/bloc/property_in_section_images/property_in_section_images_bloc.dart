import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../domain/entities/section_image.dart';
import '../../../domain/usecases/property_in_section_images/usecases.dart';
import 'property_in_section_images_event.dart';
import 'property_in_section_images_state.dart';

class PropertyInSectionImagesBloc extends Bloc<PropertyInSectionImagesEvent, PropertyInSectionImagesState> {
  final UploadPropertyInSectionImageUseCase uploadImage;
  final UploadMultiplePropertyInSectionImagesUseCase uploadMultipleImages;
  final GetPropertyInSectionImagesUseCase getImages;
  final UpdatePropertyInSectionImageUseCase updateImage;
  final DeletePropertyInSectionImageUseCase deleteImage;
  final DeleteMultiplePropertyInSectionImagesUseCase deleteMultipleImages;
  final ReorderPropertyInSectionImagesUseCase reorderImages;
  final SetPrimaryPropertyInSectionImageUseCase setPrimaryImage;

  List<SectionImage> _current = [];
  Set<String> _selected = {};
  String? _propertyInSectionId;

  PropertyInSectionImagesBloc({
    required this.uploadImage,
    required this.uploadMultipleImages,
    required this.getImages,
    required this.updateImage,
    required this.deleteImage,
    required this.deleteMultipleImages,
    required this.reorderImages,
    required this.setPrimaryImage,
  }) : super(const PropertyInSectionImagesInitial()) {
    on<LoadPropertyInSectionImagesEvent>(_onLoad);
    on<UploadPropertyInSectionImageEvent>(_onUpload);
    on<UploadMultiplePropertyInSectionImagesEvent>(_onUploadMultiple);
    on<UpdatePropertyInSectionImageEvent>(_onUpdate);
    on<DeletePropertyInSectionImageEvent>(_onDelete);
    on<DeleteMultiplePropertyInSectionImagesEvent>(_onDeleteMultiple);
    on<ReorderPropertyInSectionImagesEvent>(_onReorder);
    on<SetPrimaryPropertyInSectionImageEvent>(_onSetPrimary);
    on<ToggleSelectPropertyInSectionImageEvent>(_onToggleSelect);
    on<SelectAllPropertyInSectionImagesEvent>(_onSelectAll);
    on<ClearPropertyInSectionSelectionEvent>(_onClearSelection);
  }

  Future<void> _onLoad(LoadPropertyInSectionImagesEvent e, Emitter<PropertyInSectionImagesState> emit) async {
    _propertyInSectionId = e.propertyInSectionId;
    emit(const PropertyInSectionImagesLoading());
    final Either<Failure, List<SectionImage>> res = await getImages(GetPropertyInSectionImagesParams(propertyInSectionId: e.propertyInSectionId, page: e.page, limit: e.limit));
    res.fold(
      (f) => emit(PropertyInSectionImagesError(_msg(f))),
      (list) { _current = list; emit(PropertyInSectionImagesLoaded(images: list, propertyInSectionId: e.propertyInSectionId)); },
    );
  }

  Future<void> _onUpload(UploadPropertyInSectionImageEvent e, Emitter<PropertyInSectionImagesState> emit) async {
    emit(PropertyInSectionImageUploading(current: _current, fileName: e.filePath.split('/').last));
    final res = await uploadImage(UploadPropertyInSectionImageParams(propertyInSectionId: e.propertyInSectionId, filePath: e.filePath, category: e.category, alt: e.alt, isPrimary: e.isPrimary, order: e.order, tags: e.tags, tempKey: e.tempKey, onSendProgress: (sent,total){ if(total>0) add(_ProgressEvent(e.propertyInSectionId, sent/total)); }));
    res.fold((f)=>emit(PropertyInSectionImagesError(_msg(f))), (img){ _current.add(img); emit(PropertyInSectionImageUploaded(uploaded: img, all: List.from(_current))); });
  }

  Future<void> _onUploadMultiple(UploadMultiplePropertyInSectionImagesEvent e, Emitter<PropertyInSectionImagesState> emit) async {
    emit(PropertyInSectionImageUploading(current: _current, total: e.filePaths.length, index: 0));
    final res = await uploadMultipleImages(UploadMultiplePropertyInSectionImagesParams(propertyInSectionId: e.propertyInSectionId, filePaths: e.filePaths, category: e.category, tags: e.tags, onProgress: (path,sent,total){ if(total>0) add(_ProgressEvent(e.propertyInSectionId, sent/total)); }));
    res.fold((f)=>emit(PropertyInSectionImagesError(_msg(f))), (list){ _current.addAll(list); emit(MultiplePropertyInSectionImagesUploaded(uploaded: list, all: List.from(_current))); });
  }

  Future<void> _onUpdate(UpdatePropertyInSectionImageEvent e, Emitter<PropertyInSectionImagesState> emit) async {
    emit(PropertyInSectionImageUpdating(current: _current, imageId: e.imageId));
    final res = await updateImage(UpdatePropertyInSectionImageParams(e.imageId, e.data));
    res.fold((f)=>emit(PropertyInSectionImagesError(_msg(f))), (_){ add(LoadPropertyInSectionImagesEvent(propertyInSectionId: _propertyInSectionId!)); });
  }

  Future<void> _onDelete(DeletePropertyInSectionImageEvent e, Emitter<PropertyInSectionImagesState> emit) async {
    emit(PropertyInSectionImageDeleting(current: _current, imageId: e.imageId));
    final res = await deleteImage(_propertyInSectionId!, e.imageId, permanent: e.permanent);
    res.fold((f)=>emit(PropertyInSectionImagesError(_msg(f))), (ok){ if(ok){ _current.removeWhere((x)=>x.id==e.imageId); emit(PropertyInSectionImageDeleted(remaining: List.from(_current))); } });
  }

  Future<void> _onDeleteMultiple(DeleteMultiplePropertyInSectionImagesEvent e, Emitter<PropertyInSectionImagesState> emit) async {
    emit(const PropertyInSectionImagesLoading());
    final res = await deleteMultipleImages(_propertyInSectionId!, e.imageIds);
    res.fold((f)=>emit(PropertyInSectionImagesError(_msg(f))), (ok){ if(ok){ _current.removeWhere((x)=> e.imageIds.contains(x.id)); _selected.clear(); emit(MultiplePropertyInSectionImagesDeleted(remaining: List.from(_current))); } });
  }

  Future<void> _onReorder(ReorderPropertyInSectionImagesEvent e, Emitter<PropertyInSectionImagesState> emit) async {
    emit(PropertyInSectionImagesReordering(current: _current));
    final res = await reorderImages(ReorderPropertyInSectionImagesParams(_propertyInSectionId!, e.imageIds));
    res.fold((f)=>emit(PropertyInSectionImagesError(_msg(f))), (ok){ if(ok){ final map={for(final i in _current) i.id:i}; _current=e.imageIds.map((id)=>map[id]).whereType<SectionImage>().toList(); emit(PropertyInSectionImagesReordered(reordered: List.from(_current))); } });
  }

  Future<void> _onSetPrimary(SetPrimaryPropertyInSectionImageEvent e, Emitter<PropertyInSectionImagesState> emit) async {
    emit(const PropertyInSectionImagesLoading());
    final res = await setPrimaryImage(SetPrimaryPropertyInSectionImageParams(_propertyInSectionId!, e.imageId));
    res.fold((f)=>emit(PropertyInSectionImagesError(_msg(f))), (_){ add(LoadPropertyInSectionImagesEvent(propertyInSectionId: _propertyInSectionId!)); });
  }

  void _onToggleSelect(ToggleSelectPropertyInSectionImageEvent e, Emitter<PropertyInSectionImagesState> emit){ if(_selected.contains(e.imageId)) _selected.remove(e.imageId); else _selected.add(e.imageId); emit(PropertyInSectionImagesLoaded(images:_current, propertyInSectionId:_propertyInSectionId, selected:Set.from(_selected), isSelectionMode:_selected.isNotEmpty)); }
  void _onSelectAll(SelectAllPropertyInSectionImagesEvent e, Emitter<PropertyInSectionImagesState> emit){ _selected=_current.map((x)=>x.id).toSet(); emit(PropertyInSectionImagesLoaded(images:_current, propertyInSectionId:_propertyInSectionId, selected:Set.from(_selected), isSelectionMode:true)); }
  void _onClearSelection(ClearPropertyInSectionSelectionEvent e, Emitter<PropertyInSectionImagesState> emit){ _selected.clear(); emit(PropertyInSectionImagesLoaded(images:_current, propertyInSectionId:_propertyInSectionId, selected:Set.from(_selected), isSelectionMode:false)); }

  void _onProgress(_ProgressEvent e, Emitter<PropertyInSectionImagesState> emit){ emit(PropertyInSectionImageUploading(current: _current, progress: e.progress)); }
  String _msg(Failure f){ if(f is ServerFailure) return f.message ?? 'Server Error'; if(f is NetworkFailure) return 'Network error'; return 'Unexpected error'; }
}

class _ProgressEvent extends PropertyInSectionImagesEvent{ final String propertyInSectionId; final double progress; _ProgressEvent(this.propertyInSectionId,this.progress); }

