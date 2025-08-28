// lib/features/admin_properties/presentation/widgets/property_filters_widget.dart

import 'package:bookn_cp_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bookn_cp_app/core/theme/app_colors.dart';
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
  List<int> _selectedStarRatings = [];
  bool? _isApproved;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Property Type Filter
          Expanded(
            child: _buildPropertyTypeFilter(),
          ),
          const SizedBox(width: 12),
          
          // Price Range Filter
          Expanded(
            child: _buildPriceRangeFilter(),
          ),
          const SizedBox(width: 12),
          
          // Star Rating Filter
          Expanded(
            child: _buildStarRatingFilter(),
          ),
          const SizedBox(width: 12),
          
          // Status Filter
          Expanded(
            child: _buildStatusFilter(),
          ),
          const SizedBox(width: 12),
          
          // Apply Button
          _buildApplyButton(),
        ],
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
                  DropdownMenuItem(
                    value: null,
                    child: Text('الكل'),
                  ),
                  ...state.propertyTypes.map((type) {
                    return DropdownMenuItem(
                      value: type.id,
                      child: Text(type.name),
                    );
                  }).toList(),
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
              color: isSelected ? AppTheme.warning : AppTheme.textMuted.withValues(alpha: 0.3),
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
  
  Widget _buildApplyButton() {
    return GestureDetector(
      onTap: () {
        widget.onFilterChanged({
          'propertyTypeId': _selectedPropertyTypeId,
          'minPrice': _priceRange.start,
          'maxPrice': _priceRange.end,
          'starRatings': _selectedStarRatings,
          'isApproved': _isApproved,
        });
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