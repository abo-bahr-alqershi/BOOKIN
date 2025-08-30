import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';

class UserStatsCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradient;
  final Duration animationDelay;

  const UserStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    this.animationDelay = Duration.zero,
  });

  @override
  State<UserStatsCard> createState() => _UserStatsCardState();
}

class _UserStatsCardState extends State<UserStatsCard>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _glowController;
  late AnimationController _countController;
  
  late Animation<double> _entranceAnimation;
  late Animation<double> _glowAnimation;
  late Animation<int> _countAnimation;
  
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _countController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.elasticOut,
    );
    
    _glowAnimation = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    );
    
    final intValue = int.tryParse(widget.value) ?? 0;
    _countAnimation = IntTween(
      begin: 0,
      end: intValue,
    ).animate(CurvedAnimation(
      parent: _countController,
      curve: Curves.easeOut,
    ));
  }

  void _startAnimations() {
    Future.delayed(widget.animationDelay, () {
      if (mounted) {
        _entranceController.forward();
        _countController.forward();
      }
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _glowController.dispose();
    _countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _entranceAnimation,
        _glowAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _entranceAnimation.value,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 200,
              transform: Matrix4.identity()
                ..translate(0.0, _isHovered ? -5.0 : 0.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: widget.gradient[0].withOpacity(
                      0.2 + (_isHovered ? 0.1 : 0) + 0.1 * _glowAnimation.value,
                    ),
                    blurRadius: 20 + (_isHovered ? 10 : 0),
                    offset: Offset(0, 8 + (_isHovered ? 4 : 0)),
                  ),
                ],
              ),
              child: _buildCard(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.darkCard.withOpacity(0.8),
                AppTheme.darkCard.withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: Border.all(
              color: widget.gradient[0].withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned(
                top: -20,
                right: -20,
                child: Transform.rotate(
                  angle: math.pi / 12,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.gradient.map((c) => c.withOpacity(0.1)).toList(),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              
              // Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: widget.gradient),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: widget.gradient[0].withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      _buildTrendIndicator(),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spaceMedium),
                  
                  Text(
                    widget.title,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppTheme.textMuted,
                    ),
                  ),
                  
                  const SizedBox(height: AppDimensions.spaceXSmall),
                  
                  AnimatedBuilder(
                    animation: _countAnimation,
                    builder: (context, child) {
                      return ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            colors: widget.gradient,
                          ).createShader(bounds);
                        },
                        child: Text(
                          _countAnimation.value.toString(),
                          style: AppTextStyles.heading2.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendIndicator() {
    final isPositive = math.Random().nextBool();
    final percentage = math.Random().nextInt(30) + 1;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isPositive
            ? AppTheme.success.withOpacity(0.2)
            : AppTheme.error.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isPositive
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            size: 14,
            color: isPositive
                ? AppTheme.success
                : AppTheme.error,
          ),
          const SizedBox(width: 4),
          Text(
            '$percentage%',
            style: AppTextStyles.caption.copyWith(
              color: isPositive
                  ? AppTheme.success
                  : AppTheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}