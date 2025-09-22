// lib/features/admin_units/presentation/widgets/unit_filters_widget.dart

import 'package:bookn_cp_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:bookn_cp_app/core/theme/app_text_styles.dart';

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
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final Map<String, dynamic> _filters = {
    'propertyId': null,
    'unitTypeId': null,
    'isAvailable': null,
    'minPrice': null,
    'maxPrice': null,
    'pricingMethod': null,
    'checkInDate': null,
    'checkOutDate': null,
    'numberOfGuests': null,
    'hasActiveBookings': null,
    'location': null,
    'sortBy': null,
    'latitude': null,
    'longitude': null,
    'radiusKm': null,
  };

  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();

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

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _updateFilter(String key, dynamic value) {
    setState(() => _filters[key] = value);
    widget.onFiltersChanged(_filters);
    HapticFeedback.lightImpact();
  }

  void _resetFilters() {
    setState(() {
      _filters.forEach((key, value) {
        _filters[key] = null;
      });
      _minPriceController.clear();
      _maxPriceController.clear();
    });
    widget.onFiltersChanged(_filters);
    HapticFeedback.mediumImpact();
  }

  int get _activeFiltersCount => _filters.values.where((v) => v != null).length;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.darkCard.withOpacity(0.5),
                AppTheme.darkCard.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.primaryBlue.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildFiltersContent(),
                  if (_activeFiltersCount > 0) ...[
                    const SizedBox(height: 16),
                    _buildActiveFiltersChips(),
                  ],
                ],
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
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.filter_list_rounded,
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
                'فلاتر البحث',
                style: AppTextStyles.heading3.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_activeFiltersCount > 0)
                Text(
                  '$_activeFiltersCount فلتر نشط',
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.primaryBlue,
                  ),
                ),
            ],
          ),
        ),
        if (_activeFiltersCount > 0)
          GestureDetector(
            onTap: _resetFilters,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.error.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.clear_rounded, size: 14, color: AppTheme.error),
                  const SizedBox(width: 4),
                  Text(
                    'مسح الكل',
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFiltersContent() {
    return Column(
      children: [
        // Price Range
        Row(
          children: [
            Expanded(
              child: _buildPriceInput(
                'السعر الأدنى',
                _minPriceController,
                (value) => _updateFilter('minPrice', int.tryParse(value)),
                Icons.arrow_downward_rounded,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPriceInput(
                'السعر الأقصى',
                _maxPriceController,
                (value) => _updateFilter('maxPrice', int.tryParse(value)),
                Icons.arrow_upward_rounded,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Quick Price Ranges
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildQuickPriceChip('0-1000', 0, 1000),
              const SizedBox(width: 8),
              _buildQuickPriceChip('1000-5000', 1000, 5000),
              const SizedBox(width: 8),
              _buildQuickPriceChip('5000-10000', 5000, 10000),
              const SizedBox(width: 8),
              _buildQuickPriceChip('10000+', 10000, null),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Status Filters
        _buildStatusFilters(),

        const SizedBox(height: 20),

        // Pricing Method Filters
        _buildPricingMethodFilters(),

        const SizedBox(height: 20),

        // Availability by date + guests
        _buildAvailabilityWindowFilters(),

        const SizedBox(height: 20),

        // Geo filters
        _buildGeoFilters(),

        const SizedBox(height: 20),

        // Sort by
        _buildSortBy(),
      ],
    );
  }

  Widget _buildPriceInput(
    String label,
    TextEditingController controller,
    Function(String) onChanged,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppTheme.primaryBlue),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.darkSurface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.darkBorder.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
            ),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.textMuted.withOpacity(0.3),
              ),
              prefixText: 'ر.س ',
              prefixStyle: AppTextStyles.caption.copyWith(
                color: AppTheme.primaryBlue,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickPriceChip(String label, int? min, int? max) {
    final isActive = _filters['minPrice'] == min && _filters['maxPrice'] == max;

    return GestureDetector(
      onTap: () {
        setState(() {
          _filters['minPrice'] = min;
          _filters['maxPrice'] = max;
          _minPriceController.text = min?.toString() ?? '';
          _maxPriceController.text = max?.toString() ?? '';
        });
        widget.onFiltersChanged(_filters);
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive ? AppTheme.primaryGradient : null,
          color: !isActive ? AppTheme.darkSurface.withOpacity(0.3) : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppTheme.primaryBlue
                : AppTheme.darkBorder.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isActive ? Colors.white : AppTheme.textMuted,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'حالة الوحدة',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatusOption(
                'متاحة',
                true,
                Icons.check_circle_rounded,
                AppTheme.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatusOption(
                'غير متاحة',
                false,
                Icons.cancel_rounded,
                AppTheme.error,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusOption(
    String title,
    bool? value,
    IconData icon,
    Color color,
  ) {
    final isSelected = _filters['isAvailable'] == value;

    return GestureDetector(
      onTap: () {
        _updateFilter('isAvailable', isSelected ? null : value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    color.withOpacity(0.2),
                    color.withOpacity(0.1),
                  ],
                )
              : null,
          color: !isSelected ? AppTheme.darkSurface.withOpacity(0.3) : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color.withOpacity(0.5)
                : AppTheme.darkBorder.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppTheme.textMuted,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? color : AppTheme.textMuted,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingMethodFilters() {
    final methods = [
      {
        'value': 'Hourly',
        'label': 'بالساعة',
        'icon': Icons.hourglass_bottom_rounded,
        'color': AppTheme.warning
      },
      {
        'value': 'Daily',
        'label': 'يومي',
        'icon': Icons.today_rounded,
        'color': AppTheme.primaryBlue
      },
      {
        'value': 'Weekly',
        'label': 'أسبوعي',
        'icon': Icons.date_range_rounded,
        'color': AppTheme.primaryPurple
      },
      {
        'value': 'Monthly',
        'label': 'شهري',
        'icon': Icons.calendar_month_rounded,
        'color': AppTheme.success
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'طريقة التسعير',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: methods.map((method) {
            final isSelected = _filters['pricingMethod'] == method['value'];

            return GestureDetector(
              onTap: () {
                _updateFilter(
                    'pricingMethod', isSelected ? null : method['value']);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            (method['color'] as Color).withOpacity(0.3),
                            (method['color'] as Color).withOpacity(0.1),
                          ],
                        )
                      : null,
                  color: !isSelected
                      ? AppTheme.darkSurface.withOpacity(0.3)
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? (method['color'] as Color).withOpacity(0.5)
                        : AppTheme.darkBorder.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      method['icon'] as IconData,
                      size: 16,
                      color: isSelected
                          ? (method['color'] as Color)
                          : AppTheme.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      method['label'] as String,
                      style: AppTextStyles.caption.copyWith(
                        color: isSelected
                            ? (method['color'] as Color)
                            : AppTheme.textMuted,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAvailabilityWindowFilters() {
    DateTime? checkIn = _filters['checkInDate'];
    DateTime? checkOut = _filters['checkOutDate'];
    int? guests = _filters['numberOfGuests'];

    Future<void> pickDate(String key, DateTime? initial) async {
      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: initial ?? now,
        firstDate: DateTime(now.year - 2),
        lastDate: DateTime(now.year + 3),
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
              surface: AppTheme.darkCard,
              onSurface: AppTheme.textWhite,
            ),
          ),
          child: child!,
        ),
      );
      if (picked != null) {
        _updateFilter(key, DateTime(picked.year, picked.month, picked.day));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'فترة التوفر وعدد الضيوف',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateButton(
                label: 'من',
                value: checkIn,
                onTap: () => pickDate('checkInDate', checkIn),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateButton(
                label: 'إلى',
                value: checkOut,
                onTap: () => pickDate('checkOutDate', checkOut),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 130,
              child: _buildGuestsInput(
                label: 'الضيوف',
                value: guests,
                onChanged: (v) => _updateFilter('numberOfGuests', v),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.darkSurface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.darkBorder.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month_rounded,
                size: 16, color: AppTheme.primaryBlue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value != null ? value.toString().split(' ').first : label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color:
                      value != null ? AppTheme.textWhite : AppTheme.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestsInput({
    required String label,
    required int? value,
    required Function(int?) onChanged,
  }) {
    final controller = TextEditingController(text: value?.toString() ?? '');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.darkSurface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.darkBorder.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: AppTextStyles.bodyMedium.copyWith(color: AppTheme.textWhite),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            onChanged: (v) => onChanged(int.tryParse(v)),
          ),
        ),
      ],
    );
  }

  Widget _buildGeoFilters() {
    final latController =
        TextEditingController(text: _filters['latitude']?.toString() ?? '');
    final lonController =
        TextEditingController(text: _filters['longitude']?.toString() ?? '');
    final radiusController =
        TextEditingController(text: _filters['radiusKm']?.toString() ?? '');
    final locationController =
        TextEditingController(text: _filters['location']?.toString() ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الموقع الجغرافي',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextInput('المدينة/العنوان', locationController,
                  (v) => _updateFilter('location', v)),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 110,
              child: _buildTextInput('Latitude', latController,
                  (v) => _updateFilter('latitude', double.tryParse(v))),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 110,
              child: _buildTextInput('Longitude', lonController,
                  (v) => _updateFilter('longitude', double.tryParse(v))),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 110,
              child: _buildTextInput('نطاق (كم)', radiusController,
                  (v) => _updateFilter('radiusKm', double.tryParse(v))),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextInput(String label, TextEditingController controller,
      Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.darkSurface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.darkBorder.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            style: AppTextStyles.bodyMedium.copyWith(color: AppTheme.textWhite),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSortBy() {
    const options = {
      'popularity': 'الأكثر حجزاً',
      'price_asc': 'السعر تصاعدي',
      'price_desc': 'السعر تنازلي',
      'name_asc': 'الاسم تصاعدي',
      'name_desc': 'الاسم تنازلي',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الترتيب',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.entries.map((e) {
            final isSelected = _filters['sortBy'] == e.key;
            return GestureDetector(
              onTap: () => _updateFilter('sortBy', isSelected ? null : e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.primaryGradient : null,
                  color: !isSelected
                      ? AppTheme.darkSurface.withOpacity(0.3)
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryBlue
                        : AppTheme.darkBorder.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  e.value,
                  style: AppTextStyles.caption.copyWith(
                    color: isSelected ? Colors.white : AppTheme.textMuted,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getSortLabel(String key) {
    switch (key) {
      case 'popularity':
        return 'الأكثر حجزاً';
      case 'price_asc':
        return 'السعر تصاعدي';
      case 'price_desc':
        return 'السعر تنازلي';
      case 'name_asc':
        return 'الاسم تصاعدي';
      case 'name_desc':
        return 'الاسم تنازلي';
      default:
        return key;
    }
  }

  Widget _buildActiveFiltersChips() {
    List<Widget> chips = [];

    _filters.forEach((key, value) {
      if (value != null) {
        String label = '';
        IconData icon = Icons.filter_alt_rounded;
        Color color = AppTheme.primaryBlue;

        switch (key) {
          case 'minPrice':
            label = 'من: $value ر.س';
            icon = Icons.arrow_downward_rounded;
            color = AppTheme.success;
            break;
          case 'maxPrice':
            label = 'إلى: $value ر.س';
            icon = Icons.arrow_upward_rounded;
            color = AppTheme.success;
            break;
          case 'isAvailable':
            label = value ? 'متاحة' : 'غير متاحة';
            icon = value ? Icons.check_circle_rounded : Icons.cancel_rounded;
            color = value ? AppTheme.success : AppTheme.error;
            break;
          case 'pricingMethod':
            label = _getPricingMethodLabel(value);
            icon = Icons.schedule_rounded;
            color = AppTheme.primaryPurple;
            break;
          case 'checkInDate':
            label = 'من: ${value.toString().split('T').first}';
            icon = Icons.calendar_today_rounded;
            color = AppTheme.primaryBlue;
            break;
          case 'checkOutDate':
            label = 'إلى: ${value.toString().split('T').first}';
            icon = Icons.calendar_today_rounded;
            color = AppTheme.primaryBlue;
            break;
          case 'numberOfGuests':
            label = 'ضيوف: $value';
            icon = Icons.group_rounded;
            color = AppTheme.primaryBlue;
            break;
          case 'hasActiveBookings':
            label = value ? 'بحجوزات نشطة' : 'بدون حجوزات';
            icon = Icons.event_available_rounded;
            color = AppTheme.primaryPurple;
            break;
          case 'location':
            label = 'الموقع: $value';
            icon = Icons.place_rounded;
            color = AppTheme.warning;
            break;
          case 'radiusKm':
            label = 'نطاق: $valueكم';
            icon = Icons.radar_rounded;
            color = AppTheme.warning;
            break;
          case 'sortBy':
            label = 'ترتيب: ${_getSortLabel(value)}';
            icon = Icons.sort_rounded;
            color = AppTheme.primaryPurple;
            break;
        }

        if (label.isNotEmpty) {
          chips.add(
            Container(
              margin: const EdgeInsets.only(right: 8, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.2),
                    color.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 12, color: color),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => _updateFilter(key, null),
                    child: Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    });

    return Wrap(children: chips);
  }

  String _getPricingMethodLabel(String value) {
    switch (value) {
      case 'Hourly':
        return 'بالساعة';
      case 'Daily':
        return 'يومي';
      case 'Weekly':
        return 'أسبوعي';
      case 'Monthly':
        return 'شهري';
      default:
        return value;
    }
  }
}
