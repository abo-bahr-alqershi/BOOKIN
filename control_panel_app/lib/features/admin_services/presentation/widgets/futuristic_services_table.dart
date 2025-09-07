import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/service.dart';
import '../utils/service_icons.dart';

/// 📊 Futuristic Services Table
class FuturisticServicesTable extends StatefulWidget {
  final List<Service> services;
  final Function(Service) onServiceTap;
  final Function(Service)? onEdit;
  final Function(Service)? onDelete;

  const FuturisticServicesTable({
    super.key,
    required this.services,
    required this.onServiceTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<FuturisticServicesTable> createState() => _FuturisticServicesTableState();
}

class _FuturisticServicesTableState extends State<FuturisticServicesTable>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  int? _hoveredIndex;
  String _sortBy = 'name';
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Service> get _sortedServices {
    final sorted = List<Service>.from(widget.services);
    
    sorted.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'property':
          comparison = a.propertyName.compareTo(b.propertyName);
          break;
        case 'price':
          comparison = a.price.amount.compareTo(b.price.amount);
          break;
        default:
          comparison = 0;
      }
      return _isAscending ? comparison : -comparison;
    });
    
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkCard.withOpacity(0.7),
              AppTheme.darkCard.withOpacity(0.5),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.darkBorder.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _buildTable(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.darkBorder.withOpacity(0.2),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildHeaderCell(
            'الخدمة',
            'name',
            flex: 3,
            icon: Icons.room_service_rounded,
          ),
          _buildHeaderCell(
            'العقار',
            'property',
            flex: 2,
            icon: Icons.business_rounded,
          ),
          _buildHeaderCell(
            'السعر',
            'price',
            flex: 2,
            icon: Icons.attach_money_rounded,
          ),
          const SizedBox(width: 100), // Space for actions
        ],
      ),
    );
  }

  Widget _buildHeaderCell(
    String title,
    String sortKey, {
    required int flex,
    IconData? icon,
  }) {
    final isActive = _sortBy == sortKey;
    
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() {
            if (_sortBy == sortKey) {
              _isAscending = !_isAscending;
            } else {
              _sortBy = sortKey;
              _isAscending = true;
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(
                    colors: [
                      AppTheme.primaryBlue.withOpacity(0.1),
                      AppTheme.primaryPurple.withOpacity(0.05),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: isActive ? AppTheme.primaryBlue : AppTheme.textMuted,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isActive ? AppTheme.primaryBlue : AppTheme.textLight,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                isActive
                    ? (_isAscending
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded)
                    : Icons.unfold_more_rounded,
                size: 14,
                color: isActive ? AppTheme.primaryBlue : AppTheme.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTable() {
    final sortedServices = _sortedServices;
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: sortedServices.length,
      itemBuilder: (context, index) {
        final service = sortedServices[index];
        final isHovered = _hoveredIndex == index;
        
        return MouseRegion(
          onEnter: (_) => setState(() => _hoveredIndex = index),
          onExit: (_) => setState(() => _hoveredIndex = null),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onServiceTap(service);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isHovered
                    ? LinearGradient(
                        colors: [
                          AppTheme.primaryBlue.withOpacity(0.05),
                          AppTheme.primaryPurple.withOpacity(0.02),
                        ],
                      )
                    : null,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isHovered
                      ? AppTheme.primaryBlue.withOpacity(0.3)
                      : AppTheme.darkBorder.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  // Service Info
                  Expanded(
                    flex: 3,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isTight = constraints.maxWidth < 380;
                        return Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.primaryBlue.withOpacity(0.2),
                                    AppTheme.primaryPurple.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                ServiceIcons.getIconByName(service.icon),
                                color: AppTheme.primaryBlue,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppTheme.textWhite,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (!isTight)
                                    Text(
                                      'Icons.${service.icon}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppTheme.textMuted,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  
                  // Property
                  Expanded(
                    flex: 2,
                    child: Text(
                      service.propertyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppTheme.textLight,
                      ),
                    ),
                  ),
                  
                  // Price
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${service.price.amount} ${service.price.currency}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppTheme.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          service.pricingModel.label,
                          style: AppTextStyles.caption.copyWith(
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Actions
                  SizedBox(
                    width: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (widget.onEdit != null)
                          IconButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              widget.onEdit!(service);
                            },
                            icon: const Icon(Icons.edit_rounded),
                            iconSize: 18,
                            color: AppTheme.primaryBlue,
                            tooltip: 'تعديل',
                          ),
                        if (widget.onDelete != null)
                          IconButton(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              widget.onDelete!(service);
                            },
                            icon: const Icon(Icons.delete_rounded),
                            iconSize: 18,
                            color: AppTheme.error,
                            tooltip: 'حذف',
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}