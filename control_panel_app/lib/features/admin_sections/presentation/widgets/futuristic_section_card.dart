import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/section.dart';
import 'section_status_badge.dart';

class FuturisticSectionCard extends StatefulWidget {
  final Section section;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleStatus;
  final bool isCompact;

  const FuturisticSectionCard({
    super.key,
    required this.section,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleStatus,
    this.isCompact = false,
  });

  @override
  State<FuturisticSectionCard> createState() => _FuturisticSectionCardState();
}

class _FuturisticSectionCardState extends State<FuturisticSectionCard>
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
        ..rotateZ(_isHovered ? 0.002 : 0),
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: () {
          HapticFeedback.mediumImpact();
          setState(() => _showActions = !_showActions);
        },
        onTapDown: (_) => _setHovered(true),
        onTapUp: (_) => _setHovered(false),
        onTapCancel: () => _setHovered(false),
        child: Container(
          margin: EdgeInsets.only(bottom: widget.isCompact ? 8 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.section.isActive
                    ? AppTheme.primaryBlue.withValues(alpha: 0.2)
                    : AppTheme.shadowDark.withValues(alpha: 0.1),
                blurRadius: widget.section.isActive ? 20 : 15,
                offset: const Offset(0, 8),
                spreadRadius: widget.section.isActive ? 2 : 0,
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
                    colors: widget.section.isActive
                        ? [
                            AppTheme.primaryBlue.withValues(alpha: 0.15),
                            AppTheme.primaryPurple.withValues(alpha: 0.1),
                          ]
                        : [
                            AppTheme.darkCard.withValues(alpha: 0.8),
                            AppTheme.darkCard.withValues(alpha: 0.6),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.section.isActive
                        ? AppTheme.primaryBlue.withValues(alpha: 0.5)
                        : AppTheme.darkBorder.withValues(alpha: 0.2),
                    width: widget.section.isActive ? 2 : 1,
                  ),
                ),
                child: widget.isCompact
                    ? _buildCompactContent()
                    : _buildFullContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullContent() {
    return IntrinsicHeight(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Flexible(
            child: _buildBody(),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildCompactContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildTypeIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.section.title ?? widget.section.name ?? 'قسم',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppTheme.textWhite,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SectionStatusBadge(
                      isActive: widget.section.isActive,
                      size: BadgeSize.small,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.section.type.apiValue,
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _buildCompactActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.3),
            AppTheme.darkCard.withValues(alpha: 0.1),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.darkBorder.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          _buildTypeIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.section.title ?? widget.section.name ?? 'قسم',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.section.subtitle != null)
                  Text(
                    widget.section.subtitle!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          SectionStatusBadge(
            isActive: widget.section.isActive,
            size: BadgeSize.medium,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInfoRow(
            icon: CupertinoIcons.layers_alt_fill,
            label: 'النوع',
            value: widget.section.type.apiValue,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: CupertinoIcons.square_stack_3d_up_fill,
            label: 'المحتوى',
            value: widget.section.contentType.apiValue,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: CupertinoIcons.eye_fill,
            label: 'العرض',
            value: widget.section.displayStyle.apiValue,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: CupertinoIcons.number,
            label: 'ترتيب العرض',
            value: widget.section.displayOrder.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.darkBorder.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          _buildActionButton(
            icon: CupertinoIcons.eye,
            label: 'عرض',
            onTap: widget.onTap,
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            icon: CupertinoIcons.pencil,
            label: 'تعديل',
            onTap: widget.onEdit,
            isPrimary: true,
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            icon: widget.section.isActive
                ? CupertinoIcons.pause_circle
                : CupertinoIcons.play_circle,
            label: widget.section.isActive ? 'إيقاف' : 'تفعيل',
            onTap: widget.onToggleStatus,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeIcon() {
    IconData iconData;
    Color iconColor;

    switch (widget.section.type) {
      case SectionTypeEnum.featured:
        iconData = CupertinoIcons.star_fill;
        iconColor = AppTheme.warning;
        break;
      case SectionTypeEnum.popular:
        iconData = CupertinoIcons.flame_fill;
        iconColor = AppTheme.error;
        break;
      case SectionTypeEnum.newArrivals:
        iconData = CupertinoIcons.sparkles;
        iconColor = AppTheme.success;
        break;
      case SectionTypeEnum.topRated:
        iconData = CupertinoIcons.chart_bar_alt_fill;
        iconColor = AppTheme.primaryPurple;
        break;
      case SectionTypeEnum.discounted:
        iconData = CupertinoIcons.tag_fill;
        iconColor = AppTheme.warning;
        break;
      case SectionTypeEnum.nearBy:
        iconData = CupertinoIcons.location_fill;
        iconColor = AppTheme.info;
        break;
      case SectionTypeEnum.recommended:
        iconData = CupertinoIcons.hand_thumbsup_fill;
        iconColor = AppTheme.primaryBlue;
        break;
      case SectionTypeEnum.category:
        iconData = CupertinoIcons.square_grid_2x2_fill;
        iconColor = AppTheme.primaryViolet;
        break;
      case SectionTypeEnum.custom:
        iconData = CupertinoIcons.wrench_fill;
        iconColor = AppTheme.textMuted;
        break;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            iconColor.withValues(alpha: 0.2),
            iconColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.textMuted,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppTheme.textMuted,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    bool isPrimary = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            gradient: isPrimary ? AppTheme.primaryGradient : null,
            color: isPrimary
                ? null
                : AppTheme.darkBackground.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            border: isPrimary
                ? null
                : Border.all(
                    color: AppTheme.darkBorder.withValues(alpha: 0.3),
                  ),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isPrimary ? Colors.white : AppTheme.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: isPrimary ? Colors.white : AppTheme.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCompactActionIcon(
          icon: CupertinoIcons.pencil,
          onTap: widget.onEdit,
          color: AppTheme.primaryBlue,
        ),
        const SizedBox(width: 8),
        _buildCompactActionIcon(
          icon: widget.section.isActive
              ? CupertinoIcons.pause_circle
              : CupertinoIcons.play_circle,
          onTap: widget.onToggleStatus,
          color: widget.section.isActive ? AppTheme.warning : AppTheme.success,
        ),
      ],
    );
  }

  Widget _buildCompactActionIcon({
    required IconData icon,
    VoidCallback? onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 14,
          color: color,
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
