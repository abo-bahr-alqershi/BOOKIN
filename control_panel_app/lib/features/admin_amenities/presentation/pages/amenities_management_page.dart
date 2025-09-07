import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../bloc/amenities_bloc.dart';
import '../bloc/amenities_event.dart';
import '../bloc/amenities_state.dart';
import '../widgets/futuristic_amenities_table.dart';
import '../widgets/amenity_form_dialog.dart';
import '../widgets/amenity_filters_widget.dart';
import '../widgets/amenity_stats_card.dart';
import '../widgets/futuristic_amenity_card.dart';

class AmenitiesManagementPage extends StatefulWidget {
  const AmenitiesManagementPage({super.key});

  @override
  State<AmenitiesManagementPage> createState() =>
      _AmenitiesManagementPageState();
}

class _AmenitiesManagementPageState extends State<AmenitiesManagementPage>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _backgroundAnimationController;
  late AnimationController _glowAnimationController;
  late AnimationController _particleAnimationController;
  late AnimationController _contentAnimationController;

  // Animations
  late Animation<double> _backgroundRotation;
  late Animation<double> _glowAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;

  // Controllers
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // State
  bool _isGridView = false;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
  }

  void _initializeAnimations() {
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _glowAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _particleAnimationController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _backgroundRotation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _backgroundAnimationController,
      curve: Curves.linear,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowAnimationController,
      curve: Curves.easeInOut,
    ));

    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutQuart),
    ));

    _contentAnimationController.forward();
  }

  void _loadData() {
    context.read<AmenitiesBloc>().add(const LoadAmenitiesEvent());
    context.read<AmenitiesBloc>().add(const LoadAmenityStatsEvent());
    context.read<AmenitiesBloc>().add(const LoadPopularAmenitiesEvent());
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _glowAnimationController.dispose();
    _particleAnimationController.dispose();
    _contentAnimationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > AppDimensions.desktopBreakpoint;
        final isTablet = constraints.maxWidth > AppDimensions.tabletBreakpoint;

        return Scaffold(
          backgroundColor: AppTheme.darkBackground,
          body: Stack(
            children: [
              // Animated Background
              _buildAnimatedBackground(),

              // Particle Effects
              _buildParticleEffects(),

              // Main Content
              _buildMainContent(isDesktop, isTablet),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _backgroundRotation,
        _glowAnimation,
      ]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.darkBackground,
                AppTheme.darkBackground2.withOpacity(0.95),
                AppTheme.darkBackground3.withOpacity(0.9),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Grid Pattern
              CustomPaint(
                painter: _GridPatternPainter(
                  rotation: _backgroundRotation.value * 0.1,
                  opacity: 0.03,
                ),
                size: Size.infinite,
              ),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.5, -0.5),
                    radius: 1.5,
                    colors: [
                      AppTheme.primaryBlue.withOpacity(0.05 * _glowAnimation.value),
                      AppTheme.primaryPurple.withOpacity(0.03 * _glowAnimation.value),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildParticleEffects() {
    return AnimatedBuilder(
      animation: _particleAnimationController,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(
            animationValue: _particleAnimationController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildMainContent(bool isDesktop, bool isTablet) {
    return FadeTransition(
      opacity: _contentFadeAnimation,
      child: SlideTransition(
        position: _contentSlideAnimation,
        child: Column(
          children: [
            // App Bar
            _buildFuturisticAppBar(isDesktop),

            // Content
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: isDesktop ? 3 : 1,
                    child: _buildContentArea(isDesktop, isTablet),
                  ),
                  if (isDesktop)
                    Flexible(
                      flex: 0,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 360),
                        child: Container(
                          width: 360,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppTheme.darkCard.withOpacity(0.5),
                                AppTheme.darkCard.withOpacity(0.3),
                              ],
                            ),
                            border: Border(
                              left: BorderSide(
                                color: AppTheme.primaryBlue.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                          ),
                          child: _buildSidePanel(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFuturisticAppBar(bool isDesktop) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkCard.withOpacity(0.8),
            AppTheme.darkCard.withOpacity(0.6),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? AppDimensions.paddingXLarge : AppDimensions.paddingLarge,
            ),
            child: Row(
              children: [
                // Title Section
                _buildTitleSection(),

                const Spacer(),

                // Search Bar
                if (isDesktop)
                  SizedBox(
                    width: 300,
                    child: _buildSearchBar(),
                  ),

                if (isDesktop) const SizedBox(width: AppDimensions.paddingMedium),

                // View Toggle
                _buildViewToggle(),

                const SizedBox(width: AppDimensions.paddingMedium),

                // Add Button
                _buildAddButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Row(
      children: [
        // Icon with Glow
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.3 * _glowAnimation.value),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.star_rounded,
                color: Colors.white,
                size: 24,
              ),
            );
          },
        ),

        const SizedBox(width: AppDimensions.paddingMedium),

        // Title
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
              child: Text(
                'إدارة المرافق',
                style: AppTextStyles.heading2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              'إدارة مرافق وخدمات العقارات',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
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
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: AppTextStyles.bodyMedium.copyWith(color: AppTheme.textWhite),
        decoration: InputDecoration(
          hintText: 'البحث عن مرفق...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textMuted.withOpacity(0.5),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppTheme.primaryBlue.withOpacity(0.7),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        onChanged: (value) {
          context.read<AmenitiesBloc>().add(SearchAmenitiesEvent(searchTerm: value));
        },
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkSurface.withOpacity(0.5),
            AppTheme.darkSurface.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildToggleButton(
            icon: Icons.grid_view_rounded,
            isSelected: _isGridView,
            onTap: () => setState(() => _isGridView = true),
          ),
          _buildToggleButton(
            icon: Icons.table_rows_rounded,
            isSelected: !_isGridView,
            onTap: () => setState(() => _isGridView = false),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : AppTheme.textMuted,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _showAddAmenityDialog();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'إضافة مرفق',
              style: AppTextStyles.buttonMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentArea(bool isDesktop, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(
        isDesktop ? AppDimensions.paddingXLarge : AppDimensions.paddingLarge,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Stats Cards
            // _buildStatsCards(isDesktop, isTablet),

            const SizedBox(height: AppDimensions.paddingLarge),

            // Filters
            AmenityFiltersWidget(
              onFilterChanged: (isAssigned, isFree) {
                context.read<AmenitiesBloc>().add(
                      ApplyFiltersEvent(
                        isAssigned: isAssigned,
                        isFree: isFree,
                      ),
                    );
              },
            ),

            const SizedBox(height: AppDimensions.paddingLarge),

            // Content View
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.4,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: BlocBuilder<AmenitiesBloc, AmenitiesState>(
                builder: (context, state) {
                  if (state is AmenitiesLoading) {
                    return _buildLoadingView();
                  }

                  if (state is AmenitiesError) {
                    return _buildErrorView(state.message);
                  }

                  if (state is AmenitiesLoaded) {
                    if (_isGridView) {
                      return _buildGridView(state, isDesktop, isTablet);
                    } else {
                      return FuturisticAmenitiesTable(
                        amenities: state.amenities.items,
                        totalCount: state.amenities.totalCount,
                        currentPage: state.amenities.pageNumber,
                        pageSize: state.amenities.pageSize,
                        onPageChanged: (page) {
                          context.read<AmenitiesBloc>().add(
                                ChangePageEvent(pageNumber: page),
                              );
                        },
                        onEdit: _showEditAmenityDialog,
                        onDelete: _showDeleteConfirmation,
                        onToggleStatus: (amenity) {
                          context.read<AmenitiesBloc>().add(
                                ToggleAmenityStatusEvent(amenityId: amenity.id),
                              );
                        },
                      );
                    }
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(bool isDesktop, bool isTablet) {
    return BlocBuilder<AmenitiesBloc, AmenitiesState>(
      builder: (context, state) {
        if (state is AmenitiesLoaded && state.stats != null) {
          final columns = isDesktop ? 4 : (isTablet ? 2 : 1);
          
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: columns,
            crossAxisSpacing: AppDimensions.paddingMedium,
            mainAxisSpacing: AppDimensions.paddingMedium,
            childAspectRatio: isDesktop ? 1.5 : 2,
            children: [
              AmenityStatsCard(
                title: 'إجمالي المرافق',
                value: state.stats!.totalAmenities.toString(),
                icon: Icons.category_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
              ),
              AmenityStatsCard(
                title: 'المرافق النشطة',
                value: state.stats!.activeAmenities.toString(),
                icon: Icons.check_circle_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D4FF), Color(0xFF00A3FF)],
                ),
              ),
              AmenityStatsCard(
                title: 'إجمالي الإسنادات',
                value: state.stats!.totalAssignments.toString(),
                icon: Icons.link_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                ),
              ),
              AmenityStatsCard(
                title: 'الإيرادات',
                value: '\$${state.stats!.totalRevenue.toStringAsFixed(0)}',
                icon: Icons.attach_money_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFF00FF88), Color(0xFF00D4FF)],
                ),
              ),
            ],
          );
        }
        
        return _buildStatsLoadingSkeleton(isDesktop, isTablet);
      },
    );
  }

  Widget _buildStatsLoadingSkeleton(bool isDesktop, bool isTablet) {
    final columns = isDesktop ? 4 : (isTablet ? 2 : 1);
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: columns,
      crossAxisSpacing: AppDimensions.paddingMedium,
      mainAxisSpacing: AppDimensions.paddingMedium,
      childAspectRatio: isDesktop ? 1.5 : 2,
      children: List.generate(
        4,
        (index) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.darkCard.withOpacity(0.5),
                AppTheme.darkCard.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridView(AmenitiesLoaded state, bool isDesktop, bool isTablet) {
    final columns = isDesktop ? 4 : (isTablet ? 3 : 2);
    
    return GridView.builder(
      controller: _scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: AppDimensions.paddingMedium,
        mainAxisSpacing: AppDimensions.paddingMedium,
        childAspectRatio: 1,
      ),
      itemCount: state.amenities.items.length,
      itemBuilder: (context, index) {
        final amenity = state.amenities.items[index];
        return FuturisticAmenityCard(
          amenity: amenity,
          animationDelay: Duration(milliseconds: index * 50),
          onTap: () => _showAmenityDetails(amenity),
          onEdit: () => _showEditAmenityDialog(amenity),
          onDelete: () => _showDeleteConfirmation(amenity),
        );
      },
    );
  }

  Widget _buildSidePanel() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Popular Amenities
          _buildPopularAmenitiesSection(),
          
          const SizedBox(height: AppDimensions.paddingLarge),
          
          // Recent Activities
          _buildRecentActivitiesSection(),
        ],
      ),
    );
  }

  Widget _buildPopularAmenitiesSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        gradient: LinearGradient(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'المرافق الشائعة',
                style: AppTextStyles.heading3.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          BlocBuilder<AmenitiesBloc, AmenitiesState>(
            builder: (context, state) {
              if (state is AmenitiesLoaded) {
                return Column(
                  children: state.popularAmenities
                      .take(5)
                      .map((amenity) => _buildPopularAmenityItem(amenity))
                      .toList(),
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPopularAmenityItem(amenity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkSurface.withOpacity(0.3),
            AppTheme.darkSurface.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient.scale(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getIconForAmenity(amenity.icon),
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  amenity.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textWhite,
                  ),
                ),
                Text(
                  '${amenity.propertiesCount} عقار',
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '+${((amenity.propertiesCount ?? 0) * 2.5).toInt()}%',
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitiesSection() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          gradient: LinearGradient(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'النشاطات الأخيرة',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppTheme.textWhite,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return _buildActivityItem(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(int index) {
    final activities = [
      {'action': 'إضافة', 'item': 'واي فاي مجاني', 'time': 'قبل 5 دقائق'},
      {'action': 'تحديث', 'item': 'موقف سيارات', 'time': 'قبل 15 دقيقة'},
      {'action': 'حذف', 'item': 'خدمة الغرف', 'time': 'قبل ساعة'},
      {'action': 'إسناد', 'item': 'مسبح', 'time': 'قبل ساعتين'},
      {'action': 'تفعيل', 'item': 'صالة رياضية', 'time': 'قبل 3 ساعات'},
    ];

    final activity = activities[index];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkSurface.withOpacity(0.2),
            AppTheme.darkSurface.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _getActivityColor(activity['action']!),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: activity['action'],
                        style: AppTextStyles.bodySmall.copyWith(
                          color: _getActivityColor(activity['action']!),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: ' ${activity['item']}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppTheme.textWhite,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  activity['time']!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getActivityColor(String action) {
    switch (action) {
      case 'إضافة':
        return AppTheme.success;
      case 'تحديث':
        return AppTheme.primaryBlue;
      case 'حذف':
        return AppTheme.error;
      case 'إسناد':
        return AppTheme.warning;
      case 'تفعيل':
        return AppTheme.neonGreen;
      default:
        return AppTheme.textMuted;
    }
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'جاري تحميل المرافق...',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
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
                Icons.error_outline_rounded,
                color: AppTheme.error,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'حدث خطأ',
              style: AppTextStyles.heading2.copyWith(
                color: AppTheme.error,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: _loadData,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'إعادة المحاولة',
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAmenityDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AmenityFormDialog(
        onSave: (name, description, icon) {
          context.read<AmenitiesBloc>().add(
                CreateAmenityEvent(
                  name: name,
                  description: description,
                  icon: icon,
                ),
              );
        },
      ),
    );
  }

  void _showEditAmenityDialog(amenity) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AmenityFormDialog(
        amenity: amenity,
        onSave: (name, description, icon) {
          context.read<AmenitiesBloc>().add(
                UpdateAmenityEvent(
                  amenityId: amenity.id,
                  name: name,
                  description: description,
                  icon: icon,
                ),
              );
        },
      ),
    );
  }

  void _showDeleteConfirmation(amenity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppTheme.error.withOpacity(0.3),
            width: 1,
          ),
        ),
        title: Text(
          'تأكيد الحذف',
          style: AppTextStyles.heading2.copyWith(
            color: AppTheme.error,
          ),
        ),
        content: Text(
          'هل أنت متأكد من حذف المرفق "${amenity.name}"؟',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textWhite,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AmenitiesBloc>().add(
                    DeleteAmenityEvent(amenityId: amenity.id),
                  );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'حذف',
              style: AppTextStyles.buttonMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAmenityDetails(amenity) {
    // TODO: Implement amenity details dialog
  }

  IconData _getIconForAmenity(String iconName) {
    final iconMap = {
      'wifi': Icons.wifi_rounded,
      'parking': Icons.local_parking_rounded,
      'pool': Icons.pool_rounded,
      'gym': Icons.fitness_center_rounded,
      'restaurant': Icons.restaurant_rounded,
      'spa': Icons.spa_rounded,
      'laundry': Icons.local_laundry_service_rounded,
      'ac': Icons.ac_unit_rounded,
      'tv': Icons.tv_rounded,
      'kitchen': Icons.kitchen_rounded,
    };
    
    return iconMap[iconName] ?? Icons.star_rounded;
  }
}

// Custom Painters
class _GridPatternPainter extends CustomPainter {
  final double rotation;
  final double opacity;

  _GridPatternPainter({
    required this.rotation,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryBlue.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(rotation);
    canvas.translate(-size.width / 2, -size.height / 2);

    const spacing = 30.0;

    for (double x = -size.width; x < size.width * 2; x += spacing) {
      canvas.drawLine(
        Offset(x, -size.height),
        Offset(x, size.height * 2),
        paint,
      );
    }

    for (double y = -size.height; y < size.height * 2; y += spacing) {
      canvas.drawLine(
        Offset(-size.width, y),
        Offset(size.width * 2, y),
        paint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ParticlePainter extends CustomPainter {
  final double animationValue;

  _ParticlePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final y = (baseY - animationValue * size.height) % size.height;
      final radius = random.nextDouble() * 2 + 0.5;
      final opacity = random.nextDouble() * 0.3 + 0.1;

      paint.color = AppTheme.primaryBlue.withOpacity(opacity);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}