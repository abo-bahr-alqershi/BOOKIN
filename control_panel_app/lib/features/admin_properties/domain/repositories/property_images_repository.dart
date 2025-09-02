// lib/features/admin_properties/domain/repositories/property_images_repository.dart

import 'package:bookn_cp_app/features/admin_properties/domain/entities/property_image.dart';
import 'package:dartz/dartz.dart';
import 'package:bookn_cp_app/core/error/failures.dart';

abstract class PropertyImagesRepository {
  Future<Either<Failure, PropertyImage>> uploadImage({
    required String propertyId,
    required String filePath,
    String? category,
    String? alt,
    bool isPrimary = false,
    int? order,
    List<String>? tags,
  });
  
  Future<Either<Failure, List<PropertyImage>>> getPropertyImages(String propertyId);
  
  Future<Either<Failure, bool>> updateImage(
    String imageId,
    Map<String, dynamic> data,
  );
  
  Future<Either<Failure, bool>> deleteImage(String imageId);
  
  Future<Either<Failure, bool>> reorderImages(
    String propertyId,
    List<String> imageIds,
  );
  
  Future<Either<Failure, bool>> setAsPrimaryImage(
    String propertyId,
    String imageId,
  );
  
  Future<Either<Failure, bool>> deleteMultipleImages(List<String> imageIds);
  
  Future<Either<Failure, List<PropertyImage>>> uploadMultipleImages({
    required String propertyId,
    required List<String> filePaths,
    String? category,
    List<String>? tags,
  });
}