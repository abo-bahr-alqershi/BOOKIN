// lib/features/admin_audit_logs/presentation/widgets/futuristic_audit_log_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/audit_log.dart';

class FuturisticAuditLogCard extends StatefulWidget {
  final AuditLog auditLog;
  final VoidCallback onTap;
  final Duration animationDelay;

  const FuturisticAuditLogCard({
    super.key,
    required this.auditLog,
    required this.onTap,
    this.animationDelay = Duration.zero,
  });

  @override
  State<FuturisticAuditLogCard> createState() =>
      _FuturisticAuditLogCardState();
}

class _FuturisticAuditLogCardState extends State<FuturisticAuditLogCard>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _hoverController;
  late AnimationController _glowController;
  late AnimationController _pulseController;
  
  late Animation<double> _entranceAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;
  
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
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.elasticOut,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    Future.delayed(widget.animationDelay, () {
      if (mounted) {
        _entranceController.forward();
        if (widget.auditLog.isSlowOperation) {
          _pulseController.repeat(reverse: true);
        }
      }
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _hoverController.dispose();
    _glowController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _entranceAnimation,
        _scaleAnimation,
        _glowAnimation,
        _pulseAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _entranceAnimation.value * _scaleAnimation.value,
          child: Opacity(
            opacity: _entranceAnimation.value,
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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.identity()
                    ..translate(0.0, _isPressed ? 2.0 : 0.0),
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
    final actionColor = Color(
      int.parse(widget.auditLog.actionColor.replaceAll('#', '0xFF')),
    );
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: actionColor.withOpacity(_isHovered ? 0.3 : 0.1),
            blurRadius: _isHovered ? 20 : 10,
            offset: Offset(0, _isHovered ? 8 : 4),
          ),
          if (widget.auditLog.isSlowOperation)
            BoxShadow(
              color: AppTheme.warning.withOpacity(0.2 * _pulseAnimation.value),
              blurRadius: 20,
              spreadRadius: 5,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.darkCard.withOpacity(0.7),
                  AppTheme.darkCard.withOpacity(0.5),
                  if (_isHovered) actionColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isHovered
                    ? actionColor.withOpacity(0.5)
                    : AppTheme.darkBorder.withOpacity(0.2),
                width: _isHovered ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(actionColor),
                const SizedBox(height: 12),
                _buildContent(),
                if (widget.auditLog.notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildNotes(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color actionColor) {
    return Row(
      children: [
        // Action Icon
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: actionColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: actionColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            _getActionIcon(),
            color: actionColor,
            size: 18,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // User and Action
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.auditLog.username,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppTheme.textWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: actionColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.auditLog.action.toUpperCase(),
                      style: AppTextStyles.caption.copyWith(
                        color: actionColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _formatTimestamp(),
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
        
        // Slow Operation Indicator
        if (widget.auditLog.isSlowOperation)
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: AppTheme.warning.withOpacity(_pulseAnimation.value),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Table and Record
        Row(
          children: [
            Icon(
              Icons.table_chart_outlined,
              size: 14,
              color: AppTheme.textMuted.withOpacity(0.6),
            ),
            const SizedBox(width: 6),
            Text(
              widget.auditLog.tableName,
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.textMuted,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.description_outlined,
              size: 14,
              color: AppTheme.textMuted.withOpacity(0.6),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                widget.auditLog.recordName,
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Changes
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.darkSurface.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.darkBorder.withOpacity(0.1),
              width: 0.5,
            ),
          ),
          child: Text(
            widget.auditLog.changes,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppTheme.textLight,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildNotes() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.info.withOpacity(0.1),
            AppTheme.info.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.info.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 14,
            color: AppTheme.info.withOpacity(0.7),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              widget.auditLog.notes,
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.textMuted,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _onHover(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _hoverController.forward();
      _glowController.repeat(reverse: true);
    } else {
      _hoverController.reverse();
      _glowController.stop();
      _glowController.reset();
    }
  }

  IconData _getActionIcon() {
    switch (widget.auditLog.action.toLowerCase()) {
      case 'create':
        return Icons.add_circle_outline;
      case 'update':
        return Icons.edit_outlined;
      case 'delete':
        return Icons.delete_outline;
      case 'login':
        return Icons.login_rounded;
      case 'logout':
        return Icons.logout_rounded;
      default:
        return Icons.info_outline;
    }
  }

  String _formatTimestamp() {
    final now = DateTime.now();
    final diff = now.difference(widget.auditLog.timestamp);
    
    if (diff.inMinutes < 1) {
      return 'الآن';
    } else if (diff.inMinutes < 60) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else if (diff.inHours < 24) {
      return 'منذ ${diff.inHours} ساعة';
    } else if (diff.inDays < 7) {
      return 'منذ ${diff.inDays} يوم';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(widget.auditLog.timestamp);
    }
  }
}