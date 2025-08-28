// lib/features/admin_properties/data/models/property_model.dart

import 'package:bookn_cp_app/features/admin_properties/domain/entities/amenity.dart';
import 'package:bookn_cp_app/features/admin_properties/domain/entities/policy.dart';
import 'package:bookn_cp_app/features/admin_properties/domain/entities/property.dart';
import 'package:bookn_cp_app/features/admin_properties/domain/entities/property_image.dart';
import 'property_image_model.dart';
import 'amenity_model.dart';
import 'policy_model.dart';

class PropertyModel extends Property {
  const PropertyModel({
    required String id,
    required String ownerId,
    required String typeId,
    required String name,
    required String address,
    required String city,
    double? latitude,
    double? longitude,
    required int starRating,
    required String description,
    required bool isApproved,
    required DateTime createdAt,
    required String ownerName,
    required String typeName,
    double? distanceKm,
    List<PropertyImage> images = const [],
    List<Amenity> amenities = const [],
    List<Policy> policies = const [],
    PropertyStats? stats,
  }) : super(
    id: id,
    ownerId: ownerId,
    typeId: typeId,
    name: name,
    address: address,
    city: city,
    latitude: latitude,
    longitude: longitude,
    starRating: starRating,
    description: description,
    isApproved: isApproved,
    createdAt: createdAt,
    ownerName: ownerName,
    typeName: typeName,
    distanceKm: distanceKm,
    images: images,
    amenities: amenities,
    policies: policies,
    stats: stats,
  );
  
  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      typeId: json['typeId'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      starRating: json['starRating'] as int,
      description: json['description'] as String,
      isApproved: json['isApproved'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      ownerName: json['ownerName'] as String,
      typeName: json['typeName'] as String,
      distanceKm: json['distanceKm']?.toDouble(),
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => PropertyImageModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      amenities: (json['amenities'] as List<dynamic>?)
          ?.map((e) => AmenityModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      policies: (json['policies'] as List<dynamic>?)
          ?.map((e) => PolicyModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      stats: json['stats'] != null 
          ? PropertyStatsModel.fromJson(json['stats'] as Map<String, dynamic>)
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'typeId': typeId,
      'name': name,
      'address': address,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'starRating': starRating,
      'description': description,
      'isApproved': isApproved,
      'createdAt': createdAt.toIso8601String(),
      'ownerName': ownerName,
      'typeName': typeName,
      'distanceKm': distanceKm,
      'images': images.map((e) => (e as PropertyImageModel).toJson()).toList(),
      'amenities': amenities.map((e) => (e as AmenityModel).toJson()).toList(),
      'policies': policies.map((e) => (e as PolicyModel).toJson()).toList(),
      'stats': stats != null ? (stats as PropertyStatsModel).toJson() : null,
    };
  }
}

class PropertyStatsModel extends PropertyStats {
  const PropertyStatsModel({
    required int totalBookings,
    required int activeBookings,
    required double averageRating,
    required int reviewCount,
    required double occupancyRate,
    required double monthlyRevenue,
  }) : super(
    totalBookings: totalBookings,
    activeBookings: activeBookings,
    averageRating: averageRating,
    reviewCount: reviewCount,
    occupancyRate: occupancyRate,
    monthlyRevenue: monthlyRevenue,
  );
  
  factory PropertyStatsModel.fromJson(Map<String, dynamic> json) {
    return PropertyStatsModel(
      totalBookings: json['totalBookings'] as int,
      activeBookings: json['activeBookings'] as int,
      averageRating: (json['averageRating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      occupancyRate: (json['occupancyRate'] as num).toDouble(),
      monthlyRevenue: (json['monthlyRevenue'] as num).toDouble(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'totalBookings': totalBookings,
      'activeBookings': activeBookings,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'occupancyRate': occupancyRate,
      'monthlyRevenue': monthlyRevenue,
    };
  }
}