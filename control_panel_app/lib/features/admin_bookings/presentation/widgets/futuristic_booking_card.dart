// lib/features/admin_bookings/presentation/widgets/futuristic_booking_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/booking.dart';
import 'booking_status_badge.dart';

class FuturisticBookingCard extends StatefulWidget {
  final Booking booking;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showActions;
  final bool isCompact;

  const FuturisticBookingCard({
    super.key,
    required this.booking,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
    this.showActions = false,
    this.isCompact = false,
  });

  @override
  State<FuturisticBookingCard> createState() => _FuturisticBookingCardState();
}

class _FuturisticBookingCardState extends State<FuturisticBookingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.identity()..scale(_isHovered ? 0.98 : 1.0),
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onTapDown: (_) => _setHovered(true),
        onTapUp: (_) => _setHovered(false),
        onTapCancel: () => _setHovered(false),
        child: Container(
          margin: EdgeInsets.only(bottom: widget.isCompact ? 8 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.isSelected
                    ? AppTheme.primaryBlue.withOpacity(0.3)
                    : AppTheme.shadowDark.withOpacity(0.1),
                blurRadius: widget.isSelected ? 20 : 15,
                offset: const Offset(0, 8),
                spreadRadius: widget.isSelected ? 2 : 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.isSelected
                        ? [
                            AppTheme.primaryBlue.withOpacity(0.15),
                            AppTheme.primaryPurple.withOpacity(0.1),
                          ]
                        : [
                            AppTheme.darkCard.withOpacity(0.8),
                            AppTheme.darkCard.withOpacity(0.6),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.isSelected
                        ? AppTheme.primaryBlue.withOpacity(0.5)
                        : AppTheme.darkBorder.withOpacity(0.2),
                    width: widget.isSelected ? 2 : 1,
                  ),
                ),
                child: widget.isCompact
                    ? _buildCompactContent()
                    : _buildFullContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        _buildBody(),
        _buildFooter(),
      ],
    );
  }

  Widget _buildCompactContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildCompactImage(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.booking.unitName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppTheme.textWhite,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    BookingStatusBadge(
                      status: widget.booking.status,
                      size: BadgeSize.small,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.booking.userName,
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.calendar,
                      size: 12,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${Formatters.formatDate(widget.booking.checkIn)} - ${Formatters.formatDate(widget.booking.checkOut)}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildCompactPrice(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 140,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.booking.unitImage != null)
            CachedImageWidget(
              imageUrl: widget.booking.unitImage!,
              fit: BoxFit.cover,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppTheme.darkBackground.withOpacity(0.7),
                ],
                stops: const [0.5, 1.0],
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              child: Center(
                child: Icon(
                  CupertinoIcons.photo,
                  size: 40,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          Positioned(
            top: 12,
            right: 12,
            child: BookingStatusBadge(
              status: widget.booking.status,
              size: BadgeSize.medium,
            ),
          ),
          if (widget.isSelected)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.checkmark,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.booking.unitName,
                  style: AppTextStyles.heading3.copyWith(
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.booking.propertyName != null)
                  Text(
                    widget.booking.propertyName!,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            icon: CupertinoIcons.person_fill,
            label: widget.booking.userName,
            color: AppTheme.textWhite,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDateChip(
                  icon: CupertinoIcons.arrow_down_circle,
                  label: 'وصول',
                  date: widget.booking.checkIn,
                  color: AppTheme.success,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDateChip(
                  icon: CupertinoIcons.arrow_up_circle,
                  label: 'مغادرة',
                  date: widget.booking.checkOut,
                  color: AppTheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatChip(
                icon: CupertinoIcons.moon_fill,
                value: '${widget.booking.nights}',
                label: 'ليلة',
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                icon: CupertinoIcons.person_2_fill,
                value: '${widget.booking.guestsCount}',
                label: 'ضيف',
              ),
              const Spacer(),
              _buildPriceTag(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    if (!widget.showActions) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.darkBorder.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          _buildActionButton(
            icon: CupertinoIcons.eye,
            label: 'عرض',
            onTap: widget.onTap,
          ),
          const SizedBox(width: 8),
          if (widget.booking.canCheckIn)
            _buildActionButton(
              icon: CupertinoIcons.arrow_down_circle,
              label: 'تسجيل وصول',
              onTap: () {},
              isPrimary: true,
            ),
          if (widget.booking.canCheckOut)
            _buildActionButton(
              icon: CupertinoIcons.arrow_up_circle,
              label: 'تسجيل مغادرة',
              onTap: () {},
              isPrimary: true,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textMuted),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(color: color),
        ),
      ],
    );
  }

  Widget _buildDateChip({
    required IconData icon,
    required String label,
    required DateTime date,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: color,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            Formatters.formatDate(date),
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.textMuted),
          const SizedBox(width: 4),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        widget.booking.totalPrice.formattedAmount,
        style: AppTextStyles.bodyMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    bool isPrimary = false,
  }) {
    return Expanded(
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          gradient: isPrimary ? AppTheme.primaryGradient : null,
          color: isPrimary ? null : AppTheme.darkBackground.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
          border: isPrimary
              ? null
              : Border.all(
                  color: AppTheme.darkBorder.withOpacity(0.3),
                ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isPrimary ? Colors.white : AppTheme.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      color: isPrimary ? Colors.white : AppTheme.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: AppTheme.primaryGradient,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: widget.booking.unitImage != null
            ? CachedImageWidget(
                imageUrl: widget.booking.unitImage!,
                fit: BoxFit.cover,
              )
            : Center(
                child: Text(
                  widget.booking.unitName.substring(0, 2).toUpperCase(),
                  style: AppTextStyles.heading3.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildCompactPrice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          widget.booking.totalPrice.formattedAmount,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${widget.booking.nights} ليلة',
          style: AppTextStyles.caption.copyWith(
            color: AppTheme.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  void _setHovered(bool value) {
    setState(() => _isHovered = value);
    if (value) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }
}
