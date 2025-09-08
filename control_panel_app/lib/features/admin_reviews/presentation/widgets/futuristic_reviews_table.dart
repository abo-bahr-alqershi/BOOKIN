// lib/features/admin_reviews/presentation/widgets/futuristic_reviews_table.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/review.dart';

class FuturisticReviewsTable extends StatefulWidget {
  final List<Review> reviews;
  final Function(Review) onReviewTap;
  final Function(Review) onApproveTap;
  final Function(Review) onDeleteTap;
  
  const FuturisticReviewsTable({
    super.key,
    required this.reviews,
    required this.onReviewTap,
    required this.onApproveTap,
    required this.onDeleteTap,
  });
  
  @override
  State<FuturisticReviewsTable> createState() => _FuturisticReviewsTableState();
}

class _FuturisticReviewsTableState extends State<FuturisticReviewsTable> {
  int? _hoveredIndex;
  String _sortBy = 'date';
  bool _ascending = false;
  
  List<Review> get _sortedReviews {
    final sorted = List<Review>.from(widget.reviews);
    
    switch (_sortBy) {
      case 'date':
        sorted.sort((a, b) => _ascending 
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt));
        break;
      case 'rating':
        sorted.sort((a, b) => _ascending
            ? a.averageRating.compareTo(b.averageRating)
            : b.averageRating.compareTo(a.averageRating));
        break;
      case 'user':
        sorted.sort((a, b) => _ascending
            ? a.userName.compareTo(b.userName)
            : b.userName.compareTo(a.userName));
        break;
      case 'property':
        sorted.sort((a, b) => _ascending
            ? a.propertyName.compareTo(b.propertyName)
            : b.propertyName.compareTo(a.propertyName));
        break;
      case 'status':
        sorted.sort((a, b) {
          final statusA = a.isPending ? 0 : (a.isApproved ? 1 : 2);
          final statusB = b.isPending ? 0 : (b.isApproved ? 1 : 2);
          return _ascending 
              ? statusA.compareTo(statusB)
              : statusB.compareTo(statusA);
        });
        break;
    }
    
    return sorted;
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1200;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkCard.withOpacity(0.7),
            AppTheme.darkCard.withOpacity(0.5),
          ],
        ),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.3),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowDark.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              // Table Header
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.darkBorder.withOpacity(0.2),
                      width: 0.5,
                    ),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryBlue.withOpacity(0.05),
                      AppTheme.primaryPurple.withOpacity(0.05),
                    ],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 24 : 16,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      _buildHeaderCell(
                        'User',
                        flex: 2,
                        sortKey: 'user',
                        isFirst: true,
                      ),
                      _buildHeaderCell(
                        'Property',
                        flex: 2,
                        sortKey: 'property',
                      ),
                      _buildHeaderCell(
                        'Rating',
                        flex: 1,
                        sortKey: 'rating',
                      ),
                      if (isDesktop) ...[
                        _buildHeaderCell(
                          'Date',
                          flex: 1,
                          sortKey: 'date',
                        ),
                        _buildHeaderCell(
                          'Status',
                          flex: 1,
                          sortKey: 'status',
                        ),
                      ],
                      _buildHeaderCell(
                        'Actions',
                        flex: 1,
                        sortable: false,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Table Body
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _sortedReviews.length,
                  itemBuilder: (context, index) {
                    final review = _sortedReviews[index];
                    return _buildTableRow(review, index, isDesktop);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeaderCell(
    String title, {
    required int flex,
    String? sortKey,
    bool sortable = true,
    bool isFirst = false,
  }) {
    final isActive = _sortBy == sortKey;
    
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: sortable && sortKey != null
            ? () {
                HapticFeedback.lightImpact();
                setState(() {
                  if (_sortBy == sortKey) {
                    _ascending = !_ascending;
                  } else {
                    _sortBy = sortKey;
                    _ascending = false;
                  }
                });
              }
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.only(
            left: isFirst ? 0 : 8,
            right: 8,
            top: 4,
            bottom: 4,
          ),
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive 
                      ? AppTheme.primaryBlue
                      : AppTheme.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              if (sortable && sortKey != null) ...[
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: isActive && _ascending ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.arrow_downward,
                    size: 14,
                    color: isActive
                        ? AppTheme.primaryBlue
                        : AppTheme.textMuted.withOpacity(0.3),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTableRow(Review review, int index, bool isDesktop) {
    final isHovered = _hoveredIndex == index;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isHovered
              ? AppTheme.primaryBlue.withOpacity(0.05)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: AppTheme.darkBorder.withOpacity(0.1),
              width: 0.5,
            ),
          ),
        ),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onReviewTap(review);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 24 : 16,
              vertical: 16,
            ),
            child: Row(
              children: [
                // User Cell
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.primaryGradient,
                        ),
                        child: Center(
                          child: Text(
                            review.userName.substring(0, 2).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review.userName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textWhite,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (!isDesktop) ...[
                              const SizedBox(height: 2),
                              Text(
                                _formatDate(review.createdAt),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Property Cell
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      review.propertyName,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                
                // Rating Cell
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: _getRatingColor(review.averageRating).withOpacity(0.1),
                          border: Border.all(
                            color: _getRatingColor(review.averageRating).withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: _getRatingColor(review.averageRating),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              review.averageRating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getRatingColor(review.averageRating),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Date Cell (Desktop only)
                if (isDesktop) ...[
                  Expanded(
                    flex: 1,
                    child: Text(
                      _formatDate(review.createdAt),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                  
                  // Status Cell
                  Expanded(
                    flex: 1,
                    child: _buildStatusBadge(review),
                  ),
                ],
                
                // Actions Cell
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (review.isPending)
                        _buildActionButton(
                          icon: Icons.check,
                          color: AppTheme.success,
                          onTap: () => widget.onApproveTap(review),
                        ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        icon: Icons.delete_outline,
                        color: AppTheme.error,
                        onTap: () => widget.onDeleteTap(review),
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
  
  Widget _buildStatusBadge(Review review) {
    final color = review.isPending
        ? AppTheme.warning
        : review.isApproved
            ? AppTheme.success
            : AppTheme.error;
    
    final text = review.isPending
        ? 'Pending'
        : review.isApproved
            ? 'Approved'
            : 'Rejected';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.1),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: color.withOpacity(0.1),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
      ),
    );
  }
  
  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return AppTheme.success;
    if (rating >= 3.5) return AppTheme.warning;
    if (rating >= 2.5) return Colors.orange;
    return AppTheme.error;
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}