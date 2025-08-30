// lib/features/admin_reviews/presentation/widgets/rating_breakdown_widget.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:bookn_cp_app/core/theme/app_theme.dart';
import 'package:bookn_cp_app/core/theme/app_text_styles.dart';

class RatingBreakdownWidget extends StatelessWidget {
  final double cleanliness;
  final double service;
  final double location;
  final double value;
  
  const RatingBreakdownWidget({
    super.key,
    required this.cleanliness,
    required this.service,
    required this.location,
    required this.value,
  });
  
  double get averageRating => (cleanliness + service + location + value) / 4;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withOpacity(0.6),
            AppTheme.darkCard.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Row(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return AppTheme.primaryGradient.createShader(bounds);
                    },
                    child: Text(
                      'تفاصيل التقييم',
                      style: AppTextStyles.heading3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Overall Rating
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.warning.withOpacity(0.2),
                          AppTheme.warning.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppTheme.warning.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: AppTheme.warning,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          averageRating.toStringAsFixed(1),
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppTheme.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Rating Items
              _buildRatingItem('النظافة', cleanliness, Icons.cleaning_services_rounded),
              const SizedBox(height: 16),
              _buildRatingItem('الخدمة', service, Icons.room_service_rounded),
              const SizedBox(height: 16),
              _buildRatingItem('الموقع', location, Icons.location_on_rounded),
              const SizedBox(height: 16),
              _buildRatingItem('القيمة', value, Icons.attach_money_rounded),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildRatingItem(String label, double rating, IconData icon) {
    return Row(
      children: [
        // Icon
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryBlue.withOpacity(0.2),
                AppTheme.primaryPurple.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppTheme.primaryBlue,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Label
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textLight,
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Progress Bar
        Expanded(
          child: Stack(
            children: [
              // Background
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.darkBorder.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              
              // Fill
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: rating / 5),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return FractionallySizedBox(
                    widthFactor: value,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getRatingColor(rating),
                            _getRatingColor(rating).withOpacity(0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: _getRatingColor(rating).withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Value
        Container(
          width: 40,
          alignment: Alignment.centerRight,
          child: Text(
            rating.toStringAsFixed(1),
            style: AppTextStyles.bodyMedium.copyWith(
              color: _getRatingColor(rating),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
  
  Color _getRatingColor(double rating) {
    if (rating >= 4.0) return AppTheme.success;
    if (rating >= 3.0) return AppTheme.warning;
    if (rating >= 2.0) return Colors.orange;
    return AppTheme.error;
  }
}