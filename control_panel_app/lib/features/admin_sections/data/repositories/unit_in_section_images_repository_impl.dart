import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/section_image.dart';
import '../../domain/repositories/unit_in_section_images_repository.dart';
import '../datasources/unit_in_section_images_remote_datasource.dart';
import '../models/section_image_model.dart';

class UnitInSectionImagesRepositoryImpl implements UnitInSectionImagesRepository {
  final UnitInSectionImagesRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  UnitInSectionImagesRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, SectionImage>> uploadImage({
    required String unitInSectionId,
    required String filePath,
    String? category,
    String? alt,
    bool isPrimary = false,
    int? order,
    List<String>? tags,
    ProgressCallback? onSendProgress,
    String? tempKey,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final SectionImageModel result = await remoteDataSource.uploadImage(
          unitInSectionId: unitInSectionId,
          filePath: filePath,
          category: category,
          alt: alt,
          isPrimary: isPrimary,
          order: order,
          tags: tags,
          tempKey: tempKey,
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
  Future<Either<Failure, List<SectionImage>>> getImages(String unitInSectionId, {int? page, int? limit}) async {
    if (await networkInfo.isConnected) {
      try {
        final List<SectionImageModel> result = await remoteDataSource.getImages(unitInSectionId, page: page, limit: limit);
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
  Future<Either<Failure, List<SectionImage>>> getImagesByTempKey(String tempKey, {int? page, int? limit}) async {
    if (await networkInfo.isConnected) {
      try {
        final List<SectionImageModel> result = await remoteDataSource.getImagesByTempKey(tempKey, page: page, limit: limit);
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
  Future<Either<Failure, bool>> deleteImage(String unitInSectionId, String imageId, {bool permanent = false}) async {
    if (await networkInfo.isConnected) {
      try {
        final bool result = await remoteDataSource.deleteImageById(imageId, permanent: permanent);
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
  Future<Either<Failure, bool>> deleteImageById(String imageId, {bool permanent = false}) async {
    if (await networkInfo.isConnected) {
      try {
        final bool result = await remoteDataSource.deleteImageById(imageId, permanent: permanent);
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
  Future<Either<Failure, bool>> reorderImages(String unitInSectionId, List<String> imageIds) async {
    if (await networkInfo.isConnected) {
      try {
        final bool result = await remoteDataSource.reorderImages(unitInSectionId, imageIds);
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
  Future<Either<Failure, bool>> reorderImagesByTempKey(String tempKey, List<String> imageIds) async {
    if (await networkInfo.isConnected) {
      try {
        final bool result = await remoteDataSource.reorderImagesByTempKey(tempKey, imageIds);
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
  Future<Either<Failure, bool>> setAsPrimaryImage(String unitInSectionId, String imageId) async {
    if (await networkInfo.isConnected) {
      try {
        final bool result = await remoteDataSource.setAsPrimaryImage(unitInSectionId, imageId);
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
  Future<Either<Failure, bool>> setAsPrimaryImageByTempKey(String imageId, String tempKey) async {
    if (await networkInfo.isConnected) {
      try {
        final bool result = await remoteDataSource.setAsPrimaryImageByTempKey(imageId, tempKey);
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
    required String unitInSectionId,
    required List<String> filePaths,
    String? category,
    List<String>? tags,
    void Function(String filePath, int sent, int total)? onProgress,
  }) async {
    if (await networkInfo.isConnected) {
      final uploaded = <SectionImage>[];
      for (final path in filePaths) {
        final res = await uploadImage(
          unitInSectionId: unitInSectionId,
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
  Future<Either<Failure, bool>> deleteMultipleImages(String unitInSectionId, List<String> imageIds) async {
    if (await networkInfo.isConnected) {
      try {
        var ok = true;
        for (final id in imageIds) {
          final res = await deleteImage(unitInSectionId, id);
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

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/section_image.dart';
import '../../domain/repositories/unit_in_section_images_repository.dart';
import '../datasources/unit_in_section_images_remote_datasource.dart';
import '../models/section_image_model.dart';

class UnitInSectionImagesRepositoryImpl implements UnitInSectionImagesRepository {
  final UnitInSectionImagesRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  UnitInSectionImagesRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, SectionImage>> uploadImage({
    required String unitInSectionId,
    required String filePath,
    String? category,
    String? alt,
    bool isPrimary = false,
    int? order,
    List<String>? tags,
    ProgressCallback? onSendProgress,
    String? tempKey,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final SectionImageModel result = await remoteDataSource.uploadImage(
          unitInSectionId: unitInSectionId,
          filePath: filePath,
          category: category,
          alt: alt,
          isPrimary: isPrimary,
          order: order,
          tags: tags,
          tempKey: tempKey,
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
  Future<Either<Failure, List<SectionImage>>> getImages(String unitInSectionId, {int? page, int? limit}) async {
    if (await networkInfo.isConnected) {
      try {
        final List<SectionImageModel> result = await remoteDataSource.getImages(unitInSectionId, page: page, limit: limit);
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
  Future<Either<Failure, bool>> deleteImage(String unitInSectionId, String imageId, {bool permanent = false}) async {
    if (await networkInfo.isConnected) {
      try {
        final bool result = await remoteDataSource.deleteImage(unitInSectionId, imageId, permanent: permanent);
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
  Future<Either<Failure, bool>> reorderImages(String unitInSectionId, List<String> imageIds) async {
    if (await networkInfo.isConnected) {
      try {
        final bool result = await remoteDataSource.reorderImages(unitInSectionId, imageIds);
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
  Future<Either<Failure, bool>> setAsPrimaryImage(String unitInSectionId, String imageId) async {
    if (await networkInfo.isConnected) {
      try {
        final bool result = await remoteDataSource.setAsPrimaryImage(unitInSectionId, imageId);
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
    required String unitInSectionId,
    required List<String> filePaths,
    String? category,
    List<String>? tags,
    void Function(String filePath, int sent, int total)? onProgress,
  }) async {
    if (await networkInfo.isConnected) {
      final uploaded = <SectionImage>[];
      for (final path in filePaths) {
        final res = await uploadImage(
          unitInSectionId: unitInSectionId,
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
  Future<Either<Failure, bool>> deleteMultipleImages(String unitInSectionId, List<String> imageIds) async {
    if (await networkInfo.isConnected) {
      try {
        var ok = true;
        for (final id in imageIds) {
          final res = await deleteImage(unitInSectionId, id);
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

