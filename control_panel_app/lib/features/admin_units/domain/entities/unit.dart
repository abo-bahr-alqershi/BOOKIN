import 'package:equatable/equatable.dart';
import 'money.dart';
import 'pricing_method.dart';
import 'unit_field_value.dart';

class Unit extends Equatable {
  final String id;
  final String propertyId;
  final String unitTypeId;
  final String name;
  final Money basePrice;
  final String customFeatures;
  final bool isAvailable;
  final String propertyName;
  final String unitTypeName;
  final PricingMethod pricingMethod;
  final List<UnitFieldValue> fieldValues;
  final List<FieldGroupWithValues> dynamicFields;
  final double? distanceKm;
  final List<String>? images;
  final int? adultCapacity;
  final int? childrenCapacity;
  final int? viewCount;
  final int? bookingCount;

  const Unit({
    required this.id,
    required this.propertyId,
    required this.unitTypeId,
    required this.name,
    required this.basePrice,
    required this.customFeatures,
    required this.isAvailable,
    required this.propertyName,
    required this.unitTypeName,
    required this.pricingMethod,
    this.fieldValues = const [],
    this.dynamicFields = const [],
    this.distanceKm,
    this.images,
    this.adultCapacity,
    this.childrenCapacity,
    this.viewCount,
    this.bookingCount,
  });

  List<String> get featuresList {
    if (customFeatures.isEmpty) return [];
    return customFeatures.split(',').map((e) => e.trim()).toList();
  }

  String get capacityDisplay {
    final capacities = <String>[];
    if (adultCapacity != null) capacities.add('👨 $adultCapacity');
    if (childrenCapacity != null) capacities.add('👶 $childrenCapacity');
    return capacities.join(' • ');
  }

  @override
  List<Object?> get props => [
        id,
        propertyId,
        unitTypeId,
        name,
        basePrice,
        customFeatures,
        isAvailable,
        propertyName,
        unitTypeName,
        pricingMethod,
        fieldValues,
        dynamicFields,
        distanceKm,
        images,
        adultCapacity,
        childrenCapacity,
        viewCount,
        bookingCount,
      ];
}