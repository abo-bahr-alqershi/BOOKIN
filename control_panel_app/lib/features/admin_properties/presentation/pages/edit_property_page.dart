// lib/features/admin_properties/presentation/pages/edit_property_page.dart

import 'package:bookn_cp_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'package:bookn_cp_app/core/theme/app_colors.dart';
import 'package:bookn_cp_app/core/theme/app_text_styles.dart';
import '../bloc/properties/properties_bloc.dart';
import '../bloc/property_types/property_types_bloc.dart';
import '../bloc/amenities/amenities_bloc.dart';
import '../widgets/property_image_gallery.dart';
import '../widgets/amenity_selector_widget.dart';
import 'package:bookn_cp_app/injection_container.dart' as di;

class EditPropertyPage extends StatelessWidget {
  final String propertyId;
  
  const EditPropertyPage({
    super.key,
    required this.propertyId,
  });
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<AmenitiesBloc>()..add(const LoadAmenitiesEvent()),
      child: _EditPropertyPageContent(propertyId: propertyId),
    );
  }
}

class _EditPropertyPageContent extends StatefulWidget {
  final String propertyId;
  
  const _EditPropertyPageContent({
    required this.propertyId,
  });
  
  @override
  State<_EditPropertyPageContent> createState() => _EditPropertyPageContentState();
}

class _EditPropertyPageContentState extends State<_EditPropertyPageContent>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _animationController;
  late AnimationController _shimmerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Form Controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _shortDescriptionController = TextEditingController();
  final _basePriceController = TextEditingController();
  
  // State
  String? _selectedPropertyTypeId;
  int _starRating = 3;
  List<String> _selectedImages = [];
  List<String> _selectedAmenities = [];
  bool _isLoading = true;
  bool _isFeatured = false;
  String _currency = 'YER';
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadPropertyData();
  }
  
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));
    
    _animationController.forward();
  }
  
  void _loadPropertyData() async {
    // TODO: Load actual property data from API
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
      // Set form data from loaded property with valid image URLs
      _nameController.text = 'منتجع الشاطئ الأزرق';
      _shortDescriptionController.text = 'منتجع فاخر على البحر';
      _addressController.text = 'شارع الكورنيش';
      _cityController.text = 'عدن';
      _descriptionController.text = 'منتجع فاخر على شاطئ البحر مع جميع وسائل الراحة والترفيه';
      _latitudeController.text = '12.7855';
      _longitudeController.text = '45.0187';
      _basePriceController.text = '250000';
      _selectedPropertyTypeId = 'resort';
      _starRating = 5;
      _isFeatured = true;
      _currency = 'YER';
      // استخدام صور حقيقية من placeholder service
      _selectedImages = [
        'https://picsum.photos/seed/property1/400/300',
        'https://picsum.photos/seed/property2/400/300',
        'https://picsum.photos/seed/property3/400/300',
      ];
      _selectedAmenities = ['wifi', 'parking', 'pool'];
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _shimmerController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _shortDescriptionController.dispose();
    _basePriceController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // Animated Background
          _buildAnimatedBackground(),
          
          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),
                
                // Form Content
                Expanded(
                  child: _isLoading
                      ? _buildLoadingState()
                      : FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: _buildFormContent(),
                          ),
                        ),
                ),
                
                // Action Buttons
                if (!_isLoading) _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnimatedBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkBackground,
            AppTheme.darkBackground2.withOpacity(0.8),
            AppTheme.primaryPurple.withOpacity(0.05),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withOpacity(0.7),
            AppTheme.darkCard.withOpacity(0.3),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
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
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppTheme.textWhite,
                size: 20,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                  child: Text(
                    'تعديل العقار',
                    style: AppTextStyles.heading2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'تعديل بيانات العقار #${widget.propertyId}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          
          // Delete Button
          GestureDetector(
            onTap: _showDeleteConfirmation,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.error.withOpacity(0.2),
                    AppTheme.error.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.error.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.delete_rounded,
                color: AppTheme.error,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingState() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: List.generate(5, (index) => _buildShimmerBox()),
          ),
        );
      },
    );
  }
  
  Widget _buildShimmerBox() {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkCard.withOpacity(0.3),
            AppTheme.darkCard.withOpacity(0.5),
            AppTheme.darkCard.withOpacity(0.3),
          ],
          stops: [
            0.0,
            _shimmerController.value,
            1.0,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
  
  Widget _buildFormContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Information Section
            _buildSectionTitle('المعلومات الأساسية'),
            const SizedBox(height: 16),
            
            _buildInputField(
              controller: _nameController,
              label: 'اسم العقار',
              icon: Icons.business_rounded,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال اسم العقار';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            _buildInputField(
              controller: _shortDescriptionController,
              label: 'وصف مختصر',
              icon: Icons.short_text_rounded,
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    controller: _basePriceController,
                    label: 'السعر الأساسي',
                    icon: Icons.attach_money_rounded,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال السعر';
                      }
                      if (double.tryParse(value) == null) {
                        return 'يرجى إدخال رقم صحيح';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCurrencyDropdown(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildPropertyTypeDropdown(),
            const SizedBox(height: 16),
            
            _buildStarRatingSelector(),
            const SizedBox(height: 16),
            
            _buildFeaturedSwitch(),
            
            const SizedBox(height: 30),
            
            // Address Information Section
            _buildSectionTitle('معلومات العنوان'),
            const SizedBox(height: 16),
            
            _buildInputField(
              controller: _addressController,
              label: 'العنوان',
              icon: Icons.location_on_rounded,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال العنوان';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            _buildInputField(
              controller: _cityController,
              label: 'المدينة',
              icon: Icons.location_city_rounded,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال المدينة';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            _buildInputField(
              controller: _descriptionController,
              label: 'الوصف التفصيلي',
              icon: Icons.description_rounded,
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال الوصف';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 30),
            
            // Location Section
            _buildSectionTitle('الموقع الجغرافي'),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    controller: _latitudeController,
                    label: 'خط العرض',
                    icon: Icons.my_location_rounded,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInputField(
                    controller: _longitudeController,
                    label: 'خط الطول',
                    icon: Icons.my_location_rounded,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            _buildMapButton(),
            
            const SizedBox(height: 30),
            
            // Images Section
            _buildSectionTitle('صور العقار'),
            const SizedBox(height: 16),
            PropertyImageGallery(
              images: _selectedImages,
              onImagesChanged: (images) {
                setState(() {
                  _selectedImages = images;
                });
              },
            ),
            
            const SizedBox(height: 30),
            
            // Amenities Section
            _buildSectionTitle('المرافق'),
            const SizedBox(height: 16),
            AmenitySelectorWidget(
              selectedAmenities: _selectedAmenities,
              onAmenitiesChanged: (amenities) {
                setState(() {
                  _selectedAmenities = amenities;
                });
              },
            ),
            
            const SizedBox(height: 100), // Space for bottom buttons
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.heading3.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.darkCard.withOpacity(0.5),
                AppTheme.darkCard.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.darkBorder.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
            ),
            decoration: InputDecoration(
              prefixIcon: maxLines == 1
                  ? Icon(
                      icon,
                      color: AppTheme.primaryBlue.withOpacity(0.7),
                      size: 20,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              errorStyle: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.error,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPropertyTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نوع العقار',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.darkCard.withOpacity(0.5),
                AppTheme.darkCard.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.darkBorder.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedPropertyTypeId,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            dropdownColor: AppTheme.darkCard,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
            ),
            items: [
              DropdownMenuItem(
                value: 'hotel',
                child: Text('فندق'),
              ),
              DropdownMenuItem(
                value: 'resort',
                child: Text('منتجع'),
              ),
              DropdownMenuItem(
                value: 'apartment',
                child: Text('شقة'),
              ),
              DropdownMenuItem(
                value: 'villa',
                child: Text('فيلا'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedPropertyTypeId = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'يرجى اختيار نوع العقار';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildCurrencyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'العملة',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.darkCard.withOpacity(0.5),
                AppTheme.darkCard.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.darkBorder.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: _currency,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            dropdownColor: AppTheme.darkCard,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
            ),
            items: const [
              DropdownMenuItem(
                value: 'YER',
                child: Text('ريال يمني'),
              ),
              DropdownMenuItem(
                value: 'USD',
                child: Text('دولار أمريكي'),
              ),
              DropdownMenuItem(
                value: 'SAR',
                child: Text('ريال سعودي'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _currency = value!;
              });
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildStarRatingSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التقييم',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _starRating = index + 1;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  index < _starRating ? Icons.star_rounded : Icons.star_border_rounded,
                  color: index < _starRating ? AppTheme.warning : AppTheme.textMuted,
                  size: 32,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
  
  Widget _buildFeaturedSwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withOpacity(0.3),
            AppTheme.darkCard.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isFeatured 
              ? AppTheme.warning.withOpacity(0.3)
              : AppTheme.darkBorder.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.star_rounded,
                color: _isFeatured ? AppTheme.warning : AppTheme.textMuted,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'عقار مميز',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Switch(
            value: _isFeatured,
            onChanged: (value) {
              setState(() {
                _isFeatured = value;
              });
            },
            activeColor: AppTheme.warning,
            inactiveThumbColor: AppTheme.textMuted,
            inactiveTrackColor: AppTheme.darkBorder.withOpacity(0.3),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMapButton() {
    return GestureDetector(
      onTap: () {
        // TODO: Open map selector
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryBlue.withOpacity(0.1),
              AppTheme.primaryPurple.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_rounded,
              color: AppTheme.primaryBlue,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'اختر الموقع من الخريطة',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withOpacity(0.7),
            AppTheme.darkCard.withOpacity(0.5),
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
          // Cancel Button
          Expanded(
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                height: 48,
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
                child: Center(
                  child: Text(
                    'إلغاء',
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: AppTheme.textWhite,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Save Button
          Expanded(
            child: GestureDetector(
              onTap: _saveChanges,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'حفظ التغييرات',
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      // TODO: Update this to match your actual UpdatePropertyEvent parameters
      context.read<PropertiesBloc>().add(
        UpdatePropertyEvent(
          propertyId: widget.propertyId,
          name: _nameController.text,
          address: _addressController.text,
          city: _cityController.text,
          description: _descriptionController.text,
          latitude: double.tryParse(_latitudeController.text),
          longitude: double.tryParse(_longitudeController.text),
          starRating: _starRating,
          images: _selectedImages,
        ),
      );
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ التغييرات بنجاح'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      
      context.pop();
    }
  }
  
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => _DeleteConfirmationDialog(
        onConfirm: () {
          context.read<PropertiesBloc>().add(
            DeletePropertyEvent(widget.propertyId),
          );
          Navigator.pop(context);
          context.pop();
        },
      ),
    );
  }
}

class _DeleteConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  
  const _DeleteConfirmationDialog({required this.onConfirm});
  
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.darkCard.withOpacity(0.95),
                AppTheme.darkCard.withOpacity(0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.error.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.error.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.error.withOpacity(0.2),
                      AppTheme.error.withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_rounded,
                  size: 48,
                  color: AppTheme.error,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'تأكيد الحذف',
                style: AppTextStyles.heading2.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'هل أنت متأكد من حذف هذا العقار؟',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.textLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'لا يمكن التراجع عن هذا الإجراء',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppTheme.error.withOpacity(0.8),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
                        child: Center(
                          child: Text(
                            'إلغاء',
                            style: AppTextStyles.buttonMedium.copyWith(
                              color: AppTheme.textLight,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: onConfirm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.error,
                              AppTheme.error.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.error.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'حذف',
                            style: AppTextStyles.buttonMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}