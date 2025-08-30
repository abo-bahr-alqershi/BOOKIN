// lib/features/admin_audit_logs/presentation/widgets/activity_chart_widget.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/audit_log.dart';

class ActivityChartWidget extends StatefulWidget {
  final List<AuditLog> auditLogs;

  const ActivityChartWidget({
    super.key,
    required this.auditLogs,
  });

  @override
  State<ActivityChartWidget> createState() => _ActivityChartWidgetState();
}

class _ActivityChartWidgetState extends State<ActivityChartWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _glowController;
  late Animation<double> _chartAnimation;
  late Animation<double> _glowAnimation;
  
  int _selectedDataType = 0; // 0: Actions, 1: Users, 2: Tables
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _chartAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    
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
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          height: 320,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.darkCard.withOpacity(0.6),
                AppTheme.darkCard.withOpacity(0.4),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primaryBlue.withOpacity(0.2 + 0.1 * _glowAnimation.value),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.1 * _glowAnimation.value),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    Expanded(child: _buildChart()),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'نشاط النظام',
              style: AppTextStyles.heading3.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'آخر 7 أيام',
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
        _buildDataTypeSelector(),
      ],
    );
  }

  Widget _buildDataTypeSelector() {
    final options = ['الإجراءات', 'المستخدمون', 'الجداول'];
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: options.asMap().entries.map((entry) {
          final index = entry.key;
          final title = entry.value;
          final isSelected = _selectedDataType == index;
          
          return GestureDetector(
            onTap: () => setState(() => _selectedDataType = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.primaryGradient : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                title,
                style: AppTextStyles.caption.copyWith(
                  color: isSelected ? Colors.white : AppTheme.textMuted,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChart() {
    switch (_selectedDataType) {
      case 0:
        return _buildActionsChart();
      case 1:
        return _buildUsersChart();
      case 2:
        return _buildTablesChart();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildActionsChart() {
    final data = _getActionsData();
    
    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        return LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 20,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: AppTheme.darkBorder.withOpacity(0.1),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final days = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        days[value.toInt() % 7],
                        style: AppTextStyles.caption.copyWith(
                          color: AppTheme.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 20,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.textMuted,
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: 6,
            minY: 0,
            maxY: data.reduce(math.max) * 1.2,
            lineBarsData: [
              LineChartBarData(
                spots: data.asMap().entries.map((e) {
                  return FlSpot(e.key.toDouble(), e.value * _chartAnimation.value);
                }).toList(),
                isCurved: true,
                gradient: AppTheme.primaryGradient,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: AppTheme.primaryBlue,
                      strokeWidth: 2,
                      strokeColor: AppTheme.darkCard,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.primaryBlue.withOpacity(0.2),
                      AppTheme.primaryBlue.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
          swapAnimationDuration: const Duration(milliseconds: 300),
          swapAnimationCurve: Curves.easeOut,
        );
      },
    );
  }

  Widget _buildUsersChart() {
    final data = _getUsersData();
    final maxValue = data.values.reduce(math.max).toDouble();
    
    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxValue * 1.2,
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final users = data.keys.toList();
                    if (value.toInt() < users.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          users[value.toInt()].split(' ').first,
                          style: AppTextStyles.caption.copyWith(
                            color: AppTheme.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: maxValue / 5,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.textMuted,
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxValue / 5,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: AppTheme.darkBorder.withOpacity(0.1),
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(show: false),
            barGroups: data.entries.map((entry) {
              final index = data.keys.toList().indexOf(entry.key);
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.toDouble() * _chartAnimation.value,
                    gradient: AppTheme.primaryGradient,
                    width: 20,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          swapAnimationDuration: const Duration(milliseconds: 300),
          swapAnimationCurve: Curves.easeOut,
        );
      },
    );
  }

  Widget _buildTablesChart() {
    final data = _getTablesData();
    
    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        return PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 60,
            sections: data.entries.map((entry) {
              final index = data.keys.toList().indexOf(entry.key);
              final colors = [
                AppTheme.primaryBlue,
                AppTheme.primaryPurple,
                AppTheme.primaryCyan,
                AppTheme.success,
                AppTheme.warning,
              ];
              
              return PieChartSectionData(
                color: colors[index % colors.length],
                value: entry.value.toDouble() * _chartAnimation.value,
                title: '${entry.value}',
                radius: 50,
                titleStyle: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                badgeWidget: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.darkCard,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    entry.key,
                    style: AppTextStyles.caption.copyWith(
                      color: colors[index % colors.length],
                      fontSize: 10,
                    ),
                  ),
                ),
                badgePositionPercentageOffset: 1.3,
              );
            }).toList(),
          ),
          swapAnimationDuration: const Duration(milliseconds: 300),
          swapAnimationCurve: Curves.easeOut,
        );
      },
    );
  }

  List<double> _getActionsData() {
    // تحليل البيانات حسب الأيام
    final now = DateTime.now();
    final data = List<double>.filled(7, 0);
    
    for (final log in widget.auditLogs) {
      final diff = now.difference(log.timestamp).inDays;
      if (diff < 7) {
        data[6 - diff]++;
      }
    }
    
    return data;
  }

  Map<String, int> _getUsersData() {
    final Map<String, int> data = {};
    
    for (final log in widget.auditLogs) {
      data[log.username] = (data[log.username] ?? 0) + 1;
    }
    
    // أعلى 5 مستخدمين
    final sorted = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(sorted.take(5));
  }

  Map<String, int> _getTablesData() {
    final Map<String, int> data = {};
    
    for (final log in widget.auditLogs) {
      data[log.tableName] = (data[log.tableName] ?? 0) + 1;
    }
    
    // أعلى 5 جداول
    final sorted = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(sorted.take(5));
  }
}