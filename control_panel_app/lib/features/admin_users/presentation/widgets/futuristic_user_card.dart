import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/user.dart';

class FuturisticUserCard extends StatefulWidget {
  final User user;
  final VoidCallback onTap;
  final Function(bool) onStatusToggle;
  final Duration animationDelay;

  const FuturisticUserCard({
    super.key,
    required this.user,
    required this.onTap,
    required this.onStatusToggle,
    this.animationDelay = Duration.zero,
  });

  @override
  State<FuturisticUserCard> createState() => _FuturisticUserCardState();
}

class _FuturisticUserCardState extends State<FuturisticUserCard>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _hoverController;
  late AnimationController _glowController;
  late AnimationController _statusController;
  
  late Animation<double> _entranceAnimation;
  late Animation<double> _hoverAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _statusAnimation;
  
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _statusController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.elasticOut,
    );
    
    _hoverAnimation = CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    );
    
    _glowAnimation = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    );
    
    _statusAnimation = CurvedAnimation(
      parent: _statusController,
      curve: Curves.easeInOut,
    );
    
    if (widget.user.isActive) {
      _glowController.repeat(reverse: true);
    }
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
    _entranceController.dispose();
    _hoverController.dispose();
    _glowController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _entranceAnimation,
        _hoverAnimation,
        _glowAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _entranceAnimation.value,
          child: Transform.translate(
            offset: Offset(0, -5 * _hoverAnimation.value),
            child: MouseRegion(
              onEnter: (_) => _onHover(true),
              onExit: (_) => _onHover(false),
              child: GestureDetector(
                onTapDown: (_) => setState(() => _isPressed = true),
                onTapUp: (_) => setState(() => _isPressed = false),
                onTapCancel: () => setState(() => _isPressed = false),
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onTap();
                },
                child: AnimatedScale(
                  scale: _isPressed ? 0.95 : 1.0,
                  duration: const Duration(milliseconds: 100),
                  child: _buildCard(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: widget.user.isActive
                ? AppTheme.primaryBlue.withOpacity(0.1 + 0.1 * _glowAnimation.value)
                : Colors.black.withOpacity(0.2),
            blurRadius: 20 + 10 * _hoverAnimation.value,
            offset: Offset(0, 8 + 4 * _hoverAnimation.value),
          ),
          if (widget.user.isActive)
            BoxShadow(
              color: AppTheme.success.withOpacity(0.2 * _glowAnimation.value),
              blurRadius: 30,
              spreadRadius: -10,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
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
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              border: Border.all(
                color: widget.user.isActive
                    ? AppTheme.success.withOpacity(0.3 + 0.2 * _glowAnimation.value)
                    : AppTheme.darkBorder.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Background pattern
                if (_isHovered)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _CardPatternPainter(
                        color: AppTheme.primaryBlue.withOpacity(0.03),
                      ),
                    ),
                  ),
                
                // Content
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: AppDimensions.spaceMedium),
                      _buildUserInfo(),
                      const Spacer(),
                      _buildFooter(),
                    ],
                  ),
                ),
                
                // Status indicator
                Positioned(
                  top: 12,
                  right: 12,
                  child: _buildStatusIndicator(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Avatar
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: widget.user.profileImage != null
                ? null
                : AppTheme.primaryGradient,
            border: Border.all(
              color: widget.user.isActive
                  ? AppTheme.success.withOpacity(0.5)
                  : AppTheme.darkBorder,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.user.isActive
                    ? AppTheme.success.withOpacity(0.3)
                    : Colors.transparent,
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: widget.user.profileImage != null
              ? ClipOval(
                  child: Image.network(
                    widget.user.profileImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultAvatar();
                    },
                  ),
                )
              : _buildDefaultAvatar(),
        ),
        
        const SizedBox(width: AppDimensions.spaceSmall),
        
        // Role badge
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _getRoleGradient(widget.user.role),
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _getRoleGradient(widget.user.role)[0].withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              _getRoleText(widget.user.role),
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    final initials = widget.user.name.isNotEmpty
        ? widget.user.name[0].toUpperCase()
        : 'U';
    
    return Center(
      child: Text(
        initials,
        style: AppTextStyles.heading3.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name
        Text(
          widget.user.name,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: AppDimensions.spaceXSmall),
        
        // Email
        Row(
          children: [
            Icon(
              Icons.email_outlined,
              size: 14,
              color: AppTheme.textMuted.withOpacity(0.7),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                widget.user.email,
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppDimensions.spaceXSmall),
        
        // Phone
        Row(
          children: [
            Icon(
              Icons.phone_outlined,
              size: 14,
              color: AppTheme.textMuted.withOpacity(0.7),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                widget.user.phone,
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Created date
        Text(
          _formatDate(widget.user.createdAt),
          style: AppTextStyles.caption.copyWith(
            color: AppTheme.textMuted.withOpacity(0.6),
          ),
        ),
        
        // Status toggle
        _buildStatusToggle(),
      ],
    );
  }

  Widget _buildStatusIndicator() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.user.isActive
                ? AppTheme.success
                : AppTheme.textMuted,
            boxShadow: widget.user.isActive
                ? [
                    BoxShadow(
                      color: AppTheme.success.withOpacity(0.8),
                      blurRadius: 6 + 4 * _glowAnimation.value,
                      spreadRadius: 1 + _glowAnimation.value,
                    ),
                  ]
                : [],
          ),
        );
      },
    );
  }

  Widget _buildStatusToggle() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onStatusToggle(!widget.user.isActive);
      },
      child: Container(
        width: 40,
        height: 22,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          gradient: widget.user.isActive
              ? LinearGradient(
                  colors: [AppTheme.success, AppTheme.neonGreen],
                )
              : null,
          color: !widget.user.isActive
              ? AppTheme.darkBorder.withOpacity(0.5)
              : null,
          boxShadow: widget.user.isActive
              ? [
                  BoxShadow(
                    color: AppTheme.success.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        padding: const EdgeInsets.all(2),
        child: AnimatedAlign(
          alignment: widget.user.isActive
              ? Alignment.centerRight
              : Alignment.centerLeft,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  void _onHover(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  List<Color> _getRoleGradient(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return [AppTheme.error, AppTheme.primaryViolet];
      case 'owner':
        return [AppTheme.primaryBlue, AppTheme.primaryPurple];
      case 'staff':
        return [AppTheme.warning, AppTheme.neonBlue];
      default:
        return [AppTheme.primaryCyan, AppTheme.neonGreen];
    }
  }

  String _getRoleText(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'مدير';
      case 'owner':
        return 'مالك';
      case 'staff':
        return 'موظف';
      case 'customer':
        return 'عميل';
      default:
        return role;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

    const spacing = 20.0;
    
    for (double i = spacing; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }
    
    for (double i = spacing; i < size.height; i += spacing) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}