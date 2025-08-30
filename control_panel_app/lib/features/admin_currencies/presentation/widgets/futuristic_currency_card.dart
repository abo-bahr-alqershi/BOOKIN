import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/currency.dart';

class FuturisticCurrencyCard extends StatefulWidget {
  final Currency currency;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;
  final Function(double) onExchangeRateChanged;
  final bool isCompact;

  const FuturisticCurrencyCard({
    super.key,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
    required this.onExchangeRateChanged,
    this.isCompact = false,
  });

  @override
  State<FuturisticCurrencyCard> createState() => _FuturisticCurrencyCardState();
}

class _FuturisticCurrencyCardState extends State<FuturisticCurrencyCard>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isHovered = false;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutQuart,
    ));

    if (widget.currency.isDefault) {
      _glowController.repeat(reverse: true);
      _pulseController.repeat(reverse: true);
    }

    _slideController.forward();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: AnimatedBuilder(
        animation: Listenable.merge([_glowAnimation, _pulseAnimation]),
        builder: (context, child) {
          return MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutExpo,
              transform: Matrix4.identity()
                ..translate(0.0, _isHovered ? -5.0 : 0.0)
                ..scale(
                  widget.currency.isDefault ? _pulseAnimation.value : 1.0,
                ),
              child: _buildCard(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      margin: EdgeInsets.only(bottom: widget.isCompact ? 12 : 16),
      child: Stack(
        children: [
          // Glow effect for default currency
          if (widget.currency.isDefault)
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(
                        0.3 * _glowAnimation.value,
                      ),
                      blurRadius: 20 + (10 * _glowAnimation.value),
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: AppTheme.neonBlue.withOpacity(
                        0.2 * _glowAnimation.value,
                      ),
                      blurRadius: 30 + (15 * _glowAnimation.value),
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
            ),

          // Main card content
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.currency.isDefault
                        ? [
                            AppTheme.primaryBlue.withOpacity(0.15),
                            AppTheme.primaryPurple.withOpacity(0.08),
                          ]
                        : [
                            AppTheme.darkCard.withOpacity(0.7),
                            AppTheme.darkCard.withOpacity(0.5),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.currency.isDefault
                        ? AppTheme.primaryBlue.withOpacity(0.5)
                        : AppTheme.darkBorder.withOpacity(0.3),
                    width: widget.currency.isDefault ? 2 : 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                    borderRadius: BorderRadius.circular(20),
                    child: _buildCardContent(),
                  ),
                ),
              ),
            ),
          ),

          // Default badge
          if (widget.currency.isDefault)
            Positioned(
              top: 12,
              right: 12,
              child: _buildDefaultBadge(),
            ),
        ],
      ),
    );
  }

  Widget _buildCardContent() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(widget.isCompact ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildCurrencyIcon(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.currency.code,
                          style: AppTextStyles.heading3.copyWith(
                            color: AppTheme.textWhite,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryPurple.withOpacity(0.3),
                                AppTheme.primaryViolet.withOpacity(0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.primaryPurple.withOpacity(0.3),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            widget.currency.arabicCode,
                            style: AppTextStyles.caption.copyWith(
                              color: AppTheme.textWhite,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.currency.arabicName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppTheme.textLight,
                      ),
                    ),
                    Text(
                      widget.currency.name,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              _buildActionButtons(),
            ],
          ),
          
          if (_isExpanded) ...[
            const SizedBox(height: 20),
            _buildExchangeRateSection(),
            if (widget.currency.lastUpdated != null) ...[
              const SizedBox(height: 12),
              _buildLastUpdatedSection(),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildCurrencyIcon() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Currency symbol with glow
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.white, Colors.white70],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(bounds),
            child: Text(
              _getCurrencySymbol(widget.currency.code),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          
          // Animated ring
          if (widget.currency.isDefault)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 2 * math.pi),
              duration: const Duration(seconds: 10),
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: value,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
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

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          icon: Icons.edit_rounded,
          color: AppTheme.info,
          onTap: widget.onEdit,
          tooltip: 'تعديل',
        ),
        const SizedBox(width: 8),
        if (!widget.currency.isDefault)
          _buildActionButton(
            icon: Icons.star_outline_rounded,
            color: AppTheme.warning,
            onTap: widget.onSetDefault,
            tooltip: 'تعيين كافتراضي',
          ),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Icons.delete_outline_rounded,
          color: AppTheme.error,
          onTap: widget.onDelete,
          tooltip: 'حذف',
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.2),
                color.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: 14,
            color: AppTheme.glowWhite,
          ),
          const SizedBox(width: 4),
          Text(
            'افتراضي',
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.glowWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExchangeRateSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkSurface.withOpacity(0.3),
            AppTheme.darkSurface.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.currency_exchange_rounded,
                size: 18,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(width: 8),
              Text(
                'سعر الصرف',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.textLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.currency.isDefault)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'العملة الافتراضية',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.darkCard.withOpacity(0.5),
                          AppTheme.darkCard.withOpacity(0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppTheme.primaryBlue.withOpacity(0.2),
                        width: 0.5,
                      ),
                    ),
                    child: TextField(
                      controller: TextEditingController(
                        text: widget.currency.exchangeRate?.toString() ?? '',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppTheme.textWhite,
                      ),
                      decoration: InputDecoration(
                        hintText: 'أدخل سعر الصرف',
                        hintStyle: AppTextStyles.bodySmall.copyWith(
                          color: AppTheme.textMuted.withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        prefixIcon: Icon(
                          Icons.attach_money_rounded,
                          size: 18,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      onSubmitted: (value) {
                        final rate = double.tryParse(value);
                        if (rate != null) {
                          widget.onExchangeRateChanged(rate);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _buildUpdateButton(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton() {
    return InkWell(
      onTap: () {
        HapticFeedback.mediumImpact();
        // Trigger update
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'تحديث',
            style: AppTextStyles.buttonSmall.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLastUpdatedSection() {
    final lastUpdated = widget.currency.lastUpdated;
    if (lastUpdated == null) return const SizedBox.shrink();

    final timeAgo = _getTimeAgo(lastUpdated);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.update_rounded,
            size: 14,
            color: AppTheme.textMuted,
          ),
          const SizedBox(width: 6),
          Text(
            'آخر تحديث: $timeAgo',
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrencySymbol(String code) {
    final symbols = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
      'CNY': '¥',
      'YER': '﷼',
      'SAR': 'ر.س',
      'AED': 'د.إ',
      'EGP': 'ج.م',
      'KWD': 'د.ك',
    };
    return symbols[code] ?? code.substring(0, 1);
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'منذ $months ${months == 1 ? 'شهر' : 'شهور'}';
    } else if (difference.inDays > 0) {
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