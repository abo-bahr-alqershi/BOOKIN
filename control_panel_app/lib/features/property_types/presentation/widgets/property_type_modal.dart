import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/property_type.dart';
import 'icon_picker_modal.dart';

class PropertyTypeModal extends StatefulWidget {
  final PropertyType? propertyType;
  final Function(String name, String description, List<String> defaultAmenities, String icon) onSave;

  const PropertyTypeModal({
    super.key,
    this.propertyType,
    required this.onSave,
  });

  @override
  State<PropertyTypeModal> createState() => _PropertyTypeModalState();
}

class _PropertyTypeModalState extends State<PropertyTypeModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _defaultAmenitiesController;
  String _selectedIcon = 'home';
  
  bool _isLoading = false;

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
    
    _nameController = TextEditingController(
      text: widget.propertyType?.name ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.propertyType?.description ?? '',
    );
    _defaultAmenitiesController = TextEditingController(
      text: widget.propertyType?.defaultAmenities.join(', ') ?? '',
    );
    _selectedIcon = widget.propertyType?.icon ?? 'home';
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _defaultAmenitiesController.dispose();
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
      constraints: const BoxConstraints(maxWidth: 500),
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
          color: AppTheme.primaryBlue.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.2),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              _buildForm(),
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
            AppTheme.primaryBlue.withOpacity(0.1),
            AppTheme.primaryPurple.withOpacity(0.05),
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
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.business_rounded,
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
                  widget.propertyType == null 
                      ? 'إضافة نوع كيان جديد'
                      : 'تعديل نوع الكيان',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'قم بإدخال معلومات نوع الكيان',
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
            _buildTextField(
              controller: _nameController,
              label: 'اسم النوع',
              hint: 'مثال: شقة، فيلا، مكتب',
              icon: Icons.text_fields_rounded,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال اسم النوع';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.spaceMedium),
            
            _buildIconSelector(),
            
            const SizedBox(height: AppDimensions.spaceMedium),
            
            _buildTextField(
              controller: _descriptionController,
              label: 'الوصف',
              hint: 'وصف مختصر لنوع الكيان',
              icon: Icons.description_rounded,
              maxLines: 3,
            ),
            
            const SizedBox(height: AppDimensions.spaceMedium),
            
            _buildTextField(
              controller: _defaultAmenitiesController,
              label: 'المرافق الافتراضية',
              hint: 'المرافق التي تأتي مع هذا النوع',
              icon: Icons.apartment_rounded,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
          child: TextFormField(
            controller: controller,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
            ),
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.textMuted.withOpacity(0.5),
              ),
              prefixIcon: maxLines == 1 
                  ? Icon(
                      icon,
                      color: AppTheme.primaryBlue.withOpacity(0.7),
                      size: 20,
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 12, left: 12),
                      child: Icon(
                        icon,
                        color: AppTheme.primaryBlue.withOpacity(0.7),
                        size: 20,
                      ),
                    ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: maxLines == 1 ? 12 : 12,
                vertical: maxLines == 1 ? 14 : 12,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الأيقونة',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showIconPicker(),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.darkSurface.withOpacity(0.5),
                  AppTheme.darkSurface.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(
                color: AppTheme.primaryBlue.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getIconData(_selectedIcon),
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
                        _selectedIcon,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppTheme.textWhite,
                        ),
                      ),
                      Text(
                        'اضغط لتغيير الأيقونة',
                        style: AppTextStyles.caption.copyWith(
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppTheme.textMuted,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
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
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.3),
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
                  widget.propertyType == null ? 'إضافة' : 'تحديث',
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  void _showIconPicker() {
    showDialog(
      context: context,
      builder: (context) => IconPickerModal(
        selectedIcon: _selectedIcon,
        onIconSelected: (icon) {
          setState(() {
            _selectedIcon = icon;
          });
        },
      ),
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      widget.onSave(
        _nameController.text,
        _descriptionController.text,
        _defaultAmenitiesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        _selectedIcon,
      );
      Navigator.of(context).pop();
    }
  }

  IconData _getIconData(String iconName) {
    // This should use the IconHelper utility
    final iconMap = {
      'home': Icons.home,
      'apartment': Icons.apartment,
      'villa': Icons.villa,
      'business': Icons.business,
      'store': Icons.store,
      'hotel': Icons.hotel,
    };
    return iconMap[iconName] ?? Icons.home;
  }
}