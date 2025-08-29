part of 'unit_form_bloc.dart';

abstract class UnitFormState extends Equatable {
  const UnitFormState();

  @override
  List<Object?> get props => [];
}

class UnitFormInitial extends UnitFormState {}

class UnitFormLoading extends UnitFormState {}

class UnitFormReady extends UnitFormState {
  final bool isEditMode;
  final String? unitId;
  final String? selectedPropertyId;
  final List<UnitType> availableUnitTypes;
  final UnitType? selectedUnitType;
  final List<UnitTypeField> unitTypeFields;
  final String? unitName;
  final Money? basePrice;
  final PricingMethod? pricingMethod;
  final String? customFeatures;
  final Map<String, dynamic> dynamicFieldValues;
  final List<String>? images;
  final int? adultCapacity;
  final int? childrenCapacity;
  final bool isLoadingUnitTypes;
  final bool isLoadingFields;

  const UnitFormReady({
    this.isEditMode = false,
    this.unitId,
    this.selectedPropertyId,
    this.availableUnitTypes = const [],
    this.selectedUnitType,
    this.unitTypeFields = const [],
    this.unitName,
    this.basePrice,
    this.pricingMethod,
    this.customFeatures,
    this.dynamicFieldValues = const {},
    this.images,
    this.adultCapacity,
    this.childrenCapacity,
    this.isLoadingUnitTypes = false,
    this.isLoadingFields = false,
  });

  UnitFormReady copyWith({
    bool? isEditMode,
    String? unitId,
    String? selectedPropertyId,
    List<UnitType>? availableUnitTypes,
    UnitType? selectedUnitType,
    List<UnitTypeField>? unitTypeFields,
    String? unitName,
    Money? basePrice,
    PricingMethod? pricingMethod,
    String? customFeatures,
    Map<String, dynamic>? dynamicFieldValues,
    List<String>? images,
    int? adultCapacity,
    int? childrenCapacity,
    bool? isLoadingUnitTypes,
    bool? isLoadingFields,
  }) {
    return UnitFormReady(
      isEditMode: isEditMode ?? this.isEditMode,
      unitId: unitId ?? this.unitId,
      selectedPropertyId: selectedPropertyId ?? this.selectedPropertyId,
      availableUnitTypes: availableUnitTypes ?? this.availableUnitTypes,
      selectedUnitType: selectedUnitType ?? this.selectedUnitType,
      unitTypeFields: unitTypeFields ?? this.unitTypeFields,
      unitName: unitName ?? this.unitName,
      basePrice: basePrice ?? this.basePrice,
      pricingMethod: pricingMethod ?? this.pricingMethod,
      customFeatures: customFeatures ?? this.customFeatures,
      dynamicFieldValues: dynamicFieldValues ?? this.dynamicFieldValues,
      images: images ?? this.images,
      adultCapacity: adultCapacity ?? this.adultCapacity,
      childrenCapacity: childrenCapacity ?? this.childrenCapacity,
      isLoadingUnitTypes: isLoadingUnitTypes ?? this.isLoadingUnitTypes,
      isLoadingFields: isLoadingFields ?? this.isLoadingFields,
    );
  }

  @override
  List<Object?> get props => [
        isEditMode,
        unitId,
        selectedPropertyId,
        availableUnitTypes,
        selectedUnitType,
        unitTypeFields,
        unitName,
        basePrice,
        pricingMethod,
        customFeatures,
        dynamicFieldValues,
        images,
        adultCapacity,
        childrenCapacity,
        isLoadingUnitTypes,
        isLoadingFields,
      ];
}

class UnitFormSubmitted extends UnitFormState {}

class UnitFormError extends UnitFormState {
  final String message;

  const UnitFormError({required this.message});

  @override
  List<Object> get props => [message];
}