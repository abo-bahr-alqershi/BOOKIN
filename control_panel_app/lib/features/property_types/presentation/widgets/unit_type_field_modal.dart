import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/unit_type_field.dart';

class UnitTypeFieldModal extends StatefulWidget {
  final UnitTypeField? field;
  final String unitTypeId;
  final Function(Map<String, dynamic>) onSave;

  const UnitTypeFieldModal({
    super.key,
    this.field,
    required this.unitTypeId,
    required this.onSave,
  });

  @override
  State<UnitTypeFieldModal> createState() => _UnitTypeFieldModalState();
}

class _UnitTypeFieldModalState extends State<UnitTypeFieldModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fieldNameController;
  late TextEditingController _displayNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _sortOrderController;
  late TextEditingController _priorityController;
  late TextEditingController _optionsController;
  
  String _selectedFieldType = 'text';
  bool _isRequired = false;
  bool _isSearchable = false;
  bool _isPublic = true;
  bool _isForUnits = true;
  bool _showInCards = false;
  bool _isPrimaryFilter = false;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _fieldTypes = [
    {'value': 'text', 'label': 'نص قصير', 'icon': '📝'},
    {'value': 'textarea', 'label': 'نص طويل', 'icon': '📄'},
    {'value': 'number', 'label': 'رقم', 'icon': '🔢'},
    {'value': 'currency', 'label': 'مبلغ مالي', 'icon': '💰'},
    {'value': 'boolean', 'label': 'نعم/لا', 'icon': '☑️'},
    {'value': 'select', 'label': 'قائمة منسدلة', 'icon': '📋'},
    {'value': 'multiselect', 'label': 'تحديد متعدد', 'icon': '📋'},
    {'value': 'date', 'label': 'تاريخ', 'icon': '📅'},
    {'value': 'email', 'label': 'بريد إلكتروني', 'icon': '📧'},
    {'value': 'phone', 'label': 'رقم هاتف', 'icon': '📞'},
    {'value': 'file', 'label': 'ملف', 'icon': '📎'},
    {'value': 'image', 'label': 'صورة', 'icon': '🖼️'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _fieldNameController = TextEditingController(
      text: widget.field?.fieldName ?? '',
    );
    _displayNameController = TextEditingController(
      text: widget.field?.displayName ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.field?.description ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.field?.category ?? '',
    );
    _sortOrderController = TextEditingController(
      text: widget.field?.sortOrder.toString() ?? '0',
    );
    _priorityController = TextEditingController(
      text: widget.field?.priority.toString() ?? '0',
    );
    _optionsController = TextEditingController(
      text: widget.field?.fieldOptions['options']?.join(', ') ?? '',
    );
    
    if (widget.field != null) {
      _selectedFieldType = widget.field!.fieldTypeId;
      _isRequired = widget.field!.isRequired;
      _isSearchable = widget.field!.isSearchable;
      _isPublic = widget.field!.isPublic;
      _isForUnits = widget.field!.isForUnits;
      _showInCards = widget.field!.showInCards;
      _isPrimaryFilter = widget.field!.isPrimaryFilter;
    }
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fieldNameController.dispose();
    _displayNameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _sortOrderController.dispose();
    _priorityController.dispose();
    _optionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(20),
              child: _buildModalContent(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalContent() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkCard.withOpacity(0.95),
            AppTheme.darkCard.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        border: Border.all(
          color: AppTheme.neonPurple.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neonPurple.withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildForm(),
                ),
              ),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.neonPurple.withOpacity(0.1),
            AppTheme.neonGreen.withOpacity(0.05),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.darkBorder.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.neonPurple, AppTheme.neonGreen],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.neonPurple.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.dynamic_form_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.field == null 
                      ? 'إضافة حقل ديناميكي'
                      : 'تعديل الحقل الديناميكي',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'قم بإدخال معلومات الحقل',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.darkSurface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.close_rounded,
                color: AppTheme.textMuted,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Field Type Selector
            _buildFieldTypeSelector(),
            
            const SizedBox(height: AppDimensions.spaceMedium),
            
            // Basic Info
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _fieldNameController,
                    label: 'اسم الحقل (بالإنجليزية)',
                    hint: 'field_name',
                    icon: Icons.code_rounded,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال اسم الحقل';
                      }
                      if (!RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$').hasMatch(value)) {
                        return 'يجب أن يبدأ بحرف ويحتوي على حروف وأرقام و _ فقط';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceMedium),
                Expanded(
                  child: _buildTextField(
                    controller: _displayNameController,
                    label: 'الاسم المعروض',
                    hint: 'الاسم الذي سيظهر للمستخدم',
                    icon: Icons.label_rounded,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال الاسم المعروض';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppDimensions.spaceMedium),
            
            _buildTextField(
              controller: _descriptionController,
              label: 'الوصف',
              hint: 'وصف مختصر للحقل',
              icon: Icons.description_rounded,
              maxLines: 2,
            ),
            
            const SizedBox(height: AppDimensions.spaceMedium),
            
            // Options for select/multiselect
            if (_selectedFieldType == 'select' || _selectedFieldType == 'multiselect')
              Column(
                children: [
                  _buildTextField(
                    controller: _optionsController,
                    label: 'الخيارات',
                    hint: 'خيار 1, خيار 2, خيار 3',
                    icon: Icons.list_rounded,
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال الخيارات مفصولة بفاصلة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.spaceMedium),
                ],
              ),
            
            // Additional Fields
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _categoryController,
                    label: 'الفئة',
                    hint: 'فئة الحقل',
                    icon: Icons.category_rounded,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceMedium),
                Expanded(
                  flex: 1,
                  child: _buildTextField(
                    controller: _sortOrderController,
                    label: 'الترتيب',
                    hint: '0',
                    icon: Icons.sort_rounded,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceMedium),
                Expanded(
                  flex: 1,
                  child: _buildTextField(
                    controller: _priorityController,
                    label: 'الأولوية',
                    hint: '0',
                    icon: Icons.priority_high_rounded,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppDimensions.spaceLarge),
            
            // Feature Toggles
            _buildFeatureToggles(),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نوع الحقل',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.darkSurface.withOpacity(0.5),
                AppTheme.darkSurface.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(
              color: AppTheme.darkBorder.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedFieldType,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
            dropdownColor: AppTheme.darkCard,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
            ),
            icon: Icon(
              Icons.arrow_drop_down_rounded,
              color: AppTheme.textMuted,
            ),
            items: _fieldTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type['value'],
                child: Row(
                  children: [
                    Text(type['icon'], style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(type['label']),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedFieldType = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppTheme.textLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.darkSurface.withOpacity(0.5),
                AppTheme.darkSurface.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            border: Border.all(
              color: AppTheme.darkBorder.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppTheme.textWhite,
            ),
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.caption.copyWith(
                color: AppTheme.textMuted.withOpacity(0.5),
              ),
              prefixIcon: maxLines == 1 
                  ? Icon(
                      icon,
                      color: AppTheme.neonPurple.withOpacity(0.7),
                      size: 18,
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 10, left: 10),
                      child: Icon(
                        icon,
                        color: AppTheme.neonPurple.withOpacity(0.7),
                        size: 18,
                      ),
                    ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: maxLines == 1 ? 10 : 10,
                vertical: maxLines == 1 ? 12 : 10,
              ),
              isDense: true,
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureToggles() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkSurface.withOpacity(0.3),
            AppTheme.darkSurface.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'خصائص الحقل',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _buildCompactToggle(
                label: 'مطلوب',
                value: _isRequired,
                onChanged: (v) => setState(() => _isRequired = v),
                color: AppTheme.error,
              ),
              _buildCompactToggle(
                label: 'قابل للبحث',
                value: _isSearchable,
                onChanged: (v) => setState(() => _isSearchable = v),
                color: AppTheme.primaryBlue,
              ),
              _buildCompactToggle(
                label: 'عام',
                value: _isPublic,
                onChanged: (v) => setState(() => _isPublic = v),
                color: AppTheme.success,
              ),
              _buildCompactToggle(
                label: 'للوحدات',
                value: _isForUnits,
                onChanged: (v) => setState(() => _isForUnits = v),
                color: AppTheme.warning,
              ),
              _buildCompactToggle(
                label: 'يظهر في الكروت',
                value: _showInCards,
                onChanged: (v) => setState(() => _showInCards = v),
                color: AppTheme.info,
              ),
              _buildCompactToggle(
                label: 'فلتر أساسي',
                value: _isPrimaryFilter,
                onChanged: (v) => setState(() => _isPrimaryFilter = v),
                color: AppTheme.neonPurple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactToggle({
    required String label,
    required bool value,
    required Function(bool) onChanged,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: value ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: value ? color.withOpacity(0.5) : AppTheme.darkBorder.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: value ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: value ? color : AppTheme.darkBorder,
                  width: 1,
                ),
              ),
              child: value
                  ? const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: value ? color : AppTheme.textMuted,
                fontWeight: value ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkSurface.withOpacity(0.3),
            AppTheme.darkSurface.withOpacity(0.1),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: AppTheme.darkBorder.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildCancelButton(),
          ),
          const SizedBox(width: AppDimensions.spaceMedium),
          Expanded(
            child: _buildSaveButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop();
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkCard.withOpacity(0.5),
              AppTheme.darkCard.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: AppTheme.darkBorder.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            'إلغاء',
            style: AppTextStyles.buttonMedium.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleSave,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.neonPurple, AppTheme.neonGreen],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: AppTheme.neonPurple.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  widget.field == null ? 'إضافة' : 'تحديث',
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      
      final fieldOptions = <String, dynamic>{};
      if (_selectedFieldType == 'select' || _selectedFieldType == 'multiselect') {
        fieldOptions['options'] = _optionsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      
      widget.onSave({
        'fieldTypeId': _selectedFieldType,
        'fieldName': _fieldNameController.text,
        'displayName': _displayNameController.text,
        'description': _descriptionController.text,
        'fieldOptions': fieldOptions,
        'validationRules': {},
        'isRequired': _isRequired,
        'isSearchable': _isSearchable,
        'isPublic': _isPublic,
        'sortOrder': int.tryParse(_sortOrderController.text) ?? 0,
        'category': _categoryController.text,
        'isForUnits': _isForUnits,
        'showInCards': _showInCards,
        'isPrimaryFilter': _isPrimaryFilter,
        'priority': int.tryParse(_priorityController.text) ?? 0,
      });
      
      Navigator.of(context).pop();
    }
  }
}