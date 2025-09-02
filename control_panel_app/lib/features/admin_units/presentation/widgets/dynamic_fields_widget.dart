// lib/features/admin_units/presentation/widgets/dynamic_fields_widget.dart

import 'package:bookn_cp_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:bookn_cp_app/core/theme/app_text_styles.dart';
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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkCard.withOpacity(0.5),
            AppTheme.darkCard.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.dynamic_form_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'معلومات إضافية',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ...fields.map((field) => _buildField(field)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withOpacity(0.3),
            AppTheme.darkCard.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryBlue.withOpacity(0.2),
                    AppTheme.primaryPurple.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.dynamic_form_rounded,
                size: 30,
                color: AppTheme.primaryBlue.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد حقول إضافية',
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
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel(field),
          const SizedBox(height: 8),
          _buildFieldInput(field),
          if (field.description.isNotEmpty) ...[
            const SizedBox(height: 4),
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
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Text(
        description,
        style: AppTextStyles.caption.copyWith(
          color: AppTheme.textMuted.withOpacity(0.7),
        ),
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
            AppTheme.darkSurface.withOpacity(0.5),
            AppTheme.darkSurface.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.3),
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
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: _getFieldIcon(field.fieldTypeId),
        ),
        inputFormatters: _getInputFormatters(field),
        onChanged: isReadOnly
            ? null
            : (value) {
                final newValues = Map<String, dynamic>.from(values);
                newValues[field.fieldId] = value;
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: value
                ? [
                    AppTheme.primaryBlue.withOpacity(0.2),
                    AppTheme.primaryPurple.withOpacity(0.1),
                  ]
                : [
                    AppTheme.darkSurface.withOpacity(0.5),
                    AppTheme.darkSurface.withOpacity(0.3),
                  ],
          ),
          borderRadius: BorderRadius.circular(12),
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
            const SizedBox(width: 12),
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

  // باقي الطرق مشابهة للتحسينات السابقة...
  
  Widget? _getFieldIcon(String fieldType) {
    IconData? iconData;
    
    switch (fieldType) {
      case 'email':
        iconData = Icons.email_rounded;
        break;
      case 'phone':
        iconData = Icons.phone_rounded;
        break;
      case 'number':
        iconData = Icons.numbers_rounded;
        break;
      case 'currency':
        iconData = Icons.attach_money_rounded;
        break;
      default:
        iconData = Icons.text_fields_rounded;
    }
    
    return Icon(
      iconData,
      size: 20,
      color: AppTheme.primaryBlue.withOpacity(0.7),
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

  Widget _buildTextArea(UnitTypeField field) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkSurface.withOpacity(0.5),
            AppTheme.darkSurface.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.3),
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
          contentPadding: const EdgeInsets.all(16),
        ),
        onChanged: isReadOnly
            ? null
            : (value) {
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
            AppTheme.darkSurface.withOpacity(0.5),
            AppTheme.darkSurface.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.3),
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
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: _getFieldIcon(field.fieldTypeId),
        ),
        onChanged: isReadOnly
            ? null
            : (value) {
                final newValues = Map<String, dynamic>.from(values);
                newValues[field.fieldId] = int.tryParse(value) ?? 0;
                onChanged(newValues);
              },
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
            AppTheme.darkSurface.withOpacity(0.5),
            AppTheme.darkSurface.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: AppTheme.darkCard,
        style: AppTextStyles.bodyMedium.copyWith(color: AppTheme.textWhite),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          prefixIcon: Icon(
            Icons.arrow_drop_down_circle_rounded,
            color: AppTheme.primaryBlue.withOpacity(0.7),
            size: 20,
          ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkSurface.withOpacity(0.5),
            AppTheme.darkSurface.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppTheme.primaryGradient : null,
                    color: isSelected ? null : AppTheme.darkCard,
                    borderRadius: BorderRadius.circular(20),
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
              // Date picker implementation
            },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkSurface.withOpacity(0.5),
              AppTheme.darkSurface.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.darkBorder.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 20,
              color: AppTheme.primaryBlue.withOpacity(0.7),
            ),
            const SizedBox(width: 12),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}