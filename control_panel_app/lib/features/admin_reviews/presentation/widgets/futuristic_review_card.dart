// lib/features/admin_reviews/presentation/widgets/futuristic_review_card.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:bookn_cp_app/core/theme/app_theme.dart';
import 'package:bookn_cp_app/core/theme/app_text_styles.dart';
import '../../domain/entities/review.dart';

class FuturisticReviewCard extends StatefulWidget {
  final Review review;
  final VoidCallback onTap;
  final VoidCallback? onApprove;
  final VoidCallback? onDelete;
  final Duration animationDelay;
  
  const FuturisticReviewCard({
    super.key,
    required this.review,
    required this.onTap,
    this.onApprove,
    this.onDelete,
    this.animationDelay = Duration.zero,
  });
  
  @override
  State<FuturisticReviewCard> createState() => _FuturisticReviewCardState();
}

class _FuturisticReviewCardState extends State<FuturisticReviewCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isHovered = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    Future.delayed(widget.animationDelay, () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: GestureDetector(
                onTap: widget.onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.identity()
                    ..translate(0.0, _isHovered ? -5.0 : 0.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.darkCard.withOpacity(0.7),
                        AppTheme.darkCard.withOpacity(0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isHovered
                          ? AppTheme.primaryBlue.withOpacity(0.4)
                          : AppTheme.primaryBlue.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(
                          _isHovered ? 0.2 : 0.1,
                        ),
                        blurRadius: _isHovered ? 20 : 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              children: [
                                // Avatar
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      widget.review.userName[0].toUpperCase(),
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
                                        widget.review.userName,
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: AppTheme.textWhite,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        widget.review.propertyName,
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Rating
                                _buildRatingBadge(),
                              ],
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Comment
                            Text(
                              widget.review.comment,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppTheme.textLight,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Footer
                            Row(
                              children: [
                                // Date
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 14,
                                  color: AppTheme.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(widget.review.createdAt),
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                                
                                const Spacer(),
                                
                                // Actions
                                if (widget.review.isPending && widget.onApprove != null)
                                  _buildActionButton(
                                    icon: Icons.check_circle_rounded,
                                    color: AppTheme.success,
                                    onTap: widget.onApprove!,
                                  ),
                                
                                if (widget.onDelete != null) ...[
                                  const SizedBox(width: 8),
                                  _buildActionButton(
                                    icon: Icons.delete_rounded,
                                    color: AppTheme.error,
                                    onTap: widget.onDelete!,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildRatingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            size: 14,
            color: AppTheme.warning,
          ),
          const SizedBox(width: 4),
          Text(
            widget.review.averageRating.toStringAsFixed(1),
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.warning,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 14,
          color: color,
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}