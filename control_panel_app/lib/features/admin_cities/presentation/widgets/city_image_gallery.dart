import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';

class CityImageGallery extends StatefulWidget {
  final List<String> images;
  final Function(List<String>) onImagesChanged;
  final VoidCallback? onAddImage;
  final bool isEditable;

  const CityImageGallery({
    super.key,
    required this.images,
    required this.onImagesChanged,
    this.onAddImage,
    this.isEditable = true,
  });

  @override
  State<CityImageGallery> createState() => _CityImageGalleryState();
}

class _CityImageGalleryState extends State<CityImageGallery>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  int _selectedIndex = -1;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: widget.isEditable ? widget.images.length + 1 : widget.images.length,
          itemBuilder: (context, index) {
            if (widget.isEditable && index == widget.images.length) {
              return _buildAddButton();
            }
            
            return _buildImageItem(index);
          },
        ),
      ),
    );
  }
  
  Widget _buildImageItem(int index) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedIndex = isSelected ? -1 : index;
        });
      },
      onLongPress: widget.isEditable ? () => _showImageOptions(index) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        margin: EdgeInsets.only(
          left: index == 0 ? 0 : 8,
        ),
        transform: Matrix4.identity()
          ..scale(isSelected ? 0.95 : 1.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryBlue
                : AppTheme.darkBorder.withOpacity(0.3),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: _buildImage(widget.images[index]),
            ),
            
            // Overlay
            if (isSelected)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: AppTheme.primaryBlue.withOpacity(0.2),
                ),
              ),
            
            // Delete Button
            if (widget.isEditable)
              Positioned(
                top: 4,
                left: 4,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.error.withOpacity(0.9),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
            
            // Index Badge
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.darkBackground.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${index + 1}',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildImage(String imageUrl) {
    // Check if it's a network URL or local path
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppTheme.darkCard,
            child: Icon(
              Icons.broken_image_rounded,
              color: AppTheme.textMuted,
              size: 32,
            ),
          );
        },
      );
    } else {
      // For local images (في بيئة التطوير فقط)
      return Container(
        color: AppTheme.darkCard,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_rounded,
              color: AppTheme.primaryBlue,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              'محلي',
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      );
    }
  }
  
  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onAddImage?.call();
      },
      child: Container(
        width: 100,
        margin: EdgeInsets.only(
          left: widget.images.isEmpty ? 0 : 8,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryBlue.withOpacity(0.1),
              AppTheme.primaryPurple.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'إضافة صورة',
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _removeImage(int index) {
    HapticFeedback.mediumImpact();
    
    final updatedImages = List<String>.from(widget.images);
    updatedImages.removeAt(index);
    widget.onImagesChanged(updatedImages);
    
    if (_selectedIndex == index) {
      setState(() => _selectedIndex = -1);
    }
  }
  
  void _showImageOptions(int index) {
    HapticFeedback.mediumImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkCard.withOpacity(0.95),
              AppTheme.darkCard.withOpacity(0.85),
            ],
          ),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
          border: Border(
            top: BorderSide(
              color: AppTheme.primaryBlue.withOpacity(0.3),
              width: 2,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOption(
              icon: Icons.visibility_rounded,
              title: 'عرض الصورة',
              onTap: () {
                Navigator.of(context).pop();
                _viewImage(index);
              },
            ),
            const SizedBox(height: AppDimensions.spaceMedium),
            _buildOption(
              icon: Icons.edit_rounded,
              title: 'تعديل الصورة',
              onTap: () {
                Navigator.of(context).pop();
                // Implement edit functionality
              },
            ),
            const SizedBox(height: AppDimensions.spaceMedium),
            _buildOption(
              icon: Icons.delete_rounded,
              title: 'حذف الصورة',
              color: AppTheme.error,
              onTap: () {
                Navigator.of(context).pop();
                _removeImage(index);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          color: (color ?? AppTheme.primaryBlue).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (color ?? AppTheme.primaryBlue).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color ?? AppTheme.primaryBlue,
              size: 24,
            ),
            const SizedBox(width: AppDimensions.spaceMedium),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: color ?? AppTheme.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _viewImage(int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Blurred Background
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            
            // Image
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              child: _buildImage(widget.images[index]),
            ),
            
            // Close Button
            Positioned(
              top: 40,
              left: 20,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.darkBackground.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}