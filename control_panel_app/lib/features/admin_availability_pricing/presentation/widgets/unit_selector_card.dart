// lib/features/admin_availability_pricing/presentation/widgets/unit_selector_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';

class UnitSelectorCard extends StatefulWidget {
  final String? selectedUnitId;
  final Function(String) onUnitSelected;
  final bool isCompact;

  const UnitSelectorCard({
    super.key,
    required this.selectedUnitId,
    required this.onUnitSelected,
    this.isCompact = false,
  });

  @override
  State<UnitSelectorCard> createState() => _UnitSelectorCardState();
}

class _UnitSelectorCardState extends State<UnitSelectorCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;
  
  // Mock data - replace with actual units from bloc
  final List<Unit> _units = [
    Unit(id: 'unit_1', name: 'جناح ديلوكس', type: 'suite', isAvailable: true),
    Unit(id: 'unit_2', name: 'غرفة مزدوجة', type: 'double', isAvailable: true),
    Unit(id: 'unit_3', name: 'فيلا خاصة', type: 'villa', isAvailable: false),
    Unit(id: 'unit_4', name: 'استوديو', type: 'studio', isAvailable: true),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          height: widget.isCompact ? 60 : null,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.darkCard.withOpacity(0.7),
                AppTheme.darkCard.withOpacity(0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.primaryBlue.withOpacity(0.2 + 0.1 * _glowAnimation.value),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.1 * _glowAnimation.value),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: widget.isCompact
                  ? _buildCompactView()
                  : _buildExpandedView(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _buildUnitIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDropdown(),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildUnitsList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _buildUnitIcon(),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'اختر الوحدة',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_units.length} وحدة متاحة',
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUnitIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.apartment_rounded,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildDropdown() {
    final selectedUnit = _units.firstWhere(
      (u) => u.id == widget.selectedUnitId,
      orElse: () => _units.first,
    );
    
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedUnit.id,
        isExpanded: true,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppTheme.primaryBlue,
        ),
        dropdownColor: AppTheme.darkCard,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppTheme.textWhite,
        ),
        items: _units.map((unit) {
          return DropdownMenuItem<String>(
            value: unit.id,
            child: Row(
              children: [
                Icon(
                  _getUnitIcon(unit.type),
                  size: 16,
                  color: unit.isAvailable ? AppTheme.success : AppTheme.textMuted,
                ),
                const SizedBox(width: 8),
                Text(unit.name),
                if (!unit.isAvailable) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'غير متاح',
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.error,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            HapticFeedback.lightImpact();
            widget.onUnitSelected(value);
          }
        },
      ),
    );
  }

  Widget _buildUnitsList() {
    return Column(
      children: _units.map((unit) {
        final isSelected = unit.id == widget.selectedUnitId;
        
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onUnitSelected(unit.id);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: isSelected ? AppTheme.primaryGradient : null,
              color: !isSelected ? AppTheme.darkSurface.withOpacity(0.5) : null,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                    ? Colors.white.withOpacity(0.3)
                    : AppTheme.darkBorder.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getUnitIcon(unit.type),
                  color: isSelected 
                      ? Colors.white 
                      : unit.isAvailable 
                          ? AppTheme.success 
                          : AppTheme.textMuted,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        unit.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isSelected ? Colors.white : AppTheme.textWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _getUnitTypeLabel(unit.type),
                        style: AppTextStyles.caption.copyWith(
                          color: isSelected 
                              ? Colors.white.withOpacity(0.8)
                              : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!unit.isAvailable)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'غير متاح',
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.error,
                      ),
                    ),
                  ),
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getUnitIcon(String type) {
    switch (type) {
      case 'suite':
        return Icons.king_bed_rounded;
      case 'double':
        return Icons.bed_rounded;
      case 'villa':
        return Icons.villa_rounded;
      case 'studio':
        return Icons.weekend_rounded;
      default:
        return Icons.door_front_door_rounded;
    }
  }

  String _getUnitTypeLabel(String type) {
    switch (type) {
      case 'suite':
        return 'جناح';
      case 'double':
        return 'غرفة مزدوجة';
      case 'villa':
        return 'فيلا';
      case 'studio':
        return 'استوديو';
      default:
        return 'وحدة';
    }
  }
}

class Unit {
  final String id;
  final String name;
  final String type;
  final bool isAvailable;

  Unit({
    required this.id,
    required this.name,
    required this.type,
    required this.isAvailable,
  });
}