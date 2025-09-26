import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../entities/section_image.dart';

abstract class PropertyInSectionImagesRepository {
  Future<Either<Failure, SectionImage>> uploadImage({
    required String propertyInSectionId,
    required String filePath,
    String? category,
    String? alt,
    bool isPrimary,
    int? order,
    List<String>? tags,
    ProgressCallback? onSendProgress,
  });

  Future<Either<Failure, List<SectionImage>>> getImages(String propertyInSectionId, {int? page, int? limit});

  Future<Either<Failure, bool>> updateImage(String imageId, Map<String, dynamic> data);

  Future<Either<Failure, bool>> deleteImage(String propertyInSectionId, String imageId, {bool permanent});

  Future<Either<Failure, bool>> reorderImages(String propertyInSectionId, List<String> imageIds);

  Future<Either<Failure, bool>> setAsPrimaryImage(String propertyInSectionId, String imageId);

  Future<Either<Failure, List<SectionImage>>> uploadMultipleImages({
    required String propertyInSectionId,
    required List<String> filePaths,
    String? category,
    List<String>? tags,
    void Function(String filePath, int sent, int total)? onProgress,
  });

  Future<Either<Failure, bool>> deleteMultipleImages(String propertyInSectionId, List<String> imageIds);
}

