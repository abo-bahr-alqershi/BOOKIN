// lib/features/admin_reviews/presentation/pages/reviews_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:bookn_cp_app/core/theme/app_theme.dart';
import 'package:bookn_cp_app/core/theme/app_text_styles.dart';
import 'package:bookn_cp_app/core/theme/app_dimensions.dart';
import '../bloc/reviews_list/reviews_list_bloc.dart';
import '../widgets/futuristic_reviews_table.dart';
import '../widgets/review_filters_widget.dart';
import '../widgets/review_stats_card.dart';

class ReviewsListPage extends StatefulWidget {
  const ReviewsListPage({super.key});
  
  @override
  State<ReviewsListPage> createState() => _ReviewsListPageState();
}

class _ReviewsListPageState extends State<ReviewsListPage>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _backgroundAnimController;
  late AnimationController _glowAnimController;
  late AnimationController _particleAnimController;
  late AnimationController _contentAnimController;
  
  // Animations
  late Animation<double> _backgroundRotation;
  late Animation<double> _glowAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;
  
  // Filters
  String _searchQuery = '';
  double? _minRating;
  bool? _isPending;
  bool? _hasResponse;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadReviews();
  }
  
  void _initializeAnimations() {
    _backgroundAnimController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _glowAnimController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _particleAnimController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
    
    _contentAnimController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _backgroundRotation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_backgroundAnimController);
    
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowAnimController,
      curve: Curves.easeInOut,
    ));
    
    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentAnimController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentAnimController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutQuart),
    ));
    
    // Start animations
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _contentAnimController.forward();
      }
    });
  }
  
  void _loadReviews() {
    context.read<ReviewsListBloc>().add(const LoadReviewsEvent());
  }
  
  @override
  void dispose() {
    _backgroundAnimController.dispose();
    _glowAnimController.dispose();
    _particleAnimController.dispose();
    _contentAnimController.dispose();
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
          // Animated Background
          _buildAnimatedBackground(),
          
          // Particles
          _buildParticles(),
          
          // Main Content
          _buildMainContent(isDesktop, isTablet),
        ],
      ),
    );
  }
  
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: Listenable.merge([_backgroundRotation, _glowAnimation]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.darkBackground,
                AppTheme.darkBackground2.withOpacity(0.9),
                AppTheme.darkBackground3.withOpacity(0.8),
              ],
            ),
          ),
          child: CustomPaint(
            painter: _GridPatternPainter(
              rotation: _backgroundRotation.value * 0.1,
              opacity: 0.03,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }
  
  Widget _buildParticles() {
    return AnimatedBuilder(
      animation: _particleAnimController,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlesPainter(
            animation: _particleAnimController.value,
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
            padding: EdgeInsets.all(isDesktop ? 32 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                
                const SizedBox(height: 24),
                
                // Stats Cards
                _buildStatsSection(isDesktop, isTablet),
                
                const SizedBox(height: 24),
                
                // Filters
                _buildFiltersSection(),
                
                const SizedBox(height: 24),
                
                // Reviews Table
                Expanded(
                  child: _buildReviewsSection(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Row(
      children: [
        // Title with gradient
        ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                AppTheme.primaryCyan,
                AppTheme.primaryBlue,
                AppTheme.primaryPurple,
              ],
            ).createShader(bounds);
          },
          child: Text(
            'إدارة التقييمات',
            style: AppTextStyles.displaySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        const Spacer(),
        
        // Refresh Button
        _buildGlowingIconButton(
          icon: Icons.refresh_rounded,
          onTap: _loadReviews,
        ),
      ],
    );
  }
  
  Widget _buildStatsSection(bool isDesktop, bool isTablet) {
    return BlocBuilder<ReviewsListBloc, ReviewsListState>(
      builder: (context, state) {
        if (state is ReviewsListLoaded) {
          final columns = isDesktop ? 4 : (isTablet ? 2 : 1);
          
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: columns,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: isDesktop ? 3 : 2.5,
            children: [
              ReviewStatsCard(
                title: 'إجمالي التقييمات',
                value: state.reviews.length.toString(),
                icon: Icons.rate_review_rounded,
                gradient: AppTheme.primaryGradient,
                animationDelay: const Duration(milliseconds: 100),
              ),
              ReviewStatsCard(
                title: 'في انتظار الموافقة',
                value: state.pendingCount.toString(),
                icon: Icons.pending_actions_rounded,
                gradient: LinearGradient(
                  colors: [AppTheme.warning, AppTheme.warning.withOpacity(0.6)],
                ),
                animationDelay: const Duration(milliseconds: 200),
              ),
              ReviewStatsCard(
                title: 'متوسط التقييم',
                value: state.averageRating.toStringAsFixed(1),
                icon: Icons.star_rounded,
                gradient: LinearGradient(
                  colors: [AppTheme.success, AppTheme.success.withOpacity(0.6)],
                ),
                animationDelay: const Duration(milliseconds: 300),
              ),
              ReviewStatsCard(
                title: 'لديها ردود',
                value: state.reviews.where((r) => r.hasResponse).length.toString(),
                icon: Icons.reply_rounded,
                gradient: LinearGradient(
                  colors: [AppTheme.info, AppTheme.info.withOpacity(0.6)],
                ),
                animationDelay: const Duration(milliseconds: 400),
              ),
            ],
          );
        }
        
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
  
  Widget _buildFiltersSection() {
    return ReviewFiltersWidget(
      onSearchChanged: (query) {
        setState(() => _searchQuery = query);
        _applyFilters();
      },
      onRatingFilterChanged: (rating) {
        setState(() => _minRating = rating);
        _applyFilters();
      },
      onPendingFilterChanged: (isPending) {
        setState(() => _isPending = isPending);
        _applyFilters();
      },
      onResponseFilterChanged: (hasResponse) {
        setState(() => _hasResponse = hasResponse);
        _applyFilters();
      },
    );
  }
  
  Widget _buildReviewsSection() {
    return BlocBuilder<ReviewsListBloc, ReviewsListState>(
      builder: (context, state) {
        if (state is ReviewsListLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (state is ReviewsListLoaded) {
          return FuturisticReviewsTable(
            reviews: state.filteredReviews,
            onApprove: (reviewId) {
              HapticFeedback.mediumImpact();
              context.read<ReviewsListBloc>().add(ApproveReviewEvent(reviewId));
            },
            onDelete: (reviewId) {
              HapticFeedback.heavyImpact();
              _showDeleteConfirmation(reviewId);
            },
            onViewDetails: (review) {
              Navigator.pushNamed(
                context,
                '/admin/reviews/details',
                arguments: review,
              );
            },
          );
        }
        
        if (state is ReviewsListError) {
          return Center(
            child: Text(
              state.message,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppTheme.error,
              ),
            ),
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }
  
  Widget _buildGlowingIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedBuilder(
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
                  color: AppTheme.primaryBlue.withOpacity(
                    0.3 + 0.2 * _glowAnimation.value,
                  ),
                  blurRadius: 10 + 5 * _glowAnimation.value,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          );
        },
      ),
    );
  }
  
  void _applyFilters() {
    context.read<ReviewsListBloc>().add(
      FilterReviewsEvent(
        searchQuery: _searchQuery,
        minRating: _minRating,
        isPending: _isPending,
        hasResponse: _hasResponse,
      ),
    );
  }
  
  void _showDeleteConfirmation(String reviewId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'تأكيد الحذف',
          style: AppTextStyles.heading3.copyWith(
            color: AppTheme.textWhite,
          ),
        ),
        content: Text(
          'هل أنت متأكد من حذف هذا التقييم؟',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textLight,
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
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.error, AppTheme.error.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<ReviewsListBloc>().add(
                  DeleteReviewEvent(reviewId),
                );
              },
              child: Text(
                'حذف',
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
    
    for (double x = 0; x < size.width + spacing; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    for (double y = 0; y < size.height + spacing; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
    
    canvas.restore();
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ParticlesPainter extends CustomPainter {
  final double animation;
  
  _ParticlesPainter({required this.animation});
  
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = (random.nextDouble() * size.height + 
                 animation * size.height) % size.height;
      final radius = random.nextDouble() * 2 + 0.5;
      final opacity = random.nextDouble() * 0.3 + 0.1;
      
      final paint = Paint()
        ..color = AppTheme.primaryBlue.withOpacity(opacity)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}