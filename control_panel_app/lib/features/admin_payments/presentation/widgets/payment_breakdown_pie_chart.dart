// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'dart:ui';
// import 'dart:math' as math;
// import '../../domain/entities/payment_analytics.dart';
// import '../../../../../../core/theme/app_theme.dart';
// import '../../../../../../core/theme/app_text_styles.dart';
// import '../../../../../../core/enums/payment_method_enum.dart';

// class PaymentBreakdownPieChart extends StatefulWidget {
//   final Map<dynamic, MethodAnalytics> methodAnalytics;
//   final double height;

//   const PaymentBreakdownPieChart({
//     super.key,
//     required this.methodAnalytics,
//     this.height = 300,
//   });

//   @override
//   State<PaymentBreakdownPieChart> createState() =>
//       _PaymentBreakdownPieChartState();
// }

// class _PaymentBreakdownPieChartState extends State<PaymentBreakdownPieChart>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _animation;
//   int _touchedIndex = -1;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );

//     _animation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.elasticOut,
//     ));

//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: widget.height,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             AppTheme.darkCard.withValues(alpha: 0.8),
//             AppTheme.darkCard.withValues(alpha: 0.6),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: AppTheme.darkBorder.withValues(alpha: 0.3),
//           width: 1,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'توزيع طرق الدفع',
//             style: AppTextStyles.heading3.copyWith(
//               color: AppTheme.textWhite,
//             ),
//           ),
//           const SizedBox(height: 20),
//           Expanded(
//             child: Row(
//               children: [
//                 Expanded(
//                   flex: 3,
//                   child: AnimatedBuilder(
//                     animation: _animation,
//                     builder: (context, child) {
//                       return Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           PieChart(
//                             PieChartData(
//                               pieTouchData: PieTouchData(
//                                 touchCallback:
//                                     (FlTouchEvent event, pieTouchResponse) {
//                                   setState(() {
//                                     if (!event.isInterestedForInteractions ||
//                                         pieTouchResponse == null ||
//                                         pieTouchResponse.touchedSection ==
//                                             null) {
//                                       _touchedIndex = -1;
//                                       return;
//                                     }
//                                     _touchedIndex = pieTouchResponse
//                                         .touchedSection!.touchedSectionIndex;
//                                   });
//                                 },
//                               ),
//                               borderData: FlBorderData(show: false),
//                               sectionsSpace: 2,
//                               centerSpaceRadius: 50,
//                               sections: _buildSections(),
//                             ),
//                           ),
//                           Container(
//                             padding: const EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                               color: AppTheme.darkBackground
//                                   .withValues(alpha: 0.8),
//                               shape: BoxShape.circle,
//                             ),
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Text(
//                                   'الإجمالي',
//                                   style: AppTextStyles.caption.copyWith(
//                                     color: AppTheme.textMuted,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   _calculateTotal(),
//                                   style: AppTextStyles.bodyLarge.copyWith(
//                                     color: AppTheme.textWhite,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 20),
//                 Expanded(
//                   flex: 2,
//                   child: _buildLegend(),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   List<PieChartSectionData> _buildSections() {
//     // Create dummy data if empty
//     final data = widget.methodAnalytics.isEmpty
//         ? _createDummyData()
//         : widget.methodAnalytics;

//     final sections = <PieChartSectionData>[];
//     int index = 0;

//     data.forEach((method, analytics) {
//       final isTouched = index == _touchedIndex;
//       final fontSize = isTouched ? 16.0 : 12.0;
//       final radius = isTouched ? 70.0 : 60.0;

//       sections.add(
//         PieChartSectionData(
//           color: _getMethodColor(index),
//           value: analytics.percentage * _animation.value,
//           title:
//               '${(analytics.percentage * _animation.value).toStringAsFixed(1)}%',
//           radius: radius,
//           titleStyle: AppTextStyles.caption.copyWith(
//             fontSize: fontSize,
//             color: AppTheme.textWhite,
//             fontWeight: FontWeight.bold,
//           ),
//           titlePositionPercentageOffset: 0.55,
//         ),
//       );
//       index++;
//     });

//     return sections;
//   }

//   Widget _buildLegend() {
//     final data = widget.methodAnalytics.isEmpty
//         ? _createDummyData()
//         : widget.methodAnalytics;

//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: data.entries.map((entry) {
//         final index = data.keys.toList().indexOf(entry.key);
//         return Container(
//           margin: const EdgeInsets.only(bottom: 12),
//           child: Row(
//             children: [
//               Container(
//                 width: 12,
//                 height: 12,
//                 decoration: BoxDecoration(
//                   color: _getMethodColor(index),
//                   borderRadius: BorderRadius.circular(3),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       _getMethodName(entry.key),
//                       style: AppTextStyles.caption.copyWith(
//                         color: AppTheme.textWhite,
//                       ),
//                     ),
//                     Text(
//                       '${entry.value.transactionCount} معاملة',
//                       style: AppTextStyles.caption.copyWith(
//                         color: AppTheme.textMuted,
//                         fontSize: 10,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Map<dynamic, MethodAnalytics> _createDummyData() {
//     return {
//       PaymentMethod.creditCard: MethodAnalytics(
//         method: PaymentMethod.creditCard,
//         transactionCount: 145,
//         totalAmount: Money(
//           amount: 250000,
//           currency: 'YER',
//           formattedAmount: '250,000 YER',
//         ),
//         percentage: 35,
//         successRate: 95,
//         averageAmount: Money(
//           amount: 1724,
//           currency: 'YER',
//           formattedAmount: '1,724 YER',
//         ),
//       ),
//       PaymentMethod.bankTransfer: MethodAnalytics(
//         method: PaymentMethod.bankTransfer,
//         transactionCount: 98,
//         totalAmount: Money(
//           amount: 180000,
//           currency: 'YER',
//           formattedAmount: '180,000 YER',
//         ),
//         percentage: 25,
//         successRate: 98,
//         averageAmount: Money(
//           amount: 1837,
//           currency: 'YER',
//           formattedAmount: '1,837 YER',
//         ),
//       ),
//       PaymentMethod.wallet: MethodAnalytics(
//         method: PaymentMethod.wallet,
//         transactionCount: 87,
//         totalAmount: Money(
//           amount: 120000,
//           currency: 'YER',
//           formattedAmount: '120,000 YER',
//         ),
//         percentage: 20,
//         successRate: 92,
//         averageAmount: Money(
//           amount: 1379,
//           currency: 'YER',
//           formattedAmount: '1,379 YER',
//         ),
//       ),
//       PaymentMethod.cash: MethodAnalytics(
//         method: PaymentMethod.cash,
//         transactionCount: 65,
//         totalAmount: Money(
//           amount: 95000,
//           currency: 'YER',
//           formattedAmount: '95,000 YER',
//         ),
//         percentage: 15,
//         successRate: 100,
//         averageAmount: Money(
//           amount: 1462,
//           currency: 'YER',
//           formattedAmount: '1,462 YER',
//         ),
//       ),
//       PaymentMethod.other: MethodAnalytics(
//         method: PaymentMethod.other,
//         transactionCount: 25,
//         totalAmount: Money(
//           amount: 35000,
//           currency: 'YER',
//           formattedAmount: '35,000 YER',
//         ),
//         percentage: 5,
//         successRate: 88,
//         averageAmount: Money(
//           amount: 1400,
//           currency: 'YER',
//           formattedAmount: '1,400 YER',
//         ),
//       ),
//     };
//   }

//   Color _getMethodColor(int index) {
//     final colors = [
//       AppTheme.primaryBlue,
//       AppTheme.primaryPurple,
//       AppTheme.success,
//       AppTheme.warning,
//       AppTheme.primaryViolet,
//       AppTheme.info,
//       AppTheme.error,
//     ];
//     return colors[index % colors.length];
//   }

//   String _getMethodName(dynamic method) {
//     if (method is PaymentMethod) {
//       switch (method) {
//         case PaymentMethod.creditCard:
//           return 'بطاقة ائتمان';
//         case PaymentMethod.debitCard:
//           return 'بطاقة خصم';
//         case PaymentMethod.bankTransfer:
//           return 'تحويل بنكي';
//         case PaymentMethod.cash:
//           return 'نقدي';
//         case PaymentMethod.wallet:
//           return 'محفظة';
//         default:
//           return 'أخرى';
//       }
//     }
//     return method.toString();
//   }

//   String _calculateTotal() {
//     final data = widget.methodAnalytics.isEmpty
//         ? _createDummyData()
//         : widget.methodAnalytics;

//     final total = data.values.fold(
//       0.0,
//       (sum, analytics) => sum + analytics.totalAmount.amount,
//     );

//     if (total >= 1000000) {
//       return '${(total / 1000000).toStringAsFixed(1)}M ر.ي';
//     } else if (total >= 1000) {
//       return '${(total / 1000).toStringAsFixed(1)}K ر.ي';
//     }
//     return '${total.toStringAsFixed(0)} ر.ي';
//   }
// }
