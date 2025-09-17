// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import '../../../../../../core/theme/app_theme.dart';
// import '../../../../../../core/theme/app_text_styles.dart';
// import '../../../../../../core/enums/payment_method_enum.dart';

// class PaymentMethodIcon extends StatelessWidget {
//   final PaymentMethod method;
//   final double size;
//   final bool showLabel;
//   final Color? color;

//   const PaymentMethodIcon({
//     super.key,
//     required this.method,
//     this.size = 32,
//     this.showLabel = true,
//     this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           width: size,
//           height: size,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 _getMethodColor().withValues(alpha: 0.2),
//                 _getMethodColor().withValues(alpha: 0.1),
//               ],
//             ),
//             borderRadius: BorderRadius.circular(size / 4),
//             border: Border.all(
//               color: _getMethodColor().withValues(alpha: 0.3),
//               width: 1,
//             ),
//           ),
//           child: Center(
//             child: Icon(
//               _getMethodIcon(),
//               color: color ?? _getMethodColor(),
//               size: size * 0.6,
//             ),
//           ),
//         ),
//         if (showLabel) ...[
//           const SizedBox(height: 4),
//           Text(
//             _getMethodLabel(),
//             style: AppTextStyles.caption.copyWith(
//               color: AppTheme.textMuted,
//             ),
//           ),
//         ],
//       ],
//     );
//   }

//   IconData _getMethodIcon() {
//     switch (method) {
//       case PaymentMethod.creditCard:
//         return CupertinoIcons.creditcard_fill;
//       case PaymentMethod.debitCard:
//         return CupertinoIcons.creditcard;
//       case PaymentMethod.bankTransfer:
//         return CupertinoIcons.building_2_fill;
//       case PaymentMethod.cash:
//         return CupertinoIcons.money_dollar_circle_fill;
//       case PaymentMethod.wallet:
//         return CupertinoIcons.wallet_pass_fill;
//       case PaymentMethod.paypal:
//         return Icons.paypal;
//       case PaymentMethod.stripe:
//         return Icons.payment;
//       case PaymentMethod.applePay:
//         return Icons.apple;
//       case PaymentMethod.googlePay:
//         return Icons.g_mobiledata;
//       case PaymentMethod.crypto:
//         return Icons.currency_bitcoin;
//       case PaymentMethod.other:
//         return CupertinoIcons.ellipsis_circle_fill;
//     }
//   }

//   Color _getMethodColor() {
//     switch (method) {
//       case PaymentMethod.creditCard:
//       case PaymentMethod.debitCard:
//         return AppTheme.primaryBlue;
//       case PaymentMethod.bankTransfer:
//         return AppTheme.primaryPurple;
//       case PaymentMethod.cash:
//         return AppTheme.success;
//       case PaymentMethod.wallet:
//         return AppTheme.primaryViolet;
//       case PaymentMethod.paypal:
//         return const Color(0xFF00457C);
//       case PaymentMethod.stripe:
//         return const Color(0xFF635BFF);
//       case PaymentMethod.applePay:
//         return AppTheme.textDark;
//       case PaymentMethod.googlePay:
//         return const Color(0xFF4285F4);
//       case PaymentMethod.crypto:
//         return const Color(0xFFF7931A);
//       case PaymentMethod.other:
//         return AppTheme.textMuted;
//     }
//   }

//   String _getMethodLabel() {
//     switch (method) {
//       case PaymentMethod.creditCard:
//         return 'بطاقة ائتمان';
//       case PaymentMethod.debitCard:
//         return 'بطاقة خصم';
//       case PaymentMethod.bankTransfer:
//         return 'تحويل بنكي';
//       case PaymentMethod.cash:
//         return 'نقدي';
//       case PaymentMethod.wallet:
//         return 'محفظة';
//       case PaymentMethod.paypal:
//         return 'PayPal';
//       case PaymentMethod.stripe:
//         return 'Stripe';
//       case PaymentMethod.applePay:
//         return 'Apple Pay';
//       case PaymentMethod.googlePay:
//         return 'Google Pay';
//       case PaymentMethod.crypto:
//         return 'عملة رقمية';
//       case PaymentMethod.other:
//         return 'أخرى';
//     }
//   }
// }
