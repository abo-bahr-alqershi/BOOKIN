import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_dimensions.dart';

class UnitGalleryPage extends StatefulWidget {
  final String unitId;
  final String unitName;

  const UnitGalleryPage({
    super.key,
    required this.unitId,
    required this.unitName,
  });

  @override
  State<UnitGalleryPage> createState() => _UnitGalleryPageState();
}

class _UnitGalleryPageState extends State<UnitGalleryPage>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _gridController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _gridAnimation;

  final List<String> _images = [
    'https://example.com/image1.jpg',
    'https://example.com/image2.jpg',
    'https://example.com/image3.jpg',
    'https://example.com/image4.jpg',
    'https://example.com/image5.jpg',
    'https://example.com/image6.jpg',
  ];

  String? _selectedImage;
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _gridController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_backgroundController);

    _gridAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _gridController,
      curve: Curves.easeOutQuart,
    ));

    _gridController.forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _gridController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          _buildMainContent(),
          if (_selectedImage != null)
            _buildImageViewer(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: AppTheme.darkGradient,
          ),
          child: CustomPaint(
            painter: _GalleryBackgroundPainter(
              rotation: _backgroundAnimation.value,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Widget _buildMainContent() {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildGalleryContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.glassLight.withOpacity(0.1),
                  AppTheme.glassDark.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
              border: Border.all(
                color: AppTheme.primaryBlue.withOpacity(0.2),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Row(
              children: [
                _buildBackButton(),
                const SizedBox(width: AppDimensions.spaceMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppTheme.primaryGradient.createShader(bounds),
                        child: Text(
                          'معرض الصور',
                          style: AppTextStyles.heading2.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        widget.unitName,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildUploadButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.pop();
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkCard.withOpacity(0.5),
              AppTheme.darkCard.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: AppTheme.darkBorder.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: Icon(
          Icons.arrow_back,
          color: AppTheme.textWhite,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        // Open upload dialog
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.cloud_upload,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: AppDimensions.spaceSmall),
            Text(
              'رفع صور',
              style: AppTextStyles.buttonMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryContent() {
    return AnimatedBuilder(
      animation: _gridAnimation,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: AppDimensions.spaceMedium,
              mainAxisSpacing: AppDimensions.spaceMedium,
              childAspectRatio: 1,
            ),
            itemCount: _images.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildAddImageCard();
              }
              
              final imageIndex = index - 1;
              return Transform.scale(
                scale: _gridAnimation.value,
                child: FadeTransition(
                  opacity: _gridAnimation,
                  child: _buildImageCard(_images[imageIndex], imageIndex),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAddImageCard() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        // Open upload dialog
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryBlue.withOpacity(0.1),
              AppTheme.primaryPurple.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 32,
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(height: AppDimensions.spaceSmall),
            Text(
              'إضافة صورة',
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(String imageUrl, int index) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedImage = imageUrl);
      },
      child: Hero(
        tag: 'image_$index',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: Border.all(
              color: AppTheme.darkBorder.withOpacity(0.3),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  color: AppTheme.darkCard,
                  child:  Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryBlue,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppTheme.darkCard,
                      child: Icon(
                        Icons.broken_image,
                        color: AppTheme.textMuted.withOpacity(0.5),
                        size: 32,
                      ),
                    );
                  },
                ),
                Positioned(
                  top: AppDimensions.paddingSmall,
                  right: AppDimensions.paddingSmall,
                  child: _buildImageActions(imageUrl, index),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageActions(String imageUrl, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildImageActionButton(
            Icons.star,
            () => _setAsMain(index),
            color: AppTheme.warning,
          ),
          _buildImageActionButton(
            Icons.delete,
            () => _deleteImage(index),
            color: AppTheme.error,
          ),
        ],
      ),
    );
  }

  Widget _buildImageActionButton(
    IconData icon,
    VoidCallback onTap, {
    Color? color,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingSmall),
        child: Icon(
          icon,
          size: 16,
          color: color ?? AppTheme.textWhite,
        ),
      ),
    );
  }

  Widget _buildImageViewer() {
    return GestureDetector(
      onTap: () => setState(() => _selectedImage = null),
      child: Container(
        color: Colors.black.withOpacity(0.9),
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  _selectedImage!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + AppDimensions.paddingLarge,
              right: AppDimensions.paddingLarge,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedImage = null);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
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

  void _setAsMain(int index) {
    // Set image as main
  }

  void _deleteImage(int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.darkGradient,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
            border: Border.all(
              color: AppTheme.error.withOpacity(0.3),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 64,
                color: AppTheme.error,
              ),
              const SizedBox(height: AppDimensions.spaceMedium),
              Text(
                'تأكيد الحذف',
                style: AppTextStyles.heading2.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceSmall),
              Text(
                'هل أنت متأكد من حذف هذه الصورة؟',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spaceLarge),
              Row(
                children: [
                  Expanded(
                    child: _buildDialogButton(
                      label: 'إلغاء',
                      onTap: () => Navigator.of(context).pop(),
                      isPrimary: false,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceMedium),
                  Expanded(
                    child: _buildDialogButton(
                      label: 'حذف',
                      onTap: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _images.removeAt(index);
                        });
                      },
                      isPrimary: true,
                      isDanger: true,
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

  Widget _buildDialogButton({
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
    bool isDanger = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.paddingMedium,
        ),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? (isDanger
                  ? LinearGradient(
                      colors: [
                        AppTheme.error,
                        AppTheme.error.withOpacity(0.8),
                      ],
                    )
                  : AppTheme.primaryGradient)
              : null,
          border: isPrimary
              ? null
              : Border.all(
                  color: AppTheme.textMuted.withOpacity(0.3),
                  width: 1,
                ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        child: Text(
          label,
          style: AppTextStyles.buttonMedium.copyWith(
            color: isPrimary ? Colors.white : AppTheme.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _GalleryBackgroundPainter extends CustomPainter {
  final double rotation;

  _GalleryBackgroundPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = AppTheme.primaryBlue.withOpacity(0.05);

    // Draw hexagon pattern
    const hexSize = 50.0;
    for (double x = 0; x < size.width + hexSize; x += hexSize * 1.5) {
      for (double y = 0; y < size.height + hexSize; y += hexSize * 2) {
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(rotation);
        _drawHexagon(canvas, hexSize / 2, paint);
        canvas.restore();
      }
    }
  }

  void _drawHexagon(Canvas canvas, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * math.pi / 180;
      final x = radius * math.cos(angle);
      final y = radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}