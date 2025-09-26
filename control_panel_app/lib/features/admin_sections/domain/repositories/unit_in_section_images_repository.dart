import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../entities/section_image.dart';

abstract class UnitInSectionImagesRepository {
  Future<Either<Failure, SectionImage>> uploadImage({
    required String unitInSectionId,
    required String filePath,
    String? category,
    String? alt,
    bool isPrimary,
    int? order,
    List<String>? tags,
    ProgressCallback? onSendProgress,
    String? tempKey,
  });

  Future<Either<Failure, List<SectionImage>>> getImages(String unitInSectionId, {int? page, int? limit});

  Future<Either<Failure, bool>> updateImage(String imageId, Map<String, dynamic> data);

  Future<Either<Failure, bool>> deleteImage(String unitInSectionId, String imageId, {bool permanent});

  Future<Either<Failure, bool>> reorderImages(String unitInSectionId, List<String> imageIds);

  Future<Either<Failure, bool>> setAsPrimaryImage(String unitInSectionId, String imageId);

  Future<Either<Failure, List<SectionImage>>> uploadMultipleImages({
    required String unitInSectionId,
    required List<String> filePaths,
    String? category,
    List<String>? tags,
    void Function(String filePath, int sent, int total)? onProgress,
  });

  Future<Either<Failure, bool>> deleteMultipleImages(String unitInSectionId, List<String> imageIds);
}

