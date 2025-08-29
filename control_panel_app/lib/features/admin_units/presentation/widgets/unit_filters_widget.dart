import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_dimensions.dart';

class UnitFiltersWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onFiltersChanged;

  const UnitFiltersWidget({
    super.key,
    required this.onFiltersChanged,
  });

  @override
  State<UnitFiltersWidget> createState() => _UnitFiltersWidgetState();
}

class _UnitFiltersWidgetState extends State<UnitFiltersWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  final Map<String, dynamic> _filters = {
    'propertyId': null,
    'unitTypeId': null,
    'isAvailable': null,
    'minPrice': null,
    'maxPrice': null,
    'pricingMethod': null,
  };

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _updateFilter(String key, dynamic value) {
    setState(() => _filters[key] = value);
    widget.onFiltersChanged(_filters);
  }

  void _resetFilters() {
    setState(() {
      _filters.forEach((key, value) {
        _filters[key] = null;
      });
    });
    widget.onFiltersChanged(_filters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.glassLight.withOpacity(0.05),
            AppTheme.glassDark.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              _buildHeader(),
              SizeTransition(
                sizeFactor: _expandAnimation,
                child: _buildFilters(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final activeFiltersCount = _filters.values.where((v) => v != null).length;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _toggleExpanded();
      },
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryBlue.withOpacity(0.05),
              AppTheme.primaryPurple.withOpacity(0.02),
            ],
          ),
        ),
        child: Row(
          children: [
            AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                Icons.filter_list,
                color: AppTheme.primaryBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: AppDimensions.spaceSmall),
            Text(
              'الفلاتر',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (activeFiltersCount > 0) ...[
              const SizedBox(width: AppDimensions.spaceSmall),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingSmall,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                ),
                child: Text(
                  activeFiltersCount.toString(),
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            const Spacer(),
            if (activeFiltersCount > 0)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _resetFilters();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingSmall,
                    vertical: AppDimensions.paddingXSmall,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.clear,
                        size: 14,
                        color: AppTheme.error,
                      ),
                      const SizedBox(width: AppDimensions.spaceXSmall),
                      Text(
                        'مسح',
                        style: AppTextStyles.caption.copyWith(
                          color: AppTheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: AppTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildPriceRangeFilter(),
              ),
              const SizedBox(width: AppDimensions.spaceMedium),
              Expanded(
                child: _buildAvailabilityFilter(),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceMedium),
          _buildPricingMethodFilter(),
        ],
      ),
    );
  }

  Widget _buildPriceRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نطاق السعر',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceSmall),
        Row(
          children: [
            Expanded(
              child: _buildNumberInput(
                'من',
                _filters['minPrice']?.toString() ?? '',
                (value) => _updateFilter('minPrice', int.tryParse(value)),
              ),
            ),
            const SizedBox(width: AppDimensions.spaceSmall),
            Expanded(
              child: _buildNumberInput(
                'إلى',
                _filters['maxPrice']?.toString() ?? '',
                (value) => _updateFilter('maxPrice', int.tryParse(value)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberInput(
    String placeholder,
    String value,
    Function(String) onChanged,
  ) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: TextField(
        controller: TextEditingController(text: value),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: AppTextStyles.bodySmall.copyWith(
          color: AppTheme.textWhite,
        ),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: AppTextStyles.caption.copyWith(
            color: AppTheme.textMuted.withOpacity(0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingSmall,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildAvailabilityFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الحالة',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceSmall),
        Row(
          children: [
            _buildToggleChip(
              'متاحة',
              _filters['isAvailable'] == true,
              () => _updateFilter('isAvailable', 
                  _filters['isAvailable'] == true ? null : true),
              color: AppTheme.success,
            ),
            const SizedBox(width: AppDimensions.spaceSmall),
            _buildToggleChip(
              'غير متاحة',
              _filters['isAvailable'] == false,
              () => _updateFilter('isAvailable',
                  _filters['isAvailable'] == false ? null : false),
              color: AppTheme.error,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPricingMethodFilter() {
    final methods = [
      {'value': 'Hourly', 'label': 'بالساعة', 'icon': '⏰'},
      {'value': 'Daily', 'label': 'يومي', 'icon': '📅'},
      {'value': 'Weekly', 'label': 'أسبوعي', 'icon': '📆'},
      {'value': 'Monthly', 'label': 'شهري', 'icon': '🗓️'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'طريقة التسعير',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceSmall),
        Wrap(
          spacing: AppDimensions.spaceSmall,
          runSpacing: AppDimensions.spaceSmall,
          children: methods.map((method) {
            final isSelected = _filters['pricingMethod'] == method['value'];
            return _buildToggleChip(
              '${method['icon']} ${method['label']}',
              isSelected,
              () => _updateFilter('pricingMethod',
                  isSelected ? null : method['value']),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildToggleChip(
    String label,
    bool isSelected,
    VoidCallback onTap, {
    Color? color,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingSmall,
          vertical: AppDimensions.paddingXSmall,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? (color != null
                  ? LinearGradient(
                      colors: [color, color.withOpacity(0.8)],
                    )
                  : AppTheme.primaryGradient)
              : null,
          color: isSelected ? null : AppTheme.darkCard.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          border: Border.all(
            color: isSelected
                ? (color ?? AppTheme.primaryBlue)
                : AppTheme.darkBorder.withOpacity(0.3),
            width: isSelected ? 1 : 0.5,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isSelected ? Colors.white : AppTheme.textMuted,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}