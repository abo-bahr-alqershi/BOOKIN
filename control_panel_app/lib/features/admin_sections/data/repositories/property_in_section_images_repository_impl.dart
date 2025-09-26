import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/section_image.dart';
import '../../domain/repositories/property_in_section_images_repository.dart';
import '../datasources/property_in_section_images_remote_datasource.dart';
import '../models/section_image_model.dart';

class PropertyInSectionImagesRepositoryImpl implements PropertyInSectionImagesRepository {
  final PropertyInSectionImagesRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  PropertyInSectionImagesRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, SectionImage>> uploadImage({
    required String propertyInSectionId,
    required String filePath,
    String? category,
    String? alt,
    bool isPrimary = false,
    int? order,
    List<String>? tags,
    ProgressCallback? onSendProgress,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final SectionImageModel result = await remoteDataSource.uploadImage(
          propertyInSectionId: propertyInSectionId,
          filePath: filePath,
          category: category,
          alt: alt,
          isPrimary: isPrimary,
          order: order,
          tags: tags,
          onSendProgress: onSendProgress,
        );
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<SectionImage>>> getImages(String propertyInSectionId, {int? page, int? limit}) async {
    if (await networkInfo.isConnected) {
      try {
        final List<SectionImageModel> result = await remoteDataSource.getImages(propertyInSectionId, page: page, limit: limit);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> updateImage(String imageId, Map<String, dynamic> data) async {
    if (await networkInfo.isConnected) {
      try {
        final bool result = await remoteDataSource.updateImage(imageId, data);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteImage(String propertyInSectionId, String imageId, {bool permanent = false}) async {
    if (await networkInfo.isConnected) {
      try {
        final bool result = await remoteDataSource.deleteImage(propertyInSectionId, imageId, permanent: permanent);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> reorderImages(String propertyInSectionId, List<String> imageIds) async {
    if (await networkInfo.isConnected) {
      try {
        final bool result = await remoteDataSource.reorderImages(propertyInSectionId, imageIds);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> setAsPrimaryImage(String propertyInSectionId, String imageId) async {
    if (await networkInfo.isConnected) {
      try {
        final bool result = await remoteDataSource.setAsPrimaryImage(propertyInSectionId, imageId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<SectionImage>>> uploadMultipleImages({
    required String propertyInSectionId,
    required List<String> filePaths,
    String? category,
    List<String>? tags,
    void Function(String filePath, int sent, int total)? onProgress,
  }) async {
    if (await networkInfo.isConnected) {
      final uploaded = <SectionImage>[];
      for (final path in filePaths) {
        final res = await uploadImage(
          propertyInSectionId: propertyInSectionId,
          filePath: path,
          category: category,
          tags: tags,
          onSendProgress: (sent, total) => onProgress?.call(path, sent, total),
        );
        res.fold((_) {}, (img) => uploaded.add(img));
      }
      return Right(uploaded);
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteMultipleImages(String propertyInSectionId, List<String> imageIds) async {
    if (await networkInfo.isConnected) {
      try {
        var ok = true;
        for (final id in imageIds) {
          final res = await deleteImage(propertyInSectionId, id);
          res.fold((_) => ok = false, (_) {});
        }
        return Right(ok);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}

