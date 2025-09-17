// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../bloc/payments_list/payments_list_bloc.dart';
// import '../../bloc/payments_list/payments_list_event.dart';
// import '../../../../../../core/theme/app_theme.dart';
// import '../../../../../../core/theme/app_text_styles.dart';
// import '../../../../../../core/enums/payment_method_enum.dart';

// class PaymentFiltersWidget extends StatefulWidget {
//   const PaymentFiltersWidget({super.key});

//   @override
//   State<PaymentFiltersWidget> createState() => _PaymentFiltersWidgetState();
// }

// class _PaymentFiltersWidgetState extends State<PaymentFiltersWidget> {
//   PaymentStatus? _selectedStatus;
//   PaymentMethod? _selectedMethod;
//   DateTimeRange? _selectedDateRange;
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // Search Bar
//           _buildSearchBar(),
//           const SizedBox(height: 12),
//           // Filter Chips
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: [
//                 _buildFilterChip(
//                   label: 'الحالة',
//                   value: _selectedStatus != null
//                       ? _getStatusText(_selectedStatus!)
//                       : null,
//                   icon: CupertinoIcons.flag,
//                   onTap: _showStatusFilter,
//                 ),
//                 const SizedBox(width: 8),
//                 _buildFilterChip(
//                   label: 'طريقة الدفع',
//                   value: _selectedMethod != null
//                       ? _getMethodText(_selectedMethod!)
//                       : null,
//                   icon: CupertinoIcons.creditcard,
//                   onTap: _showMethodFilter,
//                 ),
//                 const SizedBox(width: 8),
//                 _buildFilterChip(
//                   label: 'التاريخ',
//                   value: _selectedDateRange != null
//                       ? _formatDateRange(_selectedDateRange!)
//                       : null,
//                   icon: CupertinoIcons.calendar,
//                   onTap: _showDatePicker,
//                 ),
//                 const SizedBox(width: 8),
//                 if (_hasActiveFilters()) _buildClearFiltersButton(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchBar() {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppTheme.darkCard,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: AppTheme.darkBorder,
//           width: 1,
//         ),
//       ),
//       child: TextField(
//         controller: _searchController,
//         style: AppTextStyles.bodyMedium.copyWith(
//           color: AppTheme.textWhite,
//         ),
//         decoration: InputDecoration(
//           hintText: 'البحث في المدفوعات...',
//           hintStyle: AppTextStyles.bodyMedium.copyWith(
//             color: AppTheme.textMuted,
//           ),
//           prefixIcon: Icon(
//             CupertinoIcons.search,
//             color: AppTheme.textMuted,
//             size: 20,
//           ),
//           suffixIcon: _searchController.text.isNotEmpty
//               ? IconButton(
//                   icon: Icon(
//                     CupertinoIcons.xmark_circle_fill,
//                     color: AppTheme.textMuted,
//                     size: 18,
//                   ),
//                   onPressed: () {
//                     _searchController.clear();
//                     _applyFilters();
//                   },
//                 )
//               : null,
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 12,
//           ),
//         ),
//         onSubmitted: (_) => _applyFilters(),
//       ),
//     );
//   }

//   Widget _buildFilterChip({
//     required String label,
//     String? value,
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     final hasValue = value != null;
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(
//           horizontal: 12,
//           vertical: 8,
//         ),
//         decoration: BoxDecoration(
//           gradient: hasValue ? AppTheme.primaryGradient : null,
//           color: hasValue ? null : AppTheme.darkCard,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: hasValue ? Colors.transparent : AppTheme.darkBorder,
//             width: 1,
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               color: AppTheme.textWhite,
//               size: 16,
//             ),
//             const SizedBox(width: 6),
//             Text(
//               value ?? label,
//               style: AppTextStyles.caption.copyWith(
//                 color: AppTheme.textWhite,
//                 fontWeight: hasValue ? FontWeight.bold : FontWeight.normal,
//               ),
//             ),
//             if (hasValue) ...[
//               const SizedBox(width: 6),
//               Icon(
//                 CupertinoIcons.xmark_circle_fill,
//                 color: AppTheme.textWhite,
//                 size: 14,
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildClearFiltersButton() {
//     return GestureDetector(
//       onTap: _clearFilters,
//       child: Container(
//         padding: const EdgeInsets.symmetric(
//           horizontal: 12,
//           vertical: 8,
//         ),
//         decoration: BoxDecoration(
//           color: AppTheme.error.withValues(alpha: 0.1),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: AppTheme.error.withValues(alpha: 0.3),
//             width: 1,
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               CupertinoIcons.clear_circled_solid,
//               color: AppTheme.error,
//               size: 16,
//             ),
//             const SizedBox(width: 6),
//             Text(
//               'مسح الفلاتر',
//               style: AppTextStyles.caption.copyWith(
//                 color: AppTheme.error,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showStatusFilter() {
//     showCupertinoModalPopup(
//       context: context,
//       builder: (context) => CupertinoActionSheet(
//         title: const Text('اختر حالة الدفعة'),
//         actions: PaymentStatus.values.map((status) {
//           return CupertinoActionSheetAction(
//             onPressed: () {
//               setState(() {
//                 _selectedStatus = status;
//               });
//               Navigator.pop(context);
//               _applyFilters();
//             },
//             child: Text(_getStatusText(status)),
//           );
//         }).toList(),
//         cancelButton: CupertinoActionSheetAction(
//           isDefaultAction: true,
//           onPressed: () => Navigator.pop(context),
//           child: const Text('إلغاء'),
//         ),
//       ),
//     );
//   }

//   void _showMethodFilter() {
//     showCupertinoModalPopup(
//       context: context,
//       builder: (context) => CupertinoActionSheet(
//         title: const Text('اختر طريقة الدفع'),
//         actions: PaymentMethod.values.map((method) {
//           return CupertinoActionSheetAction(
//             onPressed: () {
//               setState(() {
//                 _selectedMethod = method;
//               });
//               Navigator.pop(context);
//               _applyFilters();
//             },
//             child: Text(_getMethodText(method)),
//           );
//         }).toList(),
//         cancelButton: CupertinoActionSheetAction(
//           isDefaultAction: true,
//           onPressed: () => Navigator.pop(context),
//           child: const Text('إلغاء'),
//         ),
//       ),
//     );
//   }

//   void _showDatePicker() async {
//     final DateTimeRange? picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//       initialDateRange: _selectedDateRange,
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.dark(
//               primary: AppTheme.primaryBlue,
//               onPrimary: AppTheme.textWhite,
//               surface: AppTheme.darkCard,
//               onSurface: AppTheme.textWhite,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null) {
//       setState(() {
//         _selectedDateRange = picked;
//       });
//       _applyFilters();
//     }
//   }

//   void _applyFilters() {
//     context.read<PaymentsListBloc>().add(
//           FilterPaymentsEvent(
//             status: _selectedStatus,
//             method: _selectedMethod,
//             startDate: _selectedDateRange?.start,
//             endDate: _selectedDateRange?.end,
//           ),
//         );

//     if (_searchController.text.isNotEmpty) {
//       context.read<PaymentsListBloc>().add(
//             SearchPaymentsEvent(searchTerm: _searchController.text),
//           );
//     }
//   }

//   void _clearFilters() {
//     setState(() {
//       _selectedStatus = null;
//       _selectedMethod = null;
//       _selectedDateRange = null;
//       _searchController.clear();
//     });
//     _applyFilters();
//   }

//   bool _hasActiveFilters() {
//     return _selectedStatus != null ||
//         _selectedMethod != null ||
//         _selectedDateRange != null ||
//         _searchController.text.isNotEmpty;
//   }

//   String _getStatusText(PaymentStatus status) {
//     // Implementation based on PaymentStatus enum
//     return status.toString().split('.').last;
//   }

//   String _getMethodText(PaymentMethod method) {
//     // Implementation based on PaymentMethod enum
//     return method.toString().split('.').last;
//   }

//   String _formatDateRange(DateTimeRange range) {
//     return '${range.start.day}/${range.start.month} - ${range.end.day}/${range.end.month}';
//   }
// }
