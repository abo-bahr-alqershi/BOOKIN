// lib/features/admin_reviews/presentation/pages/reviews_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/reviews_list/reviews_list_bloc.dart';
import '../widgets/review_stats_card.dart';
import '../widgets/review_filters_widget.dart';
import '../widgets/futuristic_review_card.dart';
import '../widgets/futuristic_reviews_table.dart';
import 'review_details_page.dart';

class ReviewsListPage extends StatefulWidget {
  const ReviewsListPage({super.key});

  @override
  State<ReviewsListPage> createState() => _ReviewsListPageState();
}

class _ReviewsListPageState extends State<ReviewsListPage> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isGridView = false;
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));
    
    _animationController.forward();
    
    _scrollController.addListener(() {
      setState(() {
        _showBackToTop = _scrollController.offset > 200;
      });
    });
    
    context.read<ReviewsListBloc>().add(const LoadReviewsEvent());
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 1200;
    
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // Animated Background Gradient
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(seconds: 3),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.darkBackground,
                    AppTheme.darkBackground2.withOpacity(0.8),
                    AppTheme.primaryPurple.withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ),
          
          // Floating Orbs Animation
          ..._buildFloatingOrbs(),
          
          // Main Content
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Premium App Bar
              _buildPremiumAppBar(context, isDesktop),
              
              // Stats Cards Section
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildStatsSection(isDesktop, isTablet),
                  ),
                ),
              ),
              
              // Filters Section
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 32 : 20,
                      vertical: 16,
                    ),
                    child: ReviewFiltersWidget(
                      onFilterChanged: (filters) {
                        context.read<ReviewsListBloc>().add(
                          FilterReviewsEvent(
                            searchQuery: filters['search'] ?? '',
                            minRating: filters['minRating'],
                            isPending: filters['isPending'],
                            hasResponse: filters['hasResponse'],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              
              // View Toggle
              if (!isDesktop)
                SliverToBoxAdapter(
                  child: _buildViewToggle(),
                ),
              
              // Reviews Content
              BlocBuilder<ReviewsListBloc, ReviewsListState>(
                builder: (context, state) {
                  if (state is ReviewsListLoading) {
                    return SliverFillRemaining(
                      child: _buildLoadingState(),
                    );
                  }
                  
                  if (state is ReviewsListError) {
                    return SliverFillRemaining(
                      child: _buildErrorState(state.message),
                    );
                  }
                  
                  if (state is ReviewsListLoaded) {
                    if (state.filteredReviews.isEmpty) {
                      return SliverFillRemaining(
                        child: _buildEmptyState(),
                      );
                    }
                    
                    if (isDesktop || (!_isGridView && isTablet)) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 32 : 20,
                          ),
                          child: FuturisticReviewsTable(
                            reviews: state.filteredReviews,
                            onReviewTap: (review) => _navigateToDetails(context, review.id),
                            onApproveTap: (review) {
                              context.read<ReviewsListBloc>().add(
                                ApproveReviewEvent(review.id),
                              );
                            },
                            onDeleteTap: (review) {
                              _showDeleteConfirmation(context, review.id);
                            },
                          ),
                        ),
                      );
                    }
                    
                    return SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 32 : 20,
                      ),
                      sliver: _buildReviewsGrid(
                        state.filteredReviews,
                        isTablet: isTablet,
                      ),
                    );
                  }
                  
                  return const SliverToBoxAdapter(child: SizedBox());
                },
              ),
              
              // Bottom Padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
          
          // Floating Action Button
          if (_showBackToTop)
            Positioned(
              bottom: 32,
              right: isDesktop ? 32 : 20,
              child: _buildFloatingActionButton(),
            ),
        ],
      ),
    );
  }
  
  List<Widget> _buildFloatingOrbs() {
    return [
      Positioned(
        top: -100,
        right: -100,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(seconds: 2),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryBlue.withOpacity(0.1 * value),
                      AppTheme.primaryBlue.withOpacity(0.01),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      Positioned(
        bottom: -150,
        left: -150,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(seconds: 2, milliseconds: 500),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryPurple.withOpacity(0.08 * value),
                      AppTheme.primaryPurple.withOpacity(0.01),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ];
  }
  
  Widget _buildPremiumAppBar(BuildContext context, bool isDesktop) {
    return SliverAppBar(
      expandedHeight: isDesktop ? 140 : 120,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.glassDark.withOpacity(0.8),
                  AppTheme.glassDark.withOpacity(0.4),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.glowBlue.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
            ),
            child: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: EdgeInsets.only(
                left: isDesktop ? 32 : 20,
                bottom: 16,
                right: isDesktop ? 32 : 20,
              ),
              title: Row(
                children: [
                  // Icon with glow effect
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryBlue.withOpacity(0.2),
                          AppTheme.primaryPurple.withOpacity(0.2),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.glowBlue.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.reviews_outlined,
                      color: AppTheme.glowWhite,
                      size: isDesktop ? 28 : 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Title
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reviews Management',
                          style: TextStyle(
                            fontSize: isDesktop ? 24 : 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textWhite,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        BlocBuilder<ReviewsListBloc, ReviewsListState>(
                          builder: (context, state) {
                            if (state is ReviewsListLoaded) {
                              return Text(
                                '${state.filteredReviews.length} Total Reviews',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textLight.withOpacity(0.8),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // Refresh Button
                  IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      context.read<ReviewsListBloc>().add(RefreshReviewsEvent());
                    },
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: AppTheme.textLight,
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
  
  Widget _buildStatsSection(bool isDesktop, bool isTablet) {
    return BlocBuilder<ReviewsListBloc, ReviewsListState>(
      builder: (context, state) {
        if (state is ReviewsListLoaded) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 32 : 20,
              vertical: 20,
            ),
            child: ReviewStatsCard(
              totalReviews: state.reviews.length,
              pendingReviews: state.pendingCount,
              averageRating: state.averageRating,
              reviews: state.reviews,
              isDesktop: isDesktop,
              isTablet: isTablet,
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
  
  Widget _buildViewToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppTheme.darkCard.withOpacity(0.5),
              border: Border.all(
                color: AppTheme.glowBlue.withOpacity(0.2),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                _buildToggleButton(
                  icon: Icons.view_list_rounded,
                  isSelected: !_isGridView,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _isGridView = false);
                  },
                ),
                const SizedBox(width: 4),
                _buildToggleButton(
                  icon: Icons.grid_view_rounded,
                  isSelected: _isGridView,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _isGridView = true);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildToggleButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected 
              ? AppTheme.primaryBlue.withOpacity(0.2)
              : Colors.transparent,
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected 
              ? AppTheme.glowBlue
              : AppTheme.textLight.withOpacity(0.5),
        ),
      ),
    );
  }
  
  Widget _buildReviewsGrid(
    List<dynamic> reviews, {
    required bool isTablet,
  }) {
    final crossAxisCount = isTablet ? 2 : 1;
    
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: isTablet ? 1.5 : 1.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 600),
            columnCount: crossAxisCount,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: FuturisticReviewCard(
                  review: reviews[index],
                  onTap: () => _navigateToDetails(context, reviews[index].id),
                  onApprove: () {
                    context.read<ReviewsListBloc>().add(
                      ApproveReviewEvent(reviews[index].id),
                    );
                  },
                  onDelete: () {
                    _showDeleteConfirmation(context, reviews[index].id);
                  },
                ),
              ),
            ),
          );
        },
        childCount: reviews.length,
      ),
    );
  }
  
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: AppTheme.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.glowBlue.withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading reviews...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppTheme.error.withOpacity(0.1),
              border: Border.all(
                color: AppTheme.error.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.error_outline,
              size: 48,
              color: AppTheme.error,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Error Loading Reviews',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textWhite,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              context.read<ReviewsListBloc>().add(const LoadReviewsEvent());
            },
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withOpacity(0.1),
                  AppTheme.primaryPurple.withOpacity(0.1),
                ],
              ),
            ),
            child: Icon(
              Icons.reviews_outlined,
              size: 64,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Reviews Found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppTheme.textWhite,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no reviews matching your filters',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFloatingActionButton() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.glowBlue.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                  );
                },
                borderRadius: BorderRadius.circular(28),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  void _navigateToDetails(BuildContext context, String reviewId) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ReviewDetailsPage(reviewId: reviewId),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.95,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
  
  void _showDeleteConfirmation(BuildContext context, String reviewId) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.error.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.error.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.error.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: AppTheme.error,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Delete Review?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textWhite,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This action cannot be undone.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppTheme.textLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.read<ReviewsListBloc>().add(
                            DeleteReviewEvent(reviewId),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.error,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}