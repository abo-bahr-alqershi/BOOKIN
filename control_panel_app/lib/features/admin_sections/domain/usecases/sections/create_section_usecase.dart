import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../domain/entities/section.dart';
import '../../../domain/repositories/sections_repository.dart';

class CreateSectionUseCase implements UseCase<Section, CreateSectionParams> {
  final SectionsRepository repository;
  CreateSectionUseCase(this.repository);

  @override
  Future<Either<Failure, Section>> call(CreateSectionParams params) {
    return repository.createSection(params.section);
  }
}

class CreateSectionParams extends Equatable {
  final Section section;
  const CreateSectionParams(this.section);

  @override
  List<Object?> get props => [section];
}

