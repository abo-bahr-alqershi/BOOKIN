import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/icon_helper.dart';
import '../../domain/entities/property_type.dart';

class PropertyTypeCard extends StatefulWidget {
  final PropertyType propertyType;
  final bool isSelected;
  final Duration animationDelay;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PropertyTypeCard({
    super.key,
    required this.propertyType,
    required this.isSelected,
    required this.animationDelay,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<PropertyTypeCard> createState() => _PropertyTypeCardState();
}

class _PropertyTypeCardState extends State<PropertyTypeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
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
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: _buildCard(),
          ),
        );
      },
    );
  }

  Widget _buildCard() {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          transform: Matrix4.identity()
            ..translate(0.0, _isPressed ? 2.0 : (_isHovered ? -2.0 : 0.0))
            ..scale(_isPressed ? 0.98 : 1.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.isSelected
                    ? [
                        AppTheme.primaryBlue.withOpacity(0.15),
                        AppTheme.primaryPurple.withOpacity(0.1),
                      ]
                    : [
                        AppTheme.darkCard.withOpacity(0.5),
                        AppTheme.darkCard.withOpacity(0.3),
                      ],
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              border: Border.all(
                color: widget.isSelected
                    ? AppTheme.primaryBlue.withOpacity(0.5)
                    : AppTheme.darkBorder.withOpacity(0.3),
                width: widget.isSelected ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.isSelected
                      ? AppTheme.primaryBlue.withOpacity(0.2)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: _isHovered ? 20 : 10,
                  offset: Offset(0, _isHovered ? 4 : 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Row(
                    children: [
                      // Icon
                      _buildIcon(),
                      const SizedBox(width: AppDimensions.spaceMedium),
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.propertyType.name,
                              style: AppTextStyles.heading3.copyWith(
                                color: widget.isSelected
                                    ? AppTheme.primaryBlue
                                    : AppTheme.textWhite,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.propertyType.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                widget.propertyType.description,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppTheme.textMuted,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            if (widget.propertyType.defaultAmenities.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  widget.propertyType.defaultAmenities,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Actions
                      _buildActions(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: widget.isSelected
            ? AppTheme.primaryGradient
            : LinearGradient(
                colors: [
                  AppTheme.darkSurface.withOpacity(0.5),
                  AppTheme.darkSurface.withOpacity(0.3),
                ],
              ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: widget.isSelected
            ? [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Icon(
        IconHelper.getIconData(widget.propertyType.icon),
        color: widget.isSelected ? Colors.white : AppTheme.primaryBlue,
        size: 24,
      ),
    );
  }

  Widget _buildActions() {
    return AnimatedOpacity(
      opacity: _isHovered ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionButton(
            icon: Icons.edit_rounded,
            color: AppTheme.primaryBlue,
            onTap: widget.onEdit,
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            icon: Icons.delete_rounded,
            color: AppTheme.error,
            onTap: widget.onDelete,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: color,
        ),
      ),
    );
  }
}