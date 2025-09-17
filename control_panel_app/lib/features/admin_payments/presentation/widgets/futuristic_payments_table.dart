// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'dart:ui';
// import '../../domain/entities/payment.dart';
// import '../../../../../../core/theme/app_theme.dart';
// import '../../../../../../core/theme/app_text_styles.dart';
// import '../../../../../../core/theme/app_dimensions.dart';
// import '../../../../../../core/widgets/price_widget.dart';
// import 'payment_status_indicator.dart';
// import 'payment_method_icon.dart';

// class FuturisticPaymentsTable extends StatefulWidget {
//   final List<Payment> payments;
//   final Function(Payment) onPaymentTap;
//   final Function(Payment)? onRefundTap;
//   final Function(Payment)? onVoidTap;
//   final bool showActions;
//   final bool isLoading;

//   const FuturisticPaymentsTable({
//     super.key,
//     required this.payments,
//     required this.onPaymentTap,
//     this.onRefundTap,
//     this.onVoidTap,
//     this.showActions = true,
//     this.isLoading = false,
//   });

//   @override
//   State<FuturisticPaymentsTable> createState() =>
//       _FuturisticPaymentsTableState();
// }

// class _FuturisticPaymentsTableState extends State<FuturisticPaymentsTable>
//     with TickerProviderStateMixin {
//   final ScrollController _horizontalScrollController = ScrollController();
//   final ScrollController _verticalScrollController = ScrollController();
//   late List<AnimationController> _rowAnimationControllers;
//   late List<Animation<double>> _fadeAnimations;
//   late List<Animation<Offset>> _slideAnimations;
//   int? _hoveredRowIndex;
//   int? _selectedRowIndex;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//   }

//   void _initializeAnimations() {
//     _rowAnimationControllers = List.generate(
//       widget.payments.length,
//       (index) => AnimationController(
//         duration: Duration(milliseconds: 300 + (index * 50)),
//         vsync: this,
//       ),
//     );

//     _fadeAnimations = _rowAnimationControllers.map((controller) {
//       return Tween<double>(
//         begin: 0.0,
//         end: 1.0,
//       ).animate(CurvedAnimation(
//         parent: controller,
//         curve: Curves.easeIn,
//       ));
//     }).toList();

//     _slideAnimations = _rowAnimationControllers.map((controller) {
//       return Tween<Offset>(
//         begin: const Offset(0.2, 0),
//         end: Offset.zero,
//       ).animate(CurvedAnimation(
//         parent: controller,
//         curve: Curves.easeOutCubic,
//       ));
//     }).toList();

//     // Start animations
//     Future.forEach(_rowAnimationControllers, (controller) async {
//       await Future.delayed(const Duration(milliseconds: 50));
//       if (mounted) controller.forward();
//     });
//   }

//   @override
//   void dispose() {
//     for (var controller in _rowAnimationControllers) {
//       controller.dispose();
//     }
//     _horizontalScrollController.dispose();
//     _verticalScrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppTheme.darkCard.withValues(alpha: 0.5),
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(
//           color: AppTheme.darkBorder.withValues(alpha: 0.3),
//           width: 1,
//         ),
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(24),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//           child: Column(
//             children: [
//               _buildHeader(),
//               Expanded(
//                 child: _buildTableContent(),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 20,
//         vertical: 16,
//       ),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             AppTheme.primaryBlue.withValues(alpha: 0.1),
//             AppTheme.primaryPurple.withValues(alpha: 0.05),
//           ],
//         ),
//         border: Border(
//           bottom: BorderSide(
//             color: AppTheme.darkBorder.withValues(alpha: 0.3),
//             width: 1,
//           ),
//         ),
//       ),
//       child: Row(
//         children: [
//           _buildHeaderCell('المعاملة', flex: 2),
//           _buildHeaderCell('العميل', flex: 2),
//           _buildHeaderCell('المبلغ', flex: 2),
//           _buildHeaderCell('الطريقة', flex: 1),
//           _buildHeaderCell('الحالة', flex: 1),
//           _buildHeaderCell('التاريخ', flex: 2),
//           if (widget.showActions) _buildHeaderCell('الإجراءات', flex: 2),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeaderCell(String text, {int flex = 1}) {
//     return Expanded(
//       flex: flex,
//       child: Text(
//         text,
//         style: AppTextStyles.caption.copyWith(
//           color: AppTheme.textMuted,
//           fontWeight: FontWeight.bold,
//           letterSpacing: 0.5,
//         ),
//       ),
//     );
//   }

//   Widget _buildTableContent() {
//     if (widget.isLoading) {
//       return _buildLoadingState();
//     }

//     if (widget.payments.isEmpty) {
//       return _buildEmptyState();
//     }

//     return Scrollbar(
//       controller: _verticalScrollController,
//       child: ListView.builder(
//         controller: _verticalScrollController,
//         padding: const EdgeInsets.symmetric(vertical: 8),
//         itemCount: widget.payments.length,
//         itemBuilder: (context, index) {
//           return FadeTransition(
//             opacity: _fadeAnimations[index],
//             child: SlideTransition(
//               position: _slideAnimations[index],
//               child: _buildTableRow(widget.payments[index], index),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildTableRow(Payment payment, int index) {
//     final isHovered = _hoveredRowIndex == index;
//     final isSelected = _selectedRowIndex == index;

//     return MouseRegion(
//       onEnter: (_) => setState(() => _hoveredRowIndex = index),
//       onExit: (_) => setState(() => _hoveredRowIndex = null),
//       child: GestureDetector(
//         onTap: () {
//           setState(() => _selectedRowIndex = index);
//           widget.onPaymentTap(payment);
//         },
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           margin: const EdgeInsets.symmetric(
//             horizontal: 12,
//             vertical: 4,
//           ),
//           padding: const EdgeInsets.symmetric(
//             horizontal: 20,
//             vertical: 16,
//           ),
//           decoration: BoxDecoration(
//             gradient: isSelected
//                 ? AppTheme.primaryGradient.scale(0.2)
//                 : isHovered
//                     ? LinearGradient(
//                         colors: [
//                           AppTheme.darkCard.withValues(alpha: 0.8),
//                           AppTheme.darkCard.withValues(alpha: 0.6),
//                         ],
//                       )
//                     : null,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: isSelected
//                   ? AppTheme.primaryBlue.withValues(alpha: 0.3)
//                   : isHovered
//                       ? AppTheme.darkBorder.withValues(alpha: 0.5)
//                       : Colors.transparent,
//               width: 1,
//             ),
//           ),
//           child: Row(
//             children: [
//               // Transaction ID
//               Expanded(
//                 flex: 2,
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 4,
//                       height: 40,
//                       decoration: BoxDecoration(
//                         gradient: AppTheme.primaryGradient,
//                         borderRadius: BorderRadius.circular(2),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           '#${payment.transactionId}',
//                           style: AppTextStyles.bodyMedium.copyWith(
//                             color: AppTheme.textWhite,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         if (payment.invoiceNumber != null)
//                           Text(
//                             'فاتورة: ${payment.invoiceNumber}',
//                             style: AppTextStyles.caption.copyWith(
//                               color: AppTheme.textMuted,
//                             ),
//                           ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               // Customer
//               Expanded(
//                 flex: 2,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       payment.userName ?? 'غير محدد',
//                       style: AppTextStyles.bodySmall.copyWith(
//                         color: AppTheme.textWhite,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     if (payment.userEmail != null)
//                       Text(
//                         payment.userEmail!,
//                         style: AppTextStyles.caption.copyWith(
//                           color: AppTheme.textMuted,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                   ],
//                 ),
//               ),

//               // Amount
//               Expanded(
//                 flex: 2,
//                 child: PriceWidget(
//                   price: payment.amount.amount,
//                   currency: payment.amount.currency,
//                   displayType: PriceDisplayType.normal,
//                   priceStyle: AppTextStyles.bodyMedium.copyWith(
//                     color: AppTheme.textWhite,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),

//               // Method
//               Expanded(
//                 flex: 1,
//                 child: PaymentMethodIcon(
//                   method: payment.method,
//                   size: 24,
//                   showLabel: false,
//                 ),
//               ),

//               // Status
//               Expanded(
//                 flex: 1,
//                 child: PaymentStatusIndicator(
//                   status: payment.status,
//                   size: PaymentStatusSize.small,
//                 ),
//               ),

//               // Date
//               Expanded(
//                 flex: 2,
//                 child: Text(
//                   _formatDate(payment.paymentDate),
//                   style: AppTextStyles.caption.copyWith(
//                     color: AppTheme.textMuted,
//                   ),
//                 ),
//               ),

//               // Actions
//               if (widget.showActions)
//                 Expanded(
//                   flex: 2,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       if (payment.canRefund && widget.onRefundTap != null)
//                         _buildActionButton(
//                           icon: CupertinoIcons.arrow_counterclockwise,
//                           color: AppTheme.warning,
//                           onTap: () => widget.onRefundTap!(payment),
//                         ),
//                       const SizedBox(width: 8),
//                       if (payment.canVoid && widget.onVoidTap != null)
//                         _buildActionButton(
//                           icon: CupertinoIcons.xmark_circle,
//                           color: AppTheme.error,
//                           onTap: () => widget.onVoidTap!(payment),
//                         ),
//                       const SizedBox(width: 8),
//                       _buildActionButton(
//                         icon: CupertinoIcons.eye,
//                         color: AppTheme.primaryBlue,
//                         onTap: () => widget.onPaymentTap(payment),
//                       ),
//                     ],
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButton({
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return Material(
//       color: Colors.transparent,
//       borderRadius: BorderRadius.circular(8),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(8),
//         child: Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: color.withValues(alpha: 0.1),
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(
//               color: color.withValues(alpha: 0.3),
//               width: 1,
//             ),
//           ),
//           child: Icon(
//             icon,
//             color: color,
//             size: 16,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLoadingState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: AppTheme.darkCard,
//               shape: BoxShape.circle,
//             ),
//             child: CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'جاري تحميل المدفوعات...',
//             style: AppTextStyles.bodyMedium.copyWith(
//               color: AppTheme.textMuted,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: AppTheme.darkCard.withValues(alpha: 0.5),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               CupertinoIcons.creditcard,
//               color: AppTheme.textMuted,
//               size: 48,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'لا توجد مدفوعات',
//             style: AppTextStyles.heading3.copyWith(
//               color: AppTheme.textWhite,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'لم يتم العثور على أي مدفوعات',
//             style: AppTextStyles.bodyMedium.copyWith(
//               color: AppTheme.textMuted,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }
