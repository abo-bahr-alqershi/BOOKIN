import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/amenities_repository.dart';

class CreateAmenityUseCase implements UseCase<String, CreateAmenityParams> {
  final AmenitiesRepository repository;

  CreateAmenityUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(CreateAmenityParams params) async {
    return await repository.createAmenity(
      name: params.name,
      description: params.description,
      icon: params.icon,
    );
  }
}

class CreateAmenityParams extends Equatable {
  final String name;
  final String description;
  final String icon;

  const CreateAmenityParams({
    required this.name,
    required this.description,
    required this.icon,
  });

  @override
  List<Object> get props => [name, description, icon];
}