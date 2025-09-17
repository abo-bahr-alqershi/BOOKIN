// lib/features/admin_cities/presentation/widgets/futuristic_city_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import '../../domain/entities/city.dart';

class FuturisticCityCard extends StatefulWidget {
  final City city;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isCompact;

  const FuturisticCityCard({
    super.key,
    required this.city,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.isCompact = false,
  });

  @override
  State<FuturisticCityCard> createState() => _FuturisticCityCardState();
}

class _FuturisticCityCardState extends State<FuturisticCityCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isHovered = false;
  bool _showActions = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.identity()
        ..scale(_isHovered ? 0.98 : 1.0)
        ..rotateZ(_isHovered ? 0.005 : 0),
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: () {
          HapticFeedback.mediumImpact();
          setState(() => _showActions = !_showActions);
        },
        onTapDown: (_) => _setHovered(true),
        onTapUp: (_) => _setHovered(false),
        onTapCancel: () => _setHovered(false),
        child: Stack(
          children: [
            Container(
              height: widget.isCompact ? 120 : 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowDark.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
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
                          AppTheme.darkCard.withValues(alpha: 0.9),
                          AppTheme.darkCard.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: widget.city.isActive == true
                            ? AppTheme.success.withValues(alpha: 0.3)
                            : AppTheme.darkBorder.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: widget.isCompact
                        ? _buildCompactContent()
                        : _buildFullContent(),
                  ),
                ),
              ),
            ),
            if (_showActions) _buildActionsOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildFullContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image section with gradient overlay
        Expanded(
          flex: 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (widget.city.images.isNotEmpty)
                CachedImageWidget(
                  imageUrl: widget.city.images.first,
                  fit: BoxFit.cover,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppTheme.darkBackground.withValues(alpha: 0.8),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryBlue.withValues(alpha: 0.3),
                        AppTheme.primaryPurple.withValues(alpha: 0.2),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      CupertinoIcons.photo,
                      size: 40,
                      color: AppTheme.textMuted.withValues(alpha: 0.5),
                    ),
                  ),
                ),

              // Status badge
              Positioned(
                top: 12,
                right: 12,
                child: _buildStatusBadge(),
              ),

              // Image count badge
              if (widget.city.images.length > 1)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: _buildImageCountBadge(),
                ),
            ],
          ),
        ),

        // Content section
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.city.name,
                      style: AppTextStyles.heading3.copyWith(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.location_solid,
                          size: 12,
                          color: AppTheme.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.city.country,
                          style: AppTextStyles.caption.copyWith(
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (widget.city.propertiesCount != null)
                  _buildPropertiesCount(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactContent() {
    return Row(
      children: [
        // Compact image
        Container(
          width: 100,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            gradient: widget.city.images.isEmpty
                ? LinearGradient(
                    colors: [
                      AppTheme.primaryBlue.withValues(alpha: 0.3),
                      AppTheme.primaryPurple.withValues(alpha: 0.2),
                    ],
                  )
                : null,
          ),
          child: widget.city.images.isNotEmpty
              ? ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: CachedImageWidget(
                    imageUrl: widget.city.images.first,
                    fit: BoxFit.cover,
                  ),
                )
              : Center(
                  child: Icon(
                    CupertinoIcons.building_2_fill,
                    size: 30,
                    color: AppTheme.textMuted.withValues(alpha: 0.5),
                  ),
                ),
        ),

        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.city.name,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppTheme.textWhite,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(isSmall: true),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.location,
                      size: 14,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.city.country,
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const Spacer(),
                    if (widget.city.propertiesCount != null)
                      _buildPropertiesCount(isCompact: true),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge({bool isSmall = false}) {
    final isActive = widget.city.isActive == true;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? [
                  AppTheme.success.withValues(alpha: 0.8),
                  AppTheme.success.withValues(alpha: 0.6),
                ]
              : [
                  AppTheme.textMuted.withValues(alpha: 0.6),
                  AppTheme.textMuted.withValues(alpha: 0.4),
                ],
        ),
        borderRadius: BorderRadius.circular(isSmall ? 8 : 12),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? AppTheme.success.withValues(alpha: 0.3)
                : Colors.transparent,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isSmall ? 6 : 8,
            height: isSmall ? 6 : 8,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          SizedBox(width: isSmall ? 4 : 6),
          Text(
            isActive ? 'نشط' : 'غير نشط',
            style: (isSmall ? AppTextStyles.caption : AppTextStyles.bodySmall)
                .copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: isSmall ? 10 : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCountBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.photo_fill,
            size: 12,
            color: AppTheme.textLight,
          ),
          const SizedBox(width: 4),
          Text(
            '${widget.city.images.length}',
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesCount({bool isCompact = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withValues(alpha: 0.1),
            AppTheme.primaryPurple.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(isCompact ? 8 : 10),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.house_fill,
            size: isCompact ? 10 : 12,
            color: AppTheme.primaryBlue,
          ),
          SizedBox(width: isCompact ? 3 : 4),
          Text(
            '${widget.city.propertiesCount ?? 0}',
            style: (isCompact ? AppTextStyles.caption : AppTextStyles.bodySmall)
                .copyWith(
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: isCompact ? 10 : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsOverlay() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionButton(
              icon: CupertinoIcons.pencil,
              label: 'تعديل',
              onTap: () {
                setState(() => _showActions = false);
                widget.onEdit?.call();
              },
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(width: 16),
            _buildActionButton(
              icon: CupertinoIcons.trash,
              label: 'حذف',
              onTap: () {
                setState(() => _showActions = false);
                widget.onDelete?.call();
              },
              color: AppTheme.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
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
      ),
    );
  }

  void _setHovered(bool value) {
    setState(() => _isHovered = value);
    if (value) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }
}
