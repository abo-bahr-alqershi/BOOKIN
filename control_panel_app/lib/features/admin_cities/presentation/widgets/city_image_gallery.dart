// lib/features/admin_cities/presentation/widgets/city_image_gallery.dart
// نسخة محسّنة

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:reorderables/reorderables.dart';
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
  late AnimationController _pulseController;

  List<String> _localImages = [];
  final Map<String, double> _uploadProgress = {};
  int? _primaryImageIndex = 0;
  bool _isSelectionMode = false;
  bool _isReorderMode = false;
  final Set<int> _selectedIndices = {};
  int? _hoveredIndex;

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

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _localImages = List.from(widget.images);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _uploadAnimationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with enhanced design
        _buildEnhancedHeader(),

        const SizedBox(height: 20),

        // Upload area with glass morphism
        if (!widget.isReadOnly && _localImages.length < widget.maxImages)
          _buildEnhancedUploadArea(),

        // Images grid with animations or reorder grid
        if (_localImages.isNotEmpty) ...[
          if (!widget.isReadOnly && _localImages.length < widget.maxImages)
            const SizedBox(height: 20),
          _isReorderMode ? _buildReorderableGrid() : _buildEnhancedImagesGrid(),
        ],

        // Empty state with better design
        if (_localImages.isEmpty && widget.isReadOnly)
          _buildEnhancedEmptyState(),
      ],
    );
  }

  Widget _buildEnhancedHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Animated icon
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 600),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.photo_fill_on_rectangle_fill,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10),
                Text(
                  _isSelectionMode
                      ? 'تم تحديد ${_selectedIndices.length}'
                      : 'معرض الصور',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryBlue.withValues(alpha: 0.1),
                        AppTheme.primaryPurple.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    '${_localImages.length}/${widget.maxImages}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'صورة',
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
        if (!widget.isReadOnly && _localImages.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  if (!_isSelectionMode)
                    _buildActionChip(
                      icon: _isReorderMode ? Icons.done_rounded : Icons.swap_vert_rounded,
                      label: _isReorderMode ? 'تم' : 'ترتيب',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _isReorderMode = !_isReorderMode;
                          if (_isReorderMode) {
                            _isSelectionMode = false;
                            _selectedIndices.clear();
                          }
                        });
                      },
                      isActive: _isReorderMode,
                    ),
                  const SizedBox(width: 8),
                  if (!_isReorderMode)
                    _buildActionChip(
                      icon: _isSelectionMode ? Icons.done_rounded : Icons.check_circle_outline_rounded,
                      label: _isSelectionMode ? 'تم' : 'تحديد',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _isSelectionMode = !_isSelectionMode;
                          if (_isSelectionMode) {
                            _isReorderMode = false;
                          } else {
                            _selectedIndices.clear();
                          }
                        });
                      },
                      isActive: _isSelectionMode,
                    ),
                  if (_isSelectionMode && _selectedIndices.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    _buildActionChip(
                      icon: Icons.delete_outline_rounded,
                      label: 'حذف',
                      onTap: _deleteSelectedImages,
                      color: AppTheme.error,
                    ),
                  ],
                ],
              ),
              if (_isSelectionMode || _isReorderMode)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.darkCard.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.darkBorder.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    _isReorderMode
                        ? 'اسحب الصور لإعادة الترتيب'
                        : 'اضغط لتحديد الصور ثم احذفها',
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    Color? color,
  }) {
    final baseColor = color ?? AppTheme.primaryBlue;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isActive
              ? LinearGradient(colors: [baseColor.withValues(alpha: 0.2), baseColor.withValues(alpha: 0.1)])
              : null,
          color: !isActive ? AppTheme.darkCard.withValues(alpha: 0.5) : null,
          border: Border.all(
            color: (isActive ? baseColor : AppTheme.darkBorder).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isActive ? baseColor : AppTheme.textMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isActive ? baseColor : AppTheme.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedActionButton({
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isDestructive
              ? LinearGradient(
                  colors: [
                    AppTheme.error.withValues(alpha: 0.15),
                    AppTheme.error.withValues(alpha: 0.08),
                  ],
                )
              : isActive
                  ? AppTheme.primaryGradient.scale(0.1)
                  : null,
          color: !isDestructive && !isActive
              ? AppTheme.darkCard.withValues(alpha: 0.5)
              : null,
          border: Border.all(
            color: isDestructive
                ? AppTheme.error.withValues(alpha: 0.3)
                : isActive
                    ? AppTheme.primaryBlue.withValues(alpha: 0.3)
                    : AppTheme.darkBorder.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: isActive || isDestructive
              ? [
                  BoxShadow(
                    color:
                        (isDestructive ? AppTheme.error : AppTheme.primaryBlue)
                            .withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
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
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedUploadArea() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return GestureDetector(
          onTap: _showImagePickerOptions,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withValues(
                    alpha: 0.1 * _pulseController.value,
                  ),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(20),
                  color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                  strokeWidth: 1.5,
                  dashPattern: const [8, 4],
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryBlue.withValues(alpha: 0.05),
                          AppTheme.primaryPurple.withValues(alpha: 0.03),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryBlue
                                      .withValues(alpha: 0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add_photo_alternate_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'إضافة صور',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppTheme.textWhite,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'PNG, JPG • Max 10MB',
                            style: AppTextStyles.caption.copyWith(
                              color: AppTheme.textMuted.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
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

  Widget _buildEnhancedImagesGrid() {
    return AnimationLimiter(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getGridCrossAxisCount(context),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: _localImages.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: _getGridCrossAxisCount(context),
            child: ScaleAnimation(
              scale: 0.95,
              child: FadeInAnimation(
                child: _buildEnhancedImageItem(index),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReorderableGrid() {
    final cross = _getGridCrossAxisCount(context);
    // Build children with keys
    final children = <Widget>[];
    for (int index = 0; index < _localImages.length; index++) {
      children.add(Container(
        key: ValueKey(_localImages[index]),
        width: double.infinity,
        child: _buildEnhancedImageItem(index),
      ));
    }

    return ReorderableWrap(
      spacing: 12,
      runSpacing: 12,
      needsLongPressDraggable: false,
      maxMainAxisCount: cross,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          final item = _localImages.removeAt(oldIndex);
          _localImages.insert(newIndex, item);
          // Adjust primary index if needed
          if (_primaryImageIndex != null) {
            if (oldIndex == _primaryImageIndex) {
              _primaryImageIndex = newIndex;
            } else if (_primaryImageIndex! > oldIndex && _primaryImageIndex! <= newIndex) {
              _primaryImageIndex = _primaryImageIndex! - 1;
            } else if (_primaryImageIndex! < oldIndex && _primaryImageIndex! >= newIndex) {
              _primaryImageIndex = _primaryImageIndex! + 1;
            }
          }
        });
        widget.onImagesChanged(_localImages);
      },
      children: children,
    );
  }

  int _getGridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 350) return 3;
    if (width < 500) return 4;
    return 5;
  }

  Widget _buildEnhancedImageItem(int index) {
    final isSelected = _selectedIndices.contains(index);
    final isPrimary = index == _primaryImageIndex;
    final imagePath = _localImages[index];
    final isNetworkImage = imagePath.startsWith('http');

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: GestureDetector(
        onTap: () {
        HapticFeedback.lightImpact();
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
        transform: Matrix4.identity()..scale(isSelected ? 0.95 : 1.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryBlue
                : isPrimary
                    ? AppTheme.warning.withValues(alpha: 0.6)
                    : AppTheme.darkBorder.withValues(alpha: 0.2),
            width: isSelected || isPrimary ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected || isPrimary)
              BoxShadow(
                color: isSelected
                    ? AppTheme.primaryBlue.withValues(alpha: 0.3)
                    : AppTheme.warning.withValues(alpha: 0.2),
                blurRadius: 15,
                spreadRadius: 1,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Enhanced image display
              isNetworkImage
                  ? CachedNetworkImage(
                      imageUrl: imagePath,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.darkCard,
                              AppTheme.darkCard.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryBlue.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppTheme.darkCard,
                        child: Icon(
                          Icons.error_outline,
                          color: AppTheme.error.withValues(alpha: 0.5),
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
                            color: AppTheme.error.withValues(alpha: 0.5),
                          ),
                        );
                      },
                    ),

              // Enhanced overlay gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                    ],
                    stops: const [0.6, 1.0],
                  ),
                ),
              ),

              // Enhanced primary badge
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
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.warning,
                          AppTheme.warning.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.warning.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
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

              // Enhanced selection checkbox
              if (_isSelectionMode)
                Positioned(
                  top: 8,
                  right: 8,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppTheme.primaryGradient : null,
                      color: isSelected
                          ? null
                          : AppTheme.darkCard.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? AppTheme.primaryBlue.withValues(alpha: 0.4)
                              : Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 14,
                          )
                        : null,
                  ),
                ),

              // Quick Actions (hover)
              if (!widget.isReadOnly && !_isSelectionMode && !_isReorderMode)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  top: (_hoveredIndex == index) ? 8 : -40,
                  left: 8,
                  right: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildQuickActionButton(
                        icon: Icons.visibility_outlined,
                        onTap: () => _previewImage(imagePath),
                      ),
                      if (!isPrimary) const SizedBox(width: 6),
                      if (!isPrimary)
                        _buildQuickActionButton(
                          icon: Icons.star_outline_rounded,
                          color: AppTheme.warning,
                          onTap: () => _showImageOptions(index),
                        ),
                      const SizedBox(width: 6),
                      _buildQuickActionButton(
                        icon: Icons.delete_outline_rounded,
                        color: AppTheme.error,
                        onTap: () => _deleteImage(index),
                      ),
                    ],
                  ),
                ),

              // Upload progress with better design
              if (_uploadProgress.containsKey(imagePath))
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.darkBackground.withValues(alpha: 0.8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: _uploadProgress[imagePath],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryBlue,
                            ),
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(_uploadProgress[imagePath]! * 100).toInt()}%',
                            style: AppTextStyles.caption.copyWith(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppTheme.darkBackground.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: (color ?? AppTheme.primaryBlue).withValues(alpha: 0.3),
          ),
        ),
        child: Icon(icon, size: 16, color: color ?? AppTheme.primaryBlue),
      ),
    );
  }

  Widget _buildEnhancedEmptyState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.3),
            AppTheme.darkCard.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              color: AppTheme.textMuted.withValues(alpha: 0.3),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد صور',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textMuted.withValues(alpha: 0.5),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'لم يتم إضافة أي صور بعد',
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.textMuted.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // باقي الدوال كما هي مع تحسينات طفيفة...
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _EnhancedImagePickerSheet(
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
      builder: (context) => _EnhancedImageOptionsSheet(
        isPrimary: index == _primaryImageIndex,
        onSetPrimary: () {
          Navigator.pop(context);
          setState(() {
            _primaryImageIndex = index;
            // Move primary to front to mirror unit/property behavior
            if (index != 0) {
              final item = _localImages.removeAt(index);
              _localImages.insert(0, item);
              _primaryImageIndex = 0;
              widget.onImagesChanged(_localImages);
            } else {
              widget.onImagesChanged(_localImages);
            }
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
    final sortedIndices = _selectedIndices.toList()
      ..sort((a, b) => b.compareTo(a));
    for (var index in sortedIndices) {
      _localImages.removeAt(index);
    }

    setState(() {
      _selectedIndices.clear();
      _isSelectionMode = false;
      if (_primaryImageIndex != null &&
          _primaryImageIndex! >= _localImages.length) {
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
            child: _EnhancedImagePreview(imagePath: imagePath),
          );
        },
      ),
    );
  }
}

// Enhanced Supporting Widgets

class _EnhancedImagePickerSheet extends StatelessWidget {
  final VoidCallback onCameraSelected;
  final VoidCallback onGallerySelected;
  final VoidCallback onMultipleSelected;

  const _EnhancedImagePickerSheet({
    required this.onCameraSelected,
    required this.onGallerySelected,
    required this.onMultipleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.darkCard.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(
                color: AppTheme.darkBorder.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.darkBorder.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              _buildEnhancedOption(
                icon: Icons.camera_alt_outlined,
                title: 'الكاميرا',
                subtitle: 'التقط صورة جديدة',
                gradient: [AppTheme.primaryBlue, AppTheme.primaryCyan],
                onTap: onCameraSelected,
              ),
              const SizedBox(height: 12),
              _buildEnhancedOption(
                icon: Icons.photo_outlined,
                title: 'صورة واحدة',
                subtitle: 'اختر صورة من المعرض',
                gradient: [AppTheme.primaryPurple, AppTheme.primaryViolet],
                onTap: onGallerySelected,
              ),
              const SizedBox(height: 12),
              _buildEnhancedOption(
                icon: Icons.collections_outlined,
                title: 'عدة صور',
                subtitle: 'اختر عدة صور دفعة واحدة',
                gradient: [AppTheme.success, AppTheme.neonGreen],
                onTap: onMultipleSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: gradient.map((c) => c.withValues(alpha: 0.05)).toList(),
            ),
            border: Border.all(
              color: gradient.first.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.first.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.textMuted.withValues(alpha: 0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnhancedImageOptionsSheet extends StatelessWidget {
  final bool isPrimary;
  final VoidCallback onSetPrimary;
  final VoidCallback onDelete;
  final VoidCallback onView;

  const _EnhancedImageOptionsSheet({
    required this.isPrimary,
    required this.onSetPrimary,
    required this.onDelete,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.darkCard.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(
                color: AppTheme.darkBorder.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.darkBorder.withValues(alpha: 0.3),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                (color ?? AppTheme.primaryBlue).withValues(alpha: 0.1),
                (color ?? AppTheme.primaryBlue).withValues(alpha: 0.05),
              ],
            ),
            border: Border.all(
              color: (color ?? AppTheme.primaryBlue).withValues(alpha: 0.2),
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
              const SizedBox(width: 16),
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: color ?? AppTheme.textWhite,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnhancedImagePreview extends StatelessWidget {
  final String imagePath;

  const _EnhancedImagePreview({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final isNetworkImage = imagePath.startsWith('http');

    return Scaffold(
      backgroundColor: Colors.black87,
      body: Stack(
        children: [
          // Blurred background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ),

          // Image
          Center(
            child: Hero(
              tag: imagePath,
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
          ),

          // Close button with glassmorphism
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.darkCard.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.darkBorder.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
