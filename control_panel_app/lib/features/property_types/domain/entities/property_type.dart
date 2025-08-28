import 'package:equatable/equatable.dart';

/// 🏢 كيان نوع الملكية
class PropertyType extends Equatable {
  final String id;
  final String name;
  final String description;
  final String defaultAmenities;
  final String icon;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PropertyType({
    required this.id,
    required this.name,
    required this.description,
    required this.defaultAmenities,
    required this.icon,
    this.createdAt,
    this.updatedAt,
  });

  PropertyType copyWith({
    String? id,
    String? name,
    String? description,
    String? defaultAmenities,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PropertyType(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      defaultAmenities: defaultAmenities ?? this.defaultAmenities,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        defaultAmenities,
        icon,
        createdAt,
        updatedAt,
      ];
}