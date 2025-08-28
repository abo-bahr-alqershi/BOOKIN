// lib/features/admin_properties/data/models/property_type_model.dart

import '../../domain/entities/property_type.dart';

class PropertyTypeModel extends PropertyType {
  const PropertyTypeModel({
    required String id,
    required String name,
    required String description,
    required String defaultAmenities,
    required String icon,
    int propertiesCount = 0,
    bool isActive = true,
  }) : super(
    id: id,
    name: name,
    description: description,
    defaultAmenities: defaultAmenities,
    icon: icon,
    propertiesCount: propertiesCount,
    isActive: isActive,
  );
  
  factory PropertyTypeModel.fromJson(Map<String, dynamic> json) {
    return PropertyTypeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      defaultAmenities: json['defaultAmenities'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      propertiesCount: json['propertiesCount'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'defaultAmenities': defaultAmenities,
      'icon': icon,
      'propertiesCount': propertiesCount,
      'isActive': isActive,
    };
  }
}