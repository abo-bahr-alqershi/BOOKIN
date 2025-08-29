import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../repositories/units_repository.dart';

class UpdateUnitUseCase implements UseCase<bool, UpdateUnitParams> {
  final UnitsRepository repository;

  UpdateUnitUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(UpdateUnitParams params) async {
    return await repository.updateUnit(
      unitId: params.unitId,
      name: params.name,
      basePrice: params.basePrice,
      customFeatures: params.customFeatures,
      pricingMethod: params.pricingMethod,
      fieldValues: params.fieldValues,
      images: params.images,
      adultCapacity: params.adultCapacity,
      childrenCapacity: params.childrenCapacity,
    );
  }
}

class UpdateUnitParams extends Equatable {
  final String unitId;
  final String? name;
  final Map<String, dynamic>? basePrice;
  final String? customFeatures;
  final String? pricingMethod;
  final List<Map<String, dynamic>>? fieldValues;
  final List<String>? images;
  final int? adultCapacity;
  final int? childrenCapacity;

  const UpdateUnitParams({
    required this.unitId,
    this.name,
    this.basePrice,
    this.customFeatures,
    this.pricingMethod,
    this.fieldValues,
    this.images,
    this.adultCapacity,
    this.childrenCapacity,
  });

  @override
  List<Object?> get props => [
        unitId,
        name,
        basePrice,
        customFeatures,
        pricingMethod,
        fieldValues,
        images,
        adultCapacity,
        childrenCapacity,
      ];
}