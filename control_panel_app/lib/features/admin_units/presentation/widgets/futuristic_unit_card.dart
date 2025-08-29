import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/unit.dart';

class FuturisticUnitCard extends StatefulWidget {
  final Unit unit;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isSelected;

  const FuturisticUnitCard({
    super.key,
    required this.unit,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.isSelected = false,
  });

  @override
  State<FuturisticUnitCard> createState() => _FuturisticUnitCardState();
}

class _FuturisticUnitCardState extends State<FuturisticUnitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                margin: const EdgeInsets.all(AppDimensions.paddingSmall),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: widget.isSelected || _isHovered
                              ? [
                                  AppTheme.primaryBlue.withOpacity(0.15),
                                  AppTheme.primaryPurple.withOpacity(0.1),
                                ]
                              : [
                                  AppTheme.glassLight.withOpacity(0.1),
                                  AppTheme.glassDark.withOpacity(0.05),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
                        border: Border.all(
                          color: widget.isSelected
                              ? AppTheme.primaryBlue.withOpacity(0.5)
                              : AppTheme.darkBorder.withOpacity(0.3),
                          width: widget.isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.isSelected || _isHovered
                                ? AppTheme.primaryBlue.withOpacity(0.2 + 0.1 * _glowAnimation.value)
                                : Colors.black.withOpacity(0.1),
                            blurRadius: 20 + 10 * _glowAnimation.value,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Background pattern
                          if (widget.isSelected || _isHovered)
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _PatternPainter(
                                  color: AppTheme.primaryBlue.withOpacity(0.05),
                                ),
                              ),
                            ),
                          
                          // Main content
                          Padding(
                            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeader(),
                                const SizedBox(height: AppDimensions.spaceMedium),
                                _buildImage(),
                                const SizedBox(height: AppDimensions.spaceMedium),
                                _buildDetails(),
                                const Spacer(),
                                _buildFooter(),
                              ],
                            ),
                          ),
                          
                          // Availability badge
                          Positioned(
                            top: AppDimensions.paddingMedium,
                            right: AppDimensions.paddingMedium,
                            child: _buildAvailabilityBadge(),
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
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
          child: Text(
            widget.unit.name,
            style: AppTextStyles.heading3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceXSmall),
        Row(
          children: [
            Icon(
              Icons.apartment,
              size: 14,
              color: AppTheme.textMuted,
            ),
            const SizedBox(width: AppDimensions.spaceXSmall),
            Expanded(
              child: Text(
                widget.unit.unitTypeName,
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImage() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withOpacity(0.1),
            AppTheme.primaryPurple.withOpacity(0.05),
          ],
        ),
      ),
      child: widget.unit.images?.isNotEmpty == true
          ? ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              child: Image.network(
                widget.unit.images!.first,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
              ),
            )
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Icon(
        Icons.home_work,
        size: 48,
        color: AppTheme.primaryBlue.withOpacity(0.3),
      ),
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Property name
        Row(
          children: [
            Icon(
              Icons.location_city,
              size: 14,
              color: AppTheme.textMuted,
            ),
            const SizedBox(width: AppDimensions.spaceXSmall),
            Expanded(
              child: Text(
                widget.unit.propertyName,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppTheme.textLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppDimensions.spaceSmall),
        
        // Capacity
        if (widget.unit.capacityDisplay.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingSmall,
              vertical: AppDimensions.paddingXSmall,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: Text(
              widget.unit.capacityDisplay,
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        // Price
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'السعر',
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
                Text(
                  widget.unit.basePrice.displayAmount,
                  style: AppTextStyles.heading3.copyWith(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingSmall,
                vertical: AppDimensions.paddingXSmall,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: Row(
                children: [
                  Text(
                    widget.unit.pricingMethod.icon,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: AppDimensions.spaceXSmall),
                  Text(
                    widget.unit.pricingMethod.arabicLabel,
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.primaryPurple,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppDimensions.spaceSmall),
        
        // Actions
        if (widget.onEdit != null || widget.onDelete != null)
          Row(
            children: [
              if (widget.onEdit != null)
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.edit,
                    label: 'تعديل',
                    onTap: widget.onEdit!,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              if (widget.onEdit != null && widget.onDelete != null)
                const SizedBox(width: AppDimensions.spaceSmall),
              if (widget.onDelete != null)
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.delete,
                    label: 'حذف',
                    onTap: widget.onDelete!,
                    color: AppTheme.error,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: AppDimensions.spaceXSmall),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSmall,
        vertical: AppDimensions.paddingXSmall,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.unit.isAvailable
              ? [AppTheme.success, AppTheme.success.withOpacity(0.8)]
              : [AppTheme.error, AppTheme.error.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        boxShadow: [
          BoxShadow(
            color: widget.unit.isAvailable
                ? AppTheme.success.withOpacity(0.3)
                : AppTheme.error.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        widget.unit.isAvailable ? 'متاحة' : 'غير متاحة',
        style: AppTextStyles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  final Color color;

  _PatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const spacing = 20.0;
    const radius = 1.5;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}