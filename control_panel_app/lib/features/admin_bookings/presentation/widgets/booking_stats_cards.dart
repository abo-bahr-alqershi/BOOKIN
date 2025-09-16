// lib/features/admin_bookings/presentation/widgets/booking_stats_cards.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/booking.dart';
import '../../../../core/enums/booking_status.dart';

class BookingStatsCards extends StatelessWidget {
  final List<Booking> bookings;
  final Map<String, dynamic> stats;

  const BookingStatsCards({
    super.key,
    required this.bookings,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final calculatedStats = _calculateStats();

    return ListView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      children: [
        _buildStatCard(
          title: 'إجمالي الحجوزات',
          value: calculatedStats['total'].toString(),
          icon: CupertinoIcons.doc_text_fill,
          gradient: AppTheme.primaryGradient,
          trend: stats['totalTrend'] as double? ?? 0,
        ),
        _buildStatCard(
          title: 'حجوزات مؤكدة',
          value: calculatedStats['confirmed'].toString(),
          icon: CupertinoIcons.checkmark_circle_fill,
          gradient: LinearGradient(
            colors: [AppTheme.success, AppTheme.success.withOpacity(0.7)],
          ),
          trend: stats['confirmedTrend'] as double? ?? 0,
        ),
        _buildStatCard(
          title: 'حجوزات معلقة',
          value: calculatedStats['pending'].toString(),
          icon: CupertinoIcons.clock_fill,
          gradient: LinearGradient(
            colors: [AppTheme.warning, AppTheme.warning.withOpacity(0.7)],
          ),
          trend: stats['pendingTrend'] as double? ?? 0,
        ),
        _buildStatCard(
          title: 'الإيرادات',
          value: Formatters.formatCurrency(
            calculatedStats['revenue'] as double,
            'YER',
          ),
          icon: CupertinoIcons.money_dollar_circle_fill,
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryPurple,
              AppTheme.primaryPurple.withOpacity(0.7)
            ],
          ),
          trend: stats['revenueTrend'] as double? ?? 0,
        ),
        _buildStatCard(
          title: 'معدل الإشغال',
          value: '${calculatedStats['occupancy'].toStringAsFixed(1)}%',
          icon: CupertinoIcons.chart_pie_fill,
          gradient: LinearGradient(
            colors: [AppTheme.info, AppTheme.info.withOpacity(0.7)],
          ),
          trend: stats['occupancyTrend'] as double? ?? 0,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Gradient gradient,
    required double trend,
  }) {
    final isPositive = trend >= 0;

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                colors: [
                  gradient.colors.first.withOpacity(0.15),
                  gradient.colors.last.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: gradient.colors.first.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -15,
                  top: -15,
                  child: Icon(
                    icon,
                    size: 80,
                    color: gradient.colors.first.withOpacity(0.1),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: gradient,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              icon,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          if (trend != 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: (isPositive
                                        ? AppTheme.success
                                        : AppTheme.error)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isPositive
                                        ? CupertinoIcons.arrow_up_right
                                        : CupertinoIcons.arrow_down_right,
                                    size: 10,
                                    color: isPositive
                                        ? AppTheme.success
                                        : AppTheme.error,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${trend.abs().toStringAsFixed(1)}%',
                                    style: AppTextStyles.caption.copyWith(
                                      color: isPositive
                                          ? AppTheme.success
                                          : AppTheme.error,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: AppTextStyles.caption.copyWith(
                          color: AppTheme.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: AppTextStyles.heading2.copyWith(
                          color: gradient.colors.first,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateStats() {
    int total = bookings.length;
    int confirmed = 0;
    int pending = 0;
    double revenue = 0;

    for (final booking in bookings) {
      if (booking.status == BookingStatus.confirmed) {
        confirmed++;
      } else if (booking.status == BookingStatus.pending) {
        pending++;
      }

      if (booking.status != BookingStatus.cancelled) {
        revenue += booking.totalPrice.amount;
      }
    }

    // Calculate occupancy (simplified)
    double occupancy = total > 0 ? (confirmed / total) * 100 : 0;

    return {
      'total': total,
      'confirmed': confirmed,
      'pending': pending,
      'revenue': revenue,
      'occupancy': occupancy,
    };
  }
}
