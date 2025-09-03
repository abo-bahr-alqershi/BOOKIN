// lib/features/admin_properties/presentation/widgets/unit_image_gallery.dart

import 'dart:async';
import 'package:bookn_cp_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:bookn_cp_app/core/theme/app_colors.dart';
import 'package:bookn_cp_app/core/theme/app_text_styles.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:reorderables/reorderables.dart';
import '../../domain/entities/unit_image.dart';
import '../bloc/unit_images/unit_images_bloc.dart';
import '../bloc/unit_images/unit_images_event.dart';
import '../bloc/unit_images/unit_images_state.dart';

class UnitImageGallery extends StatefulWidget {
  final String? unitId;
  final String? tempKey;
  final bool isReadOnly;
  final int maxImages;
  final Function(List<UnitImage>)? onImagesChanged;
  final Function(List<String>)? onLocalImagesChanged;
  final List<UnitImage>? initialImages;
  final List<String>? initialLocalImages;
  
  const UnitImageGallery({
    super.key,
    this.unitId,
    this.tempKey,
    this.isReadOnly = false,
    this.maxImages = 10,
    this.onImagesChanged,
    this.onLocalImagesChanged,
    this.initialImages,
    this.initialLocalImages,
  });
  
  @override
  State<UnitImageGallery> createState() => UnitImageGalleryState();
}

class UnitImageGalleryState extends State<UnitImageGallery>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late AnimationController _selectionController;
  UnitImagesBloc? _imagesBloc;
  
  // Local state management
  List<String> _localImages = [];
  List<UnitImage> _remoteImages = [];
  List<UnitImage> _displayImages = [];
  
  // Upload tracking
  Map<String, double> _uploadProgress = {};
  Set<String> _uploadingFiles = {};
  
  int? _hoveredIndex;
  bool _isDragging = false;
  bool _isSelectionMode = false;
  bool _isReorderMode = false;
  final Set<String> _selectedImageIds = {};
  final Set<int> _selectedLocalIndices = {};
  int? _primaryImageIndex = 0;
  
  // تحديد الوضع المحلي بناءً على وجود unitId
  bool get _isLocalMode => (widget.unitId == null || widget.unitId!.isEmpty) && (widget.tempKey == null || widget.tempKey!.isEmpty);
  bool _isInitialLoadDone = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _animationController.forward();
    
    // Initialize local images if provided
    if (widget.initialLocalImages != null) {
      _localImages = List.from(widget.initialLocalImages!);
    }
    
    // Initialize remote images if provided (for edit mode)
    if (widget.initialImages != null && !_isLocalMode) {
      _remoteImages = List.from(widget.initialImages!);
      _displayImages = List.from(widget.initialImages!);
      _primaryImageIndex = _displayImages.indexWhere((img) => img.isPrimary == true);
      if (_primaryImageIndex == -1) _primaryImageIndex = 0;
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // فقط تحميل الصور إذا كان هناك unitId صالح
    if (!_isLocalMode && !_isInitialLoadDone) {
      try {
        _imagesBloc = context.read<UnitImagesBloc?>();
        if (_imagesBloc != null && ((widget.unitId != null && widget.unitId!.isNotEmpty) || (widget.tempKey != null && widget.tempKey!.isNotEmpty))) {
          _imagesBloc!.add(LoadUnitImagesEvent(unitId: widget.unitId, tempKey: widget.tempKey));
          _isInitialLoadDone = true;
        }
      } catch (e) {
        debugPrint('UnitImagesBloc not available, working in local mode');
      }
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _selectionController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // العمل في الوضع المحلي إذا لم يكن هناك unitId
    if (_isLocalMode) {
      return _buildLocalModeContent();
    }
    
    // العمل مع Bloc إذا كان هناك unitId
    if (_imagesBloc == null) {
      return _buildLocalModeContent();
    }
    
    return BlocConsumer<UnitImagesBloc, UnitImagesState>(
      bloc: _imagesBloc,
      listener: (context, state) {
        _handleStateChanges(state);
      },
      builder: (context, state) {
        return _buildContent(state);
      },
    );
  }
  
  // دالة لرفع الصور المحلية بعد إنشاء العقار
  Future<void> uploadLocalImages(String newUnitId) async {
    if (_localImages.isEmpty || _imagesBloc == null) return;
    
    // رفع جميع الصور المحلية
    _imagesBloc!.add(UploadMultipleUnitImagesEvent(
      unitId: newUnitId,
      filePaths: _localImages,
    ));
    
    // مسح القائمة المحلية
    setState(() {
      _localImages.clear();
    });
  }
  
  Widget _buildContent(UnitImagesState state) {
    final images = _displayImages.isNotEmpty ? _displayImages : _getImagesFromState(state);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEnhancedHeader(images.length, state),
        const SizedBox(height: 20),
        
        // Upload Progress Cards
        if (_uploadingFiles.isNotEmpty)
          _buildUploadProgressCards(),
        
        // Main Content Area
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildMainContent(images, state),
        ),
      ],
    );
  }
  
  Widget _buildLocalModeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLocalHeaderSection(_localImages.length),
        const SizedBox(height: 20),
        
        if (!widget.isReadOnly && _localImages.length < widget.maxImages)
          _buildMinimalistUploadArea(),
        
        if (_localImages.isNotEmpty) ...[
          if (!widget.isReadOnly && _localImages.length < widget.maxImages)
            const SizedBox(height: 24),
          _buildLocalImagesGrid(_localImages),
        ],
        
        if (_localImages.isEmpty && widget.isReadOnly)
          _buildMinimalistEmptyState(),
      ],
    );
  }
  
  Widget _buildLocalHeaderSection(int imageCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isSelectionMode 
                      ? 'تم تحديد ${_selectedLocalIndices.length}'
                      : 'معرض الصور (محلي)',
                    style: AppTextStyles.heading3.copyWith(
                      color: AppTheme.textWhite,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$imageCount من ${widget.maxImages}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.textMuted.withOpacity(0.7),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
              
              // Local mode indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppTheme.warning.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 12,
                      color: AppTheme.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'سيتم الرفع عند الحفظ',
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.warning,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildLocalImagesGrid(List<String> images) {
    return AnimationLimiter(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 275),
            columnCount: 3,
            child: ScaleAnimation(
              scale: 0.95,
              child: FadeInAnimation(
                child: _buildLocalImageItem(
                  images[index],
                  index,
                  _selectedLocalIndices.contains(index),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildLocalImageItem(String imagePath, int index, bool isSelected) {
    final bool isHovered = _hoveredIndex == index;
    final bool isPrimary = index == 0;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: GestureDetector(
        onTap: () {
          if (_isSelectionMode) {
            setState(() {
              if (_selectedLocalIndices.contains(index)) {
                _selectedLocalIndices.remove(index);
              } else {
                _selectedLocalIndices.add(index);
              }
            });
          } else {
            _previewLocalImage(imagePath);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..scale(isHovered ? 0.97 : 1.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                ? AppTheme.primaryBlue.withOpacity(0.5)
                : AppTheme.darkBorder.withOpacity(0.1),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildImageFromPath(imagePath),
                
                // Gradient overlay
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(isHovered ? 0.5 : 0.2),
                      ],
                    ),
                  ),
                ),
                
                // Delete button
                if (!widget.isReadOnly)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    top: isHovered ? 8 : -40,
                    right: 8,
                    child: _buildQuickActionButton(
                      icon: Icons.delete_outline,
                      onTap: () => _deleteLocalImage(index),
                      color: AppTheme.error,
                    ),
                  ),
                
                // Primary badge
                if (isPrimary)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'رئيسية',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Local indicator
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.schedule,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _deleteLocalImage(int index) {
    setState(() {
      _localImages.removeAt(index);
      _selectedLocalIndices.remove(index);
      // تحديث الـ indices بعد الحذف
      final updatedIndices = <int>{};
      for (var i in _selectedLocalIndices) {
        if (i > index) {
          updatedIndices.add(i - 1);
        } else if (i < index) {
          updatedIndices.add(i);
        }
      }
      _selectedLocalIndices.clear();
      _selectedLocalIndices.addAll(updatedIndices);
    });
    
    if (widget.onLocalImagesChanged != null) {
      widget.onLocalImagesChanged!(_localImages);
    }
    
    _showSuccessSnackBar('تم حذف الصورة');
  }
  
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      
      if (image != null) {
        if (_isLocalMode) {
          // في الوضع المحلي، احفظ المسار فقط
          setState(() {
            _localImages.add(image.path);
          });
          if (widget.onLocalImagesChanged != null) {
            widget.onLocalImagesChanged!(_localImages);
          }
          _showSuccessSnackBar('تم إضافة الصورة (سيتم الرفع عند الحفظ)');
        } else if (_imagesBloc != null && (widget.unitId != null || (widget.tempKey != null && widget.tempKey!.isNotEmpty))) {
          // في وضع التعديل، ارفع مباشرة
          setState(() {
            _uploadingFiles.add(image.path);
          });
          _imagesBloc!.add(UploadUnitImageEvent(
            unitId: widget.unitId,
            tempKey: widget.tempKey,
            filePath: image.path,
            isPrimary: _displayImages.isEmpty,
          ));
        }
      }
    } catch (e) {
      _showErrorSnackBar('فشل في اختيار الصورة');
    }
  }
  
  Future<void> _pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 85,
      );
      
      if (images.isNotEmpty) {
        final remainingSlots = widget.maxImages - (_isLocalMode ? _localImages.length : _displayImages.length);
        final imagesToAdd = images.take(remainingSlots).toList();
        
        if (imagesToAdd.isNotEmpty) {
          if (_isLocalMode) {
            // في الوضع المحلي
            setState(() {
              _localImages.addAll(imagesToAdd.map((img) => img.path));
            });
            if (widget.onLocalImagesChanged != null) {
              widget.onLocalImagesChanged!(_localImages);
            }
            _showSuccessSnackBar('تم إضافة ${imagesToAdd.length} صورة (سيتم الرفع عند الحفظ)');
          } else if (_imagesBloc != null && widget.unitId != null) {
            // في وضع التعديل
            setState(() {
              for (var img in imagesToAdd) {
                _uploadingFiles.add(img.path);
              }
            });
            _imagesBloc!.add(UploadMultipleUnitImagesEvent(
              unitId: widget.unitId,
              tempKey: widget.tempKey,
              filePaths: imagesToAdd.map((img) => img.path).toList(),
            ));
          }
        }
      }
    } catch (e) {
      _showErrorSnackBar('فشل في اختيار الصور');
    }
  }
  
  // باقي الدوال تبقى كما هي مع التعديلات اللازمة...
  
  Widget _buildEnhancedHeader(int imageCount, UnitImagesState state) {
    final isSelectionMode = state is UnitImagesLoaded ? state.isSelectionMode : _isSelectionMode;
    final selectedCount = state is UnitImagesLoaded ? state.selectedImageIds.length : _selectedImageIds.length;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSelectionMode 
                      ? 'تم تحديد $selectedCount'
                      : _isReorderMode
                        ? 'ترتيب الصور'
                        : 'معرض الصور',
                    style: AppTextStyles.heading3.copyWith(
                      color: AppTheme.textWhite,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$imageCount من ${widget.maxImages}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.textMuted.withOpacity(0.7),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
              
              // Action Buttons
              if (!widget.isReadOnly && imageCount > 0)
                _buildHeaderActions(isSelectionMode),
            ],
          ),
          
          // Mode Instructions
          if (_isSelectionMode || _isReorderMode)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryBlue.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isSelectionMode 
                      ? Icons.info_outline_rounded
                      : Icons.drag_indicator_rounded,
                    size: 14,
                    color: AppTheme.primaryBlue.withOpacity(0.7),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isSelectionMode
                      ? 'اضغط على الصور لتحديدها'
                      : 'اسحب الصور لإعادة ترتيبها',
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.primaryBlue.withOpacity(0.8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildHeaderActions(bool isSelectionMode) {
    return Row(
      children: [
        // Selection Mode Toggle
        if (!_isReorderMode)
          _buildActionChip(
            icon: isSelectionMode 
              ? Icons.close_rounded 
              : Icons.check_circle_outline_rounded,
            label: isSelectionMode ? 'إلغاء' : 'تحديد',
            onTap: () {
              HapticFeedback.lightImpact();
              _toggleSelectionMode();
            },
            isActive: isSelectionMode,
          ),
        
        const SizedBox(width: 8),
        
        // Reorder Mode Toggle
        if (!isSelectionMode && _displayImages.length > 1)
          _buildActionChip(
            icon: _isReorderMode 
              ? Icons.done_rounded 
              : Icons.swap_vert_rounded,
            label: _isReorderMode ? 'تم' : 'ترتيب',
            onTap: () {
              HapticFeedback.lightImpact();
              _toggleReorderMode();
            },
            isActive: _isReorderMode,
          ),
        
        // Delete Selected Button
        if (isSelectionMode && _selectedImageIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: _buildActionChip(
              icon: Icons.delete_outline_rounded,
              label: 'حذف',
              onTap: _deleteSelectedImages,
              isDestructive: true,
            ),
          ),
      ],
    );
  }
  
  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDestructive
            ? AppTheme.error.withOpacity(0.1)
            : isActive
              ? AppTheme.primaryBlue.withOpacity(0.15)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDestructive
              ? AppTheme.error.withOpacity(0.3)
              : isActive
                ? AppTheme.primaryBlue.withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
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
                  : Colors.white.withOpacity(0.6),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isDestructive
                  ? AppTheme.error
                  : isActive
                    ? AppTheme.primaryBlue
                    : Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMainContent(List<UnitImage> images, UnitImagesState state) {
    if (state is UnitImagesLoading && images.isEmpty) {
      return _buildMinimalistLoadingState();
    }
    
    return Column(
      key: ValueKey('content-${images.length}-$_isReorderMode'),
      children: [
        // Upload Area
        if (!widget.isReadOnly && 
            images.length < widget.maxImages && 
            _uploadingFiles.isEmpty &&
            !_isSelectionMode &&
            !_isReorderMode)
          _buildMinimalistUploadArea(),
        
        // Images Grid
        if (images.isNotEmpty) ...[
          if (!widget.isReadOnly && images.length < widget.maxImages && !_isSelectionMode && !_isReorderMode)
            const SizedBox(height: 24),
          _isReorderMode
            ? _buildReorderableGrid(images)
            : _buildEnhancedImagesGrid(images, state),
        ],
        
        // Empty State
        if (images.isEmpty && widget.isReadOnly)
          _buildMinimalistEmptyState(),
      ],
    );
  }

  // باقي الدوال تبقى كما هي...
  Widget _buildReorderableGrid(List<UnitImage> images) {
    return ReorderableWrap(
      spacing: 8,
      runSpacing: 8,
      needsLongPressDraggable: false,
      children: images.asMap().entries.map((entry) {
        final index = entry.key;
        final image = entry.value;
        return _buildReorderableImageItem(image, index);
      }).toList(),
      onReorder: (oldIndex, newIndex) {
        _reorderImages(oldIndex, newIndex);
      },
    );
  }
  
  Widget _buildReorderableImageItem(UnitImage image, int index) {
    final isPrimary = index == _primaryImageIndex;
    
    return Container(
      key: ValueKey(image.id),
      width: (MediaQuery.of(context).size.width - 56) / 3,
      height: (MediaQuery.of(context).size.width - 56) / 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _buildOptimizedImage(image),
          ),
          
          // Drag Handle
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.darkCard.withOpacity(0.8),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.drag_indicator_rounded,
                size: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
          
          // Order Number
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppTheme.darkCard.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          
          // Primary Badge
          if (isPrimary)
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'رئيسية',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildEnhancedImagesGrid(List<UnitImage> images, UnitImagesState state) {
    final selectedImageIds = state is UnitImagesLoaded 
      ? state.selectedImageIds 
      : _selectedImageIds;
    final isSelectionMode = state is UnitImagesLoaded 
      ? state.isSelectionMode 
      : _isSelectionMode;
    
    return AnimationLimiter(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 275),
            columnCount: 3,
            child: ScaleAnimation(
              scale: 0.95,
              child: FadeInAnimation(
                child: _buildEnhancedImageItem(
                  images[index], 
                  index,
                  selectedImageIds.contains(images[index].id),
                  isSelectionMode,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildEnhancedImageItem(
    UnitImage image, 
    int index,
    bool isSelected,
    bool isSelectionMode,
  ) {
    final bool isHovered = _hoveredIndex == index;
    final bool isPrimary = index == _primaryImageIndex;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: GestureDetector(
        onTap: () {
          if (isSelectionMode) {
            HapticFeedback.lightImpact();
            if (_imagesBloc != null) {
              _imagesBloc!.add(ToggleUnitImageSelectionEvent(imageId: image.id));
            } else {
              setState(() {
                if (_selectedImageIds.contains(image.id)) {
                  _selectedImageIds.remove(image.id);
                } else {
                  _selectedImageIds.add(image.id);
                }
              });
            }
          } else {
            _previewImage(image);
          }
        },
        onLongPress: () {
          if (!widget.isReadOnly && !isSelectionMode) {
            HapticFeedback.mediumImpact();
            _showImageOptionsMenu(image, index);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..scale(isHovered || isSelected ? 0.95 : 1.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                ? AppTheme.primaryBlue.withOpacity(0.6)
                : AppTheme.darkBorder.withOpacity(0.1),
              width: isSelected ? 2.5 : 1,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ] : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image
                _buildOptimizedImage(image),
                
                // Gradient Overlay
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(
                          isHovered || isSelectionMode ? 0.6 : 0.3
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Quick Actions (visible on hover or mobile long press)
                if (!widget.isReadOnly && !isSelectionMode)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    top: isHovered ? 8 : -40,
                    left: 8,
                    right: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildQuickActionButton(
                          icon: Icons.visibility_outlined,
                          onTap: () => _previewImage(image),
                        ),
                        if (!isPrimary)
                          _buildQuickActionButton(
                            icon: Icons.star_outline_rounded,
                            onTap: () => _setPrimaryImage(index),
                            color: AppTheme.warning,
                          ),
                        _buildQuickActionButton(
                          icon: Icons.delete_outline_rounded,
                          onTap: () => _confirmDeleteImage(image),
                          color: AppTheme.error,
                        ),
                      ],
                    ),
                  ),
                
                // Primary Badge
                if (isPrimary)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.warning.withOpacity(0.3),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: Colors.white,
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
                
                // Selection Checkbox
                if (isSelectionMode)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isSelected 
                          ? AppTheme.primaryBlue
                          : AppTheme.darkCard.withOpacity(0.8),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.9),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: isSelected
                        ? Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                    ),
                  ),
                
                // Image Number (top-left corner)
                if (!isSelectionMode)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.darkCard.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuickActionButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppTheme.darkCard.withOpacity(0.95),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: color?.withOpacity(0.3) ?? AppTheme.darkBorder.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Icon(
          icon,
          color: color?.withOpacity(0.9) ?? AppTheme.textWhite.withOpacity(0.8),
          size: 14,
        ),
      ),
    );
  }
  
  void _showImageOptionsMenu(UnitImage image, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ImageOptionsSheet(
        image: image,
        index: index,
        isPrimary: index == _primaryImageIndex,
        onSetPrimary: () {
          Navigator.pop(context);
          _setPrimaryImage(index);
        },
        onDelete: () {
          Navigator.pop(context);
          _confirmDeleteImage(image);
        },
        onView: () {
          Navigator.pop(context);
          _previewImage(image);
        },
      ),
    );
  }
  
  Widget _buildMinimalistUploadArea() {
    return GestureDetector(
      onTap: _showImagePickerOptions,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 140,
        decoration: BoxDecoration(
          color: _isDragging 
            ? AppTheme.primaryBlue.withOpacity(0.05)
            : AppTheme.darkCard.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isDragging
              ? AppTheme.primaryBlue.withOpacity(0.3)
              : AppTheme.darkBorder.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: DragTarget<List<XFile>>(
          onWillAcceptWithDetails: (details) {
            setState(() => _isDragging = true);
            return true;
          },
          onLeave: (data) {
            setState(() => _isDragging = false);
          },
          onAcceptWithDetails: (details) {
            setState(() => _isDragging = false);
            _handleDroppedFiles(details.data);
          },
          builder: (context, candidateData, rejectedData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isDragging 
                      ? Icons.file_download_outlined
                      : Icons.add_photo_alternate_outlined,
                    color: _isDragging
                      ? AppTheme.primaryBlue.withOpacity(0.8)
                      : AppTheme.textMuted.withOpacity(0.5),
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isDragging
                      ? 'أفلت الصور هنا'
                      : 'اضغط أو اسحب لإضافة صور',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppTheme.textMuted.withOpacity(0.7),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'PNG, JPG, GIF • Max 10MB',
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.textMuted.withOpacity(0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildUploadProgressCards() {
    return Column(
      children: _uploadingFiles.map((fileName) {
        final progress = _uploadProgress[fileName] ?? 0.0;
        return _buildUploadProgressCard(fileName, progress);
      }).toList(),
    );
  }
  
  Widget _buildUploadProgressCard(String fileName, double progress) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryBlue.withOpacity(
                        0.1 + (_pulseController.value * 0.1)
                      ),
                    ),
                    child: Icon(
                      Icons.cloud_upload_outlined,
                      size: 16,
                      color: AppTheme.primaryBlue,
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName.split('/').last,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppTheme.textWhite.withOpacity(0.9),
                        fontWeight: FontWeight.w300,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'جاري الرفع... ${(progress * 100).toInt()}%',
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.textMuted.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.darkBorder.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.primaryBlue.withOpacity(0.8)
              ),
              minHeight: 2,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOptimizedImage(UnitImage image) {
    return CachedNetworkImage(
      imageUrl: image.url,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (context, url) => Container(
        color: AppTheme.darkCard.withOpacity(0.3),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.primaryBlue.withOpacity(0.5)
              ),
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppTheme.darkCard.withOpacity(0.3),
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppTheme.textMuted.withOpacity(0.3),
          size: 24,
        ),
      ),
    );
  }
  
  Widget _buildImageFromPath(String path) {
    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 200),
        placeholder: (context, url) => Container(
          color: AppTheme.darkCard.withOpacity(0.3),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryBlue.withOpacity(0.5)
                ),
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: AppTheme.darkCard.withOpacity(0.3),
          child: Icon(
            Icons.image_not_supported_outlined,
            color: AppTheme.textMuted.withOpacity(0.3),
            size: 24,
          ),
        ),
      );
    } else {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppTheme.darkCard.withOpacity(0.3),
            child: Icon(
              Icons.image_not_supported_outlined,
              color: AppTheme.textMuted.withOpacity(0.3),
              size: 24,
            ),
          );
        },
      );
    }
  }
  
  Widget _buildMinimalistLoadingState() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryBlue.withOpacity(0.5)
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'جاري التحميل...',
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.textMuted.withOpacity(0.5),
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMinimalistEmptyState() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              color: AppTheme.textMuted.withOpacity(0.3),
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد صور',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.textMuted.withOpacity(0.5),
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper Methods
  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedImageIds.clear();
        _selectedLocalIndices.clear();
        if (_imagesBloc != null) {
          _imagesBloc!.add(const DeselectAllUnitImagesEvent());
        }
        _selectionController.reverse();
      } else {
        _isReorderMode = false;
        _selectionController.forward();
      }
    });
  }
  
  void _toggleReorderMode() {
    setState(() {
      _isReorderMode = !_isReorderMode;
      if (_isReorderMode) {
        _isSelectionMode = false;
        _selectedImageIds.clear();
      }
    });
  }
  
  void _setPrimaryImage(int index) {
    setState(() {
      _primaryImageIndex = index;
    });
    
    if (_imagesBloc != null && widget.unitId != null && index < _displayImages.length) {
      _imagesBloc!.add(SetPrimaryUnitImageEvent(
        unitId: widget.unitId!,
        imageId: _displayImages[index].id,
      ));
    }
    
    _showSuccessSnackBar('تم تعيين الصورة كرئيسية');
  }
  
  void _reorderImages(int oldIndex, int newIndex) {
    setState(() {
      final image = _displayImages.removeAt(oldIndex);
      _displayImages.insert(newIndex, image);
      
      // Update primary image index if needed
      if (_primaryImageIndex == oldIndex) {
        _primaryImageIndex = newIndex;
      } else if (oldIndex < _primaryImageIndex! && newIndex >= _primaryImageIndex!) {
        _primaryImageIndex = _primaryImageIndex! - 1;
      } else if (oldIndex > _primaryImageIndex! && newIndex <= _primaryImageIndex!) {
        _primaryImageIndex = _primaryImageIndex! + 1;
      }
    });
    
    if (_imagesBloc != null && widget.unitId != null) {
      _imagesBloc!.add(ReorderUnitImagesEvent(
        unitId: widget.unitId!,
        imageIds: _displayImages.map((img) => img.id).toList(),
      ));
    }
    
    if (widget.onImagesChanged != null) {
      widget.onImagesChanged!(_displayImages);
    }
  }
  
  void _deleteSelectedImages() {
    if (_selectedImageIds.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (context) => _DeleteConfirmationDialog(
        count: _selectedImageIds.length,
        onConfirm: () {
          Navigator.pop(context);
          
          if (_imagesBloc != null) {
            _imagesBloc!.add(DeleteMultipleUnitImagesEvent(
              imageIds: _selectedImageIds.toList(),
            ));
          }
          
          setState(() {
            _displayImages.removeWhere((img) => _selectedImageIds.contains(img.id));
            _selectedImageIds.clear();
            _isSelectionMode = false;
          });
          
          _showSuccessSnackBar('تم حذف الصور المحددة');
        },
      ),
    );
  }
  
  void _confirmDeleteImage(UnitImage image) {
    showDialog(
      context: context,
      builder: (context) => _DeleteConfirmationDialog(
        count: 1,
        onConfirm: () {
          Navigator.pop(context);
          
          if (_imagesBloc != null) {
            HapticFeedback.lightImpact();
            _imagesBloc!.add(DeleteUnitImageEvent(imageId: image.id));
          }
          
          setState(() {
            final index = _displayImages.indexWhere((img) => img.id == image.id);
            if (index != -1) {
              _displayImages.removeAt(index);
              if (_primaryImageIndex == index) {
                _primaryImageIndex = 0;
              } else if (_primaryImageIndex! > index) {
                _primaryImageIndex = _primaryImageIndex! - 1;
              }
            }
          });
          
          _showSuccessSnackBar('تم حذف الصورة');
        },
      ),
    );
  }
  
  void _handleStateChanges(UnitImagesState state) {
    if (state is UnitImagesLoaded) {
      setState(() {
        _displayImages = state.images;
        _primaryImageIndex = state.images.indexWhere((img) => img.isPrimary == true);
        if (_primaryImageIndex == -1) _primaryImageIndex = 0;
      });
      if (widget.onImagesChanged != null) {
        widget.onImagesChanged!(state.images);
      }
    } else if (state is UnitImageUploaded) {
      setState(() {
        _displayImages = state.allImages;
        _uploadingFiles.removeWhere((file) => true);
        _uploadProgress.clear();
      });
      _showSuccessSnackBar('تم رفع الصورة بنجاح');
      if (widget.onImagesChanged != null) {
        widget.onImagesChanged!(state.allImages);
      }
    } else if (state is MultipleImagesUploaded) {
      setState(() {
        _displayImages = state.allImages;
        _uploadingFiles.clear();
        _uploadProgress.clear();
      });
      _showSuccessSnackBar(
        'تم رفع ${state.successCount} صورة بنجاح${state.failedCount > 0 ? ' (${state.failedCount} فشلت)' : ''}',
      );
      if (widget.onImagesChanged != null) {
        widget.onImagesChanged!(state.allImages);
      }
    } else if (state is UnitImageDeleted) {
      setState(() {
        _displayImages = state.remainingImages;
      });
      _showSuccessSnackBar('تم حذف الصورة');
      if (widget.onImagesChanged != null) {
        widget.onImagesChanged!(state.remainingImages);
      }
    } else if (state is UnitImagesError) {
      setState(() {
        _uploadingFiles.clear();
        _uploadProgress.clear();
      });
      _showErrorSnackBar(state.message);
    } else if (state is UnitImageUploading) {
      if (state.uploadingFileName != null) {
        setState(() {
          _uploadingFiles.add(state.uploadingFileName!);
          _uploadProgress[state.uploadingFileName!] = state.uploadProgress ?? 0.0;
        });
        
        if (state.uploadProgress == null) {
          _simulateUploadProgress(state.uploadingFileName!);
        }
      }
    }
  }
  
  void _simulateUploadProgress(String fileName) {
    int progress = 0;
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (progress >= 100) {
        timer.cancel();
        return;
      }
      setState(() {
        progress += 5;
        _uploadProgress[fileName] = progress / 100;
      });
    });
  }
  
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _MinimalistImagePickerSheet(
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
  
  void _handleDroppedFiles(List<XFile> files) {
    if (files.isNotEmpty) {
      final remainingSlots = widget.maxImages - (_isLocalMode ? _localImages.length : _displayImages.length);
      final filesToAdd = files.take(remainingSlots).toList();
      
      if (filesToAdd.isNotEmpty) {
        if (_isLocalMode) {
          setState(() {
            _localImages.addAll(filesToAdd.map((file) => file.path));
          });
          if (widget.onLocalImagesChanged != null) {
            widget.onLocalImagesChanged!(_localImages);
          }
          _showSuccessSnackBar('تم إضافة ${filesToAdd.length} صورة (سيتم الرفع عند الحفظ)');
        } else if (_imagesBloc != null && widget.unitId != null) {
          setState(() {
            for (var file in filesToAdd) {
              _uploadingFiles.add(file.path);
            }
          });
          _imagesBloc!.add(UploadMultipleUnitImagesEvent(
            unitId: widget.unitId,
            tempKey: widget.tempKey,
            filePaths: filesToAdd.map((file) => file.path).toList(),
          ));
        }
      }
    }
  }
  
  void _previewImage(UnitImage image) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: _MinimalistImagePreview(image: image),
          );
        },
      ),
    );
  }
  
  void _previewLocalImage(String imagePath) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: _MinimalistLocalImagePreview(imagePath: imagePath),
          );
        },
      ),
    );
  }
  
  List<UnitImage> _getImagesFromState(UnitImagesState state) {
    if (state is UnitImagesLoaded) return state.images;
    if (state is UnitImageUploaded) return state.allImages;
    if (state is MultipleImagesUploaded) return state.allImages;
    if (state is UnitImageDeleted) return state.remainingImages;
    if (state is MultipleImagesDeleted) return state.remainingImages;
    if (state is ImagesReordered) return state.reorderedImages;
    if (state is PrimaryImageSet) return state.updatedImages;
    if (state is UnitImageUpdated) return state.updatedImages;
    if (state is UnitImageUploading) return state.currentImages;
    if (state is UnitImageDeleting) return state.currentImages;
    if (state is UnitImageUpdating) return state.currentImages;
    if (state is ImagesReordering) return state.currentImages;
    if (state is UnitImagesError) return state.previousImages ?? [];
    return widget.initialImages ?? _remoteImages;
  }
  
  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.caption.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.success.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.caption.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.error.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// Supporting Widgets

class _ImageOptionsSheet extends StatelessWidget {
  final UnitImage image;
  final int index;
  final bool isPrimary;
  final VoidCallback onSetPrimary;
  final VoidCallback onDelete;
  final VoidCallback onView;
  
  const _ImageOptionsSheet({
    required this.image,
    required this.index,
    required this.isPrimary,
    required this.onSetPrimary,
    required this.onDelete,
    required this.onView,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 3,
            decoration: BoxDecoration(
              color: AppTheme.darkBorder.withOpacity(0.3),
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          const SizedBox(height: 24),
          
          Text(
            'خيارات الصورة',
            style: AppTextStyles.heading3.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 20),
          
          _buildOption(
            icon: Icons.visibility_outlined,
            title: 'عرض الصورة',
            onTap: onView,
          ),
          
          if (!isPrimary) ...[
            const SizedBox(height: 8),
            _buildOption(
              icon: Icons.star_outline_rounded,
              title: 'تعيين كصورة رئيسية',
              onTap: onSetPrimary,
              color: AppTheme.warning,
            ),
          ],
          
          const SizedBox(height: 8),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color?.withOpacity(0.1) ?? AppTheme.darkCard.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color?.withOpacity(0.8) ?? AppTheme.primaryBlue.withOpacity(0.8),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: color ?? AppTheme.textWhite.withOpacity(0.9),
                fontWeight: FontWeight.w300,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.textMuted.withOpacity(0.3),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteConfirmationDialog extends StatelessWidget {
  final int count;
  final VoidCallback onConfirm;
  
  const _DeleteConfirmationDialog({
    required this.count,
    required this.onConfirm,
  });
  
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.darkCard.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.error.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.error.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: AppTheme.error.withOpacity(0.8),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'تأكيد الحذف',
                style: AppTextStyles.heading3.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                count > 1
                  ? 'هل أنت متأكد من حذف $count صور؟'
                  : 'هل أنت متأكد من حذف هذه الصورة؟',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.textLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppTheme.darkBorder.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'إلغاء',
                            style: AppTextStyles.buttonMedium.copyWith(
                              color: AppTheme.textLight,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: onConfirm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'حذف',
                            style: AppTextStyles.buttonMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Image Preview widgets remain the same...
class _MinimalistImagePickerSheet extends StatelessWidget {
  final VoidCallback onCameraSelected;
  final VoidCallback onGallerySelected;
  final VoidCallback onMultipleSelected;
  
  const _MinimalistImagePickerSheet({
    required this.onCameraSelected,
    required this.onGallerySelected,
    required this.onMultipleSelected,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 3,
            decoration: BoxDecoration(
              color: AppTheme.darkBorder.withOpacity(0.3),
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          const SizedBox(height: 24),
          _buildOption(
            icon: Icons.camera_alt_outlined,
            title: 'الكاميرا',
            onTap: onCameraSelected,
          ),
          const SizedBox(height: 8),
          _buildOption(
            icon: Icons.photo_outlined,
            title: 'صورة واحدة',
            onTap: onGallerySelected,
          ),
          const SizedBox(height: 8),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.darkCard.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryBlue.withOpacity(0.8),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.textWhite.withOpacity(0.9),
                fontWeight: FontWeight.w300,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.textMuted.withOpacity(0.3),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _MinimalistImagePreview extends StatelessWidget {
  final UnitImage image;
  
  const _MinimalistImagePreview({required this.image});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Stack(
        children: [
          Center(
            child: CachedNetworkImage(
              imageUrl: image.url,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.darkCard.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white.withOpacity(0.9),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MinimalistLocalImagePreview extends StatelessWidget {
  final String imagePath;
  
  const _MinimalistLocalImagePreview({required this.imagePath});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Stack(
        children: [
          Center(
            child: imagePath.startsWith('http')
                ? Image.network(imagePath, fit: BoxFit.contain)
                : Image.file(File(imagePath), fit: BoxFit.contain),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.darkCard.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white.withOpacity(0.9),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}