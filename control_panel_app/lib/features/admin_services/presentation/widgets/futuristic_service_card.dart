import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/service.dart';
import '../../domain/entities/pricing_model.dart';
import '../utils/service_icons.dart';

/// 🎴 Futuristic Service Card
class FuturisticServiceCard extends StatefulWidget {
  final Service service;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isSelected;

  const FuturisticServiceCard({
    super.key,
    required this.service,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.isSelected = false,
  });

  @override
  State<FuturisticServiceCard> createState() => _FuturisticServiceCardState();
}

class _FuturisticServiceCardState extends State<FuturisticServiceCard>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _floatController;
  late AnimationController _rotationController;
  late Animation<double> _glowAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _rotationAnimation;
  
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    _floatAnimation = Tween<double>(
      begin: -5,
      end: 5,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _glowController.dispose();
    _floatController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = ServiceIcons.getIconByName(widget.service.icon);
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap?.call();
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _glowAnimation,
            _floatAnimation,
            _rotationAnimation,
          ]),
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _isHovered ? _floatAnimation.value : 0),
              child: AnimatedScale(
                scale: _isPressed ? 0.95 : (_isHovered ? 1.02 : 1.0),
                duration: const Duration(milliseconds: 150),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(
                          widget.isSelected ? 0.3 : 0.1,
                        ),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: widget.isSelected ? 2 : 0,
                      ),
                      if (_isHovered)
                        BoxShadow(
                          color: AppTheme.neonBlue.withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 20,
                        sigmaY: 20,
                      ),
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
                            color: widget.isSelected
                                ? AppTheme.primaryBlue.withOpacity(0.5)
                                : AppTheme.darkBorder.withOpacity(0.3),
                            width: widget.isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Background Pattern
                            if (_isHovered)
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: _GridPatternPainter(
                                    rotation: _rotationAnimation.value,
                                    opacity: 0.05,
                                  ),
                                ),
                              ),
                            
                            // Content
                            Row(
                              children: [
                                // Icon Section
                                _buildIconSection(icon),
                                
                                const SizedBox(width: 20),
                                
                                // Info Section
                                Expanded(
                                  child: _buildInfoSection(),
                                ),
                                
                                // Price Section
                                _buildPriceSection(),
                                
                                // Actions
                                if (widget.onEdit != null || widget.onDelete != null)
                                  _buildActionsSection(),
                              ],
                            ),
                            
                            // Selection Indicator
                            if (widget.isSelected)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryBlue.withOpacity(0.5),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
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
          },
        ),
      ),
    );
  }

  Widget _buildIconSection(IconData icon) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryBlue.withOpacity(0.2),
                AppTheme.primaryPurple.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.primaryBlue.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(
                  0.2 * _glowAnimation.value,
                ),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Orbiting particle
              if (_isHovered)
                Transform.rotate(
                  angle: _rotationAnimation.value * 2,
                  child: Container(
                    width: 60,
                    height: 60,
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.neonBlue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.neonBlue,
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              
              // Icon
              Icon(
                icon,
                color: AppTheme.primaryBlue,
                size: 28,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.service.name,
          style: AppTextStyles.heading3.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppTheme.primaryBlue.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
              child: Text(
                widget.service.propertyName,
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Icons.${widget.service.icon}',
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.textMuted,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Text(
              '${widget.service.price.amount}',
              style: AppTextStyles.heading2.copyWith(
                color: AppTheme.success,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              widget.service.price.currency,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.success.withOpacity(0.7),
              ),
            ),
          ],
        ),
        Text(
          widget.service.pricingModel.label,
          style: AppTextStyles.caption.copyWith(
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildActionsSection() {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        color: AppTheme.textMuted,
      ),
      color: AppTheme.darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppTheme.darkBorder.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      onSelected: (value) {
        HapticFeedback.lightImpact();
        switch (value) {
          case 'edit':
            widget.onEdit?.call();
            break;
          case 'delete':
            widget.onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        if (widget.onEdit != null)
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_rounded, color: AppTheme.primaryBlue, size: 18),
                const SizedBox(width: 12),
                Text(
                  'تعديل',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textWhite,
                  ),
                ),
              ],
            ),
          ),
        if (widget.onDelete != null)
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_rounded, color: AppTheme.error, size: 18),
                const SizedBox(width: 12),
                Text(
                  'حذف',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.error,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// Grid Pattern Painter
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

    const spacing = 20.0;
    
    for (double x = -size.width; x < size.width * 2; x += spacing) {
      canvas.drawLine(
        Offset(x, -size.height),
        Offset(x, size.height * 2),
        paint,
      );
    }
    
    for (double y = -size.height; y < size.height * 2; y += spacing) {
      canvas.drawLine(
        Offset(-size.width, y),
        Offset(size.width * 2, y),
        paint,
      );
    }
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}