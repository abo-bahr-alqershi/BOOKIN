// lib/features/admin_audit_logs/presentation/pages/audit_logs_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/audit_log.dart';
import '../bloc/audit_logs_bloc.dart';
import '../bloc/audit_logs_event.dart';
import '../bloc/audit_logs_state.dart';
import '../widgets/futuristic_audit_logs_table.dart';
import '../widgets/audit_log_filters_widget.dart';
import '../widgets/audit_log_details_dialog.dart';
import '../widgets/audit_log_stats_card.dart';
import '../widgets/activity_chart_widget.dart';
import '../widgets/audit_log_timeline_widget.dart';

class AuditLogsPage extends StatefulWidget {
  const AuditLogsPage({super.key});

  @override
  State<AuditLogsPage> createState() => _AuditLogsPageState();
}

class _AuditLogsPageState extends State<AuditLogsPage>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _backgroundAnimationController;
  late AnimationController _glowController;
  late AnimationController _particleController;
  late AnimationController _contentAnimationController;
  
  // Animations
  late Animation<double> _backgroundAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _contentSlideAnimation;
  late Animation<double> _contentFadeAnimation;
  
  // Scroll Controller
  final ScrollController _scrollController = ScrollController();
  
  // View Mode
  bool _isTableView = true;
  bool _showFilters = true;
  
  // Particles
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateParticles();
    _loadInitialData();
    _setupScrollListener();
  }

  void _initializeAnimations() {
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
    
    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();
    
    _backgroundAnimation = Tween<double>(
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
    
    _contentSlideAnimation = Tween<double>(
      begin: 50,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutQuart),
    ));
    
    _contentFadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));
  }

  void _generateParticles() {
    for (int i = 0; i < 20; i++) {
      _particles.add(_Particle());
    }
  }

  void _loadInitialData() {
    context.read<AuditLogsBloc>().add(
          LoadAuditLogsEvent(
            query: AuditLogsQuery(
              pageNumber: 1,
              pageSize: 20,
            ),
          ),
        );
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.9) {
        context.read<AuditLogsBloc>().add(const LoadMoreAuditLogsEvent());
      }
    });
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    _contentAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > AppDimensions.tabletBreakpoint;
    
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // Animated Background
          _buildAnimatedBackground(),
          
          // Particles
          _buildParticles(),
          
          // Main Content
          _buildMainContent(isDesktop),
          
          // Export FAB
          _buildExportFAB(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
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
            painter: _GridPainter(
              animation: _backgroundAnimation.value,
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
            animation: _particleController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildMainContent(bool isDesktop) {
    return AnimatedBuilder(
      animation: _contentAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _contentSlideAnimation.value),
          child: Opacity(
            opacity: _contentFadeAnimation.value,
            child: Column(
              children: [
                // Futuristic App Bar
                _buildFuturisticAppBar(),
                
                // Content Area
                Expanded(
                  child: isDesktop
                      ? _buildDesktopLayout()
                      : _buildMobileLayout(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFuturisticAppBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withOpacity(0.9),
            AppTheme.darkCard.withOpacity(0.7),
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
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  // Title with glow effect
                  AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            colors: [
                              AppTheme.primaryCyan,
                              AppTheme.primaryBlue,
                              AppTheme.primaryPurple,
                            ],
                            stops: [
                              0.0,
                              0.5 + 0.2 * _glowAnimation.value,
                              1.0,
                            ],
                          ).createShader(bounds);
                        },
                        child: Text(
                          'سجلات النشاط',
                          style: AppTextStyles.heading2.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const Spacer(),
                  
                  // Actions wrapped to prevent overflow on small widths
                  Flexible(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Refresh Button
                          _buildRefreshButton(),
                          const SizedBox(width: 16),
                          
                          // Filter Toggle Button
                          _buildFilterToggleButton(),
                          const SizedBox(width: 16),
                          
                          // View Mode Toggle
                          _buildViewModeToggle(),
                        ],
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

  Widget _buildViewModeToggle() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withOpacity(0.6),
            AppTheme.darkCard.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildViewModeButton(
            icon: Icons.table_chart_rounded,
            isSelected: _isTableView,
            onTap: () => setState(() => _isTableView = true),
          ),
          _buildViewModeButton(
            icon: Icons.timeline_rounded,
            isSelected: !_isTableView,
            onTap: () => setState(() => _isTableView = false),
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeButton({
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? AppTheme.primaryGradient
              : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? Colors.white : AppTheme.textMuted,
        ),
      ),
    );
  }

  Widget _buildFilterToggleButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _showFilters = !_showFilters);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _showFilters
                ? [
                    AppTheme.primaryBlue.withOpacity(0.3),
                    AppTheme.primaryPurple.withOpacity(0.2),
                  ]
                : [
                    AppTheme.darkCard.withOpacity(0.6),
                    AppTheme.darkCard.withOpacity(0.4),
                  ],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _showFilters
                ? AppTheme.primaryBlue.withOpacity(0.5)
                : AppTheme.darkBorder.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          Icons.filter_list_rounded,
          size: 20,
          color: _showFilters ? AppTheme.primaryBlue : AppTheme.textMuted,
        ),
      ),
    );
  }

  Widget _buildRefreshButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.read<AuditLogsBloc>().add(const RefreshAuditLogsEvent());
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkCard.withOpacity(0.6),
              AppTheme.darkCard.withOpacity(0.4),
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppTheme.darkBorder.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          Icons.refresh_rounded,
          size: 20,
          color: AppTheme.textMuted,
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filters Sidebar
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _showFilters ? 320 : 0,
          child: _showFilters
              ? Padding(
                  padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
                  child: AuditLogFiltersWidget(
                    onFilterApplied: (filters) {
                      context.read<AuditLogsBloc>().add(
                            FilterAuditLogsEvent(
                              userId: filters['userId'],
                              from: filters['from'],
                              to: filters['to'],
                              operationType: filters['operationType'],
                              searchTerm: filters['searchTerm'],
                            ),
                          );
                    },
                  ),
                )
              : const SizedBox.shrink(),
        ),
        
        // Main Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Stats Cards
                _buildStatsCards(),
                
                const SizedBox(height: 16),
                
                // Activity Chart
                _buildActivityChart(),
                
                const SizedBox(height: 16),
                
                // Logs View
                Expanded(
                  child: _isTableView
                      ? _buildTableView()
                      : _buildTimelineView(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Filters (Collapsible)
          if (_showFilters)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: AuditLogFiltersWidget(
                onFilterApplied: (filters) {
                  context.read<AuditLogsBloc>().add(
                        FilterAuditLogsEvent(
                          userId: filters['userId'],
                          from: filters['from'],
                          to: filters['to'],
                          operationType: filters['operationType'],
                          searchTerm: filters['searchTerm'],
                        ),
                      );
                },
              ),
            ),
          
          // Stats Cards
          _buildStatsCards(),
          
          const SizedBox(height: 16),
          
          // Activity Chart
          _buildActivityChart(),
          
          const SizedBox(height: 16),
          
          // Logs View
          _isTableView
              ? _buildTableView()
              : _buildTimelineView(),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return BlocBuilder<AuditLogsBloc, AuditLogsState>(
      builder: (context, state) {
        if (state is AuditLogsLoaded) {
          return AuditLogStatsCard(
            totalLogs: state.totalCount,
            todayLogs: _getTodayLogsCount(state.auditLogs),
            criticalActions: _getCriticalActionsCount(state.auditLogs),
            activeUsers: _getActiveUsersCount(state.auditLogs),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildActivityChart() {
    return BlocBuilder<AuditLogsBloc, AuditLogsState>(
      builder: (context, state) {
        if (state is AuditLogsLoaded) {
          return ActivityChartWidget(
            auditLogs: state.auditLogs,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTableView() {
    return BlocBuilder<AuditLogsBloc, AuditLogsState>(
      builder: (context, state) {
        if (state is AuditLogsLoading) {
          return _buildLoadingState();
        }
        
        if (state is AuditLogsError) {
          return _buildErrorState(state.message);
        }
        
        if (state is AuditLogsLoaded) {
          return FuturisticAuditLogsTable(
            auditLogs: state.auditLogs,
            onLogTap: (log) => _showLogDetails(log),
            onLoadMore: () {
              context.read<AuditLogsBloc>().add(const LoadMoreAuditLogsEvent());
            },
            hasReachedMax: state.hasReachedMax,
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTimelineView() {
    return BlocBuilder<AuditLogsBloc, AuditLogsState>(
      builder: (context, state) {
        if (state is AuditLogsLoading) {
          return _buildLoadingState();
        }
        
        if (state is AuditLogsError) {
          return _buildErrorState(state.message);
        }
        
        if (state is AuditLogsLoaded) {
          return AuditLogTimelineWidget(
            auditLogs: state.auditLogs,
            onLogTap: (log) => _showLogDetails(log),
            onLoadMore: () {
              context.read<AuditLogsBloc>().add(const LoadMoreAuditLogsEvent());
            },
            hasReachedMax: state.hasReachedMax,
          );
        }
        
        return const SizedBox.shrink();
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
          const SizedBox(height: 16),
          Text(
            'جاري تحميل السجلات...',
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
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.error.withOpacity(0.1),
              AppTheme.error.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
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
              size: 48,
              color: AppTheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ',
              style: AppTextStyles.heading3.copyWith(
                color: AppTheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                context.read<AuditLogsBloc>().add(const RefreshAuditLogsEvent());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
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

  Widget _buildExportFAB() {
    return Positioned(
      bottom: 24,
      left: 24,
      child: BlocBuilder<AuditLogsBloc, AuditLogsState>(
        builder: (context, state) {
          if (state is! AuditLogsLoaded) return const SizedBox.shrink();
          
          return GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              context.read<AuditLogsBloc>().add(
                    ExportAuditLogsEvent(
                      query: state.currentQuery,
                    ),
                  );
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.download_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          );
        },
      ),
    );
  }

  void _showLogDetails(AuditLog log) {
    showDialog(
      context: context,
      builder: (context) => AuditLogDetailsDialog(auditLog: log),
    );
  }

  // Helper methods
  int _getTodayLogsCount(List<AuditLog> logs) {
    final today = DateTime.now();
    return logs.where((log) {
      return log.timestamp.day == today.day &&
          log.timestamp.month == today.month &&
          log.timestamp.year == today.year;
    }).length;
  }

  int _getCriticalActionsCount(List<AuditLog> logs) {
    return logs.where((log) => log.isDelete || log.isSlowOperation).length;
  }

  int _getActiveUsersCount(List<AuditLog> logs) {
    return logs.map((log) => log.userId).toSet().length;
  }
}

// Particle Model
class _Particle {
  late double x, y;
  late double vx, vy;
  late double radius;
  late double opacity;
  late Color color;

  _Particle() {
    reset();
  }

  void reset() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    vx = (math.Random().nextDouble() - 0.5) * 0.001;
    vy = (math.Random().nextDouble() - 0.5) * 0.001;
    radius = math.Random().nextDouble() * 2 + 0.5;
    opacity = math.Random().nextDouble() * 0.3 + 0.1;
    
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

// Custom Painters
class _GridPainter extends CustomPainter {
  final double animation;
  final double glowIntensity;

  _GridPainter({
    required this.animation,
    required this.glowIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryBlue.withOpacity(0.03 * glowIntensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const spacing = 30.0;
    final offset = animation * spacing;

    for (double x = -spacing + offset; x < size.width + spacing; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = -spacing + offset; y < size.height + spacing; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double animation;

  _ParticlePainter({
    required this.particles,
    required this.animation,
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