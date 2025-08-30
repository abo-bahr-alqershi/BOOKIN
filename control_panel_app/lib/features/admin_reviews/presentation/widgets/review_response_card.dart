// lib/features/admin_reviews/presentation/widgets/review_response_card.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:bookn_cp_app/core/theme/app_theme.dart';
import 'package:bookn_cp_app/core/theme/app_text_styles.dart';

class ReviewResponseCard extends StatelessWidget {
  final String responseText;
  final String respondedBy;
  final DateTime responseDate;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  
  const ReviewResponseCard({
    super.key,
    required this.responseText,
    required this.respondedBy,
    required this.responseDate,
    this.onEdit,
    this.onDelete,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withOpacity(0.1),
            AppTheme.primaryPurple.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.reply_rounded,
                size: 16,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(width: 8),
              Text(
                'رد من $respondedBy',
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(responseDate),
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Response Text
          Text(
            responseText,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppTheme.textLight,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          // Actions
          if (onEdit != null || onDelete != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onEdit != null)
                  _buildActionButton(
                    icon: Icons.edit_rounded,
                    onTap: onEdit!,
                  ),
                if (onEdit != null && onDelete != null)
                  const SizedBox(width: 8),
                if (onDelete != null)
                  _buildActionButton(
                    icon: Icons.delete_rounded,
                    onTap: onDelete!,
                    color: AppTheme.error,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: (color ?? AppTheme.primaryBlue).withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          icon,
          size: 14,
          color: color ?? AppTheme.primaryBlue,
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}