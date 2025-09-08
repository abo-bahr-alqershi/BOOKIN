// lib/features/admin_cities/presentation/widgets/city_image_gallery.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';

class CityImageGallery extends StatefulWidget {
  final List<String> images;
  final Function(List<String>) onImagesChanged;
  final bool isReadOnly;
  final int maxImages;
  
  const CityImageGallery({
    super.key,
    required this.images,
    required this.onImagesChanged,
    this.isReadOnly = false,
    this.maxImages = 10,
  });
  
  @override
  State<CityImageGallery> createState() => _CityImageGalleryState();
}

class _CityImageGalleryState extends State<CityImageGallery>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  late AnimationController _animationController;
  late AnimationController _uploadAnimationController;
  
  List<String> _localImages = [];
  Map<String, double> _uploadProgress = {};
  int? _primaryImageIndex = 0;
  bool _isSelectionMode = false;
  final Set<int> _selectedIndices = {};
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _uploadAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat();
    
    _localImages = List.from(widget.images);
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _uploadAnimationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with controls
        _buildHeader(),
        
        const SizedBox(height: 20),
        
        // Upload area
        if (!widget.isReadOnly && _localImages.length < widget.maxImages)
          _buildUploadArea(),
        
        // Images grid
        if (_localImages.isNotEmpty) ...[
          if (!widget.isReadOnly && _localImages.length < widget.maxImages)
            const SizedBox(height: 20),
          _buildImagesGrid(),
        ],
        
        // Empty state
        if (_localImages.isEmpty && widget.isReadOnly)
          _buildEmptyState(),
      ],
    );
  }
  
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isSelectionMode
                  ? 'تم تحديد ${_selectedIndices.length}'
                  : 'الصور (${_localImages.length}/${widget.maxImages})',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'يمكنك إضافة حتى ${widget.maxImages} صور',
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.textMuted.withOpacity(0.7),
              ),
            ),
          ],
        ),
        
        if (!widget.isReadOnly && _localImages.isNotEmpty)
          Row(
            children: [
              // Selection mode toggle
              _buildActionButton(
                icon: _isSelectionMode
                    ? Icons.close_rounded
                    : Icons.check_circle_outline_rounded,
                label: _isSelectionMode ? 'إلغاء' : 'تحديد',
                onTap: () {
                  setState(() {
                    _isSelectionMode = !_isSelectionMode;
                    _selectedIndices.clear();
                  });
                },
                isActive: _isSelectionMode,
              ),
              
              // Delete selected
              if (_isSelectionMode && _selectedIndices.isNotEmpty) ...[
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.delete_outline_rounded,
                  label: 'حذف',
                  onTap: _deleteSelectedImages,
                  isDestructive: true,
                ),
              ],
            ],
          ),
      ],
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDestructive
              ? AppTheme.error.withOpacity(0.1)
              : isActive
                  ? AppTheme.primaryBlue.withOpacity(0.1)
                  : AppTheme.darkCard.withOpacity(0.5),
          border: Border.all(
            color: isDestructive
                ? AppTheme.error.withOpacity(0.3)
                : isActive
                    ? AppTheme.primaryBlue.withOpacity(0.3)
                    : AppTheme.darkBorder.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isDestructive
                  ? AppTheme.error
                  : isActive
                      ? AppTheme.primaryBlue
                      : AppTheme.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isDestructive
                    ? AppTheme.error
                    : isActive
                        ? AppTheme.primaryBlue
                        : AppTheme.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUploadArea() {
    return GestureDetector(
      onTap: _showImagePickerOptions,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppTheme.darkCard.withOpacity(0.3),
        ),
        child: DottedBorder(
          borderType: BorderType.RRect,
          radius: const Radius.circular(20),
          color: AppTheme.primaryBlue.withOpacity(0.3),
          strokeWidth: 1.5,
          dashPattern: const [8, 4],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryBlue.withOpacity(0.2),
                        AppTheme.primaryPurple.withOpacity(0.2),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.add_photo_alternate_outlined,
                    color: AppTheme.primaryBlue,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'إضافة صور',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'PNG, JPG • Max 10MB',
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildImagesGrid() {
    return AnimationLimiter(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: _localImages.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: 4,
            child: ScaleAnimation(
              scale: 0.95,
              child: FadeInAnimation(
                child: _buildImageItem(index),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildImageItem(int index) {
    final isSelected = _selectedIndices.contains(index);
    final isPrimary = index == _primaryImageIndex;
    final imagePath = _localImages[index];
    final isNetworkImage = imagePath.startsWith('http');
    
    return GestureDetector(
      onTap: () {
        if (_isSelectionMode) {
          setState(() {
            if (isSelected) {
              _selectedIndices.remove(index);
            } else {
              _selectedIndices.add(index);
            }
          });
        } else {
          _previewImage(imagePath);
        }
      },
      onLongPress: () {
        if (!widget.isReadOnly) {
          HapticFeedback.mediumImpact();
          _showImageOptions(index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryBlue.withOpacity(0.6)
                : isPrimary
                    ? AppTheme.warning.withOpacity(0.5)
                    : AppTheme.darkBorder.withOpacity(0.2),
            width: isSelected || isPrimary ? 2 : 0.5,
          ),
          boxShadow: [
            if (isSelected || isPrimary)
              BoxShadow(
                color: isSelected
                    ? AppTheme.primaryBlue.withOpacity(0.3)
                    : AppTheme.warning.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 1,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              isNetworkImage
                  ? CachedNetworkImage(
                      imageUrl: imagePath,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppTheme.darkCard,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryBlue.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppTheme.darkCard,
                        child: Icon(
                          Icons.error_outline,
                          color: AppTheme.error.withOpacity(0.5),
                        ),
                      ),
                    )
                  : Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppTheme.darkCard,
                          child: Icon(
                            Icons.error_outline,
                            color: AppTheme.error.withOpacity(0.5),
                          ),
                        );
                      },
                    ),
              
              // Overlay gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
              ),
              
              // Primary badge
              if (isPrimary)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppTheme.warning.withOpacity(0.9),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'رئيسية',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Selection checkbox
              if (_isSelectionMode)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? AppTheme.primaryBlue
                          : AppTheme.darkCard.withOpacity(0.8),
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 14,
                          )
                        : null,
                  ),
                ),
              
              // Upload progress
              if (_uploadProgress.containsKey(imagePath))
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.7),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: _uploadProgress[imagePath],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppTheme.darkCard.withOpacity(0.2),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              color: AppTheme.textMuted.withOpacity(0.3),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد صور',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textMuted.withOpacity(0.5),
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ImagePickerSheet(
        onCameraSelected: () {
          Navigator.pop(context);
          _pickImage(ImageSource.camera);
        },
        onGallerySelected: () {
          Navigator.pop(context);
          _pickImage(ImageSource.gallery);
        },
        onMultipleSelected: () {
          Navigator.pop(context);
          _pickMultipleImages();
        },
      ),
    );
  }
  
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _localImages.add(image.path);
          if (_primaryImageIndex == null && _localImages.isNotEmpty) {
            _primaryImageIndex = 0;
          }
        });
        widget.onImagesChanged(_localImages);
      }
    } catch (e) {
      // Handle error
    }
  }
  
  Future<void> _pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 85,
      );
      
      if (images.isNotEmpty) {
        final remainingSlots = widget.maxImages - _localImages.length;
        final imagesToAdd = images.take(remainingSlots).toList();
        
        if (imagesToAdd.isNotEmpty) {
          setState(() {
            _localImages.addAll(imagesToAdd.map((img) => img.path));
            if (_primaryImageIndex == null && _localImages.isNotEmpty) {
              _primaryImageIndex = 0;
            }
          });
          widget.onImagesChanged(_localImages);
        }
      }
    } catch (e) {
      // Handle error
    }
  }
  
  void _showImageOptions(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ImageOptionsSheet(
        isPrimary: index == _primaryImageIndex,
        onSetPrimary: () {
          Navigator.pop(context);
          setState(() {
            _primaryImageIndex = index;
          });
        },
        onDelete: () {
          Navigator.pop(context);
          _deleteImage(index);
        },
        onView: () {
          Navigator.pop(context);
          _previewImage(_localImages[index]);
        },
      ),
    );
  }
  
  void _deleteImage(int index) {
    setState(() {
      _localImages.removeAt(index);
      if (_primaryImageIndex == index) {
        _primaryImageIndex = _localImages.isEmpty ? null : 0;
      } else if (_primaryImageIndex != null && _primaryImageIndex! > index) {
        _primaryImageIndex = _primaryImageIndex! - 1;
      }
    });
    widget.onImagesChanged(_localImages);
  }
  
  void _deleteSelectedImages() {
    final sortedIndices = _selectedIndices.toList()..sort((a, b) => b.compareTo(a));
    for (var index in sortedIndices) {
      _localImages.removeAt(index);
    }
    
    setState(() {
      _selectedIndices.clear();
      _isSelectionMode = false;
      if (_primaryImageIndex != null && _primaryImageIndex! >= _localImages.length) {
        _primaryImageIndex = _localImages.isEmpty ? null : 0;
      }
    });
    
    widget.onImagesChanged(_localImages);
  }
  
  void _previewImage(String imagePath) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: _ImagePreview(imagePath: imagePath),
          );
        },
      ),
    );
  }
}

// Supporting Widgets

class _ImagePickerSheet extends StatelessWidget {
  final VoidCallback onCameraSelected;
  final VoidCallback onGallerySelected;
  final VoidCallback onMultipleSelected;
  
  const _ImagePickerSheet({
    required this.onCameraSelected,
    required this.onGallerySelected,
    required this.onMultipleSelected,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.darkBorder.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          _buildOption(
            icon: Icons.camera_alt_outlined,
            title: 'الكاميرا',
            onTap: onCameraSelected,
          ),
          const SizedBox(height: 12),
          _buildOption(
            icon: Icons.photo_outlined,
            title: 'صورة واحدة',
            onTap: onGallerySelected,
          ),
          const SizedBox(height: 12),
          _buildOption(
            icon: Icons.collections_outlined,
            title: 'عدة صور',
            onTap: onMultipleSelected,
          ),
        ],
      ),
    );
  }
  
  Widget _buildOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppTheme.inputBackground.withOpacity(0.3),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryBlue,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textWhite,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.textMuted.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageOptionsSheet extends StatelessWidget {
  final bool isPrimary;
  final VoidCallback onSetPrimary;
  final VoidCallback onDelete;
  final VoidCallback onView;
  
  const _ImageOptionsSheet({
    required this.isPrimary,
    required this.onSetPrimary,
    required this.onDelete,
    required this.onView,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.darkBorder.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          _buildOption(
            icon: Icons.visibility_outlined,
            title: 'عرض الصورة',
            onTap: onView,
          ),
          if (!isPrimary) ...[
            const SizedBox(height: 12),
            _buildOption(
              icon: Icons.star_outline_rounded,
              title: 'تعيين كصورة رئيسية',
              onTap: onSetPrimary,
              color: AppTheme.warning,
            ),
          ],
          const SizedBox(height: 12),
          _buildOption(
            icon: Icons.delete_outline_rounded,
            title: 'حذف الصورة',
            onTap: onDelete,
            color: AppTheme.error,
          ),
        ],
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
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color?.withOpacity(0.1) ?? AppTheme.inputBackground.withOpacity(0.3),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color ?? AppTheme.primaryBlue,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: color ?? AppTheme.textWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final String imagePath;
  
  const _ImagePreview({required this.imagePath});
  
  @override
  Widget build(BuildContext context) {
    final isNetworkImage = imagePath.startsWith('http');
    
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Stack(
        children: [
          Center(
            child: isNetworkImage
                ? CachedNetworkImage(
                    imageUrl: imagePath,
                    fit: BoxFit.contain,
                  )
                : Image.file(
                    File(imagePath),
                    fit: BoxFit.contain,
                  ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.darkCard.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}