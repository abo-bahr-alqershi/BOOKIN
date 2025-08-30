// lib/features/admin_reviews/presentation/widgets/review_stats_card.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:bookn_cp_app/core/theme/app_theme.dart';
import 'package:bookn_cp_app/core/theme/app_text_styles.dart';

class ReviewStatsCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;
  final Duration animationDelay;
  
  const ReviewStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    this.animationDelay = Duration.zero,
  });
  
  @override
  State<ReviewStatsCard> createState() => _ReviewStatsCardState();
}

class _ReviewStatsCardState extends State<ReviewStatsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    Future.delayed(widget.animationDelay, () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Container(
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
                  color: widget.gradient.colors.first.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.gradient.colors.first.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: widget.gradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: widget.gradient.colors.first.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: AppTextStyles.caption.copyWith(
                                color: AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TweenAnimationBuilder<int>(
                              tween: IntTween(
                                begin: 0,
                                end: int.tryParse(widget.value) ?? 0,
                              ),
                              duration: const Duration(milliseconds: 1500),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Text(
                                  value.toString(),
                                  style: AppTextStyles.heading2.copyWith(
                                    color: AppTheme.textWhite,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ],
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
    );
  }
}