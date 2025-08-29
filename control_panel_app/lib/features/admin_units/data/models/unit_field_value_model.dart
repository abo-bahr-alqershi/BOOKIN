import '../../domain/entities/unit_field_value.dart';

class UnitFieldValueModel extends UnitFieldValue {
  const UnitFieldValueModel({
    required String fieldId,
    required String fieldValue,
    String? fieldName,
    String? displayName,
    String? fieldTypeId,
  }) : super(
          fieldId: fieldId,
          fieldValue: fieldValue,
          fieldName: fieldName,
          displayName: displayName,
          fieldTypeId: fieldTypeId,
        );

  factory UnitFieldValueModel.fromJson(Map<String, dynamic> json) {
    return UnitFieldValueModel(
      fieldId: json['fieldId'] as String,
      fieldValue: json['fieldValue'] as String,
      fieldName: json['fieldName'] as String?,
      displayName: json['displayName'] as String?,
      fieldTypeId: json['fieldTypeId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fieldId': fieldId,
      'fieldValue': fieldValue,
      if (fieldName != null) 'fieldName': fieldName,
      if (displayName != null) 'displayName': displayName,
      if (fieldTypeId != null) 'fieldTypeId': fieldTypeId,
    };
  }

  factory UnitFieldValueModel.fromEntity(UnitFieldValue entity) {
    return UnitFieldValueModel(
      fieldId: entity.fieldId,
      fieldValue: entity.fieldValue,
      fieldName: entity.fieldName,
      displayName: entity.displayName,
      fieldTypeId: entity.fieldTypeId,
    );
  }
}

class FieldGroupWithValuesModel extends FieldGroupWithValues {
  const FieldGroupWithValuesModel({
    required String groupId,
    required String groupName,
    required String displayName,
    required String description,
    required List<UnitFieldValue> fieldValues,
  }) : super(
          groupId: groupId,
          groupName: groupName,
          displayName: displayName,
          description: description,
          fieldValues: fieldValues,
        );

  factory FieldGroupWithValuesModel.fromJson(Map<String, dynamic> json) {
    return FieldGroupWithValuesModel(
      groupId: json['groupId'] as String,
      groupName: json['groupName'] as String,
      displayName: json['displayName'] as String,
      description: json['description'] as String,
      fieldValues: (json['fieldValues'] as List)
          .map((e) => UnitFieldValueModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'displayName': displayName,
      'description': description,
      'fieldValues': fieldValues
          .map((e) => UnitFieldValueModel.fromEntity(e).toJson())
          .toList(),
    };
  }

  factory FieldGroupWithValuesModel.fromEntity(FieldGroupWithValues entity) {
    return FieldGroupWithValuesModel(
      groupId: entity.groupId,
      groupName: entity.groupName,
      displayName: entity.displayName,
      description: entity.description,
      fieldValues: entity.fieldValues,
    );
  }
}