import 'package:dartz/dartz.dart' hide Unit;
import 'package:dio/dio.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/network/network_info.dart';
import '../../domain/entities/unit.dart';
import '../../domain/entities/unit_type.dart';
import '../../domain/repositories/units_repository.dart';
import '../datasources/units_local_datasource.dart';
import '../datasources/units_remote_datasource.dart';

class UnitsRepositoryImpl implements UnitsRepository {
  final UnitsRemoteDataSource remoteDataSource;
  final UnitsLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  UnitsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Unit>>> getUnits({
    int? pageNumber,
    int? pageSize,
    String? propertyId,
    String? unitTypeId,
    bool? isAvailable,
    double? minPrice,
    double? maxPrice,
    String? searchQuery,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteUnits = await remoteDataSource.getUnits(
          pageNumber: pageNumber,
          pageSize: pageSize,
          propertyId: propertyId,
          unitTypeId: unitTypeId,
          isAvailable: isAvailable,
          minPrice: minPrice,
          maxPrice: maxPrice,
          searchQuery: searchQuery,
        );
        await localDataSource.cacheUnits(remoteUnits);
        return Right(remoteUnits);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on DioException catch (e) {
        return Left(ServerFailure(e.message ?? 'حدث خطأ في الاتصال'));
      } catch (e) {
        return Left(ServerFailure('حدث خطأ غير متوقع'));
      }
    } else {
      try {
        final localUnits = await localDataSource.getCachedUnits();
        return Right(localUnits);
      } on CacheException {
        return Left(CacheFailure('لا توجد بيانات محفوظة'));
      }
    }
  }

  @override
  Future<Either<Failure, Unit>> getUnitDetails(String unitId) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteUnit = await remoteDataSource.getUnitDetails(unitId);
        await localDataSource.cacheUnit(remoteUnit);
        return Right(remoteUnit);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      try {
        final localUnit = await localDataSource.getCachedUnit(unitId);
        if (localUnit != null) {
          return Right(localUnit);
        } else {
          return Left(CacheFailure('لا توجد بيانات محفوظة'));
        }
      } on CacheException {
        return Left(CacheFailure('لا توجد بيانات محفوظة'));
      }
    }
  }

  @override
  Future<Either<Failure, String>> createUnit({
    required String propertyId,
    required String unitTypeId,
    required String name,
    required Map<String, dynamic> basePrice,
    required String customFeatures,
    required String pricingMethod,
    List<Map<String, dynamic>>? fieldValues,
    List<String>? images,
    int? adultCapacity,
    int? childrenCapacity,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final unitData = {
          'propertyId': propertyId,
          'unitTypeId': unitTypeId,
          'name': name,
          'basePrice': basePrice,
          'customFeatures': customFeatures,
          'pricingMethod': pricingMethod,
          'fieldValues': fieldValues,
          'images': images,
          'adultCapacity': adultCapacity,
          'childrenCapacity': childrenCapacity,
        };
        final unitId = await remoteDataSource.createUnit(unitData);
        return Right(unitId);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateUnit({
    required String unitId,
    String? name,
    Map<String, dynamic>? basePrice,
    String? customFeatures,
    String? pricingMethod,
    List<Map<String, dynamic>>? fieldValues,
    List<String>? images,
    int? adultCapacity,
    int? childrenCapacity,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final unitData = {
          if (name != null) 'name': name,
          if (basePrice != null) 'basePrice': basePrice,
          if (customFeatures != null) 'customFeatures': customFeatures,
          if (pricingMethod != null) 'pricingMethod': pricingMethod,
          if (fieldValues != null) 'fieldValues': fieldValues,
          if (images != null) 'images': images,
          if (adultCapacity != null) 'adultCapacity': adultCapacity,
          if (childrenCapacity != null) 'childrenCapacity': childrenCapacity,
        };
        final result = await remoteDataSource.updateUnit(unitId, unitData);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteUnit(String unitId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.deleteUnit(unitId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Future<Either<Failure, List<UnitType>>> getUnitTypesByProperty(
    String propertyTypeId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final unitTypes = await remoteDataSource.getUnitTypesByProperty(propertyTypeId);
        return Right(unitTypes);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Future<Either<Failure, List<UnitTypeField>>> getUnitFields(String unitTypeId) async {
    if (await networkInfo.isConnected) {
      try {
        final fields = await remoteDataSource.getUnitFields(unitTypeId);
        return Right(fields);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Future<Either<Failure, bool>> assignUnitToSections(
    String unitId,
    List<String> sectionIds,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.assignUnitToSections(unitId, sectionIds);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }
}