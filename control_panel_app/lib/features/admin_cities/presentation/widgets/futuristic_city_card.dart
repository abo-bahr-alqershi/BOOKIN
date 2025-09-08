// lib/features/admin_cities/presentation/widgets/futuristic_city_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/city.dart';

class FuturisticCityCard extends StatefulWidget {
  final City city;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onImageTap;
  final bool isGridView;
  
  const FuturisticCityCard({
    super.key,
    required this.city,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onImageTap,
    this.isGridView = true,
  });
  
  @override
  State<FuturisticCityCard> createState() => _FuturisticCityCardState();
}

class _FuturisticCityCardState extends State<FuturisticCityCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  
  bool _isHovered = false;
  bool _isPressed = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (widget.isGridView) {
      return _buildGridCard();
    } else {
      return _buildListCard();
    }
  }
  
  Widget _buildGridCard() {
    return MouseRegion(
      onEnter: (_) => _onHoverChange(true),
      onExit: (_) => _onHoverChange(false),
      child: GestureDetector(
        onTapDown: (_) => _onPressChange(true),
        onTapUp: (_) => _onPressChange(false),
        onTapCancel: () => _onPressChange(false),
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap?.call();
        },
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _isPressed ? _scaleAnimation.value : 1.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowDark.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                    if (_isHovered)
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(
                          0.3 * _glowAnimation.value,
                        ),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.darkCard.withOpacity(0.9),
                            AppTheme.darkCard.withOpacity(0.7),
                          ],
                        ),
                        border: Border.all(
                          color: _isHovered
                              ? AppTheme.primaryBlue.withOpacity(0.3)
                              : AppTheme.darkBorder.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Background Pattern
                          if (_isHovered)
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _GridPatternPainter(
                                  color: AppTheme.primaryBlue.withOpacity(0.03),
                                ),
                              ),
                            ),
                          
                          // Content
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image Section
                              _buildImageSection(),
                              
                              // Info Section
                              Expanded(
                                child: _buildInfoSection(),
                              ),
                            ],
                          ),
                          
                          // Actions Overlay
                          if (_isHovered)
                            _buildActionsOverlay(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildListCard() {
    return MouseRegion(
      onEnter: (_) => _onHoverChange(true),
      onExit: (_) => _onHoverChange(false),
      child: GestureDetector(
        onTapDown: (_) => _onPressChange(true),
        onTapUp: (_) => _onPressChange(false),
        onTapCancel: () => _onPressChange(false),
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap?.call();
        },
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _isPressed ? _scaleAnimation.value : 1.0,
              child: Container(
                height: 120,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowDark.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                    if (_isHovered)
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(
                          0.2 * _glowAnimation.value,
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
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.darkCard.withOpacity(0.8),
                            AppTheme.darkCard.withOpacity(0.6),
                          ],
                        ),
                        border: Border.all(
                          color: _isHovered
                              ? AppTheme.primaryBlue.withOpacity(0.3)
                              : AppTheme.darkBorder.withOpacity(0.1),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Image
                          _buildListImage(),
                          
                          // Content
                          Expanded(
                            child: _buildListContent(),
                          ),
                          
                          // Actions
                          _buildListActions(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildImageSection() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Main Image
          widget.city.images.isNotEmpty
              ? GestureDetector(
                  onTap: widget.onImageTap,
                  child: Hero(
                    tag: 'city-${widget.city.name}',
                    child: CachedNetworkImage(
                      imageUrl: widget.city.images.first,
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
                          Icons.image_not_supported_outlined,
                          color: AppTheme.textMuted.withOpacity(0.3),
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryBlue.withOpacity(0.1),
                        AppTheme.primaryPurple.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.location_city_rounded,
                    color: AppTheme.textMuted.withOpacity(0.3),
                    size: 48,
                  ),
                ),
          
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
          
          // Status Badge
          if (widget.city.isActive ?? true)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppTheme.success.withOpacity(0.2),
                  border: Border.all(
                    color: AppTheme.success.withOpacity(0.3),
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
                        color: AppTheme.success,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.success.withOpacity(0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'نشط',
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Image Count
          if (widget.city.images.length > 1)
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black.withOpacity(0.6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.photo_library_outlined,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.city.images.length}',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
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
  
  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // City Name
          Text(
            widget.city.name,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 8),
          
          // Country
          Row(
            children: [
              Icon(
                Icons.flag_outlined,
                color: AppTheme.textMuted.withOpacity(0.7),
                size: 14,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.city.country,
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w300,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // Properties Count
          if (widget.city.propertiesCount != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppTheme.primaryBlue.withOpacity(0.1),
                border: Border.all(
                  color: AppTheme.primaryBlue.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.apartment_rounded,
                    color: AppTheme.primaryBlue,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.city.propertiesCount} عقار',
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildActionsOverlay() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _isHovered ? 1.0 : 0.0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.5),
            ],
          ),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.edit_outlined,
                  onTap: widget.onEdit,
                  color: AppTheme.primaryBlue,
                ),
                _buildActionButton(
                  icon: Icons.photo_library_outlined,
                  onTap: widget.onImageTap,
                  color: AppTheme.neonGreen,
                ),
                _buildActionButton(
                  icon: Icons.delete_outline,
                  onTap: widget.onDelete,
                  color: AppTheme.error,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Widget _buildActionButton({
  //   required IconData icon,
  //   required VoidCallback? onTap,
  //   required Color color,
  // }) {
  //   return GestureDetector(
  //     onTap: () {
  //       HapticFeedback.lightImpact();
  //       onTap?.call();
  //     },
  //     child: Container(
  //       width: 40,
  //       height: 40,
  //       decoration: BoxDecoration(
  //         shape: BoxShape.circle,
  //         color: color.withOpacity(0.2),
  //         border: Border.all(
  //           color: color.withOpacity(0.3),
  //           width: 0.5,
  //         ),
  //         backdropFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
  //       ),
  //       child: Icon(
  //         icon,
  //         color: color,
  //         size: 18,
  //       ),
  //     ),
  //   );
  // }
    Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.2),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListImage() {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.horizontal(
          left: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.horizontal(
          left: Radius.circular(20),
        ),
        child: widget.city.images.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: widget.city.images.first,
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
                    Icons.image_not_supported_outlined,
                    color: AppTheme.textMuted.withOpacity(0.3),
                    size: 32,
                  ),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryBlue.withOpacity(0.1),
                      AppTheme.primaryPurple.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.location_city_rounded,
                  color: AppTheme.textMuted.withOpacity(0.3),
                  size: 40,
                ),
              ),
      ),
    );
  }
  
  Widget _buildListContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // City Name
          Text(
            widget.city.name,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 6),
          
          // Country
          Row(
            children: [
              Icon(
                Icons.flag_outlined,
                color: AppTheme.textMuted.withOpacity(0.7),
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                widget.city.country,
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Stats Row
          Row(
            children: [
              if (widget.city.propertiesCount != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.apartment_rounded,
                        color: AppTheme.primaryBlue,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.city.propertiesCount}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
              
              if (widget.city.images.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppTheme.neonGreen.withOpacity(0.1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        color: AppTheme.neonGreen,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.city.images.length}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppTheme.neonGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              
              const Spacer(),
              
              if (widget.city.isActive ?? true)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppTheme.success.withOpacity(0.1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.success,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'نشط',
                        style: AppTextStyles.caption.copyWith(
                          color: AppTheme.success,
                          fontWeight: FontWeight.w500,
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
  
  Widget _buildListActions() {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onEdit,
            icon: Icon(
              Icons.edit_outlined,
              color: AppTheme.primaryBlue,
              size: 20,
            ),
          ),
          IconButton(
            onPressed: widget.onDelete,
            icon: Icon(
              Icons.delete_outline,
              color: AppTheme.error,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
  
  void _onHoverChange(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    
    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }
  
  void _onPressChange(bool isPressed) {
    setState(() {
      _isPressed = isPressed;
    });
    
    if (isPressed) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }
}

class _GridPatternPainter extends CustomPainter {
  final Color color;
  
  _GridPatternPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    
    const spacing = 20.0;
    
    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}