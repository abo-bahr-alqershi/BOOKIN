// lib/features/admin_reviews/presentation/pages/review_details_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:bookn_cp_app/core/theme/app_theme.dart';
import 'package:bookn_cp_app/core/theme/app_text_styles.dart';
import 'package:bookn_cp_app/core/theme/app_dimensions.dart';
import '../../domain/entities/review.dart';
import '../bloc/review_details/review_details_bloc.dart';
import '../widgets/rating_breakdown_widget.dart';
import '../widgets/review_images_gallery.dart';
import '../widgets/add_response_dialog.dart';
import '../widgets/review_response_card.dart';

class ReviewDetailsPage extends StatefulWidget {
  final Review review;
  
  const ReviewDetailsPage({
    super.key,
    required this.review,
  });
  
  @override
  State<ReviewDetailsPage> createState() => _ReviewDetailsPageState();
}

class _ReviewDetailsPageState extends State<ReviewDetailsPage>
    with TickerProviderStateMixin {
  late AnimationController _backgroundAnimController;
  late AnimationController _contentAnimController;
  late Animation<double> _backgroundRotation;
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadDetails();
  }
  
  void _initializeAnimations() {
    _backgroundAnimController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _contentAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _backgroundRotation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_backgroundAnimController);
    
    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentAnimController,
      curve: Curves.easeOut,
    ));
    
    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentAnimController,
      curve: Curves.easeOutQuart,
    ));
    
    _contentAnimController.forward();
  }
  
  void _loadDetails() {
    context.read<ReviewDetailsBloc>().add(
      LoadReviewDetailsEvent(widget.review.id),
    );
  }
  
  @override
  void dispose() {
    _backgroundAnimController.dispose();
    _contentAnimController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > AppDimensions.desktopBreakpoint;
    
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // Animated Background
          _buildAnimatedBackground(),
          
          // Main Content
          SafeArea(
            child: FadeTransition(
              opacity: _contentFadeAnimation,
              child: SlideTransition(
                position: _contentSlideAnimation,
                child: _buildContent(isDesktop),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundRotation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.darkBackground,
                AppTheme.darkBackground2.withOpacity(0.9),
                AppTheme.darkBackground3.withOpacity(0.8),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildContent(bool isDesktop) {
    return BlocBuilder<ReviewDetailsBloc, ReviewDetailsState>(
      builder: (context, state) {
        if (state is ReviewDetailsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is ReviewDetailsLoaded) {
          return CustomScrollView(
            slivers: [
              // App Bar
              _buildAppBar(),
              
              // Content
              SliverPadding(
                padding: EdgeInsets.all(isDesktop ? 32 : 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Review Info Card
                    _buildReviewInfoCard(state.review),
                    
                    const SizedBox(height: 24),
                    
                    // Rating Breakdown
                    RatingBreakdownWidget(
                      cleanliness: state.review.cleanliness,
                      service: state.review.service,
                      location: state.review.location,
                      value: state.review.value,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Images Gallery
                    if (state.review.images.isNotEmpty) ...[
                      ReviewImagesGallery(images: state.review.images),
                      const SizedBox(height: 24),
                    ],
                    
                    // Responses Section
                    _buildResponsesSection(state),
                  ]),
                ),
              ),
            ],
          );
        }
        
        if (state is ReviewDetailsError) {
          return Center(
            child: Text(
              state.message,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppTheme.error,
              ),
            ),
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }
  
  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkCard.withOpacity(0.9),
              AppTheme.darkCard.withOpacity(0.7),
            ],
          ),
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.primaryBlue.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'تفاصيل التقييم',
        style: AppTextStyles.heading3.copyWith(
          color: AppTheme.textWhite,
        ),
      ),
      actions: [
        // Add Response Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _buildAddResponseButton(),
        ),
      ],
    );
  }
  
  Widget _buildReviewInfoCard(Review review) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withOpacity(0.7),
            AppTheme.darkCard.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
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
              // User Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    review.userName[0].toUpperCase(),
                    style: AppTextStyles.heading3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: AppTextStyles.heading3.copyWith(
                        color: AppTheme.textWhite,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      review.propertyName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Overall Rating
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.warning.withOpacity(0.2),
                      AppTheme.warning.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
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
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      review.averageRating.toStringAsFixed(1),
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
          
          // Comment
          Text(
            'التعليق',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            review.comment,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textLight,
              height: 1.6,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Date
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 16,
                color: AppTheme.textMuted,
              ),
              const SizedBox(width: 8),
              Text(
                _formatDate(review.createdAt),
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildResponsesSection(ReviewDetailsLoaded state) {
    return Column(
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
                'الردود',
                style: AppTextStyles.heading3.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                state.responses.length.toString(),
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Responses List
        if (state.responses.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.darkCard.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.darkBorder.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 48,
                    color: AppTheme.textMuted.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد ردود بعد',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.responses.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final response = state.responses[index];
              return ReviewResponseCard(
                responseText: response.responseText,
                respondedBy: response.respondedByName,
                responseDate: response.createdAt,
                onDelete: () => _deleteResponse(response.id),
              );
            },
          ),
      ],
    );
  }
  
  Widget _buildAddResponseButton() {
    return GestureDetector(
      onTap: _showAddResponseDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.reply_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'إضافة رد',
              style: AppTextStyles.buttonMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showAddResponseDialog() {
    showDialog(
      context: context,
      builder: (context) => AddResponseDialog(
        reviewId: widget.review.id,
        onSubmit: (responseText) {
          context.read<ReviewDetailsBloc>().add(
            AddResponseEvent(
              reviewId: widget.review.id,
              responseText: responseText,
              respondedBy: 'admin-id', // Get from auth
            ),
          );
        },
      ),
    );
  }
  
  void _deleteResponse(String responseId) {
    HapticFeedback.heavyImpact();
    context.read<ReviewDetailsBloc>().add(
      DeleteResponseEvent(responseId),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}