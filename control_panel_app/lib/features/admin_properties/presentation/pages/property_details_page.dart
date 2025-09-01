// lib/features/admin_properties/presentation/pages/property_details_page.dart

import 'package:bookn_cp_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:bookn_cp_app/core/theme/app_colors.dart';
import 'package:bookn_cp_app/core/theme/app_text_styles.dart';
import 'package:bookn_cp_app/core/theme/app_dimensions.dart';
import '../bloc/properties/properties_bloc.dart';
import '../../domain/entities/property.dart';
import '../widgets/property_image_gallery.dart';
import '../widgets/property_map_view.dart';

class PropertyDetailsPage extends StatefulWidget {
  final String propertyId;
  
  const PropertyDetailsPage({
    super.key,
    required this.propertyId,
  });
  
  @override
  State<PropertyDetailsPage> createState() => _PropertyDetailsPageState();
}

class _PropertyDetailsPageState extends State<PropertyDetailsPage>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _animationController;
  late AnimationController _parallaxController;
  late AnimationController _glowController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Scroll Controller
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  
  // Tab Controller
  late TabController _tabController;
  
  // Mock Property Data (Replace with BLoC data)
  final Property _property = Property(
    id: '1',
    ownerId: 'owner1',
    typeId: 'resort',
    name: 'منتجع الشاطئ الأزرق',
    address: 'شارع الكورنيش، عدن',
    city: 'عدن',
    latitude: 12.7855,
    longitude: 45.0187,
    starRating: 5,
    description: 'منتجع فاخر على شاطئ البحر مع إطلالات خلابة ومرافق عالمية المستوى',
    isApproved: true,
    createdAt: DateTime.now(),
    ownerName: 'أحمد محمد',
    typeName: 'منتجع',
    distanceKm: 5.2,
    images: [],
    amenities: [],
    policies: [],
    stats: PropertyStats(
      totalBookings: 156,
      activeBookings: 12,
      averageRating: 4.8,
      reviewCount: 89,
      occupancyRate: 78.5,
      monthlyRevenue: 125000,
    ),
  );
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollListener();
    _tabController = TabController(length: 4, vsync: this);
  }
  
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _parallaxController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
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
  
  void _setupScrollListener() {
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _parallaxController.dispose();
    _glowController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
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
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Parallax Header
              _buildParallaxHeader(),
              
              // Property Info
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildPropertyInfo(),
                  ),
                ),
              ),
              
              // Stats Cards
              SliverToBoxAdapter(
                child: _buildStatsSection(),
              ),
              
              // Tabs Content
              SliverToBoxAdapter(
                child: _buildTabsContent(),
              ),
            ],
          ),
          
          // Floating Action Buttons
          _buildFloatingActions(),
        ],
      ),
    );
  }
  
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _parallaxController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.darkBackground,
                AppTheme.darkBackground2.withValues(alpha: 0.8),
                AppTheme.primaryBlue.withValues(alpha: 0.02),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildParallaxHeader() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppTheme.darkCard.withValues(alpha: 0.9),
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.darkBackground.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.darkBorder.withValues(alpha: 0.3),
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
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(Icons.edit_rounded, size: 20,color: AppTheme.glowWhite),
            onPressed: () => context.push('/admin/properties/${widget.propertyId}/edit'),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Property Image with Parallax
            Transform.translate(
              offset: Offset(0, _scrollOffset * 0.5),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.primaryBlue.withValues(alpha: 0.3),
                      AppTheme.primaryPurple.withValues(alpha: 0.5),
                    ],
                  ),
                ),
                child: _property.images.isNotEmpty
                    ? Image.network(
                        _property.images.first.url,
                        fit: BoxFit.cover,
                      )
                    : Center(
                        child: Icon(
                          Icons.business_rounded,
                          size: 80,
                          color: AppTheme.textWhite.withValues(alpha: 0.5),
                        ),
                      ),
              ),
            ),
            
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppTheme.darkBackground.withValues(alpha: 0.7),
                    AppTheme.darkBackground,
                  ],
                  stops: const [0.3, 0.7, 1.0],
                ),
              ),
            ),
            
            // Property Name
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                    child: Text(
                      _property.name,
                      style: AppTextStyles.heading1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: AppTheme.primaryBlue.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _property.formattedAddress,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPropertyInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status and Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: _property.isApproved
                      ? LinearGradient(
                          colors: [
                            AppTheme.success.withValues(alpha: 0.2),
                            AppTheme.success.withValues(alpha: 0.1),
                          ],
                        )
                      : LinearGradient(
                          colors: [
                            AppTheme.warning.withValues(alpha: 0.2),
                            AppTheme.warning.withValues(alpha: 0.1),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _property.isApproved
                        ? AppTheme.success.withValues(alpha: 0.5)
                        : AppTheme.warning.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _property.isApproved
                          ? Icons.check_circle_rounded
                          : Icons.pending_rounded,
                      size: 16,
                      color: _property.isApproved
                          ? AppTheme.success
                          : AppTheme.warning,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _property.isApproved ? 'معتمد' : 'قيد المراجعة',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _property.isApproved
                            ? AppTheme.success
                            : AppTheme.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < _property.starRating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 20,
                    color: AppTheme.warning,
                  );
                }),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Description
          Text(
            'الوصف',
            style: AppTextStyles.heading3.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _property.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textLight,
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Owner Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.darkCard.withValues(alpha: 0.5),
                  AppTheme.darkCard.withValues(alpha: 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.darkBorder.withValues(alpha: 0.3),
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
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _property.ownerName[0],
                      style: AppTextStyles.heading3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المالك',
                        style: AppTextStyles.caption.copyWith(
                          color: AppTheme.textMuted,
                        ),
                      ),
                      Text(
                        _property.ownerName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppTheme.textWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _property.typeName,
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatsSection() {
    final stats = _property.stats;
    if (stats == null) return const SizedBox.shrink();
    
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildStatCard(
            icon: Icons.book_rounded,
            label: 'الحجوزات',
            value: stats.totalBookings.toString(),
            color: AppTheme.primaryBlue,
          ),
          _buildStatCard(
            icon: Icons.star_rounded,
            label: 'التقييم',
            value: stats.averageRating.toStringAsFixed(1),
            color: AppTheme.warning,
          ),
          _buildStatCard(
            icon: Icons.percent_rounded,
            label: 'الإشغال',
            value: '${stats.occupancyRate.toStringAsFixed(1)}%',
            color: AppTheme.success,
          ),
          _buildStatCard(
            icon: Icons.attach_money_rounded,
            label: 'الإيرادات',
            value: '${(stats.monthlyRevenue / 1000).toStringAsFixed(0)}k',
            color: AppTheme.primaryPurple,
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          width: 100,
          margin: const EdgeInsets.only(left: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.3 + _glowController.value * 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1 * _glowController.value),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                value,
                style: AppTextStyles.heading3.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildTabsContent() {
    return Container(
      height: 500,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.7),
            AppTheme.darkCard.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.darkBorder.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryBlue,
              unselectedLabelColor: AppTheme.textMuted,
              indicatorColor: AppTheme.primaryBlue,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'الصور', icon: Icon(Icons.photo_library_rounded, size: 18)),
                Tab(text: 'الموقع', icon: Icon(Icons.map_rounded, size: 18)),
                Tab(text: 'المرافق', icon: Icon(Icons.apartment_rounded, size: 18)),
                Tab(text: 'السياسات', icon: Icon(Icons.policy_rounded, size: 18)),
              ],
            ),
          ),
          
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Images Tab
                PropertyImageGallery(
                  images: const ['image1', 'image2', 'image3'],
                  onImagesChanged: (_) {},
                  isReadOnly: true,
                ),
                
                // Map Tab
                PropertyMapView(
                  initialLocation: (_property.latitude ?? 0, _property.longitude ?? 0),
                  isReadOnly: true,
                ),
                
                // Amenities Tab
                _buildAmenitiesTab(),
                
                // Policies Tab
                _buildPoliciesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAmenitiesTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        final amenities = [
          {'icon': Icons.wifi_rounded, 'name': 'واي فاي'},
          {'icon': Icons.pool_rounded, 'name': 'مسبح'},
          {'icon': Icons.local_parking_rounded, 'name': 'موقف سيارات'},
          {'icon': Icons.restaurant_rounded, 'name': 'مطعم'},
          {'icon': Icons.fitness_center_rounded, 'name': 'صالة رياضية'},
          {'icon': Icons.spa_rounded, 'name': 'سبا'},
          {'icon': Icons.beach_access_rounded, 'name': 'شاطئ خاص'},
          {'icon': Icons.room_service_rounded, 'name': 'خدمة الغرف'},
        ];
        
        final amenity = amenities[index];
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryBlue.withValues(alpha: 0.1),
                AppTheme.primaryBlue.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryBlue.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                amenity['icon'] as IconData,
                color: AppTheme.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                amenity['name'] as String,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildPoliciesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildPolicyCard(
          icon: Icons.cancel_rounded,
          title: 'سياسة الإلغاء',
          description: 'إلغاء مجاني حتى 48 ساعة قبل الوصول',
          color: AppTheme.warning,
        ),
        _buildPolicyCard(
          icon: Icons.login_rounded,
          title: 'تسجيل الدخول',
          description: 'من الساعة 2:00 مساءً',
          color: AppTheme.success,
        ),
        _buildPolicyCard(
          icon: Icons.logout_rounded,
          title: 'تسجيل الخروج',
          description: 'حتى الساعة 12:00 ظهراً',
          color: AppTheme.info,
        ),
        _buildPolicyCard(
          icon: Icons.pets_rounded,
          title: 'الحيوانات الأليفة',
          description: 'غير مسموح بالحيوانات الأليفة',
          color: AppTheme.error,
        ),
      ],
    );
  }
  
  Widget _buildPolicyCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFloatingActions() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        children: [
          _buildFloatingButton(
            icon: Icons.check_circle_rounded,
            color: AppTheme.success,
            onTap: () {
              context.read<PropertiesBloc>().add(
                ApprovePropertyEvent(widget.propertyId),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildFloatingButton(
            icon: Icons.cancel_rounded,
            color: AppTheme.error,
            onTap: () {
              context.read<PropertiesBloc>().add(
                RejectPropertyEvent(widget.propertyId),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildFloatingButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.8),
              color.withValues(alpha: 0.6),
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}