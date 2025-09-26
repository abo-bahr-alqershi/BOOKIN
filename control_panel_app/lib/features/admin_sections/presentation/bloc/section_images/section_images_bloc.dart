import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../domain/entities/section_image.dart';
import '../../../domain/usecases/section_images/usecases.dart';
import 'section_images_event.dart';
import 'section_images_state.dart';

class SectionImagesBloc extends Bloc<SectionImagesEvent, SectionImagesState> {
  final UploadSectionImageUseCase uploadImage;
  final UploadMultipleSectionImagesUseCase uploadMultipleImages;
  final GetSectionImagesUseCase getImages;
  final UpdateSectionImageUseCase updateImage;
  final DeleteSectionImageUseCase deleteImage;
  final DeleteMultipleSectionImagesUseCase deleteMultipleImages;
  final ReorderSectionImagesUseCase reorderImages;
  final SetPrimarySectionImageUseCase setPrimaryImage;

  List<SectionImage> _current = [];
  Set<String> _selected = {};
  String? _sectionId;

  SectionImagesBloc({
    required this.uploadImage,
    required this.uploadMultipleImages,
    required this.getImages,
    required this.updateImage,
    required this.deleteImage,
    required this.deleteMultipleImages,
    required this.reorderImages,
    required this.setPrimaryImage,
  }) : super(const SectionImagesInitial()) {
    on<LoadSectionImagesEvent>(_onLoad);
    on<UploadSectionImageEvent>(_onUpload);
    on<UploadMultipleSectionImagesEvent>(_onUploadMultiple);
    on<UpdateSectionImageEvent>(_onUpdate);
    on<DeleteSectionImageEvent>(_onDelete);
    on<DeleteMultipleSectionImagesEvent>(_onDeleteMultiple);
    on<ReorderSectionImagesEvent>(_onReorder);
    on<SetPrimarySectionImageEvent>(_onSetPrimary);
    on<ToggleSelectSectionImageEvent>(_onToggleSelect);
    on<SelectAllSectionImagesEvent>(_onSelectAll);
    on<ClearSectionSelectionEvent>(_onClearSelection);
  }

  Future<void> _onLoad(LoadSectionImagesEvent e, Emitter<SectionImagesState> emit) async {
    _sectionId = e.sectionId;
    emit(const SectionImagesLoading());
    final Either<Failure, List<SectionImage>> res = await getImages(GetSectionImagesParams(sectionId: e.sectionId, page: e.page, limit: e.limit));
    res.fold(
      (f) => emit(SectionImagesError(_msg(f))),
      (list) { _current = list; emit(SectionImagesLoaded(images: list, sectionId: e.sectionId)); },
    );
  }

  Future<void> _onUpload(UploadSectionImageEvent e, Emitter<SectionImagesState> emit) async {
    emit(SectionImageUploading(current: _current, fileName: e.filePath.split('/').last));
    final res = await uploadImage(UploadSectionImageParams(sectionId: e.sectionId, filePath: e.filePath, category: e.category, alt: e.alt, isPrimary: e.isPrimary, order: e.order, tags: e.tags, tempKey: e.tempKey, onSendProgress: (sent,total){ if(total>0) add(_ProgressEvent(e.sectionId, sent/total)); }));
    res.fold((f)=>emit(SectionImagesError(_msg(f))), (img){ _current.add(img); emit(SectionImageUploaded(uploaded: img, all: List.from(_current))); });
  }

  Future<void> _onUploadMultiple(UploadMultipleSectionImagesEvent e, Emitter<SectionImagesState> emit) async {
    emit(SectionImageUploading(current: _current, total: e.filePaths.length, index: 0));
    final res = await uploadMultipleImages(UploadMultipleSectionImagesParams(sectionId: e.sectionId, filePaths: e.filePaths, category: e.category, tags: e.tags, onProgress: (path,sent,total){ if(total>0) add(_ProgressEvent(e.sectionId, sent/total)); }));
    res.fold((f)=>emit(SectionImagesError(_msg(f))), (list){ _current.addAll(list); emit(MultipleSectionImagesUploaded(uploaded: list, all: List.from(_current))); });
  }

  Future<void> _onUpdate(UpdateSectionImageEvent e, Emitter<SectionImagesState> emit) async {
    emit(SectionImageUpdating(current: _current, imageId: e.imageId));
    final res = await updateImage(UpdateSectionImageParams(e.imageId, e.data));
    res.fold((f)=>emit(SectionImagesError(_msg(f))), (_){ add(LoadSectionImagesEvent(sectionId: _sectionId!)); });
  }

  Future<void> _onDelete(DeleteSectionImageEvent e, Emitter<SectionImagesState> emit) async {
    emit(SectionImageDeleting(current: _current, imageId: e.imageId));
    final res = await deleteImage(_sectionId!, e.imageId, permanent: e.permanent);
    res.fold((f)=>emit(SectionImagesError(_msg(f))), (ok){ if(ok){ _current.removeWhere((x)=>x.id==e.imageId); emit(SectionImageDeleted(remaining: List.from(_current))); } });
  }

  Future<void> _onDeleteMultiple(DeleteMultipleSectionImagesEvent e, Emitter<SectionImagesState> emit) async {
    emit(const SectionImagesLoading());
    final res = await deleteMultipleImages(_sectionId!, e.imageIds);
    res.fold((f)=>emit(SectionImagesError(_msg(f))), (ok){ if(ok){ _current.removeWhere((x)=> e.imageIds.contains(x.id)); _selected.clear(); emit(MultipleSectionImagesDeleted(remaining: List.from(_current))); } });
  }

  Future<void> _onReorder(ReorderSectionImagesEvent e, Emitter<SectionImagesState> emit) async {
    emit(SectionImagesReordering(current: _current));
    final res = await reorderImages(ReorderSectionImagesParams(_sectionId!, e.imageIds));
    res.fold((f)=>emit(SectionImagesError(_msg(f))), (ok){ if(ok){ final map={for(final i in _current) i.id:i}; _current=e.imageIds.map((id)=>map[id]).whereType<SectionImage>().toList(); emit(SectionImagesReordered(reordered: List.from(_current))); } });
  }

  Future<void> _onSetPrimary(SetPrimarySectionImageEvent e, Emitter<SectionImagesState> emit) async {
    emit(const SectionImagesLoading());
    final res = await setPrimaryImage(SetPrimarySectionImageParams(_sectionId!, e.imageId));
    res.fold((f)=>emit(SectionImagesError(_msg(f))), (_){ add(LoadSectionImagesEvent(sectionId: _sectionId!)); });
  }

  void _onToggleSelect(ToggleSelectSectionImageEvent e, Emitter<SectionImagesState> emit){ if(_selected.contains(e.imageId)) _selected.remove(e.imageId); else _selected.add(e.imageId); emit(SectionImagesLoaded(images:_current, sectionId:_sectionId, selected:Set.from(_selected), isSelectionMode:_selected.isNotEmpty)); }
  void _onSelectAll(SelectAllSectionImagesEvent e, Emitter<SectionImagesState> emit){ _selected=_current.map((x)=>x.id).toSet(); emit(SectionImagesLoaded(images:_current, sectionId:_sectionId, selected:Set.from(_selected), isSelectionMode:true)); }
  void _onClearSelection(ClearSectionSelectionEvent e, Emitter<SectionImagesState> emit){ _selected.clear(); emit(SectionImagesLoaded(images:_current, sectionId:_sectionId, selected:Set.from(_selected), isSelectionMode:false)); }

  void _onProgress(_ProgressEvent e, Emitter<SectionImagesState> emit){ emit(SectionImageUploading(current: _current, progress: e.progress)); }
  String _msg(Failure f){ if(f is ServerFailure) return f.message ?? 'Server Error'; if(f is NetworkFailure) return 'Network error'; return 'Unexpected error'; }
}

class _ProgressEvent extends SectionImagesEvent{ final String sectionId; final double progress; _ProgressEvent(this.sectionId,this.progress); }

