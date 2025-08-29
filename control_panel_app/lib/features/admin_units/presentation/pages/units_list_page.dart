import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'dart:math' as math;

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../bloc/units_list/units_list_bloc.dart';
import '../widgets/futuristic_unit_card.dart';
import '../widgets/futuristic_units_table.dart';
import '../widgets/futuristic_unit_map_view.dart';
import '../widgets/unit_filters_widget.dart';

class UnitsListPage extends StatefulWidget {
  const UnitsListPage({super.key});

  @override
  State<UnitsListPage> createState() => _UnitsListPageState();
}

class _UnitsListPageState extends State<UnitsListPage>
    with TickerProviderStateMixin {
  // View modes
  enum ViewMode { table, cards, map }
  ViewMode _currentView = ViewMode.table;

  // Animation controllers
  late AnimationController _backgroundAnimationController;
  late AnimationController _particlesController;
  late AnimationController _glowController;
  
  // Animations
  late Animation<double> _backgroundRotation;
  late Animation<double> _glowAnimation;
  
  // Particles
  final List<_Particle> _particles = [];
  
  // Filters
  bool _showFilters = false;
  String _searchQuery = '';
  final Map<String, dynamic> _filters = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateParticles();
    _loadUnits();
  }

  void _initializeAnimations() {
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _particlesController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
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
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  void _generateParticles() {
    for (int i = 0; i < 20; i++) {
      _particles.add(_Particle());
    }
  }

  void _loadUnits() {
    context.read<UnitsListBloc>().add(LoadUnitsEvent());
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _particlesController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(),
          
          // Particles
          _buildParticles(),
          
          // Main content
          _buildMainContent(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: Listenable.merge([_backgroundRotation, _glowAnimation]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: AppTheme.darkGradient,
          ),
          child: CustomPaint(
            painter: _BackgroundPainter(
              rotation: _backgroundRotation.value,
              glowIntensity: _glowAnimation.value,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Widget _buildParticles() {
    return AnimatedBuilder(
      animation: _particlesController,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlesPainter(
            particles: _particles,
            animationValue: _particlesController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildMainContent() {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          if (_showFilters) _buildFiltersSection(),
          Expanded(child: _buildContentView()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.glassLight.withOpacity(0.1),
                  AppTheme.glassDark.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
              border: Border.all(
                color: AppTheme.primaryBlue.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              children: [
                _buildHeaderTitle(),
                const SizedBox(height: AppDimensions.spaceMedium),
                _buildSearchAndControls(),
                const SizedBox(height: AppDimensions.spaceMedium),
                _buildViewModeSelector(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderTitle() {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(
                      0.3 + 0.2 * _glowAnimation.value,
                    ),
                    blurRadius: 10 + 5 * _glowAnimation.value,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.apartment,
                color: Colors.white,
                size: 24,
              ),
            );
          },
        ),
        const SizedBox(width: AppDimensions.spaceMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => AppTheme.primaryGradient
                    .createShader(bounds),
                child: Text(
                  'إدارة الوحدات',
                  style: AppTextStyles.heading1.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                'إدارة جميع الوحدات في النظام',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
        BlocBuilder<UnitsListBloc, UnitsListState>(
          builder: (context, state) {
            if (state is UnitsListLoaded) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                  vertical: AppDimensions.paddingSmall,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryBlue.withOpacity(0.2),
                      AppTheme.primaryPurple.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusLarge,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.home_work,
                      color: AppTheme.primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: AppDimensions.spaceXSmall),
                    Text(
                      '${state.units.length}',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildSearchAndControls() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.darkCard.withOpacity(0.5),
                  AppTheme.darkCard.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(
                color: AppTheme.primaryBlue.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: TextField(
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textWhite,
              ),
              decoration: InputDecoration(
                hintText: 'البحث في الوحدات...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.textMuted.withOpacity(0.5),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppTheme.textMuted.withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                  vertical: AppDimensions.paddingSmall,
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
                context.read<UnitsListBloc>().add(
                      SearchUnitsEvent(query: value),
                    );
              },
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.spaceMedium),
        _buildFilterButton(),
      ],
    );
  }

  Widget _buildFilterButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _showFilters = !_showFilters);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: _showFilters
              ? AppTheme.primaryGradient
              : LinearGradient(
                  colors: [
                    AppTheme.darkCard.withOpacity(0.5),
                    AppTheme.darkCard.withOpacity(0.3),
                  ],
                ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: _showFilters
                ? AppTheme.primaryBlue.withOpacity(0.5)
                : AppTheme.primaryBlue.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: _showFilters
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Icon(
          Icons.tune,
          color: _showFilters ? Colors.white : AppTheme.textMuted,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildViewModeSelector() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withOpacity(0.3),
            AppTheme.darkCard.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildViewModeButton(
            ViewMode.table,
            Icons.table_chart,
            'جدول',
          ),
          _buildViewModeButton(
            ViewMode.cards,
            Icons.grid_view,
            'بطاقات',
          ),
          _buildViewModeButton(
            ViewMode.map,
            Icons.map,
            'خريطة',
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeButton(ViewMode mode, IconData icon, String label) {
    final isSelected = _currentView == mode;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _currentView = mode);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.paddingSmall,
          ),
          decoration: BoxDecoration(
            gradient: isSelected ? AppTheme.primaryGradient : null,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.3),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppTheme.textMuted,
              ),
              const SizedBox(width: AppDimensions.spaceXSmall),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected ? Colors.white : AppTheme.textMuted,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
      ),
      child: UnitFiltersWidget(
        onFiltersChanged: (filters) {
          setState(() => _filters.addAll(filters));
          context.read<UnitsListBloc>().add(
                FilterUnitsEvent(filters: filters),
              );
        },
      ),
    );
  }

  Widget _buildContentView() {
    return BlocBuilder<UnitsListBloc, UnitsListState>(
      builder: (context, state) {
        if (state is UnitsListLoading) {
          return _buildLoadingState();
        }
        
        if (state is UnitsListError) {
          return _buildErrorState(state.message);
        }
        
        if (state is UnitsListLoaded) {
          switch (_currentView) {
            case ViewMode.table:
              return FuturisticUnitsTable(
                units: state.units,
                onUnitSelected: _navigateToUnitDetails,
                onEditUnit: _navigateToEditUnit,
                onDeleteUnit: _deleteUnit,
              );
            case ViewMode.cards:
              return _buildCardsView(state.units);
            case ViewMode.map:
              return FuturisticUnitMapView(
                units: state.units,
                onUnitSelected: _navigateToUnitDetails,
              );
          }
        }
        
        return _buildEmptyState();
      },
    );
  }

  Widget _buildCardsView(List<dynamic> units) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppDimensions.spaceMedium,
        mainAxisSpacing: AppDimensions.spaceMedium,
        childAspectRatio: 0.8,
      ),
      itemCount: units.length,
      itemBuilder: (context, index) {
        return FuturisticUnitCard(
          unit: units[index],
          onTap: () => _navigateToUnitDetails(units[index]),
          onEdit: () => _navigateToEditUnit(units[index]),
          onDelete: () => _deleteUnit(units[index]),
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
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceLarge),
          Text(
            'جاري تحميل الوحدات...',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(AppDimensions.paddingLarge),
        padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.error.withOpacity(0.1),
              AppTheme.error.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
          border: Border.all(
            color: AppTheme.error.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.error,
            ),
            const SizedBox(height: AppDimensions.spaceLarge),
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

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(AppDimensions.paddingLarge),
        padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                Icons.apartment_outlined,
                size: 64,
                color: AppTheme.primaryBlue.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: AppDimensions.spaceLarge),
            Text(
              'لا توجد وحدات',
              style: AppTextStyles.heading2.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceSmall),
            Text(
              'قم بإضافة وحدة جديدة للبدء',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textMuted.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRetryButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _loadUnits();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLarge,
          vertical: AppDimensions.paddingMedium,
        ),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.refresh, color: Colors.white, size: 20),
            const SizedBox(width: AppDimensions.spaceSmall),
            Text(
              'إعادة المحاولة',
              style: AppTextStyles.buttonMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(
                  0.3 + 0.3 * _glowAnimation.value,
                ),
                blurRadius: 20 + 10 * _glowAnimation.value,
                spreadRadius: 2,
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: _navigateToCreateUnit,
            backgroundColor: Colors.transparent,
            elevation: 0,
            label: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
                vertical: AppDimensions.paddingSmall,
              ),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add, color: Colors.white),
                  const SizedBox(width: AppDimensions.spaceSmall),
                  Text(
                    'إضافة وحدة',
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToCreateUnit() {
    HapticFeedback.mediumImpact();
    context.push('/admin/units/create');
  }

  void _navigateToUnitDetails(dynamic unit) {
    HapticFeedback.lightImpact();
    context.push('/admin/units/${unit.id}');
  }

  void _navigateToEditUnit(dynamic unit) {
    HapticFeedback.lightImpact();
    context.push('/admin/units/${unit.id}/edit');
  }

  void _deleteUnit(dynamic unit) {
    HapticFeedback.heavyImpact();
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => _buildDeleteConfirmationDialog(unit),
    );
  }

  Widget _buildDeleteConfirmationDialog(dynamic unit) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.darkGradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
          border: Border.all(
            color: AppTheme.error.withOpacity(0.3),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
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
              'هل أنت متأكد من حذف الوحدة "${unit.name}"؟',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spaceLarge),
            Row(
              children: [
                Expanded(
                  child: _buildDialogButton(
                    label: 'إلغاء',
                    onTap: () => Navigator.of(context).pop(),
                    isPrimary: false,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceMedium),
                Expanded(
                  child: _buildDialogButton(
                    label: 'حذف',
                    onTap: () {
                      Navigator.of(context).pop();
                      context.read<UnitsListBloc>().add(
                            DeleteUnitEvent(unitId: unit.id),
                          );
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
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
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
                        AppTheme.error,
                        AppTheme.error.withOpacity(0.8),
                      ],
                    )
                  : AppTheme.primaryGradient)
              : null,
          border: isPrimary
              ? null
              : Border.all(
                  color: AppTheme.textMuted.withOpacity(0.3),
                  width: 1,
                ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        child: Text(
          label,
          style: AppTextStyles.buttonMedium.copyWith(
            color: isPrimary ? Colors.white : AppTheme.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// Background painter
class _BackgroundPainter extends CustomPainter {
  final double rotation;
  final double glowIntensity;

  _BackgroundPainter({
    required this.rotation,
    required this.glowIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = AppTheme.primaryBlue.withOpacity(0.05 * glowIntensity);

    // Draw grid
    const spacing = 30.0;
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

    // Draw rotating circles
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(rotation);
    
    for (int i = 1; i <= 3; i++) {
      final radius = 100.0 * i;
      paint.color = AppTheme.primaryPurple.withOpacity(0.02 * glowIntensity);
      canvas.drawCircle(Offset.zero, radius, paint);
    }
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Particle model
class _Particle {
  double x = math.Random().nextDouble();
  double y = math.Random().nextDouble();
  double vx = (math.Random().nextDouble() - 0.5) * 0.001;
  double vy = (math.Random().nextDouble() - 0.5) * 0.001;
  double radius = math.Random().nextDouble() * 2 + 0.5;
  double opacity = math.Random().nextDouble() * 0.3 + 0.1;
  Color color = [
    AppTheme.primaryBlue,
    AppTheme.primaryPurple,
    AppTheme.primaryCyan,
  ][math.Random().nextInt(3)];

  void update() {
    x += vx;
    y += vy;
    
    if (x < 0 || x > 1) vx = -vx;
    if (y < 0 || y > 1) vy = -vy;
  }
}

// Particles painter
class _ParticlesPainter extends CustomPainter {
  final List<_Particle> particles;
  final double animationValue;

  _ParticlesPainter({
    required this.particles,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.update();
      
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      
      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}