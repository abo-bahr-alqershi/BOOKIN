import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/city.dart';

class FuturisticCityCard extends StatefulWidget {
  final City city;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEditTap;
  final VoidCallback onDeleteTap;
  final Duration animationDelay;

  const FuturisticCityCard({
    super.key,
    required this.city,
    this.isSelected = false,
    required this.onTap,
    required this.onEditTap,
    required this.onDeleteTap,
    this.animationDelay = Duration.zero,
  });

  @override
  State<FuturisticCityCard> createState() => _FuturisticCityCardState();
}

class _FuturisticCityCardState extends State<FuturisticCityCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _entranceController;
  late AnimationController _shimmerController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _entranceAnimation;
  late Animation<double> _shimmerAnimation;
  
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.elasticOut,
    );
    
    _shimmerAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    ));
  }

  void _startAnimations() {
    Future.delayed(widget.animationDelay, () {
      if (mounted) {
        _entranceController.forward();
        if (widget.isSelected) {
          _glowController.repeat(reverse: true);
        }
        _shimmerController.repeat();
      }
    });
  }

  @override
  void didUpdateWidget(FuturisticCityCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _glowController.repeat(reverse: true);
      } else {
        _glowController.stop();
        _glowController.reset();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    _entranceController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _onTapDown() {
    setState(() => _isPressed = true);
    _scaleController.forward();
  }

  void _onTapUp() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _onTapDown(),
      onTapUp: (_) => _onTapUp(),
      onTapCancel: _onTapCancel,
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _scaleAnimation,
            _glowAnimation,
            _entranceAnimation,
            _shimmerAnimation,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _entranceAnimation.value * _scaleAnimation.value,
              child: Opacity(
                opacity: _entranceAnimation.value,
                child: _buildCard(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceMedium),
      child: Stack(
        children: [
          // Glow Effect
          if (widget.isSelected || _isHovered)
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(
                        0.3 * _glowAnimation.value,
                      ),
                      blurRadius: 20 + 10 * _glowAnimation.value,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          
          // Main Card
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.isSelected
                    ? [
                        AppTheme.primaryBlue.withOpacity(0.1),
                        AppTheme.primaryPurple.withOpacity(0.05),
                      ]
                    : [
                        AppTheme.darkCard.withOpacity(0.7),
                        AppTheme.darkCard.withOpacity(0.5),
                      ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isSelected
                    ? AppTheme.primaryBlue.withOpacity(0.5)
                    : AppTheme.darkBorder.withOpacity(0.3),
                width: widget.isSelected ? 2 : 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: _buildCardContent(),
              ),
            ),
          ),
          
          // Shimmer Effect
          if (_isHovered)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CustomPaint(
                  painter: _ShimmerPainter(
                    animation: _shimmerAnimation.value,
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardContent() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Row(
        children: [
          // City Image or Icon
          _buildCityImage(),
          
          const SizedBox(width: AppDimensions.spaceMedium),
          
          // City Info
          Expanded(
            child: _buildCityInfo(),
          ),
          
          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildCityImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: widget.city.images.isEmpty
            ? AppTheme.primaryGradient
            : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.3),
          width: 2,
        ),
        image: widget.city.images.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(widget.city.images.first),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: widget.city.images.isEmpty
          ? Icon(
              Icons.location_city_rounded,
              size: 40,
              color: Colors.white.withOpacity(0.9),
            )
          : null,
    );
  }

  Widget _buildCityInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // City Name
        Row(
          children: [
            Flexible(
              child: Text(
                widget.city.name,
                style: AppTextStyles.heading3.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.city.isActive ?? true)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'نشط',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 4),
        
        // Country
        Row(
          children: [
            Icon(
              Icons.public_rounded,
              size: 14,
              color: AppTheme.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              widget.city.country,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Stats Row
        Row(
          children: [
            _buildStatChip(
              icon: Icons.image_rounded,
              value: widget.city.images.length.toString(),
              label: 'صورة',
            ),
            const SizedBox(width: 12),
            if (widget.city.propertiesCount != null)
              _buildStatChip(
                icon: Icons.home_rounded,
                value: widget.city.propertiesCount.toString(),
                label: 'عقار',
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppTheme.primaryBlue,
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          icon: Icons.edit_rounded,
          color: AppTheme.primaryBlue,
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onEditTap();
          },
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Icons.delete_rounded,
          color: AppTheme.error,
          onTap: () {
            HapticFeedback.mediumImpact();
            widget.onDeleteTap();
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: color,
        ),
      ),
    );
  }
}

// Shimmer Painter
class _ShimmerPainter extends CustomPainter {
  final double animation;
  final Color color;
  
  _ShimmerPainter({
    required this.animation,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          color,
          Colors.transparent,
        ],
        stops: [
          0.0,
          animation,
          1.0,
        ],
        transform: GradientRotation(animation * 2 * math.pi),
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}