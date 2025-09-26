import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/section.dart';
import '../../../../core/enums/section_type.dart';
import '../../../../core/enums/section_target.dart';
import '../../../../core/enums/section_content_type.dart';
import '../../../../core/enums/section_display_style.dart';

class SectionStatsCard extends StatefulWidget {
  final List<Section> sections;
  final int totalCount;
  final VoidCallback? onRefresh;
  final Function(String)? onStatTap;

  const SectionStatsCard({
    super.key,
    required this.sections,
    required this.totalCount,
    this.onRefresh,
    this.onStatTap,
  });

  @override
  State<SectionStatsCard> createState() => _SectionStatsCardState();
}

class _SectionStatsCardState extends State<SectionStatsCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late List<Animation<double>> _cardAnimations;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _setupAnimations();
    _animationController.forward();
  }

  void _setupAnimations() {
    _cardAnimations = List.generate(6, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.1,
            0.5 + index * 0.1,
            curve: Curves.easeOutBack,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _calculateDetailedStats() {
    int active = 0;
    int inactive = 0;
    int properties = 0;
    int units = 0;
    int mixed = 0;

    // Stats by type
    Map<SectionTypeEnum, int> typeStats = {};
    for (var type in SectionTypeEnum.values) {
      typeStats[type] = 0;
    }

    // Stats by display style
    Map<SectionDisplayStyle, int> styleStats = {};
    for (var style in SectionDisplayStyle.values) {
      styleStats[style] = 0;
    }

    // Calculate averages
    double avgItemsPerSection = 0;
    int totalItems = 0;

    for (final section in widget.sections) {
      // Basic stats
      if (section.isActive) {
        active++;
      } else {
        inactive++;
      }

      // Target stats
      if (section.target == SectionTarget.properties) {
        properties++;
      } else if (section.target == SectionTarget.units) {
        units++;
      }

      // Content type stats
      if (section.contentType == SectionContentType.mixed) {
        mixed++;
      }

      // Type stats
      typeStats[section.type] = (typeStats[section.type] ?? 0) + 1;

      // Style stats
      styleStats[section.displayStyle] =
          (styleStats[section.displayStyle] ?? 0) + 1;

      // Items stats
      totalItems += section.itemsToShow;
    }

    if (widget.sections.isNotEmpty) {
      avgItemsPerSection = totalItems / widget.sections.length;
    }

    // Find most used type
    SectionTypeEnum? mostUsedType;
    int maxTypeCount = 0;
    typeStats.forEach((type, count) {
      if (count > maxTypeCount) {
        maxTypeCount = count;
        mostUsedType = type;
      }
    });

    return {
      'active': active,
      'inactive': inactive,
      'properties': properties,
      'units': units,
      'mixed': mixed,
      'avgItems': avgItemsPerSection.round(),
      'mostUsedType': mostUsedType,
      'typeStats': typeStats,
      'styleStats': styleStats,
      'activePercentage': widget.sections.isNotEmpty
          ? (active / widget.sections.length * 100).round()
          : 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    final stats = _calculateDetailedStats();

    return Container(
      height: 140,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        children: [
          // Background gradient effect
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _StatsBackgroundPainter(
                    animationValue: _pulseController.value,
                  ),
                );
              },
            ),
          ),
          // Stats cards
          ListView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              _buildAnimatedStatCard(
                index: 0,
                title: 'إجمالي الأقسام',
                value: widget.totalCount.toString(),
                subtitle: 'قسم',
                icon: CupertinoIcons.square_stack_3d_up_fill,
                gradient: AppTheme.primaryGradient,
                onTap: () => widget.onStatTap?.call('total'),
                trend: _calculateTrend('total'),
                sparklineData: _generateSparklineData(),
              ),
              _buildAnimatedStatCard(
                index: 1,
                title: 'أقسام نشطة',
                value: stats['active'].toString(),
                subtitle: '${stats['activePercentage']}% نشط',
                icon: CupertinoIcons.checkmark_circle_fill,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.success,
                    AppTheme.success.withValues(alpha: 0.7),
                  ],
                ),
                onTap: () => widget.onStatTap?.call('active'),
                trend: _calculateTrend('active'),
                progressValue: stats['activePercentage'] / 100,
              ),
              _buildAnimatedStatCard(
                index: 2,
                title: 'أقسام متوقفة',
                value: stats['inactive'].toString(),
                subtitle: 'متوقف',
                icon: CupertinoIcons.pause_circle_fill,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.warning,
                    AppTheme.warning.withValues(alpha: 0.7),
                  ],
                ),
                onTap: () => widget.onStatTap?.call('inactive'),
                trend: _calculateTrend('inactive'),
                isNegative: true,
              ),
              _buildAnimatedStatCard(
                index: 3,
                title: 'أقسام العقارات',
                value: stats['properties'].toString(),
                subtitle: 'عقار',
                icon: CupertinoIcons.building_2_fill,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryPurple,
                    AppTheme.primaryPurple.withValues(alpha: 0.7),
                  ],
                ),
                onTap: () => widget.onStatTap?.call('properties'),
                additionalInfo: _getTypeIcon(SectionTarget.properties),
              ),
              _buildAnimatedStatCard(
                index: 4,
                title: 'أقسام الوحدات',
                value: stats['units'].toString(),
                subtitle: 'وحدة',
                icon: CupertinoIcons.house_fill,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.info,
                    AppTheme.info.withValues(alpha: 0.7),
                  ],
                ),
                onTap: () => widget.onStatTap?.call('units'),
                additionalInfo: _getTypeIcon(SectionTarget.units),
              ),
              _buildAnimatedStatCard(
                index: 5,
                title: 'محتوى مختلط',
                value: stats['mixed'].toString(),
                subtitle: 'مختلط',
                icon: CupertinoIcons.square_stack_3d_down_right_fill,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryViolet,
                    AppTheme.primaryCyan,
                  ],
                ),
                onTap: () => widget.onStatTap?.call('mixed'),
                hasGlowEffect: true,
              ),
              if (widget.onRefresh != null) _buildRefreshCard(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedStatCard({
    required int index,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    VoidCallback? onTap,
    double? trend,
    double? progressValue,
    bool isNegative = false,
    Widget? additionalInfo,
    List<double>? sparklineData,
    bool hasGlowEffect = false,
  }) {
    return AnimatedBuilder(
      animation: _cardAnimations[index],
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimations[index].value,
          child: Opacity(
            opacity: _cardAnimations[index].value,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 180,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.colors.first.withValues(alpha: 0.3),
                      blurRadius: hasGlowEffect ? 30 : 20,
                      offset: const Offset(0, 10),
                      spreadRadius: hasGlowEffect ? 5 : 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            gradient.colors.first.withValues(alpha: 0.15),
                            gradient.colors.last.withValues(alpha: 0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: gradient.colors.first.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Animated background pattern
                          if (hasGlowEffect)
                            Positioned.fill(
                              child: AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return CustomPaint(
                                    painter: _GlowPainter(
                                      color: gradient.colors.first,
                                      animationValue: _pulseController.value,
                                    ),
                                  );
                                },
                              ),
                            ),
                          // Background Icon
                          Positioned(
                            right: -20,
                            top: -20,
                            child: AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _pulseController.value * 0.1,
                                  child: Icon(
                                    icon,
                                    size: 100,
                                    color: gradient.colors.first
                                        .withValues(alpha: 0.1),
                                  ),
                                );
                              },
                            ),
                          ),
                          // Content
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Header
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: gradient,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: gradient.colors.first
                                                .withValues(alpha: 0.5),
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        icon,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                    if (trend != null)
                                      _buildTrendIndicator(trend, isNegative),
                                    if (additionalInfo != null) additionalInfo,
                                  ],
                                ),
                                // Value section
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (sparklineData != null)
                                      _buildSparkline(sparklineData, gradient),
                                    ShaderMask(
                                      shaderCallback: (bounds) =>
                                          gradient.createShader(bounds),
                                      child: Text(
                                        value,
                                        style:
                                            AppTextStyles.displaySmall.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          height: 1.0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      subtitle,
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppTheme.textMuted
                                            .withValues(alpha: 0.8),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                // Footer
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (progressValue != null)
                                      _buildProgressBar(
                                          progressValue, gradient),
                                    Text(
                                      title,
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppTheme.textMuted,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildRefreshCard() {
    return GestureDetector(
      onTap: widget.onRefresh,
      child: Container(
        width: 100,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.05),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.arrow_clockwise,
                      color: AppTheme.primaryBlue,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'تحديث',
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrendIndicator(double trend, bool isNegative) {
    final isPositive = isNegative ? trend <= 0 : trend >= 0;
    final color = isPositive ? AppTheme.success : AppTheme.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive
                ? CupertinoIcons.arrow_up_right
                : CupertinoIcons.arrow_down_right,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            '${trend.abs().toStringAsFixed(1)}%',
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double value, Gradient gradient) {
    return Container(
      height: 4,
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Stack(
          children: [
            FractionallySizedBox(
              widthFactor: value.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: gradient,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSparkline(List<double> data, Gradient gradient) {
    return Container(
      height: 30,
      margin: const EdgeInsets.only(bottom: 8),
      child: CustomPaint(
        painter: _SparklinePainter(
          data: data,
          gradient: gradient,
        ),
      ),
    );
  }

  Widget _getTypeIcon(SectionTarget target) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        target == SectionTarget.properties
            ? CupertinoIcons.building_2_fill
            : CupertinoIcons.house_fill,
        size: 12,
        color: AppTheme.primaryBlue,
      ),
    );
  }

  double _calculateTrend(String type) {
    // Mock trend calculation - replace with actual logic
    final random = math.Random();
    return (random.nextDouble() * 20) - 10;
  }

  List<double> _generateSparklineData() {
    // Mock sparkline data - replace with actual data
    final random = math.Random();
    return List.generate(10, (index) => random.nextDouble() * 100);
  }
}

// Custom painters for visual effects
class _StatsBackgroundPainter extends CustomPainter {
  final double animationValue;

  _StatsBackgroundPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    // Draw animated gradient orbs
    paint.shader = RadialGradient(
      colors: [
        AppTheme.primaryBlue.withValues(alpha: 0.1 * animationValue),
        AppTheme.primaryBlue.withValues(alpha: 0.05 * animationValue),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(
      center: Offset(size.width * 0.3, size.height * 0.5),
      radius: 60 + (20 * animationValue),
    ));

    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.5),
      60 + (20 * animationValue),
      paint,
    );

    paint.shader = RadialGradient(
      colors: [
        AppTheme.primaryPurple.withValues(alpha: 0.1 * (1 - animationValue)),
        AppTheme.primaryPurple.withValues(alpha: 0.05 * (1 - animationValue)),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(
      center: Offset(size.width * 0.7, size.height * 0.5),
      radius: 50 + (15 * (1 - animationValue)),
    ));

    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.5),
      50 + (15 * (1 - animationValue)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _GlowPainter extends CustomPainter {
  final Color color;
  final double animationValue;

  _GlowPainter({required this.color, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    for (int i = 0; i < 3; i++) {
      paint.color = color.withValues(
        alpha: (0.05 - (i * 0.015)) * animationValue,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            -10.0 - (i * 5),
            -10.0 - (i * 5),
            size.width + 20 + (i * 10),
            size.height + 20 + (i * 10),
          ),
          const Radius.circular(20),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Gradient gradient;

  _SparklinePainter({required this.data, required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    final path = Path();
    final maxValue = data.reduce(math.max);
    final minValue = data.reduce(math.min);
    final range = maxValue - minValue;

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final normalizedValue = range > 0 ? (data[i] - minValue) / range : 0.5;
      final y = size.height - (normalizedValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = ((i - 1) / (data.length - 1)) * size.width;
        final prevNormalizedValue =
            range > 0 ? (data[i - 1] - minValue) / range : 0.5;
        final prevY = size.height - (prevNormalizedValue * size.height);

        final controlX = (prevX + x) / 2;
        path.quadraticBezierTo(controlX, prevY, x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw gradient fill under the line
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          gradient.colors.first.withValues(alpha: 0.2),
          gradient.colors.first.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
