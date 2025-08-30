import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/city.dart';
import '../bloc/cities_bloc.dart';
import '../bloc/cities_event.dart';
import '../bloc/cities_state.dart';
import '../widgets/futuristic_city_card.dart';
import '../widgets/futuristic_cities_grid.dart';
import '../widgets/city_form_modal.dart';
import '../widgets/city_stats_card.dart';
import '../widgets/city_search_bar.dart';

class AdminCitiesPage extends StatefulWidget {
  const AdminCitiesPage({super.key});

  @override
  State<AdminCitiesPage> createState() => _AdminCitiesPageState();
}

class _AdminCitiesPageState extends State<AdminCitiesPage>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _backgroundAnimationController;
  late AnimationController _glowAnimationController;
  late AnimationController _particleAnimationController;
  late AnimationController _entranceAnimationController;
  
  // Animations
  late Animation<double> _backgroundAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _entranceAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Page State
  final ScrollController _scrollController = ScrollController();
  City? _selectedCity;
  bool _isGridView = false;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
  }
  
  void _initializeAnimations() {
    // Background Animation
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _backgroundAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_backgroundAnimationController);
    
    // Glow Animation
    _glowAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Particle Animation
    _particleAnimationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    // Entrance Animation
    _entranceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _entranceAnimation = CurvedAnimation(
      parent: _entranceAnimationController,
      curve: Curves.easeOutExpo,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceAnimationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutQuart),
    ));
    
    // Start entrance animation
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _entranceAnimationController.forward();
      }
    });
  }
  
  void _loadData() {
    context.read<CitiesBloc>().add(const LoadCitiesEvent());
    context.read<CitiesBloc>().add(LoadCitiesStatisticsEvent());
  }
  
  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _glowAnimationController.dispose();
    _particleAnimationController.dispose();
    _entranceAnimationController.dispose();
    _scrollController.dispose();
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
          
          // Floating Particles
          _buildFloatingParticles(),
          
          // Main Content
          _buildMainContent(),
          
          // Floating Action Button
          _buildFloatingActionButton(),
        ],
      ),
    );
  }
  
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _backgroundAnimation,
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
                AppTheme.darkBackground2.withOpacity(0.8),
                AppTheme.darkBackground3.withOpacity(0.6),
              ],
            ),
          ),
          child: CustomPaint(
            painter: _FuturisticBackgroundPainter(
              animation: _backgroundAnimation.value,
              glowIntensity: _glowAnimation.value,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }
  
  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _particleAnimationController,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlesPainter(
            animation: _particleAnimationController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
  
  Widget _buildMainContent() {
    return SafeArea(
      child: FadeTransition(
        opacity: _entranceAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Content
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Section
          Row(
            children: [
              // Back Button
              _buildGlassButton(
                icon: Icons.arrow_back_ios_rounded,
                onTap: () => Navigator.of(context).pop(),
              ),
              
              const SizedBox(width: AppDimensions.spaceMedium),
              
              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                      child: Text(
                        'إدارة المدن',
                        style: AppTextStyles.displaySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'إضافة وتعديل المدن المتاحة في النظام',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              
              // View Toggle
              _buildViewToggle(),
            ],
          ),
          
          const SizedBox(height: AppDimensions.spaceLarge),
          
          // Search Bar
          CitySearchBar(
            onSearch: (query) {
              context.read<CitiesBloc>().add(SearchCitiesEvent(query: query));
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkCard.withOpacity(0.5),
              AppTheme.darkCard.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Icon(
              icon,
              color: AppTheme.primaryBlue,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildViewToggle() {
    return Container(
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
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: [
              _buildToggleButton(
                icon: Icons.view_list_rounded,
                isSelected: !_isGridView,
                onTap: () => setState(() => _isGridView = false),
              ),
              _buildToggleButton(
                icon: Icons.grid_view_rounded,
                isSelected: _isGridView,
                onTap: () => setState(() => _isGridView = true),
              ),
            ],
          ),
        ),
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
          size: 20,
          color: isSelected ? Colors.white : AppTheme.textMuted,
        ),
      ),
    );
  }
  
  Widget _buildContent() {
    return BlocConsumer<CitiesBloc, CitiesState>(
      listener: (context, state) {
        if (state is CityOperationSuccess) {
          _showSuccessSnackBar(state.message);
        } else if (state is CityOperationFailure) {
          _showErrorSnackBar(state.message);
        }
      },
      builder: (context, state) {
        if (state is CitiesLoading) {
          return _buildLoadingState();
        }
        
        if (state is CitiesError) {
          return _buildErrorState(state.message);
        }
        
        if (state is CitiesLoaded) {
          return _buildLoadedState(state);
        }
        
        return _buildEmptyState();
      },
    );
  }
  
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceLarge),
          Text(
            'جاري تحميل المدن...',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppTheme.textWhite,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorState(String message) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        margin: const EdgeInsets.all(AppDimensions.paddingLarge),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.error.withOpacity(0.1),
              AppTheme.error.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.error.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppTheme.error,
            ),
            const SizedBox(height: AppDimensions.spaceMedium),
            Text(
              'حدث خطأ',
              style: AppTextStyles.heading2.copyWith(
                color: AppTheme.error,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceSmall),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spaceLarge),
            _buildRetryButton(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRetryButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _loadData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLarge,
          vertical: AppDimensions.paddingMedium,
        ),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
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
                  AppTheme.primaryBlue.withOpacity(0.1),
                  AppTheme.primaryPurple.withOpacity(0.05),
                ],
              ),
            ),
            child: Icon(
              Icons.location_city_rounded,
              size: 64,
              color: AppTheme.primaryBlue.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceLarge),
          Text(
            'لا توجد مدن',
            style: AppTextStyles.heading2.copyWith(
              color: AppTheme.textWhite,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceSmall),
          Text(
            'ابدأ بإضافة المدن المتاحة في النظام',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceXLarge),
          _buildAddCityButton(),
        ],
      ),
    );
  }
  
  Widget _buildLoadedState(CitiesLoaded state) {
    return Column(
      children: [
        // Statistics Cards
        Container(
          height: 120,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
          ),
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              CityStatsCard(
                title: 'إجمالي المدن',
                value: state.cities.length.toString(),
                icon: Icons.location_city_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                ),
              ),
              const SizedBox(width: AppDimensions.spaceMedium),
              CityStatsCard(
                title: 'المدن النشطة',
                value: state.cities.where((c) => c.isActive ?? true).length.toString(),
                icon: Icons.check_circle_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
                ),
              ),
              const SizedBox(width: AppDimensions.spaceMedium),
              CityStatsCard(
                title: 'الدول',
                value: state.cities.map((c) => c.country).toSet().length.toString(),
                icon: Icons.public_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFA709A), Color(0xFFFEE140)],
                ),
              ),
              const SizedBox(width: AppDimensions.spaceMedium),
              CityStatsCard(
                title: 'العقارات',
                value: state.cities.fold<int>(
                  0, 
                  (sum, city) => sum + (city.propertiesCount ?? 0),
                ).toString(),
                icon: Icons.home_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: AppDimensions.spaceLarge),
        
        // Cities List/Grid
        Expanded(
          child: state.filteredCities.isEmpty
              ? _buildNoResultsState()
              : _isGridView
                  ? FuturisticCitiesGrid(
                      cities: state.filteredCities,
                      onCityTap: (city) => _showCityDetails(city),
                      onEditTap: (city) => _showEditCityModal(city),
                      onDeleteTap: (city) => _confirmDeleteCity(city),
                    )
                  : _buildCitiesList(state),
        ),
        
        // Pagination
        if (state.totalPages > 1)
          _buildPagination(state),
      ],
    );
  }
  
  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: AppTheme.textMuted.withOpacity(0.5),
          ),
          const SizedBox(height: AppDimensions.spaceMedium),
          Text(
            'لا توجد نتائج',
            style: AppTextStyles.heading3.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceSmall),
          Text(
            'جرب البحث بكلمات مختلفة',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCitiesList(CitiesLoaded state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
      ),
      physics: const BouncingScrollPhysics(),
      itemCount: state.filteredCities.length,
      itemBuilder: (context, index) {
        final city = state.filteredCities[index];
        return FuturisticCityCard(
          city: city,
          isSelected: _selectedCity == city,
          onTap: () => _showCityDetails(city),
          onEditTap: () => _showEditCityModal(city),
          onDeleteTap: () => _confirmDeleteCity(city),
          animationDelay: Duration(milliseconds: index * 50),
        );
      },
    );
  }
  
  Widget _buildPagination(CitiesLoaded state) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous Button
          _buildPaginationButton(
            icon: Icons.chevron_left_rounded,
            enabled: state.currentPage > 1,
            onTap: () {
              context.read<CitiesBloc>().add(
                ChangeCitiesPageEvent(page: state.currentPage - 1),
              );
            },
          ),
          
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
          
          // Next Button
          _buildPaginationButton(
            icon: Icons.chevron_right_rounded,
            enabled: state.currentPage < state.totalPages,
            onTap: () {
              context.read<CitiesBloc>().add(
                ChangeCitiesPageEvent(page: state.currentPage + 1),
              );
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
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: enabled 
              ? LinearGradient(
                  colors: [
                    AppTheme.primaryBlue.withOpacity(0.2),
                    AppTheme.primaryPurple.withOpacity(0.1),
                  ],
                )
              : null,
          color: !enabled ? AppTheme.darkCard.withOpacity(0.3) : null,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: enabled 
                ? AppTheme.primaryBlue.withOpacity(0.3)
                : AppTheme.darkBorder.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppTheme.primaryBlue : AppTheme.textMuted.withOpacity(0.3),
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
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: isActive ? AppTheme.primaryGradient : null,
          color: !isActive ? AppTheme.darkCard.withOpacity(0.5) : null,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive 
                ? Colors.transparent
                : AppTheme.darkBorder.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: isActive ? Colors.white : AppTheme.textMuted,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildFloatingActionButton() {
    return Positioned(
      bottom: AppDimensions.paddingLarge,
      left: AppDimensions.paddingLarge,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          _showAddCityModal();
        },
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.3 + _glowAnimation.value * 0.2),
                    blurRadius: 20 + _glowAnimation.value * 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 32,
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildAddCityButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _showAddCityModal();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingXLarge,
          vertical: AppDimensions.paddingMedium,
        ),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.add_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: AppDimensions.spaceSmall),
            Text(
              'إضافة مدينة',
              style: AppTextStyles.buttonLarge.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showAddCityModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CityFormModal(
        onSave: (city) {
          context.read<CitiesBloc>().add(CreateCityEvent(city: city));
        },
      ),
    );
  }
  
  void _showEditCityModal(City city) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CityFormModal(
        city: city,
        onSave: (updatedCity) {
          context.read<CitiesBloc>().add(UpdateCityEvent(
            oldName: city.name,
            city: updatedCity,
          ));
        },
      ),
    );
  }
  
  void _confirmDeleteCity(City city) {
    showDialog(
      context: context,
      builder: (context) => _buildDeleteConfirmationDialog(city),
    );
  }
  
  Widget _buildDeleteConfirmationDialog(City city) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
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
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_rounded,
              size: 64,
              color: AppTheme.error,
            ),
            const SizedBox(height: AppDimensions.spaceMedium),
            Text(
              'تأكيد الحذف',
              style: AppTextStyles.heading2.copyWith(
                color: AppTheme.textWhite,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceSmall),
            Text(
              'هل أنت متأكد من حذف مدينة ${city.name}؟',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            if ((city.propertiesCount ?? 0) > 0) ...[
              const SizedBox(height: AppDimensions.spaceMedium),
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.error.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_rounded,
                      color: AppTheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: AppDimensions.spaceSmall),
                    Expanded(
                      child: Text(
                        'تحتوي هذه المدينة على ${city.propertiesCount} عقار',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppTheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppDimensions.spaceLarge),
            Row(
              children: [
                Expanded(
                  child: _buildDialogButton(
                    text: 'إلغاء',
                    onTap: () => Navigator.of(context).pop(),
                    isPrimary: false,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceMedium),
                Expanded(
                  child: _buildDialogButton(
                    text: 'حذف',
                    onTap: () {
                      Navigator.of(context).pop();
                      context.read<CitiesBloc>().add(DeleteCityEvent(name: city.name));
                    },
                    isPrimary: true,
                    isDanger: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDialogButton({
    required String text,
    required VoidCallback onTap,
    required bool isPrimary,
    bool isDanger = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.paddingMedium,
        ),
        decoration: BoxDecoration(
          gradient: isPrimary 
              ? (isDanger 
                  ? LinearGradient(
                      colors: [
                        AppTheme.error.withOpacity(0.8),
                        AppTheme.error.withOpacity(0.6),
                      ],
                    )
                  : AppTheme.primaryGradient)
              : null,
          color: !isPrimary ? AppTheme.darkCard.withOpacity(0.5) : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPrimary 
                ? Colors.transparent
                : AppTheme.darkBorder.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: AppTextStyles.buttonMedium.copyWith(
              color: isPrimary ? Colors.white : AppTheme.textMuted,
            ),
          ),
        ),
      ),
    );
  }
  
  void _showCityDetails(City city) {
    setState(() => _selectedCity = city);
    // يمكن إضافة المزيد من التفاصيل هنا
  }
  
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(AppDimensions.paddingMedium),
      ),
    );
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(AppDimensions.paddingMedium),
      ),
    );
  }
}

// Custom Painters
class _FuturisticBackgroundPainter extends CustomPainter {
  final double animation;
  final double glowIntensity;
  
  _FuturisticBackgroundPainter({
    required this.animation,
    required this.glowIntensity,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    
    // Draw animated grid
    paint.color = AppTheme.primaryBlue.withOpacity(0.05 * glowIntensity);
    
    const spacing = 50.0;
    
    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      final offset = math.sin(animation + x / 100) * 10;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + offset, size.height),
        paint,
      );
    }
    
    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      final offset = math.cos(animation + y / 100) * 10;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y + offset),
        paint,
      );
    }
    
    // Draw glow circles
    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 50);
    
    // Top right glow
    glowPaint.shader = RadialGradient(
      colors: [
        AppTheme.primaryBlue.withOpacity(0.1 * glowIntensity),
        AppTheme.primaryBlue.withOpacity(0),
      ],
    ).createShader(Rect.fromCircle(
      center: Offset(size.width * 0.8, size.height * 0.2),
      radius: 200,
    ));
    
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      200,
      glowPaint,
    );
    
    // Bottom left glow
    glowPaint.shader = RadialGradient(
      colors: [
        AppTheme.primaryPurple.withOpacity(0.1 * glowIntensity),
        AppTheme.primaryPurple.withOpacity(0),
      ],
    ).createShader(Rect.fromCircle(
      center: Offset(size.width * 0.2, size.height * 0.8),
      radius: 200,
    ));
    
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.8),
      200,
      glowPaint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ParticlesPainter extends CustomPainter {
  final double animation;
  
  _ParticlesPainter({required this.animation});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    // Draw floating particles
    for (int i = 0; i < 20; i++) {
      final x = (size.width * (i * 0.1 + animation)) % size.width;
      final y = size.height * (0.2 + 0.6 * math.sin(i + animation * 2));
      final radius = 1.0 + math.sin(i + animation * 3) * 0.5;
      final opacity = 0.3 + 0.2 * math.sin(i + animation * 2);
      
      paint.color = AppTheme.primaryBlue.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}