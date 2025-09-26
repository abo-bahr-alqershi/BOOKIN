import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/section_image.dart';

abstract class SectionImagesRepository {
  Future<Either<Failure, SectionImage>> uploadImage({
    required String sectionId,
    required String filePath,
    String? category,
    String? alt,
    bool isPrimary,
    int? order,
    List<String>? tags,
    ProgressCallback? onSendProgress,
  });

  Future<Either<Failure, List<SectionImage>>> getImages(String sectionId, {int? page, int? limit});

  Future<Either<Failure, bool>> updateImage(String imageId, Map<String, dynamic> data);

  Future<Either<Failure, bool>> deleteImage(String sectionId, String imageId, {bool permanent});

  Future<Either<Failure, bool>> reorderImages(String sectionId, List<String> imageIds);

  Future<Either<Failure, bool>> setAsPrimaryImage(String sectionId, String imageId);

  Future<Either<Failure, List<SectionImage>>> uploadMultipleImages({
    required String sectionId,
    required List<String> filePaths,
    String? category,
    List<String>? tags,
    void Function(String filePath, int sent, int total)? onProgress,
  });

  Future<Either<Failure, bool>> deleteMultipleImages(String sectionId, List<String> imageIds);
}

