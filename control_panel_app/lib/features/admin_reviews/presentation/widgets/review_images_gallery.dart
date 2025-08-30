// lib/features/admin_reviews/presentation/widgets/review_images_gallery.dart

import 'package:flutter/material.dart';
import 'package:bookn_cp_app/core/theme/app_theme.dart';
import 'package:bookn_cp_app/core/theme/app_text_styles.dart';
import '../../domain/entities/review_image.dart';

class ReviewImagesGallery extends StatelessWidget {
  final List<ReviewImage> images;
  
  const ReviewImagesGallery({
    super.key,
    required this.images,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الصور المرفقة',
          style: AppTextStyles.heading3.copyWith(
            color: AppTheme.textWhite,
          ),
        ),
        
        const SizedBox(height: 16),
        
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final image = images[index];
              return _buildImageCard(image, context);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildImageCard(ReviewImage image, BuildContext context) {
    return GestureDetector(
      onTap: () => _showFullImage(image, context),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryBlue.withOpacity(0.3),
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
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                image.url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppTheme.darkCard,
                    child: Icon(
                      Icons.broken_image_rounded,
                      color: AppTheme.textMuted.withOpacity(0.3),
                      size: 32,
                    ),
                  );
                },
              ),
            ),
            
            // Category Badge
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getCategoryName(image.category),
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textWhite,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getCategoryName(ImageCategory category) {
    switch (category) {
      case ImageCategory.exterior:
        return 'خارجي';
      case ImageCategory.interior:
        return 'داخلي';
      case ImageCategory.room:
        return 'غرفة';
      case ImageCategory.facility:
        return 'مرفق';
    }
  }
  
  void _showFullImage(ReviewImage image, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  image.url,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.darkCard.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}