// lib/features/admin_bookings/presentation/widgets/futuristic_bookings_table.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/booking.dart';
import 'booking_status_badge.dart';

class FuturisticBookingsTable extends StatefulWidget {
  final List<Booking> bookings;
  final List<Booking> selectedBookings;
  final Function(String) onBookingTap;
  final Function(List<Booking>) onSelectionChanged;
  final bool showActions;

  const FuturisticBookingsTable({
    super.key,
    required this.bookings,
    required this.selectedBookings,
    required this.onBookingTap,
    required this.onSelectionChanged,
    this.showActions = true,
  });

  @override
  State<FuturisticBookingsTable> createState() =>
      _FuturisticBookingsTableState();
}

class _FuturisticBookingsTableState extends State<FuturisticBookingsTable> {
  bool _selectAll = false;
  int? _hoveredIndex;
  String _sortColumn = 'date';
  bool _sortAscending = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.2),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              _buildHeader(),
              _buildTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.darkBorder.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'قائمة الحجوزات',
            style: AppTextStyles.heading3.copyWith(
              color: AppTheme.textWhite,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${widget.bookings.length}',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          _buildSortDropdown(),
        ],
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.sort_down,
            size: 16,
            color: AppTheme.textMuted,
          ),
          const SizedBox(width: 6),
          Text(
            'ترتيب حسب',
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _sortColumn,
            dropdownColor: AppTheme.darkCard,
            underline: const SizedBox.shrink(),
            icon: Icon(
              CupertinoIcons.chevron_down,
              size: 14,
              color: AppTheme.primaryBlue,
            ),
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.primaryBlue,
            ),
            items: const [
              DropdownMenuItem(value: 'date', child: Text('التاريخ')),
              DropdownMenuItem(value: 'status', child: Text('الحالة')),
              DropdownMenuItem(value: 'price', child: Text('السعر')),
              DropdownMenuItem(value: 'name', child: Text('الاسم')),
            ],
            onChanged: (value) {
              setState(() {
                _sortColumn = value!;
                _sortBookings();
              });
            },
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _sortAscending = !_sortAscending;
                _sortBookings();
              });
            },
            icon: Icon(
              _sortAscending
                  ? CupertinoIcons.arrow_up
                  : CupertinoIcons.arrow_down,
              size: 16,
              color: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: MediaQuery.of(context).size.width > 1200
            ? MediaQuery.of(context).size.width - 32
            : 1200,
        child: Column(
          children: [
            _buildTableHeader(),
            ...widget.bookings.asMap().entries.map((entry) {
              return _buildTableRow(entry.key, entry.value);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.darkBorder.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Checkbox(
              value: _selectAll,
              onChanged: (value) {
                setState(() {
                  _selectAll = value!;
                  if (_selectAll) {
                    widget.onSelectionChanged(widget.bookings);
                  } else {
                    widget.onSelectionChanged([]);
                  }
                });
              },
              activeColor: AppTheme.primaryBlue,
              checkColor: Colors.white,
            ),
          ),
          _buildHeaderCell('رقم الحجز', 120),
          _buildHeaderCell('الضيف', 150),
          _buildHeaderCell('الوحدة', 150),
          _buildHeaderCell('تاريخ الوصول', 120),
          _buildHeaderCell('تاريخ المغادرة', 120),
          _buildHeaderCell('الحالة', 100),
          _buildHeaderCell('السعر', 120),
          _buildHeaderCell('طريقة الدفع', 120),
          if (widget.showActions) _buildHeaderCell('الإجراءات', 150),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, double width) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: AppTheme.textMuted,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTableRow(int index, Booking booking) {
    final isSelected = widget.selectedBookings.contains(booking);
    final isHovered = _hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: GestureDetector(
        onTap: () => widget.onBookingTap(booking.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isHovered
                ? AppTheme.primaryBlue.withOpacity(0.05)
                : isSelected
                    ? AppTheme.primaryBlue.withOpacity(0.02)
                    : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: AppTheme.darkBorder.withOpacity(0.05),
              ),
              left: BorderSide(
                color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    final updatedSelection = [...widget.selectedBookings];
                    if (value!) {
                      updatedSelection.add(booking);
                    } else {
                      updatedSelection.remove(booking);
                    }
                    widget.onSelectionChanged(updatedSelection);
                  },
                  activeColor: AppTheme.primaryBlue,
                  checkColor: Colors.white,
                ),
              ),
              _buildCell(
                '#${booking.id.substring(0, 8)}',
                120,
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              _buildCell(booking.userName, 150),
              _buildCell(booking.unitName, 150),
              _buildCell(Formatters.formatDate(booking.checkIn), 120),
              _buildCell(Formatters.formatDate(booking.checkOut), 120),
              SizedBox(
                width: 100,
                child: BookingStatusBadge(
                  status: booking.status,
                  size: BadgeSize.small,
                ),
              ),
              _buildCell(
                booking.totalPrice.formattedAmount,
                120,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildCell(booking.paymentStatus ?? 'نقداً', 120),
              if (widget.showActions)
                SizedBox(
                  width: 150,
                  child: _buildActions(booking),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCell(String text, double width, {TextStyle? style}) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: style ??
            AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildActions(Booking booking) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionIcon(
          icon: CupertinoIcons.eye,
          onTap: () => widget.onBookingTap(booking.id),
          tooltip: 'عرض',
        ),
        if (booking.canCheckIn)
          _buildActionIcon(
            icon: CupertinoIcons.arrow_down_circle,
            onTap: () {},
            tooltip: 'تسجيل وصول',
            color: AppTheme.success,
          ),
        if (booking.canCheckOut)
          _buildActionIcon(
            icon: CupertinoIcons.arrow_up_circle,
            onTap: () {},
            tooltip: 'تسجيل مغادرة',
            color: AppTheme.warning,
          ),
        if (booking.canCancel)
          _buildActionIcon(
            icon: CupertinoIcons.xmark_circle,
            onTap: () {},
            tooltip: 'إلغاء',
            color: AppTheme.error,
          ),
      ],
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
    Color? color,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: (color ?? AppTheme.primaryBlue).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(6),
              child: Icon(
                icon,
                size: 16,
                color: color ?? AppTheme.primaryBlue,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _sortBookings() {
    widget.bookings.sort((a, b) {
      int result;
      switch (_sortColumn) {
        case 'date':
          result = a.bookedAt.compareTo(b.bookedAt);
          break;
        case 'status':
          result = a.status.toString().compareTo(b.status.toString());
          break;
        case 'price':
          result = a.totalPrice.amount.compareTo(b.totalPrice.amount);
          break;
        case 'name':
          result = a.userName.compareTo(b.userName);
          break;
        default:
          result = 0;
      }
      return _sortAscending ? result : -result;
    });
  }
}
