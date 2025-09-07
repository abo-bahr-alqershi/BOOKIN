import 'package:bookn_cp_app/core/theme/app_dimensions.dart';
import 'package:bookn_cp_app/features/admin_amenities/domain/entities/amenity.dart';
import 'package:bookn_cp_app/features/admin_amenities/presentation/bloc/amenities_event.dart';
import 'package:bookn_cp_app/features/admin_amenities/presentation/bloc/amenities_state.dart';
import 'package:bookn_cp_app/features/admin_amenities/presentation/widgets/assign_amenity_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/amenities_bloc.dart';
import '../widgets/futuristic_amenities_table.dart';
import '../widgets/futuristic_amenity_card.dart';
import '../widgets/amenity_filters_widget.dart';
import '../widgets/amenity_stats_card.dart';

class AmenitiesManagementPage extends StatefulWidget {
  const AmenitiesManagementPage({super.key});

  @override
  State<AmenitiesManagementPage> createState() => _AmenitiesManagementPageState();
}

class _AmenitiesManagementPageState extends State<AmenitiesManagementPage>
    with TickerProviderStateMixin {
  // Animation Controllers - نفس نمط الوحدات
  late AnimationController _glowController;
  late AnimationController _contentAnimationController;
  
  // Animations
  late Animation<double> _glowAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;
  
  // State
  final ScrollController _scrollController = ScrollController();
  bool _showFilters = false;
  String _selectedView = 'table'; // grid, table
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadAmenities();
  }
  
  void _initializeAnimations() {
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeOut,
    ));
    
    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeOutQuart,
    ));
    
    // Start animations
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _contentAnimationController.forward();
      }
    });
  }
  
  void _loadAmenities() {
    context.read<AmenitiesBloc>().add(const LoadAmenitiesEvent());
  }
  
  @override
  void dispose() {
    _glowController.dispose();
    _contentAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // Animated Background - نفس نمط الوحدات مع ألوان مختلفة
          _buildAnimatedBackground(),
          
          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Premium Header - محسّن ليطابق الوحدات
                _buildPremiumHeader(),
                
                // Stats Cards - محسّن
                // LayoutBuilder(
                //   builder: (context, constraints) {
                //     final width = constraints.maxWidth;
                //     final bool isDesktop = width >= 1024;
                //     final bool isTablet = width >= 600 && width < 1024;
                //     return _buildStatsSection(isDesktop, isTablet);
                //   },
                // ),
                
                // Filters Section
                if (_showFilters) _buildFiltersSection(),
                
                // Content Area
                Expanded(
                  child: FadeTransition(
                    opacity: _contentFadeAnimation,
                    child: SlideTransition(
                      position: _contentSlideAnimation,
                      child: _buildContent(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Floating Action Button
          _buildFloatingActionButton(),
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
            AppTheme.darkBackground3.withOpacity(0.6),
          ],
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: const SizedBox.expand(),
      ),
    );
  }
  
  Widget _buildPremiumHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.7),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryPurple.withOpacity(0.3), // Purple للمرافق
            width: 1,
          ),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              Row(
                children: [
                  // Title with gradient
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              AppTheme.primaryPurple,
                              AppTheme.primaryBlue,
                            ],
                          ).createShader(bounds),
                          child: Text(
                            'إدارة المرافق',
                            style: AppTextStyles.heading1.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'إدارة جميع مرافق وخدمات العقارات',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Action Buttons
                  Flexible(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildActionButton(
                            icon: Icons.filter_list_rounded,
                            label: 'فلتر',
                            onTap: () => setState(() => _showFilters = !_showFilters),
                            isActive: _showFilters,
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            icon: Icons.grid_view_rounded,
                            label: 'شبكة',
                            onTap: () => setState(() => _selectedView = 'grid'),
                            isActive: _selectedView == 'grid',
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            icon: Icons.table_chart_rounded,
                            label: 'جدول',
                            onTap: () => setState(() => _selectedView = 'table'),
                            isActive: _selectedView == 'table',
                          ),
                          const SizedBox(width: 16),
                          _buildPrimaryActionButton(
                            icon: Icons.add_rounded,
                            label: 'إضافة مرفق',
                            onTap: () => context.push('/admin/amenities/create'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Search Bar - محسّن
              _buildSearchBar(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() => _searchQuery = value);
          context.read<AmenitiesBloc>().add(SearchAmenitiesEvent(searchTerm: value));
        },
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppTheme.textWhite,
        ),
        decoration: InputDecoration(
          hintText: 'البحث عن مرفق...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textMuted.withOpacity(0.5),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppTheme.primaryPurple.withOpacity(0.7),
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: AppTheme.textMuted.withOpacity(0.5),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() => _searchQuery = '');
                    context.read<AmenitiesBloc>().add(const SearchAmenitiesEvent(searchTerm: ''));
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primaryPurple
              : AppTheme.darkCard.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? AppTheme.primaryPurple.withOpacity(0.5)
                : AppTheme.darkBorder.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppTheme.primaryPurple.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : AppTheme.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isActive ? Colors.white : AppTheme.textMuted,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPrimaryActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.primaryPurple,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryPurple.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.buttonMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
  

    Widget _buildStatsSection(bool isDesktop, bool isTablet) {
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
            color: AppTheme.darkCard.withOpacity(0.5),
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


  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withOpacity(0.4),
        border: Border(
          top: BorderSide(
            color: AppTheme.darkBorder.withOpacity(0.2),
            width: 1,
          ),
          bottom: BorderSide(
            color: AppTheme.darkBorder.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: AmenityFiltersWidget(
        onFilterChanged: (isAssigned, isFree) {
          context.read<AmenitiesBloc>().add(
            ApplyFiltersEvent(
              isAssigned: isAssigned,
              isFree: isFree,
            ),
          );
        },
      ),
    );
  }
  
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(30),
            ),
            border: Border.all(
              color: AppTheme.primaryPurple.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryPurple.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Column(
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryPurple, AppTheme.primaryBlue],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppTheme.darkBorder.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppTheme.primaryPurple, AppTheme.primaryBlue],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryPurple.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.filter_list_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الفلاتر المتقدمة',
                                style: AppTextStyles.heading3.copyWith(
                                  color: AppTheme.textWhite,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'تصفية وترتيب المرافق',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppTheme.darkSurface.withOpacity(0.5),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.darkBorder.withOpacity(0.3),
                                width: 1,
                              ),
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
                  ),
                  
                  // Filter Content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: AmenityFiltersWidget(
                        onFilterChanged: (isAssigned, isFree) {
                          context.read<AmenitiesBloc>().add(
                            ApplyFiltersEvent(
                              isAssigned: isAssigned,
                              isFree: isFree,
                            ),
                          );
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<AmenitiesBloc, AmenitiesState>(
      builder: (context, state) {
        if (state is AmenitiesLoading) {
          return _buildLoadingState();
        }
        
        if (state is AmenitiesError) {
          return _buildErrorState(state.message);
        }
        
        if (state is AmenitiesLoaded) {
          if (state.amenities.items.isEmpty) {
            return _buildEmptyState();
          }
          
          switch (_selectedView) {
            case 'grid':
              return _buildGridView(state);
            case 'table':
              return FuturisticAmenitiesTable(
                amenities: state.amenities.items,
                onAmenitySelected: (amenity) => _navigateToAmenity(amenity.id),
                onEditAmenity: (amenity) => _navigateToEditAmenity(amenity.id),
                onDeleteAmenity: (amenity) => _showDeleteConfirmation(amenity),
                onAssignAmenity: (amenity) => _showAssignAmenityDialog(amenity),
              );
            default:
              return _buildGridView(state);
          }
        }
        
        return const SizedBox.shrink();
      },
    );
  }
  
  Widget _buildGridView(AmenitiesLoaded state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 3;
        if (constraints.maxWidth < 900) {
          crossAxisCount = 2;
        }
        if (constraints.maxWidth < 600) {
          crossAxisCount = 1;
        }
        
        return GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: state.amenities.items.length,
          itemBuilder: (context, index) {
            final amenity = state.amenities.items[index];
            return FuturisticAmenityCard(
              amenity: amenity,
              onTap: () => _navigateToAmenity(amenity.id),
              onEdit: () => _navigateToEditAmenity(amenity.id),
              onDelete: () => _showDeleteConfirmation(amenity),
            );
          },
        );
      },
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
              gradient: LinearGradient(
                colors: [AppTheme.primaryPurple, AppTheme.primaryBlue],
              ),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'جاري تحميل المرافق...',
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
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: AppTheme.error.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _loadAmenities,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryPurple, AppTheme.primaryBlue],
                ),
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
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryPurple.withOpacity(0.1),
                  AppTheme.primaryBlue.withOpacity(0.05),
                ],
              ),
            ),
            child: Icon(
              Icons.star_outline_rounded,
              size: 60,
              color: AppTheme.primaryPurple.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد مرافق',
            style: AppTextStyles.heading2.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ بإضافة مرفق جديد',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => context.push('/admin/amenities/create'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryPurple, AppTheme.primaryBlue],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPurple.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'إضافة مرفق جديد',
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFloatingActionButton() {
    return Positioned(
      bottom: 24,
      right: 24,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPurple.withOpacity(0.4 * _glowAnimation.value),
                  blurRadius: 20 + 10 * _glowAnimation.value,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () => context.push('/admin/amenities/create'),
              backgroundColor: AppTheme.primaryPurple,
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          );
        },
      ),
    );
  }
  
  void _navigateToAmenity(String amenityId) {
    context.push('/admin/amenities/$amenityId');
  }
  
  void _navigateToEditAmenity(String amenityId) {
    context.push('/admin/amenities/$amenityId/edit');
  }
  
  void _showDeleteConfirmation(dynamic amenity) {
    showDialog(
      context: context,
      builder: (context) => _DeleteConfirmationDialog(
        amenityName: amenity.name ?? 'المرفق',
        onConfirm: () {
          context.read<AmenitiesBloc>().add(DeleteAmenityEvent(amenityId: amenity.id));
          Navigator.pop(context);
        },
      ),
    );
  }


  // عند استدعاء الديالوج
  void _showAssignAmenityDialog(Amenity amenity) {
    AssignAmenityDialog.show(
      context: context,
      amenity: amenity,
      onAssign: ({
        required String amenityId,
        required String propertyId,
        required bool isAvailable,
        double? extraCost,
        String? description,
      }) async {
        // استخدام الـ Bloc من الـ context الحالي
        context.read<AmenitiesBloc>().add(
          AssignAmenityToPropertyEvent(
            amenityId: amenityId,
            propertyId: propertyId,
            isAvailable: isAvailable,
            extraCost: extraCost,
            description: description,
          ),
        );
      },
      onSuccess: () {
        // إعادة تحميل البيانات
        context.read<AmenitiesBloc>().add(const RefreshAmenitiesEvent());
      },
      onError: (message) {
        // معالجة الخطأ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
    );
  }
}

// Delete Confirmation Dialog
class _DeleteConfirmationDialog extends StatelessWidget {
  final String amenityName;
  final VoidCallback onConfirm;
  
  const _DeleteConfirmationDialog({
    required this.amenityName,
    required this.onConfirm,
  });
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
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
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
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
                color: AppTheme.error,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'تأكيد الحذف',
              style: AppTextStyles.heading3.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'هل أنت متأكد من حذف "$amenityName"؟\nلا يمكن التراجع عن هذا الإجراء.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.darkSurface.withOpacity(0.5),
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
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      onConfirm();
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryPurple.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
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
    );
  }
}

// Background Painter - محسّن للمرافق
class _AmenitiesBackgroundPainter extends CustomPainter {
  final double rotation;
  final double glowIntensity;
  
  _AmenitiesBackgroundPainter({
    required this.rotation,
    required this.glowIntensity,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    
    // Draw grid with purple tint
    paint.color = AppTheme.primaryPurple.withOpacity(0.05);
    const spacing = 50.0;
    
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
    
    // Draw rotating circles with gradient
    final center = Offset(size.width / 2, size.height / 2);
    
    for (int i = 0; i < 3; i++) {
      final radius = 200.0 + i * 100;
      paint.color = Color.lerp(
        AppTheme.primaryPurple,
        AppTheme.primaryBlue,
        i / 3,
      )!.withOpacity(0.03 * glowIntensity);
      
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation + i * 0.5);
      canvas.translate(-center.dx, -center.dy);
      canvas.drawCircle(center, radius, paint);
      canvas.restore();
    }
    
    // Draw hexagon pattern
    paint.color = AppTheme.primaryPurple.withOpacity(0.02 * glowIntensity);
    paint.style = PaintingStyle.stroke;
    
    for (int i = 0; i < 5; i++) {
      final path = Path();
      final hexRadius = 150.0 + i * 50;
      for (int j = 0; j < 6; j++) {
        final angle = (j * 60 - 30) * math.pi / 180 + rotation * 0.5;
        final x = center.dx + hexRadius * math.cos(angle);
        final y = center.dy + hexRadius * math.sin(angle);
        
        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}