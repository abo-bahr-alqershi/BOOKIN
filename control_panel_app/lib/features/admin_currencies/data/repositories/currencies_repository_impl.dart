import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/currency.dart';
import '../../domain/repositories/currencies_repository.dart';
import '../datasources/currencies_local_datasource.dart';
import '../datasources/currencies_remote_datasource.dart';
import '../models/currency_model.dart';

class CurrenciesRepositoryImpl implements CurrenciesRepository {
  final CurrenciesRemoteDataSource remoteDataSource;
  final CurrenciesLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  CurrenciesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Currency>>> getCurrencies() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteCurrencies = await remoteDataSource.getCurrencies();
        await localDataSource.cacheCurrencies(remoteCurrencies);
        return Right(remoteCurrencies);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      try {
        final localCurrencies = await localDataSource.getCachedCurrencies();
        return Right(localCurrencies);
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> saveCurrencies(List<Currency> currencies) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }

    try {
      final currencyModels = currencies
          .map((c) => CurrencyModel.fromEntity(c))
          .toList();
      
      final result = await remoteDataSource.saveCurrencies(currencyModels);
      
      if (result) {
        await localDataSource.cacheCurrencies(currencyModels);
      }
      
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCurrency(String code) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }

    try {
      // Get current currencies
      final currentCurrencies = await remoteDataSource.getCurrencies();
      
      // Remove the currency with the given code
      final updatedCurrencies = currentCurrencies
          .where((c) => c.code != code)
          .toList();
      
      // Save updated list
      final result = await remoteDataSource.saveCurrencies(updatedCurrencies);
      
      if (result) {
        await localDataSource.cacheCurrencies(updatedCurrencies);
      }
      
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> setDefaultCurrency(String code) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }

    try {
      final currentCurrencies = await remoteDataSource.getCurrencies();
      
      final updatedCurrencies = currentCurrencies.map((c) {
        return CurrencyModel(
          code: c.code,
          arabicCode: c.arabicCode,
          name: c.name,
          arabicName: c.arabicName,
          isDefault: c.code == code,
          exchangeRate: c.exchangeRate,
          lastUpdated: c.lastUpdated,
        );
      }).toList();
      
      final result = await remoteDataSource.saveCurrencies(updatedCurrencies);
      
      if (result) {
        await localDataSource.cacheCurrencies(updatedCurrencies);
      }
      
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}