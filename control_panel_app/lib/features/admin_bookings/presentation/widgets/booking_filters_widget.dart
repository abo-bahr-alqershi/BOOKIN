// lib/features/admin_bookings/presentation/widgets/booking_filters_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../bloc/bookings_list/bookings_list_state.dart';

class BookingFiltersWidget extends StatefulWidget {
  final BookingFilters? initialFilters;
  final Function(BookingFilters) onFiltersChanged;

  const BookingFiltersWidget({
    super.key,
    this.initialFilters,
    required this.onFiltersChanged,
  });

  @override
  State<BookingFiltersWidget> createState() => _BookingFiltersWidgetState();
}

class _BookingFiltersWidgetState extends State<BookingFiltersWidget> {
  late BookingFilters _filters;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters ?? const BookingFilters();
    _searchController.text = _filters.guestNameOrEmail ?? '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDateRangeSelector(),
          const SizedBox(height: 12),
          _buildSearchAndStatusRow(),
          const SizedBox(height: 12),
          _buildQuickFilters(),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.2),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.calendar,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateButton(
                    label: 'من',
                    date: _filters.startDate,
                    onTap: () => _selectDate(true),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 20,
                  height: 1,
                  color: AppTheme.darkBorder.withOpacity(0.3),
                ),
                Expanded(
                  child: _buildDateButton(
                    label: 'إلى',
                    date: _filters.endDate,
                    onTap: () => _selectDate(false),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.darkBackground.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: date != null
                ? AppTheme.primaryBlue.withOpacity(0.3)
                : AppTheme.darkBorder.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date != null ? Formatters.formatDate(date) : 'اختر التاريخ',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color:
                        date != null ? AppTheme.textWhite : AppTheme.textMuted,
                    fontWeight: date != null ? FontWeight.w600 : null,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              CupertinoIcons.chevron_down,
              size: 14,
              color: AppTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndStatusRow() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildSearchField(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatusDropdown(),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.2),
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppTheme.textWhite,
        ),
        decoration: InputDecoration(
          hintText: 'بحث بالاسم أو البريد الإلكتروني...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textMuted,
          ),
          prefixIcon: Icon(
            CupertinoIcons.search,
            color: AppTheme.textMuted,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _filters = _filters.copyWith(guestNameOrEmail: value);
          });
          _applyFilters();
        },
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.2),
        ),
      ),
      child: DropdownButton<String?>(
        value: _filters.status,
        isExpanded: true,
        dropdownColor: AppTheme.darkCard,
        underline: const SizedBox.shrink(),
        hint: Text(
          'جميع الحالات',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textMuted,
          ),
        ),
        icon: Icon(
          CupertinoIcons.chevron_down,
          size: 16,
          color: AppTheme.textMuted,
        ),
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppTheme.textWhite,
        ),
        items: const [
          DropdownMenuItem(value: null, child: Text('جميع الحالات')),
          DropdownMenuItem(value: 'pending', child: Text('معلق')),
          DropdownMenuItem(value: 'confirmed', child: Text('مؤكد')),
          DropdownMenuItem(value: 'checkedIn', child: Text('تم الوصول')),
          DropdownMenuItem(value: 'completed', child: Text('مكتمل')),
          DropdownMenuItem(value: 'cancelled', child: Text('ملغى')),
        ],
        onChanged: (value) {
          setState(() {
            _filters = _filters.copyWith(status: value);
          });
          _applyFilters();
        },
      ),
    );
  }

  Widget _buildQuickFilters() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildQuickFilterChip(
            label: 'اليوم',
            isSelected: _isToday(),
            onTap: _selectToday,
          ),
          _buildQuickFilterChip(
            label: 'هذا الأسبوع',
            isSelected: _isThisWeek(),
            onTap: _selectThisWeek,
          ),
          _buildQuickFilterChip(
            label: 'هذا الشهر',
            isSelected: _isThisMonth(),
            onTap: _selectThisMonth,
          ),
          _buildQuickFilterChip(
            label: 'Walk-in فقط',
            isSelected: _filters.isWalkIn == true,
            onTap: () {
              setState(() {
                _filters = _filters.copyWith(
                  isWalkIn: _filters.isWalkIn == true ? null : true,
                );
              });
              _applyFilters();
            },
          ),
          _buildQuickFilterChip(
            label: 'مسح الفلاتر',
            isSelected: false,
            onTap: _clearFilters,
            isAction: true,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool isAction = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: isSelected ? AppTheme.primaryGradient : null,
              color: isSelected
                  ? null
                  : isAction
                      ? AppTheme.error.withOpacity(0.1)
                      : AppTheme.darkCard.withOpacity(0.3),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : isAction
                        ? AppTheme.error.withOpacity(0.3)
                        : AppTheme.darkBorder.withOpacity(0.2),
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: isSelected
                      ? Colors.white
                      : isAction
                          ? AppTheme.error
                          : AppTheme.textMuted,
                  fontWeight: isSelected ? FontWeight.w600 : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _selectDate(bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? _filters.startDate ?? DateTime.now()
          : _filters.endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
              surface: AppTheme.darkCard,
              onSurface: AppTheme.textWhite,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _filters = _filters.copyWith(startDate: picked);
        } else {
          _filters = _filters.copyWith(endDate: picked);
        }
      });
      _applyFilters();
    }
  }

  bool _isToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _filters.startDate == today &&
        _filters.endDate == today.add(const Duration(days: 1));
  }

  bool _isThisWeek() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    return _filters.startDate == weekStart && _filters.endDate == weekEnd;
  }

  bool _isThisMonth() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    return _filters.startDate == monthStart && _filters.endDate == monthEnd;
  }

  void _selectToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    setState(() {
      _filters = _filters.copyWith(
        startDate: today,
        endDate: today.add(const Duration(days: 1)),
      );
    });
    _applyFilters();
  }

  void _selectThisWeek() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    setState(() {
      _filters = _filters.copyWith(
        startDate: weekStart,
        endDate: weekEnd,
      );
    });
    _applyFilters();
  }

  void _selectThisMonth() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    setState(() {
      _filters = _filters.copyWith(
        startDate: monthStart,
        endDate: monthEnd,
      );
    });
    _applyFilters();
  }

  void _clearFilters() {
    setState(() {
      _filters = const BookingFilters();
      _searchController.clear();
    });
    _applyFilters();
  }

  void _applyFilters() {
    widget.onFiltersChanged(_filters);
  }
}
