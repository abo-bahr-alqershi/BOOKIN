import 'package:dartz/dartz.dart' hide Unit;
import 'package:equatable/equatable.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/unit.dart';
import '../repositories/units_repository.dart';

class GetUnitsUseCase implements UseCase<List<Unit>, GetUnitsParams> {
  final UnitsRepository repository;

  GetUnitsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Unit>>> call(GetUnitsParams params) async {
    return await repository.getUnits(
      pageNumber: params.pageNumber,
      pageSize: params.pageSize,
      propertyId: params.propertyId,
      unitTypeId: params.unitTypeId,
      isAvailable: params.isAvailable,
      minPrice: params.minPrice,
      maxPrice: params.maxPrice,
      searchQuery: params.searchQuery,
    );
  }
}

class GetUnitsParams extends Equatable {
  final int? pageNumber;
  final int? pageSize;
  final String? propertyId;
  final String? unitTypeId;
  final bool? isAvailable;
  final double? minPrice;
  final double? maxPrice;
  final String? searchQuery;

  const GetUnitsParams({
    this.pageNumber,
    this.pageSize,
    this.propertyId,
    this.unitTypeId,
    this.isAvailable,
    this.minPrice,
    this.maxPrice,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [
        pageNumber,
        pageSize,
        propertyId,
        unitTypeId,
        isAvailable,
        minPrice,
        maxPrice,
        searchQuery,
      ];
}