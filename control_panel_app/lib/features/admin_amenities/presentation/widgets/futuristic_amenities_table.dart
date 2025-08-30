import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/amenity.dart';

class FuturisticAmenitiesTable extends StatefulWidget {
  final List<Amenity> amenities;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final Function(int) onPageChanged;
  final Function(Amenity) onEdit;
  final Function(Amenity) onDelete;
  final Function(Amenity) onToggleStatus;

  const FuturisticAmenitiesTable({
    super.key,
    required this.amenities,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
    required this.onPageChanged,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  State<FuturisticAmenitiesTable> createState() =>
      _FuturisticAmenitiesTableState();
}

class _FuturisticAmenitiesTableState extends State<FuturisticAmenitiesTable>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  int? _hoveredIndex;
  String _sortColumn = 'name';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _shimmerAnimation = Tween<double>(
      begin: -1,
      end: 2,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (widget.totalCount / widget.pageSize).ceil();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkCard.withOpacity(0.5),
            AppTheme.darkCard.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              // Table Header
              _buildTableHeader(),

              // Table Content
              Expanded(
                child: Scrollbar(
                  controller: _verticalScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _verticalScrollController,
                    child: Scrollbar(
                      controller: _horizontalScrollController,
                      thumbVisibility: true,
                      notificationPredicate: (notif) => notif.depth == 1,
                      child: SingleChildScrollView(
                        controller: _horizontalScrollController,
                        scrollDirection: Axis.horizontal,
                        child: _buildTable(),
                      ),
                    ),
                  ),
                ),
              ),

              // Pagination
              _buildPagination(totalPages),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkSurface.withOpacity(0.8),
            AppTheme.darkSurface.withOpacity(0.6),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryBlue.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.table_chart_rounded,
            color: AppTheme.primaryBlue,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'جدول المرافق',
            style: AppTextStyles.heading3.copyWith(
              color: AppTheme.textWhite,
            ),
          ),
          const Spacer(),
          Text(
            'إجمالي: ${widget.totalCount} مرفق',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTable() {
    return DataTable(
      columnSpacing: AppDimensions.paddingLarge,
      horizontalMargin: AppDimensions.paddingMedium,
      dataRowHeight: 70,
      headingRowHeight: 60,
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      headingRowColor: MaterialStateProperty.all(Colors.transparent),
      dataRowColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.hovered)) {
          return AppTheme.primaryBlue.withOpacity(0.05);
        }
        return Colors.transparent;
      }),
      columns: [
        _buildDataColumn('الأيقونة', '', sortable: false),
        _buildDataColumn('الاسم', 'name'),
        _buildDataColumn('الوصف', 'description'),
        _buildDataColumn('العقارات', 'properties'),
        _buildDataColumn('متوسط التكلفة', 'cost'),
        _buildDataColumn('الحالة', 'status'),
        _buildDataColumn('الإجراءات', '', sortable: false),
      ],
      rows: widget.amenities.asMap().entries.map((entry) {
        final index = entry.key;
        final amenity = entry.value;
        return _buildDataRow(amenity, index);
      }).toList(),
    );
  }

  DataColumn _buildDataColumn(String label, String field, {bool sortable = true}) {
    final isSorted = _sortColumn == field;
    
    return DataColumn(
      label: GestureDetector(
        onTap: sortable && field.isNotEmpty
            ? () {
                setState(() {
                  if (_sortColumn == field) {
                    _sortAscending = !_sortAscending;
                  } else {
                    _sortColumn = field;
                    _sortAscending = true;
                  }
                });
                // TODO: Implement sorting
              }
            : null,
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (context, child) {
                return ShaderMask(
                  shaderCallback: (bounds) {
                    if (isSorted) {
                      return LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryBlue,
                          AppTheme.primaryPurple,
                        ],
                        transform: GradientRotation(_shimmerAnimation.value),
                      ).createShader(bounds);
                    }
                    return LinearGradient(
                      colors: [AppTheme.textWhite, AppTheme.textWhite],
                    ).createShader(bounds);
                  },
                  child: Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: isSorted ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
            if (sortable && field.isNotEmpty) ...[
              const SizedBox(width: 4),
              Icon(
                isSorted
                    ? (_sortAscending
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded)
                    : Icons.unfold_more_rounded,
                size: 16,
                color: isSorted ? AppTheme.primaryBlue : AppTheme.textMuted.withOpacity(0.3),
              ),
            ],
          ],
        ),
      ),
    );
  }

  DataRow _buildDataRow(Amenity amenity, int index) {
    final isHovered = _hoveredIndex == index;
    
    return DataRow(
      onSelectChanged: (_) => widget.onEdit(amenity),
      cells: [
        // Icon Cell
        DataCell(
          MouseRegion(
            onEnter: (_) => setState(() => _hoveredIndex = index),
            onExit: (_) => setState(() => _hoveredIndex = null),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: isHovered 
                    ? AppTheme.primaryGradient
                    : LinearGradient(
                        colors: [
                          AppTheme.primaryBlue.withOpacity(0.2),
                          AppTheme.primaryPurple.withOpacity(0.1),
                        ],
                      ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: isHovered
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                _getIconData(amenity.icon),
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        
        // Name Cell
        DataCell(
          Text(
            amenity.name,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        // Description Cell
        DataCell(
          Container(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Text(
              amenity.description,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.textMuted,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        
        // Properties Count Cell
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primaryBlue.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.home_rounded,
                  size: 14,
                  color: AppTheme.primaryBlue,
                ),
                const SizedBox(width: 4),
                Text(
                  '${amenity.propertiesCount ?? 0}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Average Cost Cell
        DataCell(
          amenity.averageExtraCost != null && amenity.averageExtraCost! > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.success.withOpacity(0.2),
                        AppTheme.success.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '\$${amenity.averageExtraCost!.toStringAsFixed(0)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppTheme.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : Text(
                  'مجاني',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
        ),
        
        // Status Cell
        DataCell(
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onToggleStatus(amenity);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: amenity.isActive == true
                      ? [
                          AppTheme.success.withOpacity(0.2),
                          AppTheme.success.withOpacity(0.1),
                        ]
                      : [
                          AppTheme.textMuted.withOpacity(0.2),
                          AppTheme.textMuted.withOpacity(0.1),
                        ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: amenity.isActive == true
                      ? AppTheme.success.withOpacity(0.5)
                      : AppTheme.textMuted.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: amenity.isActive == true
                          ? AppTheme.success
                          : AppTheme.textMuted,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    amenity.isActive == true ? 'نشط' : 'غير نشط',
                    style: AppTextStyles.caption.copyWith(
                      color: amenity.isActive == true
                          ? AppTheme.success
                          : AppTheme.textMuted,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Actions Cell
        DataCell(
          Row(
            children: [
              _buildActionButton(
                Icons.edit_rounded,
                AppTheme.primaryBlue,
                () => widget.onEdit(amenity),
                'تعديل',
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                Icons.delete_rounded,
                AppTheme.error,
                () => widget.onDelete(amenity),
                'حذف',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    Color color,
    VoidCallback onTap,
    String tooltip,
  ) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
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
            color: color,
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPagination(int totalPages) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkSurface.withOpacity(0.6),
            AppTheme.darkSurface.withOpacity(0.4),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: AppTheme.primaryBlue.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous Button
          _buildPaginationButton(
            Icons.chevron_left_rounded,
            widget.currentPage > 1,
            () => widget.onPageChanged(widget.currentPage - 1),
          ),
          
          const SizedBox(width: AppDimensions.paddingSmall),
          
          // Page Numbers
          ..._buildPageNumbers(totalPages),
          
          const SizedBox(width: AppDimensions.paddingSmall),
          
          // Next Button
          _buildPaginationButton(
            Icons.chevron_right_rounded,
            widget.currentPage < totalPages,
            () => widget.onPageChanged(widget.currentPage + 1),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers(int totalPages) {
    List<Widget> pages = [];
    int startPage = 1;
    int endPage = totalPages;

    if (totalPages > 7) {
      if (widget.currentPage <= 4) {
        endPage = 5;
      } else if (widget.currentPage >= totalPages - 3) {
        startPage = totalPages - 4;
      } else {
        startPage = widget.currentPage - 2;
        endPage = widget.currentPage + 2;
      }
    }

    for (int i = startPage; i <= endPage; i++) {
      pages.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: _buildPageNumber(i, i == widget.currentPage),
        ),
      );
    }

    if (startPage > 1) {
      pages.insert(
        0,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            '...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ),
      );
      pages.insert(
        0,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: _buildPageNumber(1, false),
        ),
      );
    }

    if (endPage < totalPages) {
      pages.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            '...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ),
      );
      pages.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: _buildPageNumber(totalPages, false),
        ),
      );
    }

    return pages;
  }

  Widget _buildPageNumber(int page, bool isActive) {
    return GestureDetector(
      onTap: !isActive ? () => widget.onPageChanged(page) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: isActive ? AppTheme.primaryGradient : null,
          color: !isActive ? AppTheme.darkCard.withOpacity(0.5) : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? AppTheme.primaryBlue.withOpacity(0.5)
                : AppTheme.darkBorder.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            page.toString(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: isActive ? Colors.white : AppTheme.textMuted,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationButton(IconData icon, bool enabled, VoidCallback onTap) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled
              ? AppTheme.darkCard.withOpacity(0.5)
              : AppTheme.darkCard.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled
                ? AppTheme.primaryBlue.withOpacity(0.3)
                : AppTheme.darkBorder.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: enabled ? AppTheme.primaryBlue : AppTheme.textMuted.withOpacity(0.3),
          size: 18,
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    final iconMap = {
      'wifi': Icons.wifi_rounded,
      'parking': Icons.local_parking_rounded,
      'pool': Icons.pool_rounded,
      'gym': Icons.fitness_center_rounded,
      'restaurant': Icons.restaurant_rounded,
      'spa': Icons.spa_rounded,
      'laundry': Icons.local_laundry_service_rounded,
      'ac': Icons.ac_unit_rounded,
      'tv': Icons.tv_rounded,
      'kitchen': Icons.kitchen_rounded,
      'elevator': Icons.elevator_rounded,
      'safe': Icons.lock_rounded,
      'minibar': Icons.local_bar_rounded,
      'balcony': Icons.balcony_rounded,
      'view': Icons.landscape_rounded,
      'pet': Icons.pets_rounded,
      'smoking': Icons.smoking_rooms_rounded,
      'wheelchair': Icons.accessible_rounded,
      'breakfast': Icons.free_breakfast_rounded,
      'airport': Icons.airport_shuttle_rounded,
    };
    
    return iconMap[iconName] ?? Icons.star_rounded;
  }
}