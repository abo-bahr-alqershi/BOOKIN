// lib/features/admin_availability_pricing/presentation/widgets/pricing_calendar_grid.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/pricing_rule.dart';
import '../../domain/entities/pricing.dart';

class PricingCalendarGrid extends StatefulWidget {
  final UnitPricing unitPricing;
  final DateTime currentDate;
  final bool isCompact;
  final Function(DateTime) onDateSelected;
  final Function(DateTime, DateTime) onDateRangeSelected;

  const PricingCalendarGrid({
    super.key,
    required this.unitPricing,
    required this.currentDate,
    required this.onDateSelected,
    required this.onDateRangeSelected,
    this.isCompact = false,
  });

  @override
  State<PricingCalendarGrid> createState() => _PricingCalendarGridState();
}

class _PricingCalendarGridState extends State<PricingCalendarGrid> {
  DateTime? _selectionStart;
  DateTime? _selectionEnd;
  bool _isSelecting = false;
  final NumberFormat _priceFormat = NumberFormat.currency(symbol: '');

  @override
  Widget build(BuildContext context) {
    final daysInMonth = _getDaysInMonth();
    final firstWeekday = _getFirstWeekday();
    
    return Padding(
      padding: EdgeInsets.all(widget.isCompact ? 8 : 16),
      child: Column(
        children: [
          _buildWeekdayHeaders(),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: 42,
              itemBuilder: (context, index) {
                return _buildDayCell(index, firstWeekday, daysInMonth);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    const weekdays = ['أحد', 'إثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت'];
    
    return Row(
      children: weekdays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDayCell(int index, int firstWeekday, int daysInMonth) {
    final dayNumber = index - firstWeekday + 1;
    
    if (dayNumber < 1 || dayNumber > daysInMonth) {
      return Container();
    }
    
    final date = DateTime(widget.currentDate.year, widget.currentDate.month, dayNumber);
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final dayPricing = widget.unitPricing.calendar[dateKey];
    
    final isSelected = _isDateInSelection(date);
    final isToday = _isToday(date);
    
    return GestureDetector(
      onTapDown: (_) => _startSelection(date),
      onTapUp: (_) => _endSelection(date),
      onTapCancel: _cancelSelection,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: !isSelected ? _getTierColor(dayPricing?.priceType).withOpacity(0.2) : null,
          borderRadius: BorderRadius.circular(widget.isCompact ? 8 : 10),
          border: Border.all(
            color: isToday 
                ? AppTheme.primaryBlue 
                : isSelected 
                    ? Colors.white.withOpacity(0.3)
                    : _getTierColor(dayPricing?.priceType).withOpacity(0.3),
            width: isToday ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Day number
            Positioned(
              top: widget.isCompact ? 2 : 4,
              left: widget.isCompact ? 4 : 6,
              child: Text(
                '$dayNumber',
                style: AppTextStyles.caption.copyWith(
                  color: isSelected 
                      ? Colors.white 
                      : AppTheme.textWhite,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                  fontSize: widget.isCompact ? 10 : 12,
                ),
              ),
            ),
            
            // Price
            if (dayPricing != null)
              Positioned(
                bottom: widget.isCompact ? 2 : 4,
                right: widget.isCompact ? 2 : 4,
                left: widget.isCompact ? 2 : 4,
                child: Text(
                  _priceFormat.format(dayPricing.price),
                  style: AppTextStyles.caption.copyWith(
                    color: isSelected 
                        ? Colors.white 
                        : _getTierColor(dayPricing.priceType),
                    fontWeight: FontWeight.w600,
                    fontSize: widget.isCompact ? 8 : 10,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            
            // Percentage change indicator
            if (dayPricing?.percentageChange != null && !widget.isCompact)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    color: dayPricing!.percentageChange! > 0 
                        ? AppTheme.success 
                        : AppTheme.error,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${dayPricing.percentageChange!.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getTierColor(PriceType? priceType) {
    if (priceType == null) return AppTheme.textMuted;
    
    switch (priceType) {
      case PriceType.base:
        return AppTheme.primaryBlue;
      case PriceType.weekend:
        return AppTheme.primaryPurple;
      case PriceType.seasonal:
        return AppTheme.warning;
      case PriceType.holiday:
        return AppTheme.error;
      case PriceType.specialEvent:
        return AppTheme.neonPurple;
      case PriceType.custom:
        return AppTheme.info;
    }
  }

  int _getDaysInMonth() {
    return DateTime(
      widget.currentDate.year,
      widget.currentDate.month + 1,
      0,
    ).day;
  }

  int _getFirstWeekday() {
    return DateTime(
      widget.currentDate.year,
      widget.currentDate.month,
      1,
    ).weekday % 7;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  bool _isDateInSelection(DateTime date) {
    if (_selectionStart == null) return false;
    if (_selectionEnd == null) return date == _selectionStart;
    
    return date.isAfter(_selectionStart!.subtract(const Duration(days: 1))) &&
           date.isBefore(_selectionEnd!.add(const Duration(days: 1)));
  }

  void _startSelection(DateTime date) {
    HapticFeedback.lightImpact();
    setState(() {
      _isSelecting = true;
      _selectionStart = date;
      _selectionEnd = null;
    });
  }

  void _endSelection(DateTime date) {
    if (!_isSelecting) return;
    
    setState(() {
      _isSelecting = false;
      if (_selectionStart != null) {
        if (date.isBefore(_selectionStart!)) {
          _selectionEnd = _selectionStart;
          _selectionStart = date;
        } else {
          _selectionEnd = date;
        }
        
        if (_selectionStart == _selectionEnd) {
          widget.onDateSelected(_selectionStart!);
        } else {
          widget.onDateRangeSelected(_selectionStart!, _selectionEnd!);
        }
      }
      _selectionStart = null;
      _selectionEnd = null;
    });
  }

  void _cancelSelection() {
    setState(() {
      _isSelecting = false;
      _selectionStart = null;
      _selectionEnd = null;
    });
  }
}