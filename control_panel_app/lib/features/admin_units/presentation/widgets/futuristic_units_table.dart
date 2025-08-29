import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/unit.dart';

class FuturisticUnitsTable extends StatelessWidget {
  final List<Unit> units;
  final Function(Unit) onUnitSelected;
  final Function(Unit)? onEditUnit;
  final Function(Unit)? onDeleteUnit;

  const FuturisticUnitsTable({
    super.key,
    required this.units,
    required this.onUnitSelected,
    this.onEditUnit,
    this.onDeleteUnit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.glassLight.withOpacity(0.05),
            AppTheme.glassDark.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              _buildTableHeader(),
              Expanded(
                child: ListView.builder(
                  itemCount: units.length,
                  itemBuilder: (context, index) => _buildTableRow(units[index], index),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withOpacity(0.1),
            AppTheme.primaryPurple.withOpacity(0.05),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryBlue.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildHeaderCell('الوحدة', flex: 2),
          _buildHeaderCell('النوع', flex: 1),
          _buildHeaderCell('الكيان', flex: 2),
          _buildHeaderCell('السعر', flex: 1),
          _buildHeaderCell('السعة', flex: 1),
          _buildHeaderCell('الحالة', flex: 1),
          _buildHeaderCell('الإجراءات', flex: 1),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String title, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppTheme.primaryBlue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTableRow(Unit unit, int index) {
    final isEven = index % 2 == 0;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onUnitSelected(unit);
      },
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          color: isEven
              ? AppTheme.darkCard.withOpacity(0.03)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: AppTheme.darkBorder.withOpacity(0.1),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            _buildCell(unit.name, flex: 2, isName: true),
            _buildCell(unit.unitTypeName, flex: 1),
            _buildCell(unit.propertyName, flex: 2),
            _buildCell(unit.basePrice.displayAmount, flex: 1, isPrice: true),
            _buildCell(unit.capacityDisplay.isEmpty ? '-' : unit.capacityDisplay, flex: 1),
            _buildStatusCell(unit.isAvailable, flex: 1),
            _buildActionsCell(unit, flex: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(String text, {int flex = 1, bool isName = false, bool isPrice = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          color: isName
              ? AppTheme.textWhite
              : isPrice
                  ? AppTheme.primaryBlue
                  : AppTheme.textLight,
          fontWeight: isName || isPrice ? FontWeight.w600 : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildStatusCell(bool isAvailable, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingSmall,
          vertical: AppDimensions.paddingXSmall,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isAvailable
                ? [AppTheme.success.withOpacity(0.2), AppTheme.success.withOpacity(0.1)]
                : [AppTheme.error.withOpacity(0.2), AppTheme.error.withOpacity(0.1)],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        child: Text(
          isAvailable ? 'متاحة' : 'غير متاحة',
          style: AppTextStyles.caption.copyWith(
            color: isAvailable ? AppTheme.success : AppTheme.error,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildActionsCell(Unit unit, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onEditUnit != null)
            _buildActionButton(
              Icons.edit,
              AppTheme.primaryBlue,
              () => onEditUnit!(unit),
            ),
          if (onDeleteUnit != null) ...[
            const SizedBox(width: AppDimensions.spaceXSmall),
            _buildActionButton(
              Icons.delete,
              AppTheme.error,
              () => onDeleteUnit!(unit),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: Icon(
          icon,
          size: 14,
          color: color,
        ),
      ),
    );
  }
}