import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/unit_type.dart';

class DynamicFieldsWidget extends StatelessWidget {
  final List<UnitTypeField> fields;
  final Map<String, dynamic> values;
  final Function(Map<String, dynamic>) onChanged;
  final bool isReadOnly;

  const DynamicFieldsWidget({
    super.key,
    required this.fields,
    required this.values,
    required this.onChanged,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    if (fields.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: fields.map((field) => _buildField(field)).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withOpacity(0.3),
            AppTheme.darkCard.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.dynamic_form,
              size: 48,
              color: AppTheme.textMuted.withOpacity(0.5),
            ),
            const SizedBox(height: AppDimensions.spaceMedium),
            Text(
              'لا توجد حقول ديناميكية',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(UnitTypeField field) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel(field),
          const SizedBox(height: AppDimensions.spaceSmall),
          _buildFieldInput(field),
          if (field.description.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spaceXSmall),
            _buildFieldDescription(field.description),
          ],
        ],
      ),
    );
  }

  Widget _buildFieldLabel(UnitTypeField field) {
    return Row(
      children: [
        Text(
          field.displayName,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (field.isRequired)
          Text(
            ' *',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.error,
            ),
          ),
      ],
    );
  }

  Widget _buildFieldDescription(String description) {
    return Text(
      description,
      style: AppTextStyles.caption.copyWith(
        color: AppTheme.textMuted.withOpacity(0.7),
      ),
    );
  }

  Widget _buildFieldInput(UnitTypeField field) {
    switch (field.fieldTypeId) {
      case 'text':
      case 'email':
      case 'phone':
        return _buildTextField(field);
      case 'textarea':
        return _buildTextArea(field);
      case 'number':
      case 'currency':
        return _buildNumberField(field);
      case 'boolean':
        return _buildBooleanField(field);
      case 'select':
        return _buildSelectField(field);
      case 'multiselect':
        return _buildMultiSelectField(field);
      case 'date':
        return _buildDateField(field);
      default:
        return _buildTextField(field);
    }
  }

  Widget _buildTextField(UnitTypeField field) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withOpacity(0.5),
            AppTheme.darkCard.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: TextEditingController(text: values[field.fieldId] ?? ''),
        style: AppTextStyles.bodyMedium.copyWith(color: AppTheme.textWhite),
        readOnly: isReadOnly,
        decoration: InputDecoration(
          hintText: 'أدخل ${field.displayName}',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textMuted.withOpacity(0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(AppDimensions.paddingMedium),
          prefixIcon: _getFieldIcon(field.fieldTypeId),
        ),
        inputFormatters: _getInputFormatters(field),
        onChanged: (value) {
          final newValues = Map<String, dynamic>.from(values);
          newValues[field.fieldId] = value;
          onChanged(newValues);
        },
      ),
    );
  }

  Widget _buildTextArea(UnitTypeField field) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withOpacity(0.5),
            AppTheme.darkCard.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: TextEditingController(text: values[field.fieldId] ?? ''),
        style: AppTextStyles.bodyMedium.copyWith(color: AppTheme.textWhite),
        readOnly: isReadOnly,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'أدخل ${field.displayName}',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textMuted.withOpacity(0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(AppDimensions.paddingMedium),
        ),
        onChanged: (value) {
          final newValues = Map<String, dynamic>.from(values);
          newValues[field.fieldId] = value;
          onChanged(newValues);
        },
      ),
    );
  }

  Widget _buildNumberField(UnitTypeField field) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withOpacity(0.5),
            AppTheme.darkCard.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: TextEditingController(
          text: values[field.fieldId]?.toString() ?? '',
        ),
        style: AppTextStyles.bodyMedium.copyWith(color: AppTheme.textWhite),
        readOnly: isReadOnly,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          hintText: 'أدخل ${field.displayName}',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textMuted.withOpacity(0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(AppDimensions.paddingMedium),
          prefixIcon: _getFieldIcon(field.fieldTypeId),
        ),
        onChanged: (value) {
          final newValues = Map<String, dynamic>.from(values);
          newValues[field.fieldId] = int.tryParse(value) ?? 0;
          onChanged(newValues);
        },
      ),
    );
  }

  Widget _buildBooleanField(UnitTypeField field) {
    final value = values[field.fieldId] ?? false;
    
    return GestureDetector(
      onTap: isReadOnly
          ? null
          : () {
              HapticFeedback.lightImpact();
              final newValues = Map<String, dynamic>.from(values);
              newValues[field.fieldId] = !value;
              onChanged(newValues);
            },
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: value
                ? [
                    AppTheme.primaryBlue.withOpacity(0.2),
                    AppTheme.primaryPurple.withOpacity(0.1),
                  ]
                : [
                    AppTheme.darkCard.withOpacity(0.5),
                    AppTheme.darkCard.withOpacity(0.3),
                  ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: value
                ? AppTheme.primaryBlue.withOpacity(0.5)
                : AppTheme.darkBorder.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                gradient: value ? AppTheme.primaryGradient : null,
                color: value ? null : AppTheme.darkCard,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value
                      ? AppTheme.primaryBlue
                      : AppTheme.darkBorder.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: value
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: AppDimensions.spaceMedium),
            Text(
              value ? 'نعم' : 'لا',
              style: AppTextStyles.bodyMedium.copyWith(
                color: value ? AppTheme.primaryBlue : AppTheme.textMuted,
                fontWeight: value ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectField(UnitTypeField field) {
    final options = field.fieldOptions['options'] as List<dynamic>? ?? [];
    final value = values[field.fieldId];
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withOpacity(0.5),
            AppTheme.darkCard.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: AppTheme.darkCard,
        style: AppTextStyles.bodyMedium.copyWith(color: AppTheme.textWhite),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(AppDimensions.paddingMedium),
          prefixIcon: _getFieldIcon('select'),
        ),
        hint: Text(
          'اختر ${field.displayName}',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textMuted.withOpacity(0.5),
          ),
        ),
        items: options.map((option) {
          return DropdownMenuItem<String>(
            value: option.toString(),
            child: Text(
              option.toString(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textWhite,
              ),
            ),
          );
        }).toList(),
        onChanged: isReadOnly
            ? null
            : (newValue) {
                final newValues = Map<String, dynamic>.from(values);
                newValues[field.fieldId] = newValue;
                onChanged(newValues);
              },
      ),
    );
  }

  Widget _buildMultiSelectField(UnitTypeField field) {
    final options = field.fieldOptions['options'] as List<dynamic>? ?? [];
    final selectedValues = values[field.fieldId] as List<dynamic>? ?? [];
    
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withOpacity(0.5),
            AppTheme.darkCard.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppDimensions.spaceSmall,
            runSpacing: AppDimensions.spaceSmall,
            children: options.map((option) {
              final isSelected = selectedValues.contains(option);
              
              return GestureDetector(
                onTap: isReadOnly
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        final newValues = Map<String, dynamic>.from(values);
                        final newSelected = List<dynamic>.from(selectedValues);
                        
                        if (isSelected) {
                          newSelected.remove(option);
                        } else {
                          newSelected.add(option);
                        }
                        
                        newValues[field.fieldId] = newSelected;
                        onChanged(newValues);
                      },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMedium,
                    vertical: AppDimensions.paddingSmall,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppTheme.primaryGradient : null,
                    color: isSelected ? null : AppTheme.darkCard,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryBlue
                          : AppTheme.darkBorder.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    option.toString(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected ? Colors.white : AppTheme.textMuted,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(UnitTypeField field) {
    final value = values[field.fieldId];
    
    return GestureDetector(
      onTap: isReadOnly
          ? null
          : () async {
              HapticFeedback.lightImpact();
              final date = await showDatePicker(
                context: field.fieldId.hashCode as BuildContext,
                initialDate: value != null
                    ? DateTime.parse(value.toString())
                    : DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              
              if (date != null) {
                final newValues = Map<String, dynamic>.from(values);
                newValues[field.fieldId] = date.toIso8601String();
                onChanged(newValues);
              }
            },
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkCard.withOpacity(0.5),
              AppTheme.darkCard.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: AppTheme.primaryBlue.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 20,
              color: AppTheme.textMuted,
            ),
            const SizedBox(width: AppDimensions.spaceMedium),
            Expanded(
              child: Text(
                value != null
                    ? _formatDate(DateTime.parse(value.toString()))
                    : 'اختر التاريخ',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: value != null
                      ? AppTheme.textWhite
                      : AppTheme.textMuted.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _getFieldIcon(String fieldType) {
    IconData? iconData;
    
    switch (fieldType) {
      case 'email':
        iconData = Icons.email;
        break;
      case 'phone':
        iconData = Icons.phone;
        break;
      case 'number':
        iconData = Icons.numbers;
        break;
      case 'currency':
        iconData = Icons.attach_money;
        break;
      case 'select':
        iconData = Icons.arrow_drop_down;
        break;
      default:
        return null;
    }
    
    return Icon(
      iconData,
      size: 20,
      color: AppTheme.textMuted,
    );
  }

  List<TextInputFormatter> _getInputFormatters(UnitTypeField field) {
    switch (field.fieldTypeId) {
      case 'phone':
        return [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ];
      case 'email':
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._-]')),
        ];
      default:
        return [];
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}