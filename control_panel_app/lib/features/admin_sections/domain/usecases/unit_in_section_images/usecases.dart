import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../entities/section_image.dart';
import '../../repositories/unit_in_section_images_repository.dart';
import '../../../../core/error/failures.dart';

class UploadUnitInSectionImageParams {
  final String unitInSectionId;
  final String filePath;
  final String? category;
  final String? alt;
  final bool isPrimary;
  final int? order;
  final List<String>? tags;
  final ProgressCallback? onSendProgress;
  final String? tempKey;
  UploadUnitInSectionImageParams({
    required this.unitInSectionId,
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

class UploadUnitInSectionImageUseCase {
  final UnitInSectionImagesRepository repo;
  UploadUnitInSectionImageUseCase(this.repo);
  Future<Either<Failure, SectionImage>> call(UploadUnitInSectionImageParams p) =>
      repo.uploadImage(
        unitInSectionId: p.unitInSectionId,
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

class GetUnitInSectionImagesParams { final String unitInSectionId; final int? page; final int? limit; GetUnitInSectionImagesParams({required this.unitInSectionId, this.page, this.limit}); }
class GetUnitInSectionImagesUseCase { final UnitInSectionImagesRepository repo; GetUnitInSectionImagesUseCase(this.repo); Future<Either<Failure, List<SectionImage>>> call(GetUnitInSectionImagesParams p)=> repo.getImages(p.unitInSectionId, page: p.page, limit: p.limit); }

class UpdateUnitInSectionImageParams { final String imageId; final Map<String,dynamic> data; UpdateUnitInSectionImageParams(this.imageId, this.data); }
class UpdateUnitInSectionImageUseCase { final UnitInSectionImagesRepository repo; UpdateUnitInSectionImageUseCase(this.repo); Future<Either<Failure,bool>> call(UpdateUnitInSectionImageParams p)=> repo.updateImage(p.imageId, p.data); }

class DeleteUnitInSectionImageUseCase { final UnitInSectionImagesRepository repo; DeleteUnitInSectionImageUseCase(this.repo); Future<Either<Failure,bool>> call(String unitInSectionId,String imageId,{bool permanent=false})=> repo.deleteImage(unitInSectionId, imageId, permanent: permanent); }

class ReorderUnitInSectionImagesParams { final String unitInSectionId; final List<String> imageIds; ReorderUnitInSectionImagesParams(this.unitInSectionId, this.imageIds); }
class ReorderUnitInSectionImagesUseCase { final UnitInSectionImagesRepository repo; ReorderUnitInSectionImagesUseCase(this.repo); Future<Either<Failure,bool>> call(ReorderUnitInSectionImagesParams p)=> repo.reorderImages(p.unitInSectionId, p.imageIds); }

class SetPrimaryUnitInSectionImageParams { final String unitInSectionId; final String imageId; SetPrimaryUnitInSectionImageParams(this.unitInSectionId, this.imageId); }
class SetPrimaryUnitInSectionImageUseCase { final UnitInSectionImagesRepository repo; SetPrimaryUnitInSectionImageUseCase(this.repo); Future<Either<Failure,bool>> call(SetPrimaryUnitInSectionImageParams p)=> repo.setAsPrimaryImage(p.unitInSectionId, p.imageId); }

class UploadMultipleUnitInSectionImagesParams { final String unitInSectionId; final List<String> filePaths; final String? category; final List<String>? tags; final void Function(String,int,int)? onProgress; UploadMultipleUnitInSectionImagesParams({required this.unitInSectionId, required this.filePaths, this.category, this.tags, this.onProgress}); }
class UploadMultipleUnitInSectionImagesUseCase { final UnitInSectionImagesRepository repo; UploadMultipleUnitInSectionImagesUseCase(this.repo); Future<Either<Failure,List<SectionImage>>> call(UploadMultipleUnitInSectionImagesParams p)=> repo.uploadMultipleImages(unitInSectionId: p.unitInSectionId, filePaths: p.filePaths, category: p.category, tags: p.tags, onProgress: p.onProgress); }

class DeleteMultipleUnitInSectionImagesUseCase { final UnitInSectionImagesRepository repo; DeleteMultipleUnitInSectionImagesUseCase(this.repo); Future<Either<Failure,bool>> call(String unitInSectionId,List<String> imageIds)=> repo.deleteMultipleImages(unitInSectionId, imageIds); }

