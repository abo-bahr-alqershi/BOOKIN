// lib/features/admin_reviews/presentation/widgets/review_stats_card.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/review.dart';

class ReviewStatsCard extends StatefulWidget {
  final int totalReviews;
  final int pendingReviews;
  final double averageRating;
  final List<Review> reviews;
  final bool isDesktop;
  final bool isTablet;
  
  const ReviewStatsCard({
    super.key,
    required this.totalReviews,
    required this.pendingReviews,
    required this.averageRating,
    required this.reviews,
    required this.isDesktop,
    required this.isTablet,
  });
  
  @override
  State<ReviewStatsCard> createState() => _ReviewStatsCardState();
}

class _ReviewStatsCardState extends State<ReviewStatsCard>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
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
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
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
    super.dispose();
  }
  
  Map<String, dynamic> _calculateStats() {
    if (widget.reviews.isEmpty) {
      return {
        'fiveStars': 0,
        'fourStars': 0,
        'threeStars': 0,
        'twoStars': 0,
        'oneStar': 0,
        'withImages': 0,
        'withResponse': 0,
        'approved': 0,
      };
    }
    
    return {
      'fiveStars': widget.reviews.where((r) => r.averageRating >= 4.5).length,
      'fourStars': widget.reviews.where((r) => r.averageRating >= 3.5 && r.averageRating < 4.5).length,
      'threeStars': widget.reviews.where((r) => r.averageRating >= 2.5 && r.averageRating < 3.5).length,
      'twoStars': widget.reviews.where((r) => r.averageRating >= 1.5 && r.averageRating < 2.5).length,
      'oneStar': widget.reviews.where((r) => r.averageRating < 1.5).length,
      'withImages': widget.reviews.where((r) => r.images.isNotEmpty).length,
      'withResponse': widget.reviews.where((r) => r.hasResponse).length,
      'approved': widget.reviews.where((r) => r.isApproved).length,
    };
  }
  
  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();
    final columns = widget.isDesktop ? 4 : (widget.isTablet ? 2 : 1);
    
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
              childAspectRatio: widget.isDesktop ? 1.5 : (widget.isTablet ? 1.3 : 1.8),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard(
                  title: 'Total Reviews',
                  value: widget.totalReviews.toString(),
                  icon: Icons.reviews_outlined,
                  gradient: [
                    AppTheme.primaryBlue.withOpacity(0.8),
                    AppTheme.primaryPurple.withOpacity(0.8),
                  ],
                  index: 0,
                ),
                _buildStatCard(
                  title: 'Pending',
                  value: widget.pendingReviews.toString(),
                  icon: Icons.pending_outlined,
                  gradient: [
                    AppTheme.warning.withOpacity(0.8),
                    Colors.orange.withOpacity(0.8),
                  ],
                  index: 1,
                  isPulsing: widget.pendingReviews > 0,
                ),
                _buildStatCard(
                  title: 'Average Rating',
                  value: widget.averageRating.toStringAsFixed(1),
                  icon: Icons.star_rounded,
                  gradient: [
                    AppTheme.success.withOpacity(0.8),
                    AppTheme.neonGreen.withOpacity(0.8),
                  ],
                  index: 2,
                  suffix: '/ 5.0',
                ),
                _buildStatCard(
                  title: 'Response Rate',
                  value: widget.totalReviews > 0
                      ? '${((stats['withResponse'] / widget.totalReviews) * 100).toStringAsFixed(0)}%'
                      : '0%',
                  icon: Icons.reply_all_rounded,
                  gradient: [
                    AppTheme.info.withOpacity(0.8),
                    AppTheme.neonBlue.withOpacity(0.8),
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
    String? suffix,
    bool isPulsing = false,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800 + (index * 200)),
      curve: Curves.easeOutBack,
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: animValue,
          child: AnimatedBuilder(
            animation: isPulsing ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
            builder: (context, child) {
              return Transform.scale(
                scale: isPulsing ? _pulseAnimation.value : 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
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
                    boxShadow: [
                      BoxShadow(
                        color: gradient[0].withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Stack(
                        children: [
                          // Background Gradient Orb
                          Positioned(
                            top: -30,
                            right: -30,
                            child: Container(
                              width: 100,
                              height: 100,
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
                          
                          // Content
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Icon
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
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
                                
                                // Text
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        TweenAnimationBuilder<double>(
                                          tween: Tween(
                                            begin: 0.0,
                                            end: double.tryParse(
                                              value.replaceAll('%', ''),
                                            ) ?? 0.0,
                                          ),
                                          duration: const Duration(milliseconds: 1500),
                                          curve: Curves.easeOutCubic,
                                          builder: (context, animValue, child) {
                                            String displayValue = value;
                                            if (value.contains('%')) {
                                              displayValue = '${animValue.toStringAsFixed(0)}%';
                                            } else if (value.contains('.')) {
                                              displayValue = animValue.toStringAsFixed(1);
                                            } else {
                                              displayValue = animValue.toStringAsFixed(0);
                                            }
                                            
                                            return Text(
                                              displayValue,
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w700,
                                                color: AppTheme.textWhite,
                                              ),
                                            );
                                          },
                                        ),
                                        if (suffix != null) ...[
                                          const SizedBox(width: 4),
                                          Text(
                                            suffix,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: AppTheme.textMuted.withOpacity(0.7),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          // Shimmer Effect
                          if (isPulsing)
                            Positioned.fill(
                              child: AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      gradient: LinearGradient(
                                        begin: Alignment(-1.0 + 2 * _pulseController.value, -1.0),
                                        end: Alignment(1.0 + 2 * _pulseController.value, 1.0),
                                        colors: [
                                          Colors.transparent,
                                          gradient[0].withOpacity(0.1),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
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