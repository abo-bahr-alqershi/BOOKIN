// lib/features/admin_audit_logs/presentation/widgets/audit_log_stats_card.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';

class AuditLogStatsCard extends StatefulWidget {
  final int totalLogs;
  final int todayLogs;
  final int criticalActions;
  final int activeUsers;

  const AuditLogStatsCard({
    super.key,
    required this.totalLogs,
    required this.todayLogs,
    required this.criticalActions,
    required this.activeUsers,
  });

  @override
  State<AuditLogStatsCard> createState() => _AuditLogStatsCardState();
}

class _AuditLogStatsCardState extends State<AuditLogStatsCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _numberController;
  late AnimationController _glowController;
  
  late List<Animation<double>> _cardAnimations;
  late List<Animation<int>> _numberAnimations;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();
    
    _numberController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _cardAnimations = List.generate(4, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.1,
          0.6 + index * 0.1,
          curve: Curves.easeOutBack,
        ),
      ));
    });
    
    _numberAnimations = [
      IntTween(begin: 0, end: widget.totalLogs).animate(
        CurvedAnimation(parent: _numberController, curve: Curves.easeOut),
      ),
      IntTween(begin: 0, end: widget.todayLogs).animate(
        CurvedAnimation(parent: _numberController, curve: Curves.easeOut),
      ),
      IntTween(begin: 0, end: widget.criticalActions).animate(
        CurvedAnimation(parent: _numberController, curve: Curves.easeOut),
      ),
      IntTween(begin: 0, end: widget.activeUsers).animate(
        CurvedAnimation(parent: _numberController, curve: Curves.easeOut),
      ),
    ];
    
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _numberController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = [
      {
        'title': 'إجمالي السجلات',
        'icon': Icons.format_list_bulleted_rounded,
        'color': AppTheme.primaryBlue,
        'gradient': [AppTheme.primaryBlue, AppTheme.primaryCyan],
      },
      {
        'title': 'سجلات اليوم',
        'icon': Icons.today_rounded,
        'color': AppTheme.success,
        'gradient': [AppTheme.success, AppTheme.neonGreen],
      },
      {
        'title': 'عمليات حرجة',
        'icon': Icons.warning_amber_rounded,
        'color': AppTheme.warning,
        'gradient': [AppTheme.warning, const Color(0xFFFF6B6B)],
      },
      {
        'title': 'مستخدمون نشطون',
        'icon': Icons.people_rounded,
        'color': AppTheme.primaryPurple,
        'gradient': [AppTheme.primaryPurple, AppTheme.primaryViolet],
      },
    ];
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;
        final childAspectRatio = constraints.maxWidth > 800 ? 1.6 : 1.1;
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: Listenable.merge([
                _cardAnimations[index],
                _numberAnimations[index],
                _glowAnimation,
              ]),
              builder: (context, child) {
                final safeScale = _cardAnimations[index].value.clamp(0.0, 1.0);
                final safeOpacity = _cardAnimations[index].value.clamp(0.0, 1.0);
                return Transform.scale(
                  scale: safeScale,
                  child: Opacity(
                    opacity: safeOpacity,
                    child: _buildStatCard(
                      title: stats[index]['title'] as String,
                      value: _numberAnimations[index].value,
                      icon: stats[index]['icon'] as IconData,
                      color: stats[index]['color'] as Color,
                      gradient: stats[index]['gradient'] as List<Color>,
                      glowIntensity: _glowAnimation.value.clamp(0.0, 1.0),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
    required List<Color> gradient,
    required double glowIntensity,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2 * glowIntensity),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.darkCard.withOpacity(0.7),
                  AppTheme.darkCard.withOpacity(0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradient),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: gradient.first.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    _buildTrendIndicator(value),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          colors: gradient,
                        ).createShader(bounds);
                      },
                      child: Text(
                        value.toString(),
                        style: AppTextStyles.heading1.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppTheme.textMuted,
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

  Widget _buildTrendIndicator(int value) {
    final isPositive = value > 0;
    final trend = math.Random().nextDouble() * 20 - 10; // Mock trend
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPositive
            ? AppTheme.success.withOpacity(0.1)
            : AppTheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            trend > 0
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            size: 14,
            color: trend > 0 ? AppTheme.success : AppTheme.error,
          ),
          const SizedBox(width: 4),
          Text(
            '${trend.abs().toStringAsFixed(1)}%',
            style: AppTextStyles.caption.copyWith(
              color: trend > 0 ? AppTheme.success : AppTheme.error,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}