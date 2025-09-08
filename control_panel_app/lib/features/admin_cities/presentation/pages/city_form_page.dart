// lib/features/admin_cities/presentation/pages/city_form_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/city.dart';
import '../widgets/city_image_gallery.dart';

class CityFormPage extends StatefulWidget {
  final City? city;
  
  const CityFormPage({
    super.key,
    this.city,
  });
  
  @override
  State<CityFormPage> createState() => _CityFormPageState();
}

class _CityFormPageState extends State<CityFormPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _floatingAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _countryController = TextEditingController();
  
  List<String> _images = [];
  bool _isActive = true;
  bool _isSaving = false;
  
  // Focus nodes
  final _nameFocusNode = FocusNode();
  final _countryFocusNode = FocusNode();
  
  bool get isEditing => widget.city != null;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeForm();
  }
  
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _floatingAnimationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));
    
    _animationController.forward();
  }
  
  void _initializeForm() {
    if (isEditing) {
      _nameController.text = widget.city!.name;
      _countryController.text = widget.city!.country;
      _images = List.from(widget.city!.images);
      _isActive = widget.city!.isActive ?? true;
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _floatingAnimationController.dispose();
    _nameController.dispose();
    _countryController.dispose();
    _nameFocusNode.dispose();
    _countryFocusNode.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1200;
    
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // Premium Background
          _buildPremiumBackground(),
          
          // Floating Orbs
          ..._buildFloatingOrbs(),
          
          // Main Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App Bar
              _buildAppBar(context),
              
              // Form Content
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildFormContent(isDesktop),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPremiumBackground() {
    return Stack(
      children: [
        // Gradient Background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.darkBackground,
                AppTheme.darkBackground2,
                AppTheme.darkBackground3.withOpacity(0.5),
              ],
            ),
          ),
        ),
        
        // Animated Pattern
        AnimatedBuilder(
          animation: _floatingAnimationController,
          builder: (context, child) {
            return CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _DiamondPatternPainter(
                color: AppTheme.primaryBlue.withOpacity(0.02),
                animation: _floatingAnimationController.value,
              ),
            );
          },
        ),
      ],
    );
  }
  
  List<Widget> _buildFloatingOrbs() {
    return [
      AnimatedBuilder(
        animation: _floatingAnimationController,
        builder: (context, child) {
          return Positioned(
            top: 100 + (30 * _floatingAnimationController.value),
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryPurple.withOpacity(0.2),
                    AppTheme.primaryPurple.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          );
        },
      ),
      AnimatedBuilder(
        animation: _floatingAnimationController,
        builder: (context, child) {
          return Positioned(
            bottom: 100 + (20 * _floatingAnimationController.value),
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.neonGreen.withOpacity(0.15),
                    AppTheme.neonGreen.withOpacity(0.03),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ];
  }
  
  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppTheme.darkCard.withOpacity(0.5),
            border: Border.all(
              color: AppTheme.darkBorder.withOpacity(0.2),
              width: 0.5,
            ),
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: AppTheme.textLight,
            size: 18,
          ),
        ),
      ),
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.darkCard.withOpacity(0.8),
                  AppTheme.darkCard.withOpacity(0.4),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.glowBlue.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
            ),
            child: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.only(
                left: 60,
                bottom: 16,
                right: 20,
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryBlue.withOpacity(0.2),
                          AppTheme.primaryPurple.withOpacity(0.2),
                        ],
                      ),
                    ),
                    child: Icon(
                      isEditing ? Icons.edit_location : Icons.add_location,
                      color: AppTheme.glowWhite,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEditing ? 'تعديل المدينة' : 'إضافة مدينة جديدة',
                    style: AppTextStyles.heading3.copyWith(
                      color: AppTheme.textWhite,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        // Save Button
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: GestureDetector(
              onTap: _isSaving ? null : _saveCity,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: _isSaving
                      ? LinearGradient(
                          colors: [
                            AppTheme.textMuted.withOpacity(0.3),
                            AppTheme.textMuted.withOpacity(0.2),
                          ],
                        )
                      : AppTheme.primaryGradient,
                  boxShadow: _isSaving
                      ? []
                      : [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isSaving) ...[
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.textLight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ] else ...[
                      Icon(
                        Icons.save_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      _isSaving ? 'جاري الحفظ...' : 'حفظ',
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildFormContent(bool isDesktop) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: isDesktop ? 1200 : double.infinity,
      ),
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 20,
        vertical: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form Fields Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: isDesktop ? 2 : 1,
                  child: Column(
                    children: [
                      _buildInputCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('معلومات المدينة'),
                            const SizedBox(height: 24),
                            _buildTextField(
                              controller: _nameController,
                              focusNode: _nameFocusNode,
                              label: 'اسم المدينة',
                              hint: 'مثال: دبي',
                              icon: Icons.location_city,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال اسم المدينة';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              controller: _countryController,
                              focusNode: _countryFocusNode,
                              label: 'الدولة',
                              hint: 'مثال: الإمارات العربية المتحدة',
                              icon: Icons.flag,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال اسم الدولة';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            _buildActiveSwitch(),
                          ],
                        ),
                      ),
                      
                      if (!isDesktop) ...[
                        const SizedBox(height: 24),
                        _buildImageGallerySection(),
                      ],
                    ],
                  ),
                ),
                
                if (isDesktop) ...[
                  const SizedBox(width: 32),
                  Expanded(
                    flex: 3,
                    child: _buildImageGallerySection(),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInputCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkCard.withOpacity(0.5),
            AppTheme.darkCard.withOpacity(0.3),
          ],
        ),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.1),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowDark.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTextStyles.heading3.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          validator: validator,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textWhite,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted.withOpacity(0.5),
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppTheme.primaryBlue.withOpacity(0.1),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryBlue,
                size: 18,
              ),
            ),
            filled: true,
            fillColor: AppTheme.inputBackground.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppTheme.darkBorder.withOpacity(0.1),
                width: 0.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppTheme.darkBorder.withOpacity(0.1),
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppTheme.primaryBlue.withOpacity(0.5),
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppTheme.error.withOpacity(0.5),
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppTheme.error.withOpacity(0.5),
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildActiveSwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppTheme.inputBackground.withOpacity(0.3),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: _isActive
                  ? AppTheme.success.withOpacity(0.1)
                  : AppTheme.textMuted.withOpacity(0.1),
            ),
            child: Icon(
              _isActive ? Icons.check_circle : Icons.cancel,
              color: _isActive ? AppTheme.success : AppTheme.textMuted,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حالة المدينة',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isActive ? 'نشطة' : 'غير نشطة',
                  style: AppTextStyles.caption.copyWith(
                    color: _isActive ? AppTheme.success : AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isActive,
            onChanged: (value) {
              setState(() {
                _isActive = value;
              });
            },
            activeColor: AppTheme.success,
            activeTrackColor: AppTheme.success.withOpacity(0.3),
            inactiveThumbColor: AppTheme.textMuted,
            inactiveTrackColor: AppTheme.textMuted.withOpacity(0.3),
          ),
        ],
      ),
    );
  }
  
  Widget _buildImageGallerySection() {
    return _buildInputCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('معرض الصور'),
          const SizedBox(height: 24),
          CityImageGallery(
            images: _images,
            onImagesChanged: (images) {
              setState(() {
                _images = images;
              });
            },
          ),
        ],
      ),
    );
  }
  
  void _saveCity() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isSaving = true;
    });
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    final newCity = City(
      name: _nameController.text,
      country: _countryController.text,
      images: _images,
      isActive: _isActive,
      createdAt: isEditing ? widget.city!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // Return the city data
    if (mounted) {
      context.pop(newCity);
    }
  }
}

// Custom Painter for diamond pattern
class _DiamondPatternPainter extends CustomPainter {
  final Color color;
  final double animation;
  
  _DiamondPatternPainter({
    required this.color,
    required this.animation,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    
    const spacing = 60.0;
    final offset = animation * spacing;
    
    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      for (double y = -spacing; y < size.height + spacing; y += spacing) {
        final path = Path()
          ..moveTo(x + offset, y)
          ..lineTo(x + spacing / 2 + offset, y - spacing / 2)
          ..lineTo(x + spacing + offset, y)
          ..lineTo(x + spacing / 2 + offset, y + spacing / 2)
          ..close();
        
        canvas.drawPath(path, paint);
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}