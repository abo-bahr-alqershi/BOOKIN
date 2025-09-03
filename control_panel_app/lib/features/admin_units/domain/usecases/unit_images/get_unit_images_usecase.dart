// lib/features/admin_units/domain/usecases/unit_images/get_unit_images_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:bookn_cp_app/core/error/failures.dart';
import 'package:bookn_cp_app/core/usecases/usecase.dart';
import '../../entities/unit_image.dart';
import '../../repositories/unit_images_repository.dart';

class GetUnitImagesUseCase implements UseCase<List<UnitImage>, String> {
  final UnitImagesRepository repository;

  GetUnitImagesUseCase(this.repository);

  @override
  Future<Either<Failure, List<UnitImage>>> call(String? unitId) async {
    return await repository.getUnitImages(unitId);
  }
}