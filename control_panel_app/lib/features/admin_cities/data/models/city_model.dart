import '../../domain/entities/city.dart';

/// 🏙️ City Model for API communication
class CityModel extends City {
  const CityModel({
    required String name,
    required String country,
    required List<String> images,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? propertiesCount,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) : super(
    name: name,
    country: country,
    images: images,
    createdAt: createdAt,
    updatedAt: updatedAt,
    propertiesCount: propertiesCount,
    isActive: isActive,
    metadata: metadata,
  );

  /// تحويل من JSON
  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      images: json['images'] != null 
          ? List<String>.from(json['images']) 
          : [],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      propertiesCount: json['propertiesCount'],
      isActive: json['isActive'] ?? true,
      metadata: json['metadata'],
    );
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'country': country,
      'images': images,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'propertiesCount': propertiesCount,
      'isActive': isActive,
      'metadata': metadata,
    };
  }

  /// تحويل من Entity
  factory CityModel.fromEntity(City city) {
    return CityModel(
      name: city.name,
      country: city.country,
      images: city.images,
      createdAt: city.createdAt,
      updatedAt: city.updatedAt,
      propertiesCount: city.propertiesCount,
      isActive: city.isActive,
      metadata: city.metadata,
    );
  }
}