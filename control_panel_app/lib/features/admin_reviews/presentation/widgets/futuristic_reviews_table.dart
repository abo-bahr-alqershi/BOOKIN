// lib/features/admin_reviews/presentation/widgets/futuristic_reviews_table.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:bookn_cp_app/core/theme/app_theme.dart';
import 'package:bookn_cp_app/core/theme/app_text_styles.dart';
import 'package:bookn_cp_app/core/theme/app_dimensions.dart';
import '../../domain/entities/review.dart';
import 'review_response_card.dart';

class FuturisticReviewsTable extends StatefulWidget {
  final List<Review> reviews;
  final Function(String) onApprove;
  final Function(String) onDelete;
  final Function(Review) onViewDetails;
  
  const FuturisticReviewsTable({
    super.key,
    required this.reviews,
    required this.onApprove,
    required this.onDelete,
    required this.onViewDetails,
  });
  
  @override
  State<FuturisticReviewsTable> createState() => _FuturisticReviewsTableState();
}

class _FuturisticReviewsTableState extends State<FuturisticReviewsTable>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;
  
  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _shimmerAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > AppDimensions.desktopBreakpoint;
    
    if (widget.reviews.isEmpty) {
      return _buildEmptyState();
    }
    
    return isDesktop ? _buildDesktopTable() : _buildMobileList();
  }
  
  Widget _buildDesktopTable() {
    return Container(
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
            children: [
              // Header
              _buildTableHeader(),
              
              // Divider
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppTheme.primaryBlue.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              
              // Content
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: widget.reviews.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildTableRow(widget.reviews[index], index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildHeaderCell('المستخدم', flex: 2),
          _buildHeaderCell('العقار', flex: 2),
          _buildHeaderCell('التقييم', flex: 1),
          _buildHeaderCell('التعليق', flex: 3),
          _buildHeaderCell('الحالة', flex: 1),
          _buildHeaderCell('الرد', flex: 2),
          _buildHeaderCell('الإجراءات', flex: 2),
        ],
      ),
    );
  }
  
  Widget _buildHeaderCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppTheme.primaryBlue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildTableRow(Review review, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.darkSurface.withOpacity(0.3),
                    AppTheme.darkSurface.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: review.isPending
                      ? AppTheme.warning.withOpacity(0.3)
                      : AppTheme.primaryBlue.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // User Info
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review.userName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppTheme.textWhite,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(review.createdAt),
                          style: AppTextStyles.caption.copyWith(
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Property Name
                  Expanded(
                    flex: 2,
                    child: Text(
                      review.propertyName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppTheme.textLight,
                      ),
                    ),
                  ),
                  
                  // Rating
                  Expanded(
                    flex: 1,
                    child: _buildRatingDisplay(review.averageRating),
                  ),
                  
                  // Comment
                  Expanded(
                    flex: 3,
                    child: Text(
                      review.comment,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppTheme.textLight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // Status
                  Expanded(
                    flex: 1,
                    child: _buildStatusBadge(review),
                  ),
                  
                  // Response
                  Expanded(
                    flex: 2,
                    child: review.hasResponse
                        ? ReviewResponseCard(
                            responseText: review.responseText!,
                            respondedBy: review.respondedBy ?? 'الإدارة',
                            responseDate: review.responseDate!,
                          )
                        : Text(
                            'لا يوجد رد',
                            style: AppTextStyles.caption.copyWith(
                              color: AppTheme.textMuted,
                            ),
                          ),
                  ),
                  
                  // Actions
                  Expanded(
                    flex: 2,
                    child: _buildActionButtons(review),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildMobileList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: widget.reviews.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final review = widget.reviews[index];
        return _buildMobileCard(review, index);
      },
    );
  }
  
  Widget _buildMobileCard(Review review, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.darkCard.withOpacity(0.7),
                    AppTheme.darkCard.withOpacity(0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: review.isPending
                      ? AppTheme.warning.withOpacity(0.3)
                      : AppTheme.primaryBlue.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      // User Avatar
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            review.userName[0].toUpperCase(),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review.userName,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppTheme.textWhite,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              review.propertyName,
                              style: AppTextStyles.caption.copyWith(
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Status Badge
                      _buildStatusBadge(review),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Rating
                  _buildRatingDisplay(review.averageRating),
                  
                  const SizedBox(height: 12),
                  
                  // Comment
                  Text(
                    review.comment,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppTheme.textLight,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // Response if exists
                  if (review.hasResponse) ...[
                    const SizedBox(height: 12),
                    ReviewResponseCard(
                      responseText: review.responseText!,
                      respondedBy: review.respondedBy ?? 'الإدارة',
                      responseDate: review.responseDate!,
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  // Actions
                  _buildActionButtons(review),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildRatingDisplay(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          final filled = index < rating.floor();
          final half = index == rating.floor() && rating % 1 >= 0.5;
          
          return Icon(
            half ? Icons.star_half_rounded : Icons.star_rounded,
            size: 16,
            color: filled || half
                ? AppTheme.warning
                : AppTheme.darkBorder.withOpacity(0.3),
          );
        }),
        const SizedBox(width: 8),
        Text(
          rating.toStringAsFixed(1),
          style: AppTextStyles.caption.copyWith(
            color: AppTheme.warning,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatusBadge(Review review) {
    final color = review.isPending
        ? AppTheme.warning
        : (review.isApproved ? AppTheme.success : AppTheme.error);
    
    final text = review.isPending
        ? 'معلق'
        : (review.isApproved ? 'موافق عليه' : 'مرفوض');
    
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.2),
                color.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(0.5),
              width: 1,
            ),
            boxShadow: review.isPending
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3 * _shimmerAnimation.value),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildActionButtons(Review review) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // View Details
        _buildActionButton(
          icon: Icons.visibility_rounded,
          color: AppTheme.info,
          onTap: () => widget.onViewDetails(review),
        ),
        
        const SizedBox(width: 8),
        
        // Approve if pending
        if (review.isPending)
          _buildActionButton(
            icon: Icons.check_circle_rounded,
            color: AppTheme.success,
            onTap: () => widget.onApprove(review.id),
          ),
        
        const SizedBox(width: 8),
        
        // Delete
        _buildActionButton(
          icon: Icons.delete_rounded,
          color: AppTheme.error,
          onTap: () => widget.onDelete(review.id),
        ),
      ],
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.2),
              color.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: color,
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 64,
            color: AppTheme.textMuted.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد تقييمات',
            style: AppTextStyles.heading3.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}