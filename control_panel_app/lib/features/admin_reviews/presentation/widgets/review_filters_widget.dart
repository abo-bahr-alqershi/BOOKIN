// lib/features/admin_reviews/presentation/widgets/review_filters_widget.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:bookn_cp_app/core/theme/app_theme.dart';
import 'package:bookn_cp_app/core/theme/app_text_styles.dart';

class ReviewFiltersWidget extends StatelessWidget {
  final Function(String) onSearchChanged;
  final Function(double?) onRatingFilterChanged;
  final Function(bool?) onPendingFilterChanged;
  final Function(bool?) onResponseFilterChanged;
  
  const ReviewFiltersWidget({
    super.key,
    required this.onSearchChanged,
    required this.onRatingFilterChanged,
    required this.onPendingFilterChanged,
    required this.onResponseFilterChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withOpacity(0.6),
            AppTheme.darkCard.withOpacity(0.4),
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
            children: [
              // Search Bar
              _buildSearchBar(),
              
              const SizedBox(height: 16),
              
              // Filter Chips
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildFilterChip(
                    label: 'معلق',
                    icon: Icons.pending_actions_rounded,
                    onSelected: (selected) => onPendingFilterChanged(selected ? true : null),
                  ),
                  _buildFilterChip(
                    label: 'له رد',
                    icon: Icons.reply_rounded,
                    onSelected: (selected) => onResponseFilterChanged(selected ? true : null),
                  ),
                  _buildRatingFilter(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkSurface.withOpacity(0.6),
            AppTheme.darkSurface.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: TextField(
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppTheme.textWhite,
        ),
        decoration: InputDecoration(
          hintText: 'البحث في التقييمات...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textMuted.withOpacity(0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppTheme.textMuted,
          ),
        ),
        onChanged: onSearchChanged,
      ),
    );
  }
  
  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      onSelected: onSelected,
      backgroundColor: AppTheme.darkCard.withOpacity(0.3),
      selectedColor: AppTheme.primaryBlue.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryBlue,
      side: BorderSide(
        color: AppTheme.primaryBlue.withOpacity(0.3),
        width: 1,
      ),
      labelStyle: AppTextStyles.caption.copyWith(
        color: AppTheme.textLight,
      ),
    );
  }
  
  Widget _buildRatingFilter() {
    return PopupMenuButton<double>(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.warning.withOpacity(0.2),
              AppTheme.warning.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.warning.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star_rounded,
              size: 16,
              color: AppTheme.warning,
            ),
            const SizedBox(width: 6),
            Text(
              'التقييم',
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.warning,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 16,
              color: AppTheme.warning,
            ),
          ],
        ),
      ),
      onSelected: onRatingFilterChanged,
      itemBuilder: (context) => [
        const PopupMenuItem(value: null, child: Text('الكل')),
        const PopupMenuItem(value: 4.0, child: Text('4+ نجوم')),
        const PopupMenuItem(value: 3.0, child: Text('3+ نجوم')),
        const PopupMenuItem(value: 2.0, child: Text('2+ نجوم')),
        const PopupMenuItem(value: 1.0, child: Text('1+ نجمة')),
      ],
    );
  }
}