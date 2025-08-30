import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/cities_repository.dart';

class UploadCityImageUseCase implements UseCase<String, UploadCityImageParams> {
  final CitiesRepository repository;

  UploadCityImageUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(UploadCityImageParams params) async {
    return await repository.uploadCityImage(params.imagePath);
  }
}

class UploadCityImageParams extends Equatable {
  final String cityName;
  final String imagePath;

  const UploadCityImageParams({
    required this.cityName,
    required this.imagePath,
  });

  @override
  List<Object?> get props => [cityName, imagePath];
}