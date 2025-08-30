// lib/features/admin_audit_logs/presentation/widgets/audit_log_timeline_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/audit_log.dart';

class AuditLogTimelineWidget extends StatefulWidget {
  final List<AuditLog> auditLogs;
  final Function(AuditLog) onLogTap;
  final VoidCallback onLoadMore;
  final bool hasReachedMax;

  const AuditLogTimelineWidget({
    super.key,
    required this.auditLogs,
    required this.onLogTap,
    required this.onLoadMore,
    required this.hasReachedMax,
  });

  @override
  State<AuditLogTimelineWidget> createState() =>
      _AuditLogTimelineWidgetState();
}

class _AuditLogTimelineWidgetState extends State<AuditLogTimelineWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
    
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.9) {
        if (!widget.hasReachedMax) {
          widget.onLoadMore();
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupedLogs = _groupLogsByDate();
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkCard.withOpacity(0.5),
              AppTheme.darkCard.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryBlue.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: groupedLogs.length + (widget.hasReachedMax ? 0 : 1),
              itemBuilder: (context, index) {
                if (index == groupedLogs.length) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryBlue,
                        ),
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }
                
                final dateGroup = groupedLogs.entries.elementAt(index);
                return _buildDateSection(dateGroup.key, dateGroup.value);
              },
            ),
          ),
        ),
      ),
    );
  }

  Map<String, List<AuditLog>> _groupLogsByDate() {
    final Map<String, List<AuditLog>> grouped = {};
    
    for (final log in widget.auditLogs) {
      final dateKey = DateFormat('yyyy-MM-dd').format(log.timestamp);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(log);
    }
    
    return grouped;
  }

  Widget _buildDateSection(String date, List<AuditLog> logs) {
    final formattedDate = _formatDateHeader(date);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Header
        Container(
          margin: const EdgeInsets.only(bottom: 16, top: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  formattedDate,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryBlue.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Timeline Items
        ...logs.asMap().entries.map((entry) {
          final index = entry.key;
          final log = entry.value;
          final isLast = index == logs.length - 1;
          
          return _buildTimelineItem(log, isLast);
        }).toList(),
      ],
    );
  }

  Widget _buildTimelineItem(AuditLog log, bool isLast) {
    final actionColor = Color(
      int.parse(log.actionColor.replaceAll('#', '0xFF')),
    );
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line and Dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: actionColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: actionColor.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            actionColor.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onLogTap(log);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.darkSurface.withOpacity(0.5),
                      AppTheme.darkSurface.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: actionColor.withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        // Time
                        Text(
                          DateFormat('HH:mm:ss').format(log.timestamp),
                          style: AppTextStyles.caption.copyWith(
                            color: AppTheme.textMuted,
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Action Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: actionColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            log.action.toUpperCase(),
                            style: AppTextStyles.caption.copyWith(
                              color: actionColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // User
                        Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  log.username.isNotEmpty
                                      ? log.username[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              log.username,
                              style: AppTextStyles.caption.copyWith(
                                color: AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Table and Record
                    Row(
                      children: [
                        Icon(
                          Icons.table_chart_outlined,
                          size: 12,
                          color: AppTheme.textMuted.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          log.tableName,
                          style: AppTextStyles.caption.copyWith(
                            color: AppTheme.textMuted,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 12,
                          color: AppTheme.textMuted.withOpacity(0.4),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            log.recordName,
                            style: AppTextStyles.caption.copyWith(
                              color: AppTheme.textWhite,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Changes
                    Text(
                      log.changes,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppTheme.textLight,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Slow Operation Warning
                    if (log.isSlowOperation) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppTheme.warning.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 12,
                              color: AppTheme.warning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'عملية بطيئة',
                              style: AppTextStyles.caption.copyWith(
                                color: AppTheme.warning,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateHeader(String date) {
    final parsedDate = DateTime.parse(date);
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateOnly = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
    
    if (dateOnly == DateTime(now.year, now.month, now.day)) {
      return 'اليوم';
    } else if (dateOnly == yesterday) {
      return 'أمس';
    } else {
      return DateFormat('dd MMMM yyyy', 'ar').format(parsedDate);
    }
  }
}