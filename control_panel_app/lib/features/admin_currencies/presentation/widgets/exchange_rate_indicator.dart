import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';

class ExchangeRateIndicator extends StatefulWidget {
  final double currentRate;
  final double? previousRate;
  final DateTime? lastUpdated;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const ExchangeRateIndicator({
    super.key,
    required this.currentRate,
    this.previousRate,
    this.lastUpdated,
    this.isLoading = false,
    this.onRefresh,
  });

  @override
  State<ExchangeRateIndicator> createState() => _ExchangeRateIndicatorState();
}

class _ExchangeRateIndicatorState extends State<ExchangeRateIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _arrowController;
  late AnimationController _shimmerController;
  late AnimationController _rotateController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _arrowAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _rotateAnimation;
  
  double get _changePercentage {
    if (widget.previousRate == null || widget.previousRate == 0) return 0;
    return ((widget.currentRate - widget.previousRate!) / widget.previousRate!) * 100;
  }
  
  bool get _isIncreased => _changePercentage > 0;
  bool get _hasChanged => _changePercentage != 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _arrowController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(seconds: 1.5),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _arrowAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _arrowController,
      curve: Curves.elasticOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1,
      end: 2,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.linear,
    ));
  }

  void _startAnimations() {
    if (_hasChanged) {
      _pulseController.repeat(reverse: true);
      _arrowController.forward();
    }
    _shimmerController.repeat();
  }

  @override
  void didUpdateWidget(ExchangeRateIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRate != widget.currentRate) {
      _arrowController.reset();
      _arrowController.forward();
    }
    if (widget.isLoading && !oldWidget.isLoading) {
      _rotateController.repeat();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _rotateController.stop();
      _rotateController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _arrowController.dispose();
    _shimmerController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      child: Stack(
        children: [
          // Background gradient
          _buildBackgroundGradient(),
          
          // Glass morphism container
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.darkCard.withOpacity(0.6),
                      AppTheme.darkCard.withOpacity(0.4),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getIndicatorColor().withOpacity(0.3),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: _buildContent(),
              ),
            ),
          ),

          // Shimmer effect
          if (!widget.isLoading)
            AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (context, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.transparent,
                          AppTheme.glowWhite.withOpacity(0.05),
                          Colors.transparent,
                        ],
                        stops: [
                          0.0,
                          _shimmerAnimation.value,
                          1.0,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGradient() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1,
            colors: [
              _getIndicatorColor().withOpacity(0.1),
              Colors.transparent,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return _buildLoadingState();
    }

    return Row(
      children: [
        _buildRateSection(),
        const SizedBox(width: 16),
        _buildChangeIndicator(),
        const Spacer(),
        if (widget.onRefresh != null) _buildRefreshButton(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: AnimatedBuilder(
        animation: _rotateAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotateAnimation.value,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.primaryGradient,
              ),
              child: Center(
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.darkCard,
                  ),
                  child: Center(
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.primaryGradient,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(
              Icons.currency_exchange_rounded,
              color: AppTheme.primaryBlue,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'سعر الصرف',
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _hasChanged ? _pulseAnimation : AlwaysStoppedAnimation(1.0),
          builder: (context, child) {
            return Transform.scale(
              scale: _hasChanged ? _pulseAnimation.value : 1.0,
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    _getIndicatorColor(),
                    _getIndicatorColor().withOpacity(0.8),
                  ],
                ).createShader(bounds),
                child: Text(
                  widget.currentRate.toStringAsFixed(2),
                  style: AppTextStyles.heading2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.lastUpdated != null) ...[
          const SizedBox(height: 4),
          Text(
            _getTimeAgo(widget.lastUpdated!),
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textMuted.withOpacity(0.7),
              fontSize: 10,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildChangeIndicator() {
    if (!_hasChanged) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.textMuted.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'بدون تغيير',
          style: AppTextStyles.caption.copyWith(
            color: AppTheme.textMuted,
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _arrowAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _arrowAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getIndicatorColor().withOpacity(0.2),
                  _getIndicatorColor().withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getIndicatorColor().withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.rotate(
                  angle: _isIncreased ? -math.pi / 4 : math.pi / 4,
                  child: Icon(
                    _isIncreased 
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    color: _getIndicatorColor(),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${_changePercentage.abs().toStringAsFixed(2)}%',
                  style: AppTextStyles.caption.copyWith(
                    color: _getIndicatorColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRefreshButton() {
    return InkWell(
      onTap: widget.onRefresh,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryBlue.withOpacity(0.2),
              AppTheme.primaryPurple.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: Icon(
          Icons.refresh_rounded,
          color: AppTheme.primaryBlue,
          size: 20,
        ),
      ),
    );
  }

  Color _getIndicatorColor() {
    if (!_hasChanged) return AppTheme.textMuted;
    return _isIncreased ? AppTheme.success : AppTheme.error;
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'}';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} ${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
    } else {
      return 'الآن';
    }
  }
}

// Mini version for list items
class MiniExchangeRateIndicator extends StatelessWidget {
  final double rate;
  final double? previousRate;
  final bool showChange;

  const MiniExchangeRateIndicator({
    super.key,
    required this.rate,
    this.previousRate,
    this.showChange = true,
  });

  double get _changePercentage {
    if (previousRate == null || previousRate == 0) return 0;
    return ((rate - previousRate!) / previousRate!) * 100;
  }

  bool get _isIncreased => _changePercentage > 0;
  bool get _hasChanged => _changePercentage != 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkSurface.withOpacity(0.3),
            AppTheme.darkSurface.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            rate.toStringAsFixed(2),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (showChange && _hasChanged) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getIndicatorColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isIncreased 
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    color: _getIndicatorColor(),
                    size: 12,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${_changePercentage.abs().toStringAsFixed(1)}%',
                    style: AppTextStyles.caption.copyWith(
                      color: _getIndicatorColor(),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getIndicatorColor() {
    if (!_hasChanged) return AppTheme.textMuted;
    return _isIncreased ? AppTheme.success : AppTheme.error;
  }
}