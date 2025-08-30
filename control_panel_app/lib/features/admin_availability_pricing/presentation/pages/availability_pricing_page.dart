// lib/features/admin_availability_pricing/presentation/pages/availability_pricing_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../bloc/availability/availability_bloc.dart';
import '../bloc/pricing/pricing_bloc.dart';
import '../widgets/futuristic_calendar_view.dart';
import '../widgets/unit_selector_card.dart';
import '../widgets/stats_dashboard_card.dart';
import '../widgets/quick_actions_panel.dart';
import '../widgets/availability_status_legend.dart';
import '../widgets/pricing_tier_legend.dart';

class AvailabilityPricingPage extends StatefulWidget {
  const AvailabilityPricingPage({super.key});

  @override
  State<AvailabilityPricingPage> createState() => _AvailabilityPricingPageState();
}

class _AvailabilityPricingPageState extends State<AvailabilityPricingPage>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _backgroundAnimationController;
  late AnimationController _glowController;
  late AnimationController _particleController;
  late AnimationController _contentAnimationController;
  
  // Animations
  late Animation<double> _backgroundRotation;
  late Animation<double> _glowAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;
  
  // State
  ViewMode _viewMode = ViewMode.availability;
  String? _selectedUnitId;
  DateTime _currentDate = DateTime.now();
  
  // Particles for background
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateParticles();
    _startAnimations();
    
    // Load initial data
    _loadInitialData();
  }

  void _initializeAnimations() {
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
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
      begin: 0.5,
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
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutQuart),
    ));
  }

  void _generateParticles() {
    for (int i = 0; i < 20; i++) {
      _particles.add(_Particle());
    }
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _contentAnimationController.forward();
      }
    });
  }

  void _loadInitialData() {
    // Load units and initial availability data
    // This would typically come from a units bloc
    // For now, we'll use mock data
    _selectedUnitId = 'unit_1';
    
    if (_selectedUnitId != null) {
      context.read<AvailabilityBloc>().add(
        LoadMonthlyAvailability(
          unitId: _selectedUnitId!,
          year: _currentDate.year,
          month: _currentDate.month,
        ),
      );
      
      context.read<PricingBloc>().add(
        LoadMonthlyPricing(
          unitId: _selectedUnitId!,
          year: _currentDate.year,
          month: _currentDate.month,
        ),
      );
    }
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > AppDimensions.desktopBreakpoint;
    final isTablet = size.width > AppDimensions.tabletBreakpoint;
    
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(),
          
          // Particles
          _buildParticles(),
          
          // Main content
          _buildMainContent(isDesktop, isTablet),
        ],
      ),
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
                AppTheme.darkBackground2.withOpacity(0.8),
                AppTheme.darkBackground3.withOpacity(0.6),
              ],
            ),
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
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            animationValue: _particleController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildMainContent(bool isDesktop, bool isTablet) {
    return SafeArea(
      child: FadeTransition(
        opacity: _contentFadeAnimation,
        child: SlideTransition(
          position: _contentSlideAnimation,
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 24 : 16),
            child: Column(
              children: [
                // Header
                _buildHeader(),
                
                const SizedBox(height: 20),
                
                // Main content area
                Expanded(
                  child: isDesktop
                      ? _buildDesktopLayout()
                      : _buildMobileLayout(isTablet),
                ),
              ],
            ),
          ),
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
            AppTheme.darkCard.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: [
              // Title with gradient
              ShaderMask(
                shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'إدارة الإتاحة والتسعير',
                      style: AppTextStyles.heading2.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // View mode toggle
              _buildViewModeToggle(),
              
              const SizedBox(width: 20),
              
              // Quick stats
              _buildQuickStats(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewModeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkSurface.withOpacity(0.6),
            AppTheme.darkSurface.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          _buildModeButton(
            icon: Icons.event_available_rounded,
            label: 'الإتاحة',
            isSelected: _viewMode == ViewMode.availability,
            onTap: () => setState(() => _viewMode = ViewMode.availability),
          ),
          const SizedBox(width: 4),
          _buildModeButton(
            icon: Icons.attach_money_rounded,
            label: 'التسعير',
            isSelected: _viewMode == ViewMode.pricing,
            onTap: () => setState(() => _viewMode = ViewMode.pricing),
          ),
          const SizedBox(width: 4),
          _buildModeButton(
            icon: Icons.dashboard_rounded,
            label: 'كلاهما',
            isSelected: _viewMode == ViewMode.both,
            onTap: () => setState(() => _viewMode = ViewMode.both),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required IconData icon,
    required String label,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: !isSelected ? Colors.transparent : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppTheme.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? Colors.white : AppTheme.textMuted,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return BlocBuilder<AvailabilityBloc, AvailabilityState>(
      builder: (context, state) {
        if (state is AvailabilityLoaded) {
          final stats = state.unitAvailability.stats;
          return Row(
            children: [
              _buildStatChip(
                icon: Icons.check_circle,
                value: '${stats.availableDays}',
                label: 'متاح',
                color: AppTheme.success,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                icon: Icons.event_busy,
                value: '${stats.bookedDays}',
                label: 'محجوز',
                color: AppTheme.warning,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                icon: Icons.block,
                value: '${stats.blockedDays}',
                label: 'محظور',
                color: AppTheme.error,
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left sidebar
        SizedBox(
          width: 320,
          child: Column(
            children: [
              // Unit selector
              UnitSelectorCard(
                selectedUnitId: _selectedUnitId,
                onUnitSelected: _onUnitSelected,
              ),
              
              const SizedBox(height: 16),
              
              // Stats dashboard
              Expanded(
                child: StatsDashboardCard(
                  viewMode: _viewMode,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Quick actions
              QuickActionsPanel(
                viewMode: _viewMode,
                onActionTap: _handleQuickAction,
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 20),
        
        // Main calendar area
        Expanded(
          child: Column(
            children: [
              // Calendar view
              Expanded(
                child: FuturisticCalendarView(
                  viewMode: _viewMode,
                  currentDate: _currentDate,
                  onDateChanged: _onDateChanged,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Legend
              _buildLegend(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(bool isTablet) {
    return Column(
      children: [
        // Unit selector (compact)
        UnitSelectorCard(
          selectedUnitId: _selectedUnitId,
          onUnitSelected: _onUnitSelected,
          isCompact: true,
        ),
        
        const SizedBox(height: 12),
        
        // Calendar view
        Expanded(
          child: FuturisticCalendarView(
            viewMode: _viewMode,
            currentDate: _currentDate,
            onDateChanged: _onDateChanged,
            isCompact: !isTablet,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Legend
        _buildLegend(),
        
        const SizedBox(height: 12),
        
        // Quick actions (horizontal scroll)
        SizedBox(
          height: 60,
          child: QuickActionsPanel(
            viewMode: _viewMode,
            onActionTap: _handleQuickAction,
            isHorizontal: true,
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    if (_viewMode == ViewMode.availability) {
      return const AvailabilityStatusLegend();
    } else if (_viewMode == ViewMode.pricing) {
      return const PricingTierLegend();
    } else {
      return Row(
        children: const [
          Expanded(child: AvailabilityStatusLegend()),
          SizedBox(width: 16),
          Expanded(child: PricingTierLegend()),
        ],
      );
    }
  }

  void _onUnitSelected(String unitId) {
    setState(() {
      _selectedUnitId = unitId;
    });
    
    context.read<AvailabilityBloc>().add(
      LoadMonthlyAvailability(
        unitId: unitId,
        year: _currentDate.year,
        month: _currentDate.month,
      ),
    );
    
    context.read<PricingBloc>().add(
      LoadMonthlyPricing(
        unitId: unitId,
        year: _currentDate.year,
        month: _currentDate.month,
      ),
    );
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      _currentDate = date;
    });
    
    if (_selectedUnitId != null) {
      context.read<AvailabilityBloc>().add(
        ChangeMonth(year: date.year, month: date.month),
      );
      
      context.read<PricingBloc>().add(
        ChangePricingMonth(year: date.year, month: date.month),
      );
    }
  }

  void _handleQuickAction(QuickAction action) {
    HapticFeedback.mediumImpact();
    
    switch (action) {
      case QuickAction.bulkUpdate:
        _showBulkUpdateDialog();
        break;
      case QuickAction.seasonalPricing:
        _showSeasonalPricingDialog();
        break;
      case QuickAction.cloneSettings:
        _showCloneSettingsDialog();
        break;
      case QuickAction.exportData:
        _exportData();
        break;
      case QuickAction.importData:
        _importData();
        break;
    }
  }

  void _showBulkUpdateDialog() {
    // Show bulk update dialog
  }

  void _showSeasonalPricingDialog() {
    // Show seasonal pricing dialog
  }

  void _showCloneSettingsDialog() {
    // Show clone settings dialog
  }

  void _exportData() {
    // Export data functionality
  }

  void _importData() {
    // Import data functionality
  }
}

// Enums
enum ViewMode {
  availability,
  pricing,
  both,
}

enum QuickAction {
  bulkUpdate,
  seasonalPricing,
  cloneSettings,
  exportData,
  importData,
}

// Background Painter
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
      ..color = AppTheme.primaryBlue.withOpacity(0.05);

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

    // Draw rotating glow
    final center = Offset(size.width / 2, size.height / 2);
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppTheme.primaryBlue.withOpacity(0.1 * glowIntensity),
          AppTheme.primaryPurple.withOpacity(0.05 * glowIntensity),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size.width / 2));

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawCircle(center, size.width / 3, glowPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Particle class
class _Particle {
  late double x, y, vx, vy;
  late double radius;
  late Color color;

  _Particle() {
    reset();
  }

  void reset() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    vx = (math.Random().nextDouble() - 0.5) * 0.001;
    vy = (math.Random().nextDouble() - 0.5) * 0.001;
    radius = math.Random().nextDouble() * 2 + 1;
    
    final colors = [
      AppTheme.primaryBlue,
      AppTheme.primaryPurple,
      AppTheme.primaryCyan,
    ];
    color = colors[math.Random().nextInt(colors.length)];
  }

  void update() {
    x += vx;
    y += vy;
    
    if (x < 0 || x > 1) vx = -vx;
    if (y < 0 || y > 1) vy = -vy;
  }
}

// Particle painter
class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double animationValue;

  _ParticlePainter({
    required this.particles,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.update();
      
      final paint = Paint()
        ..color = particle.color.withOpacity(0.3)
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