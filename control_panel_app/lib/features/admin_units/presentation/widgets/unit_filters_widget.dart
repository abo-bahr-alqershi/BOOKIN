// lib/features/admin_units/presentation/widgets/unit_filters_widget.dart

import 'package:bookn_cp_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _locationController = TextEditingController();
  final _latController = TextEditingController();
  final _lonController = TextEditingController();
  final _radiusController = TextEditingController();
  final _guestsController = TextEditingController();

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
    _locationController.dispose();
    _latController.dispose();
    _lonController.dispose();
    _radiusController.dispose();
    _guestsController.dispose();
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
      _locationController.clear();
      _latController.clear();
      _lonController.clear();
      _radiusController.clear();
      _guestsController.clear();
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
          height: double.infinity, // استخدام الارتفاع الكامل المتاح
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            // إضافة التمرير
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // عنوان الفلترات مع زر إعادة التعيين
                _buildHeader(),
                const SizedBox(height: 16),

                // محتوى الفلترات
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    // فلتر السعر
                    SizedBox(width: 280, child: _buildPriceRangeFilter()),

                    // فلتر حالة الوحدة
                    SizedBox(width: 220, child: _buildAvailabilityFilter()),

                    // فلتر طريقة التسعير
                    SizedBox(width: 280, child: _buildPricingMethodFilter()),

                    // فلتر التواريخ
                    SizedBox(width: 280, child: _buildDateRangeFilter()),

                    // فلتر عدد الضيوف
                    SizedBox(width: 180, child: _buildGuestsFilter()),

                    // فلتر الحجوزات النشطة
                    SizedBox(width: 220, child: _buildActiveBookingsFilter()),

                    // فلتر الموقع
                    SizedBox(width: 300, child: _buildLocationFilter()),

                    // فلتر الترتيب
                    SizedBox(width: 400, child: _buildSortFilter()),

                    // زر التطبيق
                    _buildApplyButton(),
                  ],
                ),

                // عرض الفلاتر النشطة
                if (_activeFiltersCount > 0) ...[
                  const SizedBox(height: 16),
                  _buildActiveFiltersChips(),
                ],

                const SizedBox(height: 16), // مساحة إضافية في الأسفل
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.filter_list_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'فلترة الوحدات',
                    style: AppTextStyles.displayMedium.copyWith(
                      color: AppTheme.textWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_activeFiltersCount > 0)
                    Text(
                      '$_activeFiltersCount فلتر نشط',
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.primaryBlue,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ],
          ),
          // زر إعادة تعيين
          if (_activeFiltersCount > 0) _buildResetButton(),
        ],
      ),
    );
  }

  Widget _buildResetButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _resetFilters,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.textMuted.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.refresh_rounded,
                color: AppTheme.textMuted,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                'إعادة تعيين',
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRangeFilter() {
    return _buildFilterContainer(
      label: 'نطاق السعر (ريال)',
      icon: Icons.monetization_on_rounded,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildPriceField(
                  'الحد الأدنى',
                  _minPriceController,
                  Icons.arrow_downward_rounded,
                  (value) => _updateFilter('minPrice', int.tryParse(value)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPriceField(
                  'الحد الأقصى',
                  _maxPriceController,
                  Icons.arrow_upward_rounded,
                  (value) => _updateFilter('maxPrice', int.tryParse(value)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // أزرار سريعة للأسعار
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickPriceChip('0-1000', 0, 1000),
                const SizedBox(width: 6),
                _buildQuickPriceChip('1000-5000', 1000, 5000),
                const SizedBox(width: 6),
                _buildQuickPriceChip('5000-10000', 5000, 10000),
                const SizedBox(width: 6),
                _buildQuickPriceChip('10000+', 10000, null),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceField(
    String hint,
    TextEditingController controller,
    IconData icon,
    Function(String) onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(icon,
                size: 14, color: AppTheme.primaryBlue.withValues(alpha: 0.6)),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.textWhite,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                suffixText: 'ر.س',
                suffixStyle: AppTextStyles.caption.copyWith(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.5),
                  fontSize: 11,
                ),
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
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
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          gradient: isActive ? AppTheme.primaryGradient : null,
          color: !isActive ? AppTheme.darkSurface.withValues(alpha: 0.2) : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? AppTheme.primaryBlue.withValues(alpha: 0.5)
                : AppTheme.darkBorder.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isActive
                ? Colors.white
                : AppTheme.textMuted.withValues(alpha: 0.7),
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildAvailabilityFilter() {
    return _buildFilterContainer(
      label: 'حالة التوفر',
      icon: Icons.check_circle_outline_rounded,
      child: Column(
        children: [
          _buildToggleOption(
            'متاحة',
            true,
            Icons.check_circle_rounded,
            AppTheme.success,
            _filters['isAvailable'] == true,
            () => _updateFilter(
                'isAvailable', _filters['isAvailable'] == true ? null : true),
          ),
          const SizedBox(height: 8),
          _buildToggleOption(
            'غير متاحة',
            false,
            Icons.cancel_rounded,
            AppTheme.error,
            _filters['isAvailable'] == false,
            () => _updateFilter(
                'isAvailable', _filters['isAvailable'] == false ? null : false),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption(
    String label,
    dynamic value,
    IconData icon,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.2),
                    color.withValues(alpha: 0.1),
                  ],
                )
              : null,
          color:
              !isSelected ? AppTheme.darkSurface.withValues(alpha: 0.2) : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.5)
                : AppTheme.darkBorder.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16, color: isSelected ? color : AppTheme.textMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? color : AppTheme.textMuted,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingMethodFilter() {
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

    return _buildFilterContainer(
      label: 'طريقة التسعير',
      icon: Icons.payments_rounded,
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: methods.map((method) {
          final isSelected = _filters['pricingMethod'] == method['value'];

          return GestureDetector(
            onTap: () => _updateFilter(
                'pricingMethod', isSelected ? null : method['value']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          (method['color'] as Color).withValues(alpha: 0.3),
                          (method['color'] as Color).withValues(alpha: 0.1),
                        ],
                      )
                    : null,
                color: !isSelected
                    ? AppTheme.darkSurface.withValues(alpha: 0.2)
                    : null,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? (method['color'] as Color).withValues(alpha: 0.5)
                      : AppTheme.darkBorder.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    method['icon'] as IconData,
                    size: 14,
                    color: isSelected
                        ? (method['color'] as Color)
                        : AppTheme.textMuted.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    method['label'] as String,
                    style: AppTextStyles.caption.copyWith(
                      color: isSelected
                          ? (method['color'] as Color)
                          : AppTheme.textMuted.withValues(alpha: 0.7),
                      fontSize: 11,
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
    );
  }

  Widget _buildDateRangeFilter() {
    DateTime? checkIn = _filters['checkInDate'];
    DateTime? checkOut = _filters['checkOutDate'];

    return _buildFilterContainer(
      label: 'فترة الإقامة',
      icon: Icons.calendar_month_rounded,
      child: Row(
        children: [
          Expanded(
            child: _buildDateButton(
              'تاريخ الوصول',
              checkIn,
              Icons.login_rounded,
              () => _pickDate('checkInDate', checkIn),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildDateButton(
              'تاريخ المغادرة',
              checkOut,
              Icons.logout_rounded,
              () => _pickDate('checkOutDate', checkOut),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton(
      String label, DateTime? value, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.darkSurface.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: value != null
                ? AppTheme.primaryBlue.withValues(alpha: 0.3)
                : AppTheme.darkBorder.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 14, color: AppTheme.primaryBlue.withValues(alpha: 0.6)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                value != null
                    ? '${value.day}/${value.month}/${value.year}'
                    : label,
                style: AppTextStyles.caption.copyWith(
                  color: value != null
                      ? AppTheme.textWhite
                      : AppTheme.textMuted.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(String key, DateTime? initial) async {
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
      _updateFilter(key, picked);
    }
  }

  Widget _buildGuestsFilter() {
    return _buildFilterContainer(
      label: 'عدد الضيوف',
      icon: Icons.group_rounded,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.darkSurface.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.darkBorder.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.person_rounded,
                  size: 14, color: AppTheme.primaryBlue.withValues(alpha: 0.6)),
            ),
            Expanded(
              child: TextField(
                controller: _guestsController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppTheme.textWhite,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: 'العدد',
                  hintStyle: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (v) =>
                    _updateFilter('numberOfGuests', int.tryParse(v)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveBookingsFilter() {
    return _buildFilterContainer(
      label: 'الحجوزات',
      icon: Icons.event_available_rounded,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<bool?>(
          value: _filters['hasActiveBookings'],
          isExpanded: true,
          dropdownColor: AppTheme.darkCard,
          icon: Icon(
            Icons.arrow_drop_down_rounded,
            color: AppTheme.primaryBlue.withValues(alpha: 0.7),
            size: 20,
          ),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppTheme.textWhite,
          ),
          hint: Text(
            'حالة الحجوزات',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppTheme.textMuted.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('جميع الوحدات'),
            ),
            DropdownMenuItem(
              value: true,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('مع حجوزات نشطة'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: false,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.textMuted,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('بدون حجوزات'),
                ],
              ),
            ),
          ],
          onChanged: (value) => _updateFilter('hasActiveBookings', value),
        ),
      ),
    );
  }

  Widget _buildLocationFilter() {
    return _buildFilterContainer(
      label: 'الموقع الجغرافي',
      icon: Icons.location_on_rounded,
      child: Column(
        children: [
          // حقل البحث بالموقع
          Container(
            decoration: BoxDecoration(
              color: AppTheme.darkSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.darkBorder.withValues(alpha: 0.2),
              ),
            ),
            child: TextField(
              controller: _locationController,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.textWhite,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: 'المدينة أو العنوان...',
                hintStyle: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 16,
                  color: AppTheme.textMuted.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (v) => _updateFilter('location', v.isEmpty ? null : v),
            ),
          ),
          const SizedBox(height: 8),
          // إحداثيات ونطاق البحث
          ExpansionTile(
            title: Text(
              'بحث متقدم بالإحداثيات',
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.primaryBlue.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
            tilePadding: EdgeInsets.zero,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildCoordinateField('Latitude', _latController,
                        (v) => _updateFilter('latitude', double.tryParse(v))),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildCoordinateField('Longitude', _lonController,
                        (v) => _updateFilter('longitude', double.tryParse(v))),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 80,
                    child: _buildCoordinateField('نطاق (كم)', _radiusController,
                        (v) => _updateFilter('radiusKm', double.tryParse(v))),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinateField(String label, TextEditingController controller,
      Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppTheme.textMuted.withValues(alpha: 0.6),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.darkSurface.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppTheme.darkBorder.withValues(alpha: 0.15),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textWhite,
              fontSize: 11,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 8),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSortFilter() {
    const options = {
      'popularity': {
        'label': 'الأكثر حجزاً',
        'icon': Icons.trending_up_rounded
      },
      'price_asc': {
        'label': 'السعر تصاعدي',
        'icon': Icons.arrow_upward_rounded
      },
      'price_desc': {
        'label': 'السعر تنازلي',
        'icon': Icons.arrow_downward_rounded
      },
      'name_asc': {'label': 'الاسم (أ-ي)', 'icon': Icons.sort_by_alpha_rounded},
      'name_desc': {
        'label': 'الاسم (ي-أ)',
        'icon': Icons.sort_by_alpha_rounded
      },
    };

    return _buildFilterContainer(
      label: 'الترتيب حسب',
      icon: Icons.sort_rounded,
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: options.entries.map((e) {
          final isSelected = _filters['sortBy'] == e.key;

          return GestureDetector(
            onTap: () => _updateFilter('sortBy', isSelected ? null : e.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.primaryGradient : null,
                color: !isSelected
                    ? AppTheme.darkSurface.withValues(alpha: 0.2)
                    : null,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryBlue.withValues(alpha: 0.5)
                      : AppTheme.darkBorder.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    e.value['icon'] as IconData,
                    size: 14,
                    color: isSelected
                        ? Colors.white
                        : AppTheme.textMuted.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    e.value['label'] as String,
                    style: AppTextStyles.caption.copyWith(
                      color: isSelected
                          ? Colors.white
                          : AppTheme.textMuted.withValues(alpha: 0.7),
                      fontSize: 11,
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
    );
  }

  // Container موحد للفلاتر مع label وicon
  Widget _buildFilterContainer({
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.5),
            AppTheme.darkCard.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with label and icon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withValues(alpha: 0.1),
                  AppTheme.primaryBlue.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: AppTheme.primaryBlue.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textWhite.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(8),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onFiltersChanged(_filters),
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.filter_list_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'تطبيق الفلاتر',
                  style: AppTextStyles.buttonSmall.copyWith(
                    color: Colors.white,
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
            label = 'وصول: ${(value as DateTime).day}/${value.month}';
            icon = Icons.login_rounded;
            color = AppTheme.primaryBlue;
            break;
          case 'checkOutDate':
            label = 'مغادرة: ${(value as DateTime).day}/${value.month}';
            icon = Icons.logout_rounded;
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
            label = _getSortLabel(value);
            icon = Icons.sort_rounded;
            color = AppTheme.primaryPurple;
            break;
        }

        if (label.isNotEmpty) {
          chips.add(
            Container(
              margin: const EdgeInsets.only(left: 6, bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.2),
                    color.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
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
                      fontSize: 11,
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

  String _getSortLabel(String value) {
    switch (value) {
      case 'popularity':
        return 'الأكثر حجزاً';
      case 'price_asc':
        return 'السعر تصاعدي';
      case 'price_desc':
        return 'السعر تنازلي';
      case 'name_asc':
        return 'الاسم (أ-ي)';
      case 'name_desc':
        return 'الاسم (ي-أ)';
      default:
        return value;
    }
  }
}
