import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/amenity.dart';

class FuturisticAmenityCard extends StatefulWidget {
  final Amenity amenity;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Duration animationDelay;

  const FuturisticAmenityCard({
    super.key,
    required this.amenity,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.animationDelay = Duration.zero,
  });

  @override
  State<FuturisticAmenityCard> createState() => _FuturisticAmenityCardState();
}

class _FuturisticAmenityCardState extends State<FuturisticAmenityCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _entranceController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _entranceAnimation;

  bool _isHovered = false;
  bool _isPressed = false;

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
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 600),
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
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.elasticOut,
    );
  }

  void _startAnimations() {
    Future.delayed(widget.animationDelay, () {
      if (mounted) {
        _entranceController.forward();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _onTapDown(),
        onTapUp: (_) => _onTapUp(),
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _scaleAnimation,
            _glowAnimation,
            _entranceAnimation,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _entranceAnimation.value * 
                     (_isPressed ? _scaleAnimation.value : 1.0),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(_isHovered ? -0.02 : 0)
        ..rotateY(_isHovered ? 0.02 : 0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.darkCard.withOpacity(0.8),
              AppTheme.darkCard.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.amenity.isActive == true
                ? AppTheme.primaryBlue.withOpacity(0.3 + (_isHovered ? 0.2 : 0))
                : AppTheme.textMuted.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.amenity.isActive == true
                  ? AppTheme.primaryBlue.withOpacity(0.2 * _glowAnimation.value)
                  : Colors.black.withOpacity(0.3),
              blurRadius: _isHovered ? 25 : 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Stack(
              children: [
                // Background Pattern
                if (_isHovered)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _CardPatternPainter(
                        color: AppTheme.primaryBlue.withOpacity(0.05),
                      ),
                    ),
                  ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon
                      _buildIcon(),
                      
                      const SizedBox(height: AppDimensions.paddingSmall),
                      
                      // Name
                      Text(
                        widget.amenity.name,
                        style: AppTextStyles.heading3.copyWith(
                          color: AppTheme.textWhite,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Description
                      Text(
                        widget.amenity.description,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppTheme.textMuted.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const Spacer(),
                      
                      // Stats
                      _buildStats(),
                      
                      // Actions (shown on hover)
                      if (_isHovered) ...[
                        const SizedBox(height: AppDimensions.paddingSmall),
                        _buildActions(),
                      ],
                    ],
                  ),
                ),

                // Status Badge
                Positioned(
                  top: 10,
                  right: 10,
                  child: _buildStatusBadge(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: widget.amenity.isActive == true
            ? AppTheme.primaryGradient
            : LinearGradient(
                colors: [
                  AppTheme.textMuted.withOpacity(0.3),
                  AppTheme.textMuted.withOpacity(0.2),
                ],
              ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (widget.amenity.isActive == true)
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.3 * _glowAnimation.value),
              blurRadius: 20,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Icon(
        _getIconData(widget.amenity.icon),
        color: Colors.white,
        size: 28,
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(
          Icons.home_rounded,
          widget.amenity.propertiesCount?.toString() ?? '0',
          'عقار',
        ),
        if (widget.amenity.averageExtraCost != null && 
            widget.amenity.averageExtraCost! > 0)
          _buildStatItem(
            Icons.attach_money_rounded,
            '\$${widget.amenity.averageExtraCost!.toStringAsFixed(0)}',
            'متوسط',
          ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: AppTheme.primaryBlue.withOpacity(0.7),
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppTheme.textMuted.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return AnimatedOpacity(
      opacity: _isHovered ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (widget.onEdit != null)
            _buildActionButton(
              Icons.edit_rounded,
              AppTheme.primaryBlue,
              widget.onEdit!,
            ),
          if (widget.onDelete != null)
            _buildActionButton(
              Icons.delete_rounded,
              AppTheme.error,
              widget.onDelete!,
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: color,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final isActive = widget.amenity.isActive == true;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? [AppTheme.success.withOpacity(0.3), AppTheme.success.withOpacity(0.2)]
              : [AppTheme.textMuted.withOpacity(0.3), AppTheme.textMuted.withOpacity(0.2)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? AppTheme.success.withOpacity(0.5)
              : AppTheme.textMuted.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? AppTheme.success : AppTheme.textMuted,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'نشط' : 'غير نشط',
            style: AppTextStyles.caption.copyWith(
              color: isActive ? AppTheme.success : AppTheme.textMuted,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
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

  IconData _getIconData(String iconName) {
    final iconMap = {
      'wifi': Icons.wifi_rounded,
      'parking': Icons.local_parking_rounded,
      'pool': Icons.pool_rounded,
      'gym': Icons.fitness_center_rounded,
      'restaurant': Icons.restaurant_rounded,
      'spa': Icons.spa_rounded,
      'laundry': Icons.local_laundry_service_rounded,
      'ac': Icons.ac_unit_rounded,
      'tv': Icons.tv_rounded,
      'kitchen': Icons.kitchen_rounded,
      'elevator': Icons.elevator_rounded,
      'safe': Icons.lock_rounded,
      'minibar': Icons.local_bar_rounded,
      'balcony': Icons.balcony_rounded,
      'view': Icons.landscape_rounded,
      'pet': Icons.pets_rounded,
      'smoking': Icons.smoking_rooms_rounded,
      'wheelchair': Icons.accessible_rounded,
      'breakfast': Icons.free_breakfast_rounded,
      'airport': Icons.airport_shuttle_rounded,
    };
    
    return iconMap[iconName] ?? Icons.star_rounded;
  }
}

class _CardPatternPainter extends CustomPainter {
  final Color color;

  _CardPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const spacing = 15.0;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height / 2, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}