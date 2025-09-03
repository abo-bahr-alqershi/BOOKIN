// lib/features/admin_units/domain/repositories/unit_images_repository.dart

import 'package:bookn_cp_app/features/admin_units/domain/entities/unit_image.dart';
import 'package:dartz/dartz.dart';
import 'package:bookn_cp_app/core/error/failures.dart';

abstract class UnitImagesRepository {
  Future<Either<Failure, UnitImage>> uploadImage({
    String? unitId,
    String? tempKey,
    required String filePath,
    String? category,
    String? alt,
    bool isPrimary = false,
    int? order,
    List<String>? tags,
  });
  
  Future<Either<Failure, List<UnitImage>>> getUnitImages(String? unitId, {String? tempKey});
  
  Future<Either<Failure, bool>> updateImage(
    String imageId,
    Map<String, dynamic> data,
  );
  
  Future<Either<Failure, bool>> deleteImage(String imageId);
  
  Future<Either<Failure, bool>> reorderImages(
    String? unitId,
    List<String> imageIds,
  );
  
  Future<Either<Failure, bool>> setAsPrimaryImage(
    String? unitId,
    String imageId,
  );
  
  Future<Either<Failure, bool>> deleteMultipleImages(List<String> imageIds);
  
  Future<Either<Failure, List<UnitImage>>> uploadMultipleImages({
    String? unitId,
    String? tempKey,
    required List<String> filePaths,
    String? category,
    List<String>? tags,
  });
}
