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
  final List<String>? amenityIds; // أضف هذا السطر
  
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
    this.amenityIds, // أضف هذا السطر
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
    'images': images ?? [],
    'amenityIds': amenityIds ?? [],
    'isApproved': false, // أضف هذا لتجنب مشاكل API
    'isActive': true,    // أضف هذا أيضاً
  };
}

class CreatePropertyUseCase implements UseCase<String, CreatePropertyParams> {
  final PropertiesRepository repository;
  
  CreatePropertyUseCase(this.repository);
  
  @override
  Future<Either<Failure, String>> call(CreatePropertyParams params) async {
    // تحقق من صحة البيانات قبل الإرسال
    if (params.starRating < 1 || params.starRating > 5) {
      return Left(ValidationFailure('تقييم النجوم يجب أن يكون بين 1 و 5'));
    }
    
    if (params.latitude < -90 || params.latitude > 90) {
      return Left(ValidationFailure('خط العرض غير صحيح'));
    }
    
    if (params.longitude < -180 || params.longitude > 180) {
      return Left(ValidationFailure('خط الطول غير صحيح'));
    }
    
    return await repository.createProperty(params.toJson());
  }
}