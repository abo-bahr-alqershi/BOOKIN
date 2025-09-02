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
import '../bloc/property_images/property_images_bloc.dart'; // إضافة استيراد
import '../widgets/property_image_gallery.dart';
import '../widgets/amenity_selector_widget.dart';
import 'package:bookn_cp_app/injection_container.dart' as di;
import '../../domain/entities/property.dart';
import '../../domain/entities/property_type.dart';
import '../../domain/entities/property_image.dart'; // إضافة استيراد

class EditPropertyPage extends StatelessWidget {
  final String propertyId;
  
  const EditPropertyPage({
    super.key,
    required this.propertyId,
  });
  
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<PropertiesBloc>()
            ..add(LoadPropertyDetailsEvent(propertyId: propertyId)),
        ),
        BlocProvider(
          create: (_) => di.sl<PropertyTypesBloc>()
            ..add(const LoadPropertyTypesEvent(pageSize: 100)),
        ),
        BlocProvider(
          create: (_) => di.sl<AmenitiesBloc>()
            ..add(const LoadAmenitiesEvent()),
        ),
        // إضافة PropertyImagesBloc
        BlocProvider(
          create: (_) => di.sl<PropertyImagesBloc>(),
        ),
      ],
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
  List<PropertyImage> _selectedImages = []; // تغيير نوع البيانات
  List<String> _selectedAmenities = [];
  bool _isFeatured = false;
  String _currency = 'YER';
  Property? _currentProperty;
  bool _isDataLoaded = false;
  bool _isNavigating = false;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
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
  
  void _loadPropertyDataToForm(Property property) {
    if (!_isDataLoaded) {
      setState(() {
        _currentProperty = property;
        _nameController.text = property.name;
        _shortDescriptionController.text = property.shortDescription ?? '';
        _addressController.text = property.address;
        _cityController.text = property.city;
        _descriptionController.text = property.description;
        _latitudeController.text = property.latitude?.toString() ?? '';
        _longitudeController.text = property.longitude?.toString() ?? '';
        _basePriceController.text = property.basePricePerNight.toString();
        _selectedPropertyTypeId = property.typeId;
        _starRating = property.starRating;
        _isFeatured = property.isFeatured;
        _currency = property.currency;
        _selectedImages = property.images; // تخزين كائنات PropertyImage
        _selectedAmenities = property.amenities.map((amenity) => amenity.id).toList();
        _isDataLoaded = true;
      });
    }
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
  
  void _showSnackBar(String message, {Color? backgroundColor, bool isError = false}) {
    if (!mounted) return;
    
    Future.microtask(() {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor ?? (isError ? AppTheme.error : AppTheme.success),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }
  
  void _navigateBack() {
    if (!_isNavigating && mounted) {
      _isNavigating = true;
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          context.pop();
        }
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return !_isNavigating;
      },
      child: Scaffold(
        backgroundColor: AppTheme.darkBackground,
        body: Stack(
          children: [
            _buildAnimatedBackground(),
            
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  
                  Expanded(
                    child: BlocConsumer<PropertiesBloc, PropertiesState>(
                      listenWhen: (previous, current) {
                        return !_isNavigating;
                      },
                      listener: (context, state) {
                        if (state is PropertyDetailsLoaded) {
                          _loadPropertyDataToForm(state.property);
                        } else if (state is PropertyDetailsError) {
                          _showSnackBar('خطأ في تحميل البيانات: ${state.message}', isError: true);
                        } else if (state is PropertyUpdated) {
                          _showSnackBar('تم حفظ التغييرات بنجاح');
                          _navigateBack();
                        } else if (state is PropertyDeleted) {
                          _showSnackBar('تم حذف العقار بنجاح');
                          _navigateBack();
                        } else if (state is PropertiesError) {
                          _showSnackBar('خطأ: ${state.message}', isError: true);
                        }
                      },
                      builder: (context, state) {
                        if (state is PropertyDetailsLoading) {
                          return _buildLoadingState();
                        } else if (state is PropertyDetailsError) {
                          return _buildErrorState(state.message);
                        } else if (state is PropertyDetailsLoaded) {
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: _buildFormContent(),
                            ),
                          );
                        } else if (state is PropertyUpdating) {
                          return _buildUpdatingState();
                        } else {
                          return _buildLoadingState();
                        }
                      },
                    ),
                  ),
                  
                  BlocBuilder<PropertiesBloc, PropertiesState>(
                    builder: (context, state) {
                      if (state is PropertyDetailsLoaded || state is PropertyUpdating) {
                        return _buildActionButtons(state is PropertyUpdating);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
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
          GestureDetector(
            onTap: _isNavigating ? null : () => _navigateBack(),
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
                BlocBuilder<PropertiesBloc, PropertiesState>(
                  builder: (context, state) {
                    String propertyName = 'جاري التحميل...';
                    if (state is PropertyDetailsLoaded) {
                      propertyName = state.property.name;
                    }
                    return Text(
                      propertyName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppTheme.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ],
            ),
          ),
          
          GestureDetector(
            onTap: _isNavigating ? null : _showDeleteConfirmation,
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
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInputField(
                    controller: _longitudeController,
                    label: 'خط الطول',
                    icon: Icons.my_location_rounded,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            _buildMapButton(),
            
            const SizedBox(height: 30),
            
            // Images Section - استخدام المكون الجديد
            _buildSectionTitle('صور العقار'),
            const SizedBox(height: 16),
            PropertyImageGallery(
              propertyId: widget.propertyId, // تمرير propertyId
              initialImages: _selectedImages, // تمرير الصور الحالية
              onImagesChanged: (images) {
                setState(() {
                  _selectedImages = images; // تحديث قائمة الصور
                });
              },
              maxImages: 10,
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
            
            const SizedBox(height: 100),
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
  
  // باقي الدوال (_buildPropertyTypeDropdown, _buildCurrencyDropdown, etc.) تبقى كما هي...
  
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
  
  Widget _buildUpdatingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
          ),
          const SizedBox(height: 16),
          Text(
            'جاري حفظ التغييرات...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                Icons.error_rounded,
                size: 48,
                color: AppTheme.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'خطأ في تحميل البيانات',
              style: AppTextStyles.heading2.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                context.read<PropertiesBloc>().add(
                  LoadPropertyDetailsEvent(propertyId: widget.propertyId),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'إعادة المحاولة',
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
  
  // باقي الدوال كما هي...
  Widget _buildPropertyTypeDropdown() {
    // نفس الكود السابق
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
          child: BlocBuilder<PropertyTypesBloc, PropertyTypesState>(
            builder: (context, state) {
              List<PropertyType> propertyTypes = [];
              bool isLoading = false;
              
              if (state is PropertyTypesLoading) {
                isLoading = true;
              } else if (state is PropertyTypesLoaded) {
                propertyTypes = state.propertyTypes;
              }
              
              String? validSelectedValue = _selectedPropertyTypeId;
              if (validSelectedValue != null && 
                  propertyTypes.isNotEmpty &&
                  !propertyTypes.any((type) => type.id == validSelectedValue)) {
                if (_currentProperty != null) {
                  propertyTypes.insert(0, PropertyType(
                    id: _currentProperty!.typeId,
                    name: _currentProperty!.typeName,
                    description: '',
                    defaultAmenities: [],
                    icon: '',
                    propertiesCount: 0,
                  ));
                } else {
                  validSelectedValue = null;
                }
              }
              
              if (isLoading) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryBlue.withOpacity(0.7),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'جاري تحميل أنواع العقارات...',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              if (propertyTypes.isEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Text(
                    'لا توجد أنواع عقارات متاحة',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppTheme.textMuted,
                    ),
                  ),
                );
              }
              
              return DropdownButtonFormField<String>(
                value: validSelectedValue,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                dropdownColor: AppTheme.darkCard,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.textWhite,
                ),
                hint: Text(
                  'اختر نوع العقار',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
                items: propertyTypes.map((type) {
                  return DropdownMenuItem(
                    value: type.id,
                    child: Text(type.name),
                  );
                }).toList(),
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
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildCurrencyDropdown() {
    // نفس الكود السابق
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
    // نفس الكود السابق
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
    // نفس الكود السابق
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
    // نفس الكود السابق
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
  
  Widget _buildActionButtons(bool isUpdating) {
    // نفس الكود السابق
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
          Expanded(
            child: GestureDetector(
              onTap: (isUpdating || _isNavigating) ? null : () => _navigateBack(),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.darkSurface.withOpacity(isUpdating ? 0.3 : 0.5),
                      AppTheme.darkSurface.withOpacity(isUpdating ? 0.2 : 0.3),
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
                      color: isUpdating ? AppTheme.textMuted : AppTheme.textWhite,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: GestureDetector(
              onTap: (isUpdating || _isNavigating) ? null : _saveChanges,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: isUpdating 
                      ? LinearGradient(
                          colors: [
                            AppTheme.primaryBlue.withOpacity(0.3),
                            AppTheme.primaryPurple.withOpacity(0.3),
                          ],
                        )
                      : AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isUpdating ? [] : [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: isUpdating
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
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
    if (_formKey.currentState!.validate() && !_isNavigating) {
      // استخراج URLs من PropertyImage objects
      final List<String> imageUrls = _selectedImages.map((img) => img.url).toList();
      
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
          images: imageUrls, // تمرير URLs فقط
        ),
      );
    }
  }
  
  void _showDeleteConfirmation() {
    if (_isNavigating) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _DeleteConfirmationDialog(
        onConfirm: () {
          Navigator.pop(dialogContext);
          if (mounted) {
            context.read<PropertiesBloc>().add(
              DeletePropertyEvent(widget.propertyId),
            );
          }
        },
      ),
    );
  }
}

// _DeleteConfirmationDialog يبقى كما هو...
class _DeleteConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  
  const _DeleteConfirmationDialog({required this.onConfirm});
  
  @override
  Widget build(BuildContext context) {
    // نفس الكود السابق
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