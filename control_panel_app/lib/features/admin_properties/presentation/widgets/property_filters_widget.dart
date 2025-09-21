// lib/features/admin_properties/presentation/widgets/property_filters_widget.dart

import 'package:bookn_cp_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bookn_cp_app/core/theme/app_text_styles.dart';
import '../bloc/property_types/property_types_bloc.dart';

class PropertyFiltersWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onFilterChanged;

  const PropertyFiltersWidget({
    super.key,
    required this.onFilterChanged,
  });

  @override
  State<PropertyFiltersWidget> createState() => _PropertyFiltersWidgetState();
}

class _PropertyFiltersWidgetState extends State<PropertyFiltersWidget> {
  String? _selectedPropertyTypeId;
  RangeValues _priceRange = const RangeValues(0, 1000);
  final List<int> _selectedStarRatings = [];
  bool? _isApproved;
  bool? _hasActiveBookings;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Search field (identity matching Bookings filters)
          SizedBox(width: 260, child: _buildSearchField()),
          // Property Type Filter
          SizedBox(width: 220, child: _buildPropertyTypeFilter()),

          // Price Range Filter
          SizedBox(width: 260, child: _buildPriceRangeFilter()),

          // Star Rating Filter
          SizedBox(width: 200, child: _buildStarRatingFilter()),

          // Status Filter
          SizedBox(width: 200, child: _buildStatusFilter()),

          // Active Bookings Filter
          SizedBox(width: 220, child: _buildHasActiveBookingsFilter()),

          // Apply Button
          _buildApplyButton(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.3),
            AppTheme.darkCard.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.2),
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppTheme.textWhite,
          fontSize: 13,
        ),
        decoration: InputDecoration(
          hintText: 'بحث بالاسم أو المدينة...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textMuted,
            fontSize: 13,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppTheme.textMuted,
            size: 18,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        onSubmitted: (_) => _applyFilters(),
      ),
    );
  }

  Widget _buildPropertyTypeFilter() {
    return BlocBuilder<PropertyTypesBloc, PropertyTypesState>(
      builder: (context, state) {
        if (state is PropertyTypesLoaded) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.darkCard.withValues(alpha: 0.5),
                  AppTheme.darkCard.withValues(alpha: 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppTheme.darkBorder.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPropertyTypeId,
                isExpanded: true,
                dropdownColor: AppTheme.darkCard,
                icon: Icon(
                  Icons.arrow_drop_down_rounded,
                  color: AppTheme.primaryBlue.withValues(alpha: 0.7),
                ),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppTheme.textWhite,
                ),
                hint: Text(
                  'نوع العقار',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.textMuted.withValues(alpha: 0.5),
                  ),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('الكل'),
                  ),
                  ...state.propertyTypes.map((type) {
                    return DropdownMenuItem(
                      value: type.id,
                      child: Text(type.name),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPropertyTypeId = value;
                  });
                },
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPriceRangeFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.5),
            AppTheme.darkCard.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'السعر: ${_priceRange.start.toInt()} - ${_priceRange.end.toInt()}',
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 1000,
            activeColor: AppTheme.primaryBlue,
            inactiveColor: AppTheme.darkBorder,
            onChanged: (values) {
              setState(() {
                _priceRange = values;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStarRatingFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.5),
            AppTheme.darkCard.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          final rating = index + 1;
          final isSelected = _selectedStarRatings.contains(rating);

          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedStarRatings.remove(rating);
                } else {
                  _selectedStarRatings.add(rating);
                }
              });
            },
            child: Icon(
              Icons.star_rounded,
              size: 16,
              color: isSelected
                  ? AppTheme.warning
                  : AppTheme.textMuted.withValues(alpha: 0.3),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.5),
            AppTheme.darkCard.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<bool?>(
          value: _isApproved,
          isExpanded: true,
          dropdownColor: AppTheme.darkCard,
          icon: Icon(
            Icons.arrow_drop_down_rounded,
            color: AppTheme.primaryBlue.withValues(alpha: 0.7),
          ),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppTheme.textWhite,
          ),
          hint: Text(
            'الحالة',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppTheme.textMuted.withValues(alpha: 0.5),
            ),
          ),
          items: const [
            DropdownMenuItem(
              value: null,
              child: Text('الكل'),
            ),
            DropdownMenuItem(
              value: true,
              child: Text('معتمد'),
            ),
            DropdownMenuItem(
              value: false,
              child: Text('قيد المراجعة'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _isApproved = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildHasActiveBookingsFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.5),
            AppTheme.darkCard.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<bool?>(
          value: _hasActiveBookings,
          isExpanded: true,
          dropdownColor: AppTheme.darkCard,
          icon: Icon(
            Icons.arrow_drop_down_rounded,
            color: AppTheme.primaryBlue.withValues(alpha: 0.7),
          ),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppTheme.textWhite,
          ),
          hint: Text(
            'حجوزات نشطة',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppTheme.textMuted.withValues(alpha: 0.5),
            ),
          ),
          items: const [
            DropdownMenuItem(
              value: null,
              child: Text('الكل'),
            ),
            DropdownMenuItem(
              value: true,
              child: Text('نعم'),
            ),
            DropdownMenuItem(
              value: false,
              child: Text('لا'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _hasActiveBookings = value;
            });
          },
        ),
      ),
    );
  }

  // Apply current filters (used by onSubmitted and Apply button)
  void _applyFilters() {
    widget.onFilterChanged({
      'searchTerm': _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
      'propertyTypeId': _selectedPropertyTypeId,
      'minPrice': _priceRange.start,
      'maxPrice': _priceRange.end,
      'starRatings': _selectedStarRatings,
      'isApproved': _isApproved,
      'hasActiveBookings': _hasActiveBookings,
    });
  }

  Widget _buildApplyButton() {
    return GestureDetector(
      onTap: () {
        _applyFilters();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'تطبيق',
          style: AppTextStyles.buttonSmall.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
