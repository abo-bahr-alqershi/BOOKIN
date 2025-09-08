// lib/features/admin_cities/presentation/pages/admin_cities_page.dart

import 'package:bookn_cp_app/features/admin_cities/domain/entities/city.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/cities_bloc.dart';
import '../bloc/cities_event.dart';
import '../bloc/cities_state.dart';
import '../widgets/city_stats_card.dart';
import '../widgets/city_search_bar.dart';
import '../widgets/futuristic_cities_grid.dart';

class AdminCitiesPage extends StatefulWidget {
  const AdminCitiesPage({super.key});

  @override
  State<AdminCitiesPage> createState() => _AdminCitiesPageState();
}

class _AdminCitiesPageState extends State<AdminCitiesPage>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _mainAnimationController;
  late AnimationController _floatingAnimationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _shimmerAnimationController;
  
  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  // UI State
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingHeader = false;
  bool _isGridView = true;
  String _selectedCountry = 'الكل';
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollListener();
    _loadInitialData();
  }

  void _initializeAnimations() {
    // Main entrance animation
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Floating animation for background elements
    _floatingAnimationController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);
    
    // Pulse animation for interactive elements
    _pulseAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    // Shimmer animation
        _shimmerAnimationController = AnimationController(
          duration: const Duration(milliseconds: 1500),
          vsync: this,
        )..repeat();
    
    // Setup animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOutBack),
    ));
    
    _rotationAnimation = Tween<double>(
      begin: -0.05,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.4, 0.9, curve: Curves.elasticOut),
    ));
    
    // Start animations
    _mainAnimationController.forward();
  }
  
  void _setupScrollListener() {
    _scrollController.addListener(() {
      final shouldShow = _scrollController.offset > 200;
      if (shouldShow != _showFloatingHeader) {
        setState(() {
          _showFloatingHeader = shouldShow;
        });
      }
    });
  }

  void _loadInitialData() {
    context.read<CitiesBloc>()
      ..add(const LoadCitiesEvent())
      ..add(LoadCitiesStatisticsEvent());
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _floatingAnimationController.dispose();
    _pulseAnimationController.dispose();
    _shimmerAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 1200;
    
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // Premium Animated Background
          _buildPremiumBackground(),
          
          // Floating Orbs
          ..._buildFloatingOrbs(),
          
          // Main Content
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Premium App Bar
              _buildPremiumAppBar(context, isDesktop),
              
              // Hero Section with Stats
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildHeroSection(isDesktop, isTablet),
                  ),
                ),
              ),
              
              // Search and Filters Section
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildSearchSection(isDesktop, isTablet),
                  ),
                ),
              ),
              
              // Cities Content
              BlocBuilder<CitiesBloc, CitiesState>(
                builder: (context, state) {
                  if (state is CitiesLoading) {
                    return SliverFillRemaining(
                      child: _buildLoadingState(),
                    );
                  }
                  
                  if (state is CitiesError) {
                    return SliverFillRemaining(
                      child: _buildErrorState(state.message),
                    );
                  }
                  
                  if (state is CitiesLoaded) {
                    if (state.filteredCities.isEmpty) {
                      return SliverFillRemaining(
                        child: _buildEmptyState(),
                      );
                    }
                    
                    return SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 32 : 20,
                        vertical: 20,
                      ),
                      sliver: FuturisticCitiesGrid(
                        cities: state.filteredCities,
                        isGridView: _isGridView,
                        isDesktop: isDesktop,
                        isTablet: isTablet,
                        onEdit: (city) => _showCityModal(city: city),
                        onDelete: (city) => _confirmDelete(city),
                        onImageTap: (city) => _showImageGallery(city),
                      ),
                    );
                  }
                  
                  return const SliverToBoxAdapter(child: SizedBox());
                },
              ),
              
              // Pagination
              BlocBuilder<CitiesBloc, CitiesState>(
                builder: (context, state) {
                  if (state is CitiesLoaded && state.totalPages > 1) {
                    return SliverToBoxAdapter(
                      child: _buildPagination(state),
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox());
                },
              ),
              
              // Bottom Padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
          
          // Floating Header
          if (_showFloatingHeader) _buildFloatingHeader(context),
          
          // Floating Action Button
          _buildFloatingActionButton(),
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
                AppTheme.darkBackground3.withOpacity(0.3),
              ],
            ),
          ),
        ),
        
        // Animated Mesh Pattern
        AnimatedBuilder(
          animation: _floatingAnimationController,
          builder: (context, child) {
            return CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _MeshPatternPainter(
                color: AppTheme.primaryBlue.withOpacity(0.03),
                animation: _floatingAnimationController.value,
              ),
            );
          },
        ),
        
        // Noise Texture
        Container(
          decoration: BoxDecoration(
            backgroundBlendMode: BlendMode.overlay,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.glowBlue.withOpacity(0.01),
                Colors.transparent,
                AppTheme.primaryPurple.withOpacity(0.01),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFloatingOrbs() {
    return [
      // Top Right Orb
      AnimatedBuilder(
        animation: _floatingAnimationController,
        builder: (context, child) {
          return Positioned(
            top: -100 + (50 * _floatingAnimationController.value),
            right: -100 + (30 * math.sin(_floatingAnimationController.value * math.pi)),
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryBlue.withOpacity(0.15),
                    AppTheme.primaryBlue.withOpacity(0.05),
                    AppTheme.primaryBlue.withOpacity(0.01),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          );
        },
      ),
      
      // Bottom Left Orb
      AnimatedBuilder(
        animation: _floatingAnimationController,
        builder: (context, child) {
          return Positioned(
            bottom: -150 + (40 * _floatingAnimationController.value),
            left: -150 + (40 * math.cos(_floatingAnimationController.value * math.pi)),
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryPurple.withOpacity(0.12),
                    AppTheme.primaryPurple.withOpacity(0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          );
        },
      ),
      
      // Center Floating Orb
      AnimatedBuilder(
        animation: _pulseAnimationController,
        builder: (context, child) {
          return Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            right: MediaQuery.of(context).size.width * 0.6,
            child: Transform.scale(
              scale: 0.8 + (0.2 * _pulseAnimationController.value),
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.neonGreen.withOpacity(0.08),
                      AppTheme.neonGreen.withOpacity(0.02),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ];
  }

  Widget _buildPremiumAppBar(BuildContext context, bool isDesktop) {
    return SliverAppBar(
      expandedHeight: isDesktop ? 180 : 160,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
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
              titlePadding: EdgeInsets.only(
                left: isDesktop ? 32 : 20,
                bottom: 16,
                right: isDesktop ? 32 : 20,
              ),
              title: Row(
                children: [
                  // Animated Icon
                  AnimatedBuilder(
                    animation: _pulseAnimationController,
                    builder: (context, child) {
                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryBlue.withOpacity(0.2),
                              AppTheme.primaryPurple.withOpacity(0.2),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.glowBlue.withOpacity(
                                0.3 + (0.2 * _pulseAnimationController.value),
                              ),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.location_city_rounded,
                          color: AppTheme.glowWhite,
                          size: isDesktop ? 32 : 28,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  
                  // Title and Subtitle
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إدارة المدن',
                          style: AppTextStyles.heading2.copyWith(
                            color: AppTheme.textWhite,
                            fontSize: isDesktop ? 24 : 20,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        BlocBuilder<CitiesBloc, CitiesState>(
                          builder: (context, state) {
                            if (state is CitiesLoaded) {
                              return Text(
                                '${state.cities.length} مدينة متاحة',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppTheme.textMuted.withOpacity(0.7),
                                  letterSpacing: 0.3,
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // View Toggle
                  _buildViewToggle(),
                  
                  const SizedBox(width: 16),
                  
                  // Refresh Button
                  _buildAppBarAction(
                    icon: Icons.refresh_rounded,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.read<CitiesBloc>().add(RefreshCitiesEvent());
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppTheme.darkCard.withOpacity(0.5),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          _buildToggleButton(
            icon: Icons.grid_view_rounded,
            isSelected: _isGridView,
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _isGridView = true);
            },
          ),
          const SizedBox(width: 4),
          _buildToggleButton(
            icon: Icons.view_list_rounded,
            isSelected: !_isGridView,
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _isGridView = false);
            },
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
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected 
              ? AppTheme.primaryBlue.withOpacity(0.2)
              : Colors.transparent,
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected 
              ? AppTheme.glowBlue
              : AppTheme.textMuted.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildAppBarAction({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return IconButton(
      onPressed: onTap,
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppTheme.inputBackground.withOpacity(0.3),
        ),
        child: Icon(
          icon,
          color: AppTheme.textLight,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isDesktop, bool isTablet) {
    return BlocBuilder<CitiesBloc, CitiesState>(
      builder: (context, state) {
        Map<String, dynamic>? stats;
        if (state is CitiesLoaded) {
          stats = state.statistics;
        }
        
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32 : 20,
            vertical: 24,
          ),
          child: CityStatsCard(
            totalCities: stats?['total'] ?? 0,
            activeCities: stats?['active'] ?? 0,
            totalProperties: stats?['properties'] ?? 0,
            countries: stats?['countries'] ?? 0,
            isDesktop: isDesktop,
            isTablet: isTablet,
          ),
        );
      },
    );
  }

  Widget _buildSearchSection(bool isDesktop, bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : 20,
      ),
      child: Row(
        children: [
          Expanded(
            flex: isDesktop ? 3 : 2,
            child: CitySearchBar(
              onSearch: (query) {
                context.read<CitiesBloc>().add(
                  SearchCitiesEvent(query: query),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          
          // Country Filter
          _buildCountryFilter(),
          
          const SizedBox(width: 16),
          
          // Add Button
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildCountryFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppTheme.inputBackground.withOpacity(0.3),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.flag_outlined,
            color: AppTheme.textMuted.withOpacity(0.7),
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            _selectedCountry,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textLight,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_drop_down,
            color: AppTheme.textMuted.withOpacity(0.5),
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showCityModal();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: AppTheme.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildPagination(CitiesLoaded state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous Button
          _buildPaginationButton(
            icon: Icons.chevron_left,
            enabled: state.currentPage > 1,
            onTap: () {
              if (state.currentPage > 1) {
                context.read<CitiesBloc>().add(
                  ChangeCitiesPageEvent(page: state.currentPage - 1),
                );
              }
            },
          ),
          
          const SizedBox(width: 16),
          
          // Page Numbers
          ...List.generate(
            math.min(5, state.totalPages),
            (index) {
              final pageNumber = _calculatePageNumber(
                index,
                state.currentPage,
                state.totalPages,
              );
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildPageNumber(
                  pageNumber,
                  isActive: pageNumber == state.currentPage,
                  onTap: () {
                    context.read<CitiesBloc>().add(
                      ChangeCitiesPageEvent(page: pageNumber),
                    );
                  },
                ),
              );
            },
          ),
          
          const SizedBox(width: 16),
          
          // Next Button
          _buildPaginationButton(
            icon: Icons.chevron_right,
            enabled: state.currentPage < state.totalPages,
            onTap: () {
              if (state.currentPage < state.totalPages) {
                context.read<CitiesBloc>().add(
                  ChangeCitiesPageEvent(page: state.currentPage + 1),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  int _calculatePageNumber(int index, int currentPage, int totalPages) {
    if (totalPages <= 5) {
      return index + 1;
    }
    
    if (currentPage <= 3) {
      return index + 1;
    }
    
    if (currentPage >= totalPages - 2) {
      return totalPages - 4 + index;
    }
    
    return currentPage - 2 + index;
  }

  Widget _buildPaginationButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? () {
        HapticFeedback.lightImpact();
        onTap();
      } : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: enabled
              ? AppTheme.darkCard.withOpacity(0.5)
              : AppTheme.darkCard.withOpacity(0.2),
          border: Border.all(
            color: enabled
                ? AppTheme.darkBorder.withOpacity(0.3)
                : AppTheme.darkBorder.withOpacity(0.1),
            width: 0.5,
          ),
        ),
        child: Icon(
          icon,
          color: enabled
              ? AppTheme.textLight
              : AppTheme.textMuted.withOpacity(0.3),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildPageNumber(
    int number,
    {required bool isActive, required VoidCallback onTap}
  ) {
    return GestureDetector(
      onTap: () {
        if (!isActive) {
          HapticFeedback.lightImpact();
          onTap();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: isActive ? AppTheme.primaryGradient : null,
          color: isActive ? null : AppTheme.darkCard.withOpacity(0.3),
          border: isActive ? null : Border.all(
            color: AppTheme.darkBorder.withOpacity(0.2),
            width: 0.5,
          ),
          boxShadow: isActive ? [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ] : null,
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: AppTextStyles.buttonMedium.copyWith(
              color: isActive ? Colors.white : AppTheme.textLight,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Premium Loading Animation
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: AppTheme.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.glowBlue.withOpacity(0.5),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 32),
          AnimatedBuilder(
            animation: _shimmerAnimationController,
            builder: (context, child) {
              return ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    begin: Alignment(-1.0 + 2 * _shimmerAnimationController.value, 0),
                    end: Alignment(1.0 + 2 * _shimmerAnimationController.value, 0),
                    colors: [
                      AppTheme.textMuted,
                      AppTheme.glowWhite,
                      AppTheme.textMuted,
                    ],
                  ).createShader(bounds);
                },
                child: Text(
                  'جاري تحميل المدن...',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              );
            },
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
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.error.withOpacity(0.1),
              border: Border.all(
                color: AppTheme.error.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.error_outline,
              size: 56,
              color: AppTheme.error,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'حدث خطأ',
            style: AppTextStyles.heading2.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.read<CitiesBloc>().add(const LoadCitiesEvent());
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: AppTheme.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
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
          // Empty State Illustration
          AnimatedBuilder(
            animation: _floatingAnimationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 10 * _floatingAnimationController.value),
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryBlue.withOpacity(0.1),
                        AppTheme.primaryPurple.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.location_city_outlined,
                    size: 80,
                    color: AppTheme.textMuted.withOpacity(0.5),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          Text(
            'لا توجد مدن',
            style: AppTextStyles.heading1.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ بإضافة أول مدينة',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppTheme.textMuted,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _showCityModal();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: AppTheme.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'إضافة مدينة',
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: Colors.white,
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

  Widget _buildFloatingHeader(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      top: _showFloatingHeader ? 0 : -100,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              bottom: 12,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              color: AppTheme.darkCard.withOpacity(0.8),
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.glowBlue.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.location_city_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'المدن',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                BlocBuilder<CitiesBloc, CitiesState>(
                  builder: (context, state) {
                    if (state is CitiesLoaded) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          border: Border.all(
                            color: AppTheme.primaryBlue.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          '${state.cities.length}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Positioned(
      bottom: 32,
      right: 32,
      child: AnimatedBuilder(
        animation: _pulseAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (0.05 * _pulseAnimationController.value),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.glowBlue.withOpacity(0.5),
                    blurRadius: 20 + (10 * _pulseAnimationController.value),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showCityModal();
                  },
                  borderRadius: BorderRadius.circular(28),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showCityModal({City? city}) async {
    HapticFeedback.lightImpact();

    final City? result = await Navigator.of(context).pushNamed<City>(
      '/city-form',
      arguments: city,
    );

    if (result == null) return;

    if (city == null) {
      context.read<CitiesBloc>().add(CreateCityEvent(city: result));
    } else {
      context.read<CitiesBloc>().add(
            UpdateCityEvent(
              oldName: city.name,
              city: result,
            ),
          );
    }
  }

  void _confirmDelete(City city) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.error.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.error.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.error.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: AppTheme.error,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'حذف المدينة؟',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'سيتم حذف "${city.name}" نهائياً',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.darkBorder.withOpacity(0.3),
                              width: 0.5,
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
                        onTap: () {
                          Navigator.pop(context);
                          context.read<CitiesBloc>().add(
                            DeleteCityEvent(name: city.name),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.error,
                                AppTheme.error.withOpacity(0.8),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'حذف',
                              style: AppTextStyles.buttonMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
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
      ),
    );
  }

  void _showImageGallery(City city) {
    // Implement image gallery view
  }
}

// Custom Painter for mesh pattern
class _MeshPatternPainter extends CustomPainter {
  final Color color;
  final double animation;

  _MeshPatternPainter({
    required this.color,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const spacing = 80.0;
    final offset = animation * spacing;

    // Draw diagonal lines
    for (double i = -size.width; i < size.height + size.width; i += spacing) {
      canvas.drawLine(
        Offset(0, i + offset),
        Offset(size.width, i + offset - size.width),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}