import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../entities/section_image.dart';
import '../../repositories/section_images_repository.dart';
import '../../../../core/error/failures.dart';

class UploadSectionImageParams {
  final String sectionId;
  final String filePath;
  final String? category;
  final String? alt;
  final bool isPrimary;
  final int? order;
  final List<String>? tags;
  final ProgressCallback? onSendProgress;
  final String? tempKey;
  UploadSectionImageParams({
    required this.sectionId,
    required this.filePath,
    this.category,
    this.alt,
    this.isPrimary = false,
    this.order,
    this.tags,
    this.onSendProgress,
    this.tempKey,
  });
}

class UploadSectionImageUseCase {
  final SectionImagesRepository repo;
  UploadSectionImageUseCase(this.repo);
  Future<Either<Failure, SectionImage>> call(UploadSectionImageParams p) =>
      repo.uploadImage(
        sectionId: p.sectionId,
        filePath: p.filePath,
        category: p.category,
        alt: p.alt,
        isPrimary: p.isPrimary,
        order: p.order,
        tags: p.tags,
        onSendProgress: p.onSendProgress,
        tempKey: p.tempKey,
      );
}

class GetSectionImagesParams { final String sectionId; final int? page; final int? limit; GetSectionImagesParams({required this.sectionId, this.page, this.limit}); }
class GetSectionImagesUseCase { final SectionImagesRepository repo; GetSectionImagesUseCase(this.repo); Future<Either<Failure, List<SectionImage>>> call(GetSectionImagesParams p)=> repo.getImages(p.sectionId, page: p.page, limit: p.limit); }

class UpdateSectionImageParams { final String imageId; final Map<String,dynamic> data; UpdateSectionImageParams(this.imageId, this.data); }
class UpdateSectionImageUseCase { final SectionImagesRepository repo; UpdateSectionImageUseCase(this.repo); Future<Either<Failure,bool>> call(UpdateSectionImageParams p)=> repo.updateImage(p.imageId, p.data); }

class DeleteSectionImageUseCase { final SectionImagesRepository repo; DeleteSectionImageUseCase(this.repo); Future<Either<Failure,bool>> call(String sectionId,String imageId,{bool permanent=false})=> repo.deleteImage(sectionId, imageId, permanent: permanent); }

class ReorderSectionImagesParams { final String sectionId; final List<String> imageIds; ReorderSectionImagesParams(this.sectionId, this.imageIds); }
class ReorderSectionImagesUseCase { final SectionImagesRepository repo; ReorderSectionImagesUseCase(this.repo); Future<Either<Failure,bool>> call(ReorderSectionImagesParams p)=> repo.reorderImages(p.sectionId, p.imageIds); }

class SetPrimarySectionImageParams { final String sectionId; final String imageId; SetPrimarySectionImageParams(this.sectionId, this.imageId); }
class SetPrimarySectionImageUseCase { final SectionImagesRepository repo; SetPrimarySectionImageUseCase(this.repo); Future<Either<Failure,bool>> call(SetPrimarySectionImageParams p)=> repo.setAsPrimaryImage(p.sectionId, p.imageId); }

class UploadMultipleSectionImagesParams { final String sectionId; final List<String> filePaths; final String? category; final List<String>? tags; final void Function(String,int,int)? onProgress; UploadMultipleSectionImagesParams({required this.sectionId, required this.filePaths, this.category, this.tags, this.onProgress}); }
class UploadMultipleSectionImagesUseCase { final SectionImagesRepository repo; UploadMultipleSectionImagesUseCase(this.repo); Future<Either<Failure,List<SectionImage>>> call(UploadMultipleSectionImagesParams p)=> repo.uploadMultipleImages(sectionId: p.sectionId, filePaths: p.filePaths, category: p.category, tags: p.tags, onProgress: p.onProgress); }

class DeleteMultipleSectionImagesUseCase { final SectionImagesRepository repo; DeleteMultipleSectionImagesUseCase(this.repo); Future<Either<Failure,bool>> call(String sectionId,List<String> imageIds)=> repo.deleteMultipleImages(sectionId, imageIds); }

