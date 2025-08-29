import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_dimensions.dart';

class UnitFormWidget extends StatefulWidget {
  final Function(String) onPropertyChanged;
  final Function(String) onUnitTypeChanged;
  final String? initialPropertyId;
  final String? initialUnitTypeId;
  final String? initialName;

  const UnitFormWidget({
    super.key,
    required this.onPropertyChanged,
    required this.onUnitTypeChanged,
    this.initialPropertyId,
    this.initialUnitTypeId,
    this.initialName,
  });

  @override
  State<UnitFormWidget> createState() => _UnitFormWidgetState();
}

class _UnitFormWidgetState extends State<UnitFormWidget> {
  final _nameController = TextEditingController();
  String? _selectedPropertyId;
  String? _selectedUnitTypeId;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName ?? '';
    _selectedPropertyId = widget.initialPropertyId;
    _selectedUnitTypeId = widget.initialUnitTypeId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            label: 'اسم الوحدة',
            controller: _nameController,
            icon: Icons.home,
            hint: 'أدخل اسم الوحدة',
          ),
          const SizedBox(height: AppDimensions.spaceMedium),
          _buildDropdown(
            label: 'الكيان',
            value: _selectedPropertyId,
            icon: Icons.location_city,
            hint: 'اختر الكيان',
            items: _getPropertyItems(),
            onChanged: (value) {
              setState(() {
                _selectedPropertyId = value;
                _selectedUnitTypeId = null;
              });
              widget.onPropertyChanged(value!);
            },
          ),
          const SizedBox(height: AppDimensions.spaceMedium),
          _buildDropdown(
            label: 'نوع الوحدة',
            value: _selectedUnitTypeId,
            icon: Icons.apartment,
            hint: 'اختر نوع الوحدة',
            items: _getUnitTypeItems(),
            onChanged: (value) {
              setState(() => _selectedUnitTypeId = value);
              widget.onUnitTypeChanged(value!);
            },
            enabled: _selectedPropertyId != null,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: AppDimensions.spaceSmall),
        Container(
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
            controller: controller,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textMuted.withOpacity(0.5),
              ),
              prefixIcon: Icon(
                icon,
                size: 20,
                color: AppTheme.textMuted,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(AppDimensions.paddingMedium),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required IconData icon,
    required String hint,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: AppDimensions.spaceSmall),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: enabled
                  ? [
                      AppTheme.darkCard.withOpacity(0.5),
                      AppTheme.darkCard.withOpacity(0.3),
                    ]
                  : [
                      AppTheme.darkCard.withOpacity(0.2),
                      AppTheme.darkCard.withOpacity(0.1),
                    ],
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(
              color: enabled
                  ? AppTheme.primaryBlue.withOpacity(0.2)
                  : AppTheme.darkBorder.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            dropdownColor: AppTheme.darkCard,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textMuted.withOpacity(0.5),
              ),
              prefixIcon: Icon(
                icon,
                size: 20,
                color: enabled ? AppTheme.textMuted : AppTheme.textMuted.withOpacity(0.5),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(AppDimensions.paddingMedium),
            ),
            items: items,
            onChanged: enabled ? onChanged : null,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Row(
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          ' *',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.error,
          ),
        ),
      ],
    );
  }

  List<DropdownMenuItem<String>> _getPropertyItems() {
    // This would be loaded from BLoC/API
    return [
      DropdownMenuItem(
        value: 'prop1',
        child: Text('فندق الهيلتون'),
      ),
      DropdownMenuItem(
        value: 'prop2',
        child: Text('منتجع البحر الأحمر'),
      ),
    ];
  }

  List<DropdownMenuItem<String>> _getUnitTypeItems() {
    if (_selectedPropertyId == null) return [];
    
    // This would be loaded based on selected property
    return [
      DropdownMenuItem(
        value: 'type1',
        child: Text('غرفة مفردة'),
      ),
      DropdownMenuItem(
        value: 'type2',
        child: Text('جناح'),
      ),
    ];
  }
}