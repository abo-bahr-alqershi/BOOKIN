import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/unit_type.dart';

class CapacitySelectorWidget extends StatefulWidget {
  final UnitType unitType;
  final Function(int?, int?) onCapacityChanged;
  final int? initialAdults;
  final int? initialChildren;

  const CapacitySelectorWidget({
    super.key,
    required this.unitType,
    required this.onCapacityChanged,
    this.initialAdults,
    this.initialChildren,
  });

  @override
  State<CapacitySelectorWidget> createState() => _CapacitySelectorWidgetState();
}

class _CapacitySelectorWidgetState extends State<CapacitySelectorWidget> {
  int? _adults;
  int? _children;

  @override
  void initState() {
    super.initState();
    _adults = widget.initialAdults;
    _children = widget.initialChildren;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.unitType.isHasAdults && !widget.unitType.isHasChildren) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withOpacity(0.05),
            AppTheme.primaryPurple.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.group,
                size: 20,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(width: AppDimensions.spaceSmall),
              Text(
                'السعة الاستيعابية',
                style: AppTextStyles.heading3.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceMedium),
          Row(
            children: [
              if (widget.unitType.isHasAdults)
                Expanded(
                  child: _buildCapacityField(
                    label: 'عدد البالغين',
                    icon: Icons.person,
                    value: _adults,
                    onChanged: (value) {
                      setState(() => _adults = value);
                      widget.onCapacityChanged(_adults, _children);
                    },
                  ),
                ),
              if (widget.unitType.isHasAdults && widget.unitType.isHasChildren)
                const SizedBox(width: AppDimensions.spaceMedium),
              if (widget.unitType.isHasChildren)
                Expanded(
                  child: _buildCapacityField(
                    label: 'عدد الأطفال',
                    icon: Icons.child_care,
                    value: _children,
                    onChanged: (value) {
                      setState(() => _children = value);
                      widget.onCapacityChanged(_adults, _children);
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCapacityField({
    required String label,
    required IconData icon,
    required int? value,
    required Function(int?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
          child: Row(
            children: [
              _buildCounterButton(
                icon: Icons.remove,
                onTap: () {
                  if ((value ?? 0) > 0) {
                    onChanged((value ?? 0) - 1);
                  }
                },
              ),
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: value?.toString() ?? '0'),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(icon, size: 16, color: AppTheme.textMuted),
                  ),
                  onChanged: (text) {
                    onChanged(int.tryParse(text));
                  },
                ),
              ),
              _buildCounterButton(
                icon: Icons.add,
                onTap: () {
                  onChanged((value ?? 0) + 1);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        child: Icon(
          icon,
          size: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}