import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/money.dart';
import '../../domain/entities/pricing_method.dart';

class PricingFormWidget extends StatefulWidget {
  final Function(Money, PricingMethod) onPricingChanged;
  final Money? initialBasePrice;
  final PricingMethod? initialPricingMethod;

  const PricingFormWidget({
    super.key,
    required this.onPricingChanged,
    this.initialBasePrice,
    this.initialPricingMethod,
  });

  @override
  State<PricingFormWidget> createState() => _PricingFormWidgetState();
}

class _PricingFormWidgetState extends State<PricingFormWidget> {
  late TextEditingController _amountController;
  late String _selectedCurrency;
  late PricingMethod _selectedMethod;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.initialBasePrice?.amount.toString() ?? '',
    );
    _selectedCurrency = widget.initialBasePrice?.currency ?? 'YER';
    _selectedMethod = widget.initialPricingMethod ?? PricingMethod.daily;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _updatePricing() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final money = Money(
      amount: amount,
      currency: _selectedCurrency,
    );
    widget.onPricingChanged(money, _selectedMethod);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.success.withOpacity(0.05),
            AppTheme.success.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(
          color: AppTheme.success.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.attach_money,
                size: 20,
                color: AppTheme.success,
              ),
              const SizedBox(width: AppDimensions.spaceSmall),
              Text(
                'التسعير',
                style: AppTextStyles.heading3.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceMedium),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildAmountField(),
              ),
              const SizedBox(width: AppDimensions.spaceMedium),
              Expanded(
                child: _buildCurrencySelector(),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceMedium),
          _buildPricingMethodSelector(),
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المبلغ',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceSmall),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.darkCard.withOpacity(0.3),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(
              color: AppTheme.darkBorder.withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(AppDimensions.paddingMedium),
              prefixIcon: Icon(
                Icons.payments,
                size: 20,
                color: AppTheme.success,
              ),
            ),
            onChanged: (_) => _updatePricing(),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'العملة',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceSmall),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.darkCard.withOpacity(0.3),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(
              color: AppTheme.darkBorder.withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedCurrency,
            dropdownColor: AppTheme.darkCard,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
              ),
            ),
            items: ['YER', 'USD', 'EUR', 'SAR'].map((currency) {
              return DropdownMenuItem(
                value: currency,
                child: Text(currency),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedCurrency = value!);
              _updatePricing();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPricingMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'طريقة التسعير',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceSmall),
        Wrap(
          spacing: AppDimensions.spaceSmall,
          children: PricingMethod.values.map((method) {
            final isSelected = _selectedMethod == method;
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _selectedMethod = method);
                _updatePricing();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                  vertical: AppDimensions.paddingSmall,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.primaryGradient : null,
                  color: isSelected ? null : AppTheme.darkCard.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryBlue
                        : AppTheme.darkBorder.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      method.icon,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: AppDimensions.spaceXSmall),
                    Text(
                      method.arabicLabel,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isSelected ? Colors.white : AppTheme.textMuted,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}