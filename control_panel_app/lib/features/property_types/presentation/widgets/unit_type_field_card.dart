import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/unit_type_field.dart';

class UnitTypeFieldCard extends StatefulWidget {
  final UnitTypeField field;
  final Duration animationDelay;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const UnitTypeFieldCard({
    super.key,
    required this.field,
    required this.animationDelay,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<UnitTypeFieldCard> createState() => _UnitTypeFieldCardState();
}

class _UnitTypeFieldCardState extends State<UnitTypeFieldCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isHovered = false;
  bool _isExpanded = false;

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

  String _getFieldTypeIcon(String fieldType) {
    final icons = {
      'text': '📝',
      'textarea': '📄',
      'number': '🔢',
      'currency': '💰',
      'boolean': '☑️',
      'select': '📋',
      'multiselect': '📋',
      'date': '📅',
      'email': '📧',
      'phone': '📞',
      'file': '📎',
      'image': '🖼️',
    };
    return icons[fieldType] ?? '📝';
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
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.darkCard.withOpacity(0.5),
              AppTheme.darkCard.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(
            color: _isHovered
                ? AppTheme.neonPurple.withOpacity(0.3)
                : AppTheme.darkBorder.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? AppTheme.neonPurple.withOpacity(0.2)
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
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      if (_isExpanded) ...[
                        const SizedBox(height: 12),
                        _buildDetails(),
                      ],
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

  Widget _buildHeader() {
    return Row(
      children: [
        // Field Type Icon
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.neonPurple.withOpacity(0.2),
                AppTheme.neonGreen.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppTheme.neonPurple.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              _getFieldTypeIcon(widget.field.fieldTypeId),
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Field Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.field.displayName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppTheme.textWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.field.isRequired) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.star,
                        size: 8,
                        color: AppTheme.error,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                widget.field.fieldName,
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
        // Tags
        _buildTags(),
        // Actions
        if (_isHovered) ...[
          const SizedBox(width: 8),
          _buildActions(),
        ],
        // Expand Icon
        Icon(
          _isExpanded ? Icons.expand_less : Icons.expand_more,
          color: AppTheme.textMuted,
          size: 20,
        ),
      ],
    );
  }

  Widget _buildTags() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.field.isSearchable)
          _buildTag(Icons.search, AppTheme.primaryBlue),
        if (widget.field.isPublic)
          _buildTag(Icons.public, AppTheme.success),
        if (widget.field.showInCards)
          _buildTag(Icons.credit_card, AppTheme.warning),
        if (widget.field.isPrimaryFilter)
          _buildTag(Icons.filter_alt, AppTheme.neonPurple),
      ],
    );
  }

  Widget _buildTag(IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        icon,
        size: 12,
        color: color,
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          icon: Icons.edit_rounded,
          color: AppTheme.primaryBlue,
          onTap: widget.onEdit,
        ),
        const SizedBox(width: 4),
        _buildActionButton(
          icon: Icons.delete_rounded,
          color: AppTheme.error,
          onTap: widget.onDelete,
        ),
      ],
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
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: color.withOpacity(0.3),
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

  Widget _buildDetails() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.field.description.isNotEmpty) ...[
            _buildDetailRow('الوصف', widget.field.description),
            const SizedBox(height: 8),
          ],
          _buildDetailRow('النوع', widget.field.fieldTypeId),
          const SizedBox(height: 8),
          _buildDetailRow('الفئة', widget.field.category.isEmpty ? 'عام' : widget.field.category),
          const SizedBox(height: 8),
          _buildDetailRow('الترتيب', widget.field.sortOrder.toString()),
          const SizedBox(height: 8),
          _buildDetailRow('الأولوية', widget.field.priority.toString()),
          if (widget.field.fieldOptions.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildDetailRow(
              'الخيارات',
              widget.field.fieldOptions.toString(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textLight,
            ),
          ),
        ),
      ],
    );
  }
}