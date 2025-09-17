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

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollListener();
    _tabController = TabController(length: 4, vsync: this);

    // جلب تفاصيل العقار من الـ Backend
    context.read<PropertiesBloc>().add(
          LoadPropertyDetailsEvent(
            propertyId: widget.propertyId,
            includeUnits: true,
          ),
        );
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
      body: BlocBuilder<PropertiesBloc, PropertiesState>(
        builder: (context, state) {
          if (state is PropertyDetailsLoading) {
            return _buildLoadingState();
          }

          if (state is PropertyDetailsError) {
            return _buildErrorState(state.message);
          }

          if (state is PropertyDetailsLoaded) {
            return _buildLoadedState(state.property);
          }

          return _buildInitialState();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'جاري تحميل تفاصيل العقار...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              color: AppTheme.error,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'حدث خطأ في تحميل البيانات',
            style: AppTextStyles.heading3.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              context.read<PropertiesBloc>().add(
                    LoadPropertyDetailsEvent(
                      propertyId: widget.propertyId,
                      includeUnits: true,
                    ),
                  );
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_rounded,
            color: AppTheme.textMuted,
            size: 80,
          ),
          const SizedBox(height: 20),
          Text(
            'لا توجد بيانات للعرض',
            style: AppTextStyles.heading3.copyWith(
              color: AppTheme.textWhite,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('العودة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.darkCard,
              foregroundColor: AppTheme.textWhite,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(Property property) {
    return Stack(
      children: [
        // Animated Background
        _buildAnimatedBackground(),

        // Main Content
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Parallax Header
            _buildParallaxHeader(property),

            // Property Info
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildPropertyInfo(property),
                ),
              ),
            ),

            // Stats Cards
            if (property.stats != null)
              SliverToBoxAdapter(
                child: _buildStatsSection(property),
              ),

            // Tabs Content
            SliverToBoxAdapter(
              child: _buildTabsContent(property),
            ),
          ],
        ),

        // Floating Action Buttons
        _buildFloatingActions(property),
      ],
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

  Widget _buildParallaxHeader(Property property) {
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
            icon: Icon(Icons.edit_rounded, size: 20, color: AppTheme.glowWhite),
            onPressed: () =>
                context.push('/admin/properties/${widget.propertyId}/edit'),
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
                child: property.images.isNotEmpty
                    ? Image.network(
                        property.images.first.url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.business_rounded,
                              size: 80,
                              color: AppTheme.textWhite.withValues(alpha: 0.5),
                            ),
                          );
                        },
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
                    shaderCallback: (bounds) =>
                        AppTheme.primaryGradient.createShader(bounds),
                    child: Text(
                      property.name,
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
                        property.formattedAddress,
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

  Widget _buildPropertyInfo(Property property) {
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: property.isApproved
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
                    color: property.isApproved
                        ? AppTheme.success.withValues(alpha: 0.5)
                        : AppTheme.warning.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      property.isApproved
                          ? Icons.check_circle_rounded
                          : Icons.pending_rounded,
                      size: 16,
                      color: property.isApproved
                          ? AppTheme.success
                          : AppTheme.warning,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      property.isApproved ? 'معتمد' : 'قيد المراجعة',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: property.isApproved
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
                    index < property.starRating
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
            property.description,
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
                      property.ownerName.isNotEmpty
                          ? property.ownerName[0]
                          : 'U',
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
                        property.ownerName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppTheme.textWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    property.typeName,
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

  Widget _buildStatsSection(Property property) {
    final stats = property.stats;
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

  Widget _buildTabsContent(Property property) {
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
                Tab(
                    text: 'الصور',
                    icon: Icon(Icons.photo_library_rounded, size: 18)),
                Tab(text: 'الموقع', icon: Icon(Icons.map_rounded, size: 18)),
                Tab(
                    text: 'المرافق',
                    icon: Icon(Icons.apartment_rounded, size: 18)),
                Tab(
                    text: 'السياسات',
                    icon: Icon(Icons.policy_rounded, size: 18)),
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
                  propertyId: property.id,
                  // images: property.images.map((img) => img.url).toList(),
                  onImagesChanged: (_) {},
                  isReadOnly: true,
                ),

                // Map Tab
                PropertyMapView(
                  initialLocation: (
                    property.latitude ?? 0,
                    property.longitude ?? 0
                  ),
                  isReadOnly: true,
                ),

                // Amenities Tab
                _buildAmenitiesTab(property),

                // Policies Tab
                _buildPoliciesTab(property),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesTab(Property property) {
    if (property.amenities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.apartment_rounded,
              color: AppTheme.textMuted.withValues(alpha: 0.5),
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد مرافق مضافة',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3,
      ),
      itemCount: property.amenities.length,
      itemBuilder: (context, index) {
        final amenity = property.amenities[index];

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
                _getAmenityIcon(amenity.icon ?? 'wifi'),
                color: AppTheme.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  amenity.name,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.textWhite,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getAmenityIcon(String iconName) {
    return AmenityIcons.getIconByName(iconName)?.icon ?? Icons.star_rounded;
  }

  Widget _buildPoliciesTab(Property property) {
    if (property.policies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.policy_rounded,
              color: AppTheme.textMuted.withValues(alpha: 0.5),
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد سياسات مضافة',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: property.policies.length,
      itemBuilder: (context, index) {
        final policy = property.policies[index];

        return _buildPolicyCard(
          icon: _getPolicyIcon(policy.policyType.name),
          title: policy.policyTypeLabel,
          description: policy.description,
          color: _getPolicyColor(policy.policyType.name),
        );
      },
    );
  }

  IconData _getPolicyIcon(String type) {
    final iconMap = {
      'cancellation': Icons.cancel_rounded,
      'check_in': Icons.login_rounded,
      'check_out': Icons.logout_rounded,
      'pets': Icons.pets_rounded,
      'smoking': Icons.smoke_free_rounded,
      'payment': Icons.payment_rounded,
    };

    return iconMap[type] ?? Icons.info_rounded;
  }

  Color _getPolicyColor(String type) {
    final colorMap = {
      'cancellation': AppTheme.warning,
      'check_in': AppTheme.success,
      'check_out': AppTheme.info,
      'pets': AppTheme.error,
      'smoking': AppTheme.error,
      'payment': AppTheme.primaryBlue,
    };

    return colorMap[type] ?? AppTheme.primaryBlue;
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

  Widget _buildFloatingActions(Property property) {
    if (property.isApproved) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        children: [
          _buildFloatingButton(
            icon: Icons.check_circle_rounded,
            color: AppTheme.success,
            onTap: () {
              HapticFeedback.mediumImpact();
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
              HapticFeedback.mediumImpact();
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
      onTap: onTap,
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
