// lib/features/admin_properties/presentation/widgets/futuristic_property_table.dart

import 'package:bookn_cp_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:bookn_cp_app/core/theme/app_colors.dart';
import 'package:bookn_cp_app/core/theme/app_text_styles.dart';
import 'package:bookn_cp_app/core/theme/app_dimensions.dart';
import '../../domain/entities/property.dart';

class FuturisticPropertyTable extends StatefulWidget {
  final List<Property> properties;
  final Function(Property) onPropertyTap;
  final Function(String) onApprove;
  final Function(String) onReject;
  final Function(String) onDelete;
  
  const FuturisticPropertyTable({
    super.key,
    required this.properties,
    required this.onPropertyTap,
    required this.onApprove,
    required this.onReject,
    required this.onDelete,
  });
  
  @override
  State<FuturisticPropertyTable> createState() => _FuturisticPropertyTableState();
}

class _FuturisticPropertyTableState extends State<FuturisticPropertyTable>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  String? _sortColumn;
  bool _isAscending = true;
  String? _hoveredRowId;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkCard.withValues(alpha: 0.7),
              AppTheme.darkCard.withValues(alpha: 0.5),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryBlue.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              children: [
                // Table Header
                _buildTableHeader(),
                
                // Table Body
                Expanded(
                  child: _buildTableBody(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTableHeader() {
    final headers = [
      {'label': 'العقار', 'key': 'name', 'flex': 3},
      {'label': 'النوع', 'key': 'type', 'flex': 2},
      {'label': 'المدينة', 'key': 'city', 'flex': 2},
      {'label': 'التقييم', 'key': 'rating', 'flex': 1},
      {'label': 'الحالة', 'key': 'status', 'flex': 2},
      {'label': 'الإجراءات', 'key': 'actions', 'flex': 2},
    ];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withValues(alpha: 0.1),
            AppTheme.primaryPurple.withValues(alpha: 0.05),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: headers.map((header) {
          final isActionColumn = header['key'] == 'actions';
          return Expanded(
            flex: header['flex'] as int,
            child: isActionColumn
                ? Center(
                    child: Text(
                      header['label'] as String,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: () => _sort(header['key'] as String),
                    child: Row(
                      children: [
                        Text(
                          header['label'] as String,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppTheme.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_sortColumn == header['key'])
                          Icon(
                            _isAscending
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            size: 14,
                            color: AppTheme.primaryBlue,
                          ),
                      ],
                    ),
                  ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildTableBody() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: widget.properties.length,
      itemBuilder: (context, index) {
        final property = widget.properties[index];
        final isHovered = _hoveredRowId == property.id;
        
        return MouseRegion(
          onEnter: (_) => setState(() => _hoveredRowId = property.id),
          onExit: (_) => setState(() => _hoveredRowId = null),
          child: GestureDetector(
            onTap: () => widget.onPropertyTap(property),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: isHovered
                    ? LinearGradient(
                        colors: [
                          AppTheme.primaryBlue.withValues(alpha: 0.08),
                          AppTheme.primaryPurple.withValues(alpha: 0.04),
                        ],
                      )
                    : null,
                color: !isHovered
                    ? AppTheme.darkSurface.withValues(alpha: 0.3)
                    : null,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isHovered
                      ? AppTheme.primaryBlue.withValues(alpha: 0.3)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Property Name & Image
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: property.images.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    property.images.first.thumbnails.small,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.business_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.business_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                property.name,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppTheme.textWhite,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                property.address,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppTheme.textMuted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Type
                  Expanded(
                    flex: 2,
                    child: Text(
                      property.typeName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppTheme.textLight,
                      ),
                    ),
                  ),
                  
                  // City
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: AppTheme.primaryBlue.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          property.city,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Rating
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: AppTheme.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          property.starRating.toString(),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppTheme.textLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: property.isApproved
                              ? [
                                  AppTheme.success.withValues(alpha: 0.2),
                                  AppTheme.success.withValues(alpha: 0.1),
                                ]
                              : [
                                  AppTheme.warning.withValues(alpha: 0.2),
                                  AppTheme.warning.withValues(alpha: 0.1),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: property.isApproved
                              ? AppTheme.success.withValues(alpha: 0.5)
                              : AppTheme.warning.withValues(alpha: 0.5),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        property.isApproved ? 'معتمد' : 'قيد المراجعة',
                        style: AppTextStyles.caption.copyWith(
                          color: property.isApproved
                              ? AppTheme.success
                              : AppTheme.warning,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  
                  // Actions
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!property.isApproved) ...[
                          _buildActionButton(
                            icon: Icons.check_rounded,
                            color: AppTheme.success,
                            onTap: () => widget.onApprove(property.id),
                          ),
                          const SizedBox(width: 4),
                          _buildActionButton(
                            icon: Icons.close_rounded,
                            color: AppTheme.warning,
                            onTap: () => widget.onReject(property.id),
                          ),
                        ] else
                          _buildActionButton(
                            icon: Icons.edit_rounded,
                            color: AppTheme.primaryBlue,
                            onTap: () {
                              // Navigate to edit
                            },
                          ),
                        const SizedBox(width: 4),
                        _buildActionButton(
                          icon: Icons.delete_rounded,
                          color: AppTheme.error,
                          onTap: () => widget.onDelete(property.id),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 0.5,
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
  
  void _sort(String column) {
    setState(() {
      if (_sortColumn == column) {
        _isAscending = !_isAscending;
      } else {
        _sortColumn = column;
        _isAscending = true;
      }
      
      // TODO: Implement sorting logic
    });
  }
}