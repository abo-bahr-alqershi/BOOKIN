import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../entities/section_image.dart';
import '../../repositories/property_in_section_images_repository.dart';
import '../../../../core/error/failures.dart';

class UploadPropertyInSectionImageParams {
  final String propertyInSectionId;
  final String filePath;
  final String? category;
  final String? alt;
  final bool isPrimary;
  final int? order;
  final List<String>? tags;
  final ProgressCallback? onSendProgress;
  UploadPropertyInSectionImageParams({
    required this.propertyInSectionId,
    required this.filePath,
    this.category,
    this.alt,
    this.isPrimary = false,
    this.order,
    this.tags,
    this.onSendProgress,
  });
}

class UploadPropertyInSectionImageUseCase {
  final PropertyInSectionImagesRepository repo;
  UploadPropertyInSectionImageUseCase(this.repo);
  Future<Either<Failure, SectionImage>> call(UploadPropertyInSectionImageParams p) =>
      repo.uploadImage(
        propertyInSectionId: p.propertyInSectionId,
        filePath: p.filePath,
        category: p.category,
        alt: p.alt,
        isPrimary: p.isPrimary,
        order: p.order,
        tags: p.tags,
        onSendProgress: p.onSendProgress,
      );
}

class GetPropertyInSectionImagesParams { final String propertyInSectionId; final int? page; final int? limit; GetPropertyInSectionImagesParams({required this.propertyInSectionId, this.page, this.limit}); }
class GetPropertyInSectionImagesUseCase { final PropertyInSectionImagesRepository repo; GetPropertyInSectionImagesUseCase(this.repo); Future<Either<Failure, List<SectionImage>>> call(GetPropertyInSectionImagesParams p)=> repo.getImages(p.propertyInSectionId, page: p.page, limit: p.limit); }

class UpdatePropertyInSectionImageParams { final String imageId; final Map<String,dynamic> data; UpdatePropertyInSectionImageParams(this.imageId, this.data); }
class UpdatePropertyInSectionImageUseCase { final PropertyInSectionImagesRepository repo; UpdatePropertyInSectionImageUseCase(this.repo); Future<Either<Failure,bool>> call(UpdatePropertyInSectionImageParams p)=> repo.updateImage(p.imageId, p.data); }

class DeletePropertyInSectionImageUseCase { final PropertyInSectionImagesRepository repo; DeletePropertyInSectionImageUseCase(this.repo); Future<Either<Failure,bool>> call(String propertyInSectionId,String imageId,{bool permanent=false})=> repo.deleteImage(propertyInSectionId, imageId, permanent: permanent); }

class ReorderPropertyInSectionImagesParams { final String propertyInSectionId; final List<String> imageIds; ReorderPropertyInSectionImagesParams(this.propertyInSectionId, this.imageIds); }
class ReorderPropertyInSectionImagesUseCase { final PropertyInSectionImagesRepository repo; ReorderPropertyInSectionImagesUseCase(this.repo); Future<Either<Failure,bool>> call(ReorderPropertyInSectionImagesParams p)=> repo.reorderImages(p.propertyInSectionId, p.imageIds); }

class SetPrimaryPropertyInSectionImageParams { final String propertyInSectionId; final String imageId; SetPrimaryPropertyInSectionImageParams(this.propertyInSectionId, this.imageId); }
class SetPrimaryPropertyInSectionImageUseCase { final PropertyInSectionImagesRepository repo; SetPrimaryPropertyInSectionImageUseCase(this.repo); Future<Either<Failure,bool>> call(SetPrimaryPropertyInSectionImageParams p)=> repo.setAsPrimaryImage(p.propertyInSectionId, p.imageId); }

class UploadMultiplePropertyInSectionImagesParams { final String propertyInSectionId; final List<String> filePaths; final String? category; final List<String>? tags; final void Function(String,int,int)? onProgress; UploadMultiplePropertyInSectionImagesParams({required this.propertyInSectionId, required this.filePaths, this.category, this.tags, this.onProgress}); }
class UploadMultiplePropertyInSectionImagesUseCase { final PropertyInSectionImagesRepository repo; UploadMultiplePropertyInSectionImagesUseCase(this.repo); Future<Either<Failure,List<SectionImage>>> call(UploadMultiplePropertyInSectionImagesParams p)=> repo.uploadMultipleImages(propertyInSectionId: p.propertyInSectionId, filePaths: p.filePaths, category: p.category, tags: p.tags, onProgress: p.onProgress); }

class DeleteMultiplePropertyInSectionImagesUseCase { final PropertyInSectionImagesRepository repo; DeleteMultiplePropertyInSectionImagesUseCase(this.repo); Future<Either<Failure,bool>> call(String propertyInSectionId,List<String> imageIds)=> repo.deleteMultipleImages(propertyInSectionId, imageIds); }

