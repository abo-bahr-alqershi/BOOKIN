// lib/features/admin_cities/presentation/widgets/city_stats_card.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';

class CityStatsCard extends StatefulWidget {
  final int totalCities;
  final int activeCities;
  final int totalProperties;
  final int countries;
  final bool isDesktop;
  final bool isTablet;
  
  const CityStatsCard({
    super.key,
    required this.totalCities,
    required this.activeCities,
    required this.totalProperties,
    required this.countries,
    required this.isDesktop,
    required this.isTablet,
  });
  
  @override
  State<CityStatsCard> createState() => _CityStatsCardState();
}

class _CityStatsCardState extends State<CityStatsCard>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _mainController.forward();
  }
  
  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final columns = widget.isDesktop ? 4 : (widget.isTablet ? 2 : 2);
    
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: columns,
              childAspectRatio: widget.isDesktop ? 1.8 : (widget.isTablet ? 1.6 : 1.4),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard(
                  title: 'إجمالي المدن',
                  value: widget.totalCities.toString(),
                  icon: Icons.location_city_rounded,
                  gradient: [
                    AppTheme.primaryBlue.withOpacity(0.8),
                    AppTheme.primaryPurple.withOpacity(0.8),
                  ],
                  index: 0,
                  isMain: true,
                ),
                _buildStatCard(
                  title: 'المدن النشطة',
                  value: widget.activeCities.toString(),
                  icon: Icons.check_circle_rounded,
                  gradient: [
                    AppTheme.success.withOpacity(0.8),
                    AppTheme.neonGreen.withOpacity(0.8),
                  ],
                  index: 1,
                  percentage: widget.totalCities > 0
                      ? (widget.activeCities / widget.totalCities * 100).toInt()
                      : 0,
                ),
                _buildStatCard(
                  title: 'العقارات',
                  value: widget.totalProperties.toString(),
                  icon: Icons.apartment_rounded,
                  gradient: [
                    AppTheme.primaryViolet.withOpacity(0.8),
                    AppTheme.neonPurple.withOpacity(0.8),
                  ],
                  index: 2,
                ),
                _buildStatCard(
                  title: 'الدول',
                  value: widget.countries.toString(),
                  icon: Icons.flag_rounded,
                  gradient: [
                    AppTheme.warning.withOpacity(0.8),
                    Colors.orange.withOpacity(0.8),
                  ],
                  index: 3,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradient,
    required int index,
    bool isMain = false,
    int? percentage,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800 + (index * 200)),
      curve: Curves.easeOutBack,
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: animValue,
          child: AnimatedBuilder(
            animation: isMain ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
            builder: (context, child) {
              return Transform.scale(
                scale: isMain ? _pulseAnimation.value : 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: gradient[0].withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.darkCard.withOpacity(0.7),
                              AppTheme.darkCard.withOpacity(0.5),
                            ],
                          ),
                          border: Border.all(
                            color: gradient[0].withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Background Glow
                            Positioned(
                              top: -50,
                              right: -50,
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      gradient[0].withOpacity(0.3),
                                      gradient[0].withOpacity(0.0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            
                            // Shimmer Effect
                            if (isMain)
                              AnimatedBuilder(
                                animation: _shimmerController,
                                builder: (context, child) {
                                  return Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        gradient: LinearGradient(
                                          begin: Alignment(-1.0 + 2 * _shimmerController.value, -1.0),
                                          end: Alignment(1.0 + 2 * _shimmerController.value, 1.0),
                                          colors: [
                                            Colors.transparent,
                                            gradient[0].withOpacity(0.1),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            
                            // Content
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Icon with gradient background
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      gradient: LinearGradient(
                                        colors: gradient,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: gradient[0].withOpacity(0.5),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      icon,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  
                                  // Value and Title
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          TweenAnimationBuilder<double>(
                                            tween: Tween(
                                              begin: 0.0,
                                              end: double.tryParse(value) ?? 0.0,
                                            ),
                                            duration: const Duration(milliseconds: 1500),
                                            curve: Curves.easeOutCubic,
                                            builder: (context, animValue, child) {
                                              return Text(
                                                animValue.toStringAsFixed(0),
                                                style: AppTextStyles.heading1.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  color: AppTheme.textWhite,
                                                  fontSize: 28,
                                                  letterSpacing: -0.5,
                                                ),
                                              );
                                            },
                                          ),
                                          if (percentage != null) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(6),
                                                color: AppTheme.success.withOpacity(0.2),
                                              ),
                                              child: Text(
                                                '$percentage%',
                                                style: AppTextStyles.caption.copyWith(
                                                  color: AppTheme.success,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        title,
                                        style: AppTextStyles.caption.copyWith(
                                          fontWeight: FontWeight.w400,
                                          color: AppTheme.textMuted.withOpacity(0.8),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            // Corner Pattern
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CustomPaint(
                                size: const Size(60, 60),
                                painter: _CornerPatternPainter(
                                  color: gradient[0].withOpacity(0.1),
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
            },
          ),
        );
      },
    );
  }
}

class _CornerPatternPainter extends CustomPainter {
  final Color color;
  
  _CornerPatternPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    // Draw corner pattern
    for (int i = 0; i < 5; i++) {
      final radius = (i + 1) * 12.0;
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(size.width, size.height),
          radius: radius,
        ),
        -math.pi,
        math.pi / 2,
        false,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}