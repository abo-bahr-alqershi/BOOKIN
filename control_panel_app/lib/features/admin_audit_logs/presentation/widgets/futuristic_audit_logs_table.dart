// lib/features/admin_audit_logs/presentation/widgets/futuristic_audit_logs_table.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/audit_log.dart';

class FuturisticAuditLogsTable extends StatefulWidget {
  final List<AuditLog> auditLogs;
  final Function(AuditLog) onLogTap;
  final VoidCallback onLoadMore;
  final bool hasReachedMax;

  const FuturisticAuditLogsTable({
    super.key,
    required this.auditLogs,
    required this.onLogTap,
    required this.onLoadMore,
    required this.hasReachedMax,
  });

  @override
  State<FuturisticAuditLogsTable> createState() =>
      _FuturisticAuditLogsTableState();
}

class _FuturisticAuditLogsTableState extends State<FuturisticAuditLogsTable>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;
  
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
  
  int? _hoveredIndex;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _shimmerAnimation = Tween<double>(
      begin: -1,
      end: 2,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
    
    _verticalScrollController.addListener(() {
      if (_verticalScrollController.position.pixels >=
          _verticalScrollController.position.maxScrollExtent * 0.9) {
        if (!widget.hasReachedMax) {
          widget.onLoadMore();
        }
      }
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > AppDimensions.tabletBreakpoint;
    
    return Container(
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
          child: Column(
            children: [
              // Header
              _buildTableHeader(isDesktop),
              
              // Divider
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppTheme.primaryBlue.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              
              // Table Body
              Expanded(
                child: Scrollbar(
                  controller: _verticalScrollController,
                  child: SingleChildScrollView(
                    controller: _verticalScrollController,
                    child: SingleChildScrollView(
                      controller: _horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      child: _buildTableBody(isDesktop),
                    ),
                  ),
                ),
              ),
              
              // Loading Indicator
              if (!widget.hasReachedMax)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                    strokeWidth: 2,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader(bool isDesktop) {
    final headers = [
      'الوقت',
      'المستخدم',
      'الإجراء',
      'الجدول',
      'السجل',
      'التفاصيل',
      if (isDesktop) 'الملاحظات',
    ];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: headers.map((header) {
          return Expanded(
            flex: header == 'التفاصيل' ? 2 : 1,
            child: Text(
              header,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTableBody(bool isDesktop) {
    return DataTable(
      horizontalMargin: 20,
      columnSpacing: isDesktop ? 24 : 16,
      dataRowHeight: 72,
      headingRowHeight: 0,
      dividerThickness: 0,
      columns: _buildColumns(isDesktop),
      rows: widget.auditLogs.asMap().entries.map((entry) {
        final index = entry.key;
        final log = entry.value;
        return _buildDataRow(log, index, isDesktop);
      }).toList(),
    );
  }

  List<DataColumn> _buildColumns(bool isDesktop) {
    final columns = [
      const DataColumn(label: SizedBox.shrink()),
      const DataColumn(label: SizedBox.shrink()),
      const DataColumn(label: SizedBox.shrink()),
      const DataColumn(label: SizedBox.shrink()),
      const DataColumn(label: SizedBox.shrink()),
      const DataColumn(label: SizedBox.shrink()),
    ];
    
    if (isDesktop) {
      columns.add(const DataColumn(label: SizedBox.shrink()));
    }
    
    return columns;
  }

  DataRow _buildDataRow(AuditLog log, int index, bool isDesktop) {
    final isHovered = _hoveredIndex == index;
    final isSelected = _selectedIndex == index;
    
    return DataRow(
      selected: isSelected,
      onSelectChanged: (_) {
        HapticFeedback.lightImpact();
        setState(() => _selectedIndex = index);
        widget.onLogTap(log);
      },
      cells: [
        // Time
        DataCell(_buildTimeCell(log.timestamp)),
        
        // User
        DataCell(_buildUserCell(log.username)),
        
        // Action
        DataCell(_buildActionCell(log)),
        
        // Table
        DataCell(_buildTableCell(log.tableName)),
        
        // Record
        DataCell(_buildRecordCell(log.recordName)),
        
        // Changes
        DataCell(_buildChangesCell(log.changes)),
        
        // Notes (Desktop only)
        if (isDesktop)
          DataCell(_buildNotesCell(log.notes)),
      ],
    );
  }

  Widget _buildTimeCell(DateTime timestamp) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(timestamp);
    final formattedTime = DateFormat('HH:mm:ss').format(timestamp);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formattedDate,
          style: AppTextStyles.caption.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          formattedTime,
          style: AppTextStyles.caption.copyWith(
            color: AppTheme.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildUserCell(String username) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withOpacity(0.1),
            AppTheme.primaryPurple.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              username,
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.textWhite,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCell(AuditLog log) {
    final color = Color(int.parse(log.actionColor.replaceAll('#', '0xFF')));
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getActionIcon(log.action),
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            log.action.toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String tableName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        tableName,
        style: AppTextStyles.caption.copyWith(
          color: AppTheme.textMuted,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget _buildRecordCell(String recordName) {
    return Text(
      recordName,
      style: AppTextStyles.caption.copyWith(
        color: AppTheme.textWhite,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildChangesCell(String changes) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      child: Text(
        changes,
        style: AppTextStyles.caption.copyWith(
          color: AppTheme.textLight,
          fontSize: 11,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildNotesCell(String notes) {
    if (notes.isEmpty) {
      return Text(
        '-',
        style: AppTextStyles.caption.copyWith(
          color: AppTheme.textMuted.withOpacity(0.5),
        ),
      );
    }
    
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      child: Text(
        notes,
        style: AppTextStyles.caption.copyWith(
          color: AppTheme.textMuted,
          fontSize: 11,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  IconData _getActionIcon(String action) {
    switch (action.toLowerCase()) {
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