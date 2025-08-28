// lib/features/admin_properties/domain/usecases/properties/create_property_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:bookn_cp_app/core/error/failures.dart';
import 'package:bookn_cp_app/core/usecases/usecase.dart';
import '../../repositories/properties_repository.dart';

class CreatePropertyParams {
  final String name;
  final String address;
  final String propertyTypeId;
  final String ownerId;
  final String description;
  final double latitude;
  final double longitude;
  final String city;
  final int starRating;
  final List<String>? images;
  
  CreatePropertyParams({
    required this.name,
    required this.address,
    required this.propertyTypeId,
    required this.ownerId,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.starRating,
    this.images,
  });
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'address': address,
    'propertyTypeId': propertyTypeId,
    'ownerId': ownerId,
    'description': description,
    'latitude': latitude,
    'longitude': longitude,
    'city': city,
    'starRating': starRating,
    if (images != null) 'images': images,
  };
}

class CreatePropertyUseCase implements UseCase<String, CreatePropertyParams> {
  final PropertiesRepository repository;
  
  CreatePropertyUseCase(this.repository);
  
  @override
  Future<Either<Failure, String>> call(CreatePropertyParams params) async {
    return await repository.createProperty(params.toJson());
  }
}