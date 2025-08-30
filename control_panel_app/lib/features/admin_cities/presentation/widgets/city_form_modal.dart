import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui';
import 'dart:io';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/city.dart';
import 'city_image_gallery.dart';

class CityFormModal extends StatefulWidget {
  final City? city;
  final Function(City) onSave;

  const CityFormModal({
    super.key,
    this.city,
    required this.onSave,
  });

  @override
  State<CityFormModal> createState() => _CityFormModalState();
}

class _CityFormModalState extends State<CityFormModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _countryController = TextEditingController();
  final List<String> _images = [];
  
  bool _isLoading = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeForm();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutExpo,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  void _initializeForm() {
    if (widget.city != null) {
      _nameController.text = widget.city!.name;
      _countryController.text = widget.city!.country;
      _images.addAll(widget.city!.images);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            MediaQuery.of(context).size.height * _slideAnimation.value,
          ),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: _buildModalContent(),
          ),
        );
      },
    );
  }

  Widget _buildModalContent() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.darkCard.withOpacity(0.95),
            AppTheme.darkBackground,
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(32),
        ),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(32),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildForm(),
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
            ),
            child: Icon(
              widget.city == null ? Icons.add_rounded : Icons.edit_rounded,
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
                  widget.city == null ? 'إضافة مدينة جديدة' : 'تعديل المدينة',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.city == null
                      ? 'أضف مدينة جديدة للنظام'
                      : 'قم بتحديث معلومات المدينة',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close_rounded,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(
              controller: _nameController,
              label: 'اسم المدينة',
              hint: 'أدخل اسم المدينة',
              icon: Icons.location_city_rounded,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'اسم المدينة مطلوب';
                }
                return null;
              },
            ),
            
            const SizedBox(height: AppDimensions.spaceLarge),
            
            _buildTextField(
              controller: _countryController,
              label: 'الدولة',
              hint: 'أدخل اسم الدولة',
              icon: Icons.public_rounded,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'اسم الدولة مطلوب';
                }
                return null;
              },
            ),
            
            const SizedBox(height: AppDimensions.spaceLarge),
            
            _buildImagesSection(),
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
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceSmall),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.darkCard.withOpacity(0.5),
                AppTheme.darkCard.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.darkBorder.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: TextFormField(
                controller: controller,
                validator: validator,
                keyboardType: keyboardType,
                maxLines: maxLines,
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
                    color: AppTheme.primaryBlue,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  errorStyle: AppTextStyles.caption.copyWith(
                    color: AppTheme.error,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'صور المدينة',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${_images.length} صورة',
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppDimensions.spaceMedium),
        
        CityImageGallery(
          images: _images,
          onImagesChanged: (images) {
            setState(() {
              _images.clear();
              _images.addAll(images);
            });
          },
          onAddImage: _pickImage,
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
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
            child: _buildActionButton(
              text: 'إلغاء',
              onTap: () => Navigator.of(context).pop(),
              isPrimary: false,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceMedium),
          Expanded(
            child: _buildActionButton(
              text: widget.city == null ? 'إضافة' : 'حفظ',
              onTap: _handleSave,
              isPrimary: true,
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onTap,
    required bool isPrimary,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: isPrimary ? AppTheme.primaryGradient : null,
          color: !isPrimary ? AppTheme.darkCard.withOpacity(0.5) : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPrimary
                ? Colors.transparent
                : AppTheme.darkBorder.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  text,
                  style: AppTextStyles.buttonLarge.copyWith(
                    color: isPrimary ? Colors.white : AppTheme.textMuted,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        // في بيئة الإنتاج، يجب رفع الصورة إلى الخادم والحصول على URL
        // هنا نستخدم المسار المحلي كمثال فقط
        setState(() {
          _images.add(image.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('فشل في اختيار الصورة');
    }
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final city = City(
        name: _nameController.text,
        country: _countryController.text,
        images: _images,
        isActive: widget.city?.isActive ?? true,
        propertiesCount: widget.city?.propertiesCount ?? 0,
        createdAt: widget.city?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      widget.onSave(city);
      Navigator.of(context).pop();
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}