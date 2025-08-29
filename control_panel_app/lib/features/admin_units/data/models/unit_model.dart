import 'package:bookn_cp_app/features/admin_units/domain/entities/money.dart';
import 'package:bookn_cp_app/features/admin_units/domain/entities/unit_field_value.dart';

import '../../domain/entities/unit.dart';
import '../../domain/entities/pricing_method.dart';
import 'money_model.dart';
import 'unit_field_value_model.dart';

class UnitModel extends Unit {
  const UnitModel({
    required String id,
    required String propertyId,
    required String unitTypeId,
    required String name,
    required Money basePrice,
    required String customFeatures,
    required bool isAvailable,
    required String propertyName,
    required String unitTypeName,
    required PricingMethod pricingMethod,
    List<UnitFieldValue> fieldValues = const [],
    List<FieldGroupWithValues> dynamicFields = const [],
    double? distanceKm,
    List<String>? images,
    int? adultCapacity,
    int? childrenCapacity,
    int? viewCount,
    int? bookingCount,
  }) : super(
          id: id,
          propertyId: propertyId,
          unitTypeId: unitTypeId,
          name: name,
          basePrice: basePrice,
          customFeatures: customFeatures,
          isAvailable: isAvailable,
          propertyName: propertyName,
          unitTypeName: unitTypeName,
          pricingMethod: pricingMethod,
          fieldValues: fieldValues,
          dynamicFields: dynamicFields,
          distanceKm: distanceKm,
          images: images,
          adultCapacity: adultCapacity,
          childrenCapacity: childrenCapacity,
          viewCount: viewCount,
          bookingCount: bookingCount,
        );

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'] as String,
      propertyId: json['propertyId'] as String,
      unitTypeId: json['unitTypeId'] as String,
      name: json['name'] as String,
      basePrice: MoneyModel.fromJson(json['basePrice']),
      customFeatures: json['customFeatures'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool,
      propertyName: json['propertyName'] as String,
      unitTypeName: json['unitTypeName'] as String,
      pricingMethod: PricingMethod.fromString(json['pricingMethod'] as String),
      fieldValues: (json['fieldValues'] as List?)
              ?.map((e) => UnitFieldValueModel.fromJson(e))
              .toList() ??
          [],
      dynamicFields: (json['dynamicFields'] as List?)
              ?.map((e) => FieldGroupWithValuesModel.fromJson(e))
              .toList() ??
          [],
      distanceKm: json['distanceKm'] as double?,
      images: (json['images'] as List?)
              ?.map((e) => e['url'] as String)
              .toList() ??
          [],
      adultCapacity: json['adultCapacity'] as int?,
      childrenCapacity: json['childrenCapacity'] as int?,
      viewCount: json['viewCount'] as int?,
      bookingCount: json['bookingCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propertyId': propertyId,
      'unitTypeId': unitTypeId,
      'name': name,
      'basePrice': MoneyModel.fromEntity(basePrice).toJson(),
      'customFeatures': customFeatures,
      'isAvailable': isAvailable,
      'propertyName': propertyName,
      'unitTypeName': unitTypeName,
      'pricingMethod': pricingMethod.value,
      'fieldValues': fieldValues
          .map((e) => UnitFieldValueModel.fromEntity(e).toJson())
          .toList(),
      'dynamicFields': dynamicFields
          .map((e) => FieldGroupWithValuesModel.fromEntity(e).toJson())
          .toList(),
      if (distanceKm != null) 'distanceKm': distanceKm,
      if (images != null) 'images': images,
      if (adultCapacity != null) 'adultCapacity': adultCapacity,
      if (childrenCapacity != null) 'childrenCapacity': childrenCapacity,
      if (viewCount != null) 'viewCount': viewCount,
      if (bookingCount != null) 'bookingCount': bookingCount,
    };
  }
}