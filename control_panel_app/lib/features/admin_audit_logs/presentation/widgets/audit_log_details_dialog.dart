// lib/features/admin_audit_logs/presentation/widgets/audit_log_details_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'dart:convert';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/audit_log.dart';

class AuditLogDetailsDialog extends StatefulWidget {
  final AuditLog auditLog;

  const AuditLogDetailsDialog({
    super.key,
    required this.auditLog,
  });

  @override
  State<AuditLogDetailsDialog> createState() => _AuditLogDetailsDialogState();
}

class _AuditLogDetailsDialogState extends State<AuditLogDetailsDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;
  
  int _selectedTab = 0;
  final List<String> _tabs = ['معلومات عامة', 'القيم القديمة', 'القيم الجديدة', 'البيانات الوصفية'];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..forward();
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final actionColor = Color(
      int.parse(widget.auditLog.actionColor.replaceAll('#', '0xFF')),
    );
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: size.width > 600 ? 600 : size.width * 0.9,
                constraints: BoxConstraints(
                  maxHeight: size.height * 0.85,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: actionColor.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.darkCard.withOpacity(0.9),
                            AppTheme.darkCard.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: actionColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader(actionColor),
                          _buildTabs(),
                          Flexible(child: _buildContent()),
                          _buildActions(),
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

  Widget _buildHeader(Color actionColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            actionColor.withOpacity(0.15),
            actionColor.withOpacity(0.05),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: actionColor.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: actionColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: actionColor.withOpacity(0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: actionColor.withOpacity(0.3 * _glowAnimation.value),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  _getActionIcon(),
                  color: actionColor,
                  size: 24,
                ),
              );
            },
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تفاصيل السجل',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'معرف السجل: ${widget.auditLog.id}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close_rounded,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.darkBorder.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedTab == index;
          final hasContent = _hasContentForTab(index);
          
          if (!hasContent) return const SizedBox.shrink();
          
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _selectedTab = index);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected
                        ? AppTheme.primaryBlue
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  _tabs[index],
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isSelected
                        ? AppTheme.primaryBlue
                        : AppTheme.textMuted,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildTabContent(),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildGeneralInfo();
      case 1:
        return _buildOldValues();
      case 2:
        return _buildNewValues();
      case 3:
        return _buildMetadata();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildGeneralInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('المستخدم', widget.auditLog.username),
        _buildInfoRow('الإجراء', widget.auditLog.action.toUpperCase()),
        _buildInfoRow('الجدول', widget.auditLog.tableName),
        _buildInfoRow('معرف السجل', widget.auditLog.recordId),
        _buildInfoRow('اسم السجل', widget.auditLog.recordName),
        _buildInfoRow(
          'الوقت',
          DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.auditLog.timestamp),
        ),
        if (widget.auditLog.isSlowOperation)
          _buildWarningBox('عملية بطيئة', 'هذه العملية استغرقت وقتاً أطول من المعتاد'),
        const SizedBox(height: 16),
        _buildChangesSection(),
        if (widget.auditLog.notes.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildNotesSection(),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangesSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'التغييرات',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.auditLog.changes,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppTheme.textLight,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.info.withOpacity(0.1),
            AppTheme.info.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.info.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.note_rounded,
                size: 16,
                color: AppTheme.info,
              ),
              const SizedBox(width: 8),
              Text(
                'ملاحظات',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.info,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.auditLog.notes,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppTheme.textLight,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOldValues() {
    if (widget.auditLog.oldValues == null || widget.auditLog.oldValues!.isEmpty) {
      return _buildEmptyState('لا توجد قيم قديمة');
    }
    
    return _buildJsonViewer(widget.auditLog.oldValues!);
  }

  Widget _buildNewValues() {
    if (widget.auditLog.newValues == null || widget.auditLog.newValues!.isEmpty) {
      return _buildEmptyState('لا توجد قيم جديدة');
    }
    
    return _buildJsonViewer(widget.auditLog.newValues!);
  }

  Widget _buildMetadata() {
    if (widget.auditLog.metadata == null || widget.auditLog.metadata!.isEmpty) {
      return _buildEmptyState('لا توجد بيانات وصفية');
    }
    
    return _buildJsonViewer(widget.auditLog.metadata!);
  }

  Widget _buildJsonViewer(Map<String, dynamic> data) {
    final prettyJson = const JsonEncoder.withIndent('  ').convert(data);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Stack(
        children: [
          SelectableText(
            prettyJson,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppTheme.primaryCyan,
              fontFamily: 'monospace',
              height: 1.5,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: prettyJson));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم نسخ البيانات'),
                    backgroundColor: AppTheme.success,
                  ),
                );
              },
              icon: Icon(
                Icons.copy_rounded,
                size: 16,
                color: AppTheme.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 48,
              color: AppTheme.textMuted.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textMuted.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningBox(String title, String message) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.warning.withOpacity(0.15),
            AppTheme.warning.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.warning.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppTheme.warning,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  message,
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withOpacity(0.3),
        border: Border(
          top: BorderSide(
            color: AppTheme.darkBorder.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'إغلاق',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasContentForTab(int index) {
    switch (index) {
      case 0:
        return true;
      case 1:
        return widget.auditLog.oldValues != null && 
               widget.auditLog.oldValues!.isNotEmpty;
      case 2:
        return widget.auditLog.newValues != null && 
               widget.auditLog.newValues!.isNotEmpty;
      case 3:
        return widget.auditLog.metadata != null && 
               widget.auditLog.metadata!.isNotEmpty;
      default:
        return false;
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
}