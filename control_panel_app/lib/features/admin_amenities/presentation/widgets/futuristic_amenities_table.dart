import 'package:bookn_cp_app/features/admin_amenities/presentation/bloc/amenities_bloc.dart';
import 'package:bookn_cp_app/features/admin_amenities/presentation/bloc/amenities_event.dart';
import 'package:bookn_cp_app/features/admin_amenities/presentation/utils/amenity_icons.dart';
import 'package:bookn_cp_app/features/admin_amenities/presentation/widgets/assign_amenity_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/amenity.dart';

/// 📊 Premium Amenities Table - Enhanced Version
class FuturisticAmenitiesTable extends StatefulWidget {
  final List<Amenity> amenities;
  final Function(Amenity) onAmenitySelected;
  final Function(Amenity)? onEditAmenity;
  final Function(Amenity)? onDeleteAmenity;
  final Function(Amenity)? onAssignAmenity;
  final VoidCallback? onLoadMore;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final ScrollController? controller;

  const FuturisticAmenitiesTable({
    super.key,
    required this.amenities,
    required this.onAmenitySelected,
    this.onEditAmenity,
    this.onDeleteAmenity,
    this.onAssignAmenity,
    this.onLoadMore,
    this.hasReachedMax = true,
    this.isLoadingMore = false,
    this.controller,
  });

  @override
  State<FuturisticAmenitiesTable> createState() => _FuturisticAmenitiesTableState();
}

class _FuturisticAmenitiesTableState extends State<FuturisticAmenitiesTable>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _fadeAnimationController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;
  
  // State
  int? _hoveredIndex;
  int? _selectedIndex;
  String _sortBy = 'name';
  bool _isAscending = true;
  late final ScrollController _scrollController;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeControllers();
  }

  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    _shimmerAnimation = Tween<double>(
      begin: -1,
      end: 2,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimationController.forward();
  }

  void _initializeControllers() {
    _scrollController = widget.controller ?? ScrollController();
    _ownsController = widget.controller == null;
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    if (_ownsController) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_handleScroll);
    }
    super.dispose();
  }

  void _handleScroll() {
    if (widget.onLoadMore == null || widget.hasReachedMax) return;
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent * 0.9) {
      widget.onLoadMore!.call();
    }
  }

  List<Amenity> get _sortedAmenities {
    final sorted = List<Amenity>.from(widget.amenities);
    
    sorted.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'properties':
          comparison = (a.propertiesCount ?? 0).compareTo(b.propertiesCount ?? 0);
          break;
        case 'cost':
          comparison = (a.averageExtraCost ?? 0).compareTo(b.averageExtraCost ?? 0);
          break;
        case 'status':
          comparison = (a.isActive == true ? 1 : 0).compareTo(b.isActive == true ? 1 : 0);
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
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final isTablet = size.width >= 600 && size.width < 1200;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Enhanced gradient with purple tint
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppTheme.isDark 
              ? [
                  AppTheme.darkCard.withOpacity(0.7),
                  const Color(0xFF1A0E2E).withOpacity(0.4),
                ]
              : [
                  Colors.white,
                  AppTheme.lightBackground,
                ],
          ),
          borderRadius: BorderRadius.circular(isMobile ? 16 : 24), // زوايا حادة هادئة
          border: Border.all(
            color: AppTheme.primaryPurple.withOpacity(0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryPurple.withOpacity(AppTheme.isDark ? 0.2 : 0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(AppTheme.isDark ? 0.3 : 0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              children: [
                if (!isMobile) _buildEnhancedDesktopHeader(),
                if (isMobile) _buildEnhancedMobileHeader(),
                Expanded(
                  child: isMobile 
                    ? _buildEnhancedMobileList() 
                    : _buildEnhancedDesktopTable(),
                ),
                if (widget.isLoadingMore) _buildLoadingIndicator(),
                _buildFooterStats(), // إضافة footer مع إحصائيات
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedDesktopHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppTheme.isDark 
            ? [
                AppTheme.darkSurface.withOpacity(0.5),
                AppTheme.darkSurface.withOpacity(0.3),
              ]
            : [
                AppTheme.lightBackground.withOpacity(0.7),
                AppTheme.lightBackground.withOpacity(0.5),
              ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryPurple.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildEnhancedHeaderCell(
            'المرفق',
            'name',
            flex: 3,
            icon: Icons.star_rounded,
            isPrimary: true,
          ),
          _buildEnhancedHeaderCell(
            'العقارات',
            'properties',
            flex: 2,
            icon: Icons.business_rounded,
          ),
          _buildEnhancedHeaderCell(
            'التكلفة',
            'cost',
            flex: 2,
            icon: Icons.attach_money_rounded,
          ),
          _buildEnhancedHeaderCell(
            'الحالة',
            'status',
            flex: 1,
            icon: Icons.toggle_on_rounded,
          ),
          const SizedBox(width: 120), // مساحة للإجراءات
        ],
      ),
    );
  }

  Widget _buildEnhancedMobileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppTheme.isDark 
            ? [
                AppTheme.darkSurface.withOpacity(0.5),
                AppTheme.darkSurface.withOpacity(0.3),
              ]
            : [
                AppTheme.lightBackground.withOpacity(0.7),
                AppTheme.lightBackground.withOpacity(0.5),
              ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryPurple.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Animated Icon
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryPurple, AppTheme.primaryBlue],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryPurple.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المرافق (${widget.amenities.length})',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.amenities.where((a) => a.isActive == true).length} نشط',
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          _buildSortMenu(),
        ],
      ),
    );
  }

  Widget _buildSortMenu() {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryPurple.withOpacity(0.1),
              AppTheme.primaryBlue.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.primaryPurple.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Icon(
          Icons.sort_rounded,
          color: AppTheme.primaryPurple,
          size: 20,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppTheme.primaryPurple.withOpacity(0.2),
          width: 1,
        ),
      ),
      color: AppTheme.isDark ? AppTheme.darkCard : Colors.white,
      elevation: 8,
      onSelected: (value) {
        setState(() {
          if (_sortBy == value) {
            _isAscending = !_isAscending;
          } else {
            _sortBy = value;
            _isAscending = true;
          }
        });
      },
      itemBuilder: (context) => [
        _buildEnhancedSortMenuItem('name', 'الاسم', Icons.text_fields),
        _buildEnhancedSortMenuItem('properties', 'العقارات', Icons.business_rounded),
        _buildEnhancedSortMenuItem('cost', 'التكلفة', Icons.attach_money_rounded),
        _buildEnhancedSortMenuItem('status', 'الحالة', Icons.toggle_on_rounded),
      ],
    );
  }

  PopupMenuItem<String> _buildEnhancedSortMenuItem(String value, String label, IconData icon) {
    final isActive = _sortBy == value;
    return PopupMenuItem(
      value: value,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: isActive
                  ? LinearGradient(
                      colors: [
                        AppTheme.primaryPurple.withOpacity(0.2),
                        AppTheme.primaryBlue.withOpacity(0.1),
                      ],
                    )
                  : null,
                color: !isActive ? AppTheme.darkSurface.withOpacity(0.3) : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: isActive ? AppTheme.primaryPurple : AppTheme.textMuted,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isActive ? AppTheme.primaryPurple : AppTheme.textWhite,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isActive)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 12,
                  color: AppTheme.primaryPurple,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedHeaderCell(
    String title,
    String sortKey, {
    required int flex,
    IconData? icon,
    bool isPrimary = false,
  }) {
    final isActive = _sortBy == sortKey;
    
    return Expanded(
      flex: flex,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              if (_sortBy == sortKey) {
                _isAscending = !_isAscending;
              } else {
                _sortBy = sortKey;
                _isAscending = true;
              }
            });
          },
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                if (icon != null) ...[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: isActive || isPrimary
                        ? LinearGradient(
                            colors: [
                              AppTheme.primaryPurple.withOpacity(0.2),
                              AppTheme.primaryBlue.withOpacity(0.1),
                            ],
                          )
                        : null,
                      color: !isActive && !isPrimary 
                        ? AppTheme.darkSurface.withOpacity(0.2) 
                        : null,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      icon,
                      size: 14,
                      color: isActive || isPrimary 
                        ? AppTheme.primaryPurple 
                        : AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isActive 
                        ? AppTheme.primaryPurple 
                        : AppTheme.textLight,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: isActive && !_isAscending ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isActive
                      ? Icons.arrow_upward_rounded
                      : Icons.unfold_more_rounded,
                    size: 14,
                    color: isActive 
                      ? AppTheme.primaryPurple 
                      : AppTheme.textMuted.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedDesktopTable() {
    final sortedAmenities = _sortedAmenities;
    
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      trackVisibility: true,
      thickness: 8,
      radius: const Radius.circular(4),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: sortedAmenities.length,
        itemBuilder: (context, index) {
          final amenity = sortedAmenities[index];
          final isHovered = _hoveredIndex == index;
          final isSelected = _selectedIndex == index;
          
          return MouseRegion(
            onEnter: (_) => setState(() => _hoveredIndex = index),
            onExit: (_) => setState(() => _hoveredIndex = null),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedIndex = index);
                  widget.onAmenitySelected(amenity);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            AppTheme.primaryPurple.withOpacity(0.1),
                            AppTheme.primaryBlue.withOpacity(0.05),
                          ],
                        )
                      : isHovered
                        ? LinearGradient(
                            colors: [
                              AppTheme.primaryPurple.withOpacity(0.05),
                              Colors.transparent,
                            ],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(14), // زوايا حادة هادئة
                    border: Border.all(
                      color: isSelected
                        ? AppTheme.primaryPurple.withOpacity(0.3)
                        : isHovered 
                          ? AppTheme.primaryPurple.withOpacity(0.15)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                    boxShadow: isSelected || isHovered
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryPurple.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                  ),
                  child: Row(
                    children: [
                      // Amenity Info - Enhanced
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            // Animated Icon Container
                            AnimatedBuilder(
                              animation: _shimmerAnimation,
                              builder: (context, child) {
                                return Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.primaryPurple.withOpacity(0.2),
                                        AppTheme.primaryBlue.withOpacity(0.1),
                                      ],
                                      transform: isHovered 
                                        ? GradientRotation(_shimmerAnimation.value)
                                        : const GradientRotation(0),
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.primaryPurple.withOpacity(0.3),
                                      width: 1,
                                    ),
                                    boxShadow: isHovered
                                      ? [
                                          BoxShadow(
                                            color: AppTheme.primaryPurple.withOpacity(0.3),
                                            blurRadius: 12,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : [],
                                  ),
                                  child: Icon(
                                    _getAmenityIcon(amenity.icon),
                                    color: AppTheme.primaryPurple,
                                    size: 22,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          amenity.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            color: AppTheme.textWhite,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // ID Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryPurple.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                            color: AppTheme.primaryPurple.withOpacity(0.2),
                                            width: 0.5,
                                          ),
                                        ),
                                        child: Text(
                                          '#${amenity.id.substring(0, 6).toUpperCase()}',
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppTheme.primaryPurple,
                                            fontSize: 9,
                                            fontFamily: 'monospace',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    amenity.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Properties Count - Enhanced
                      Expanded(
                        flex: 2,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryBlue.withOpacity(0.1),
                                AppTheme.primaryBlue.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppTheme.primaryBlue.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.business_rounded,
                                size: 16,
                                color: AppTheme.primaryBlue,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${amenity.propertiesCount ?? 0}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppTheme.primaryBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'عقار',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppTheme.primaryBlue.withOpacity(0.7),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Cost - Enhanced
                      Expanded(
                        flex: 2,
                        child: _buildCostWidget(amenity),
                      ),
                      
                      // Status - Interactive
                      Expanded(
                        flex: 1,
                        child: _buildStatusWidget(amenity),
                      ),
                      
                      // Actions - Premium
                      SizedBox(
                        width: 120,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _buildPremiumActionButton(
                              icon: Icons.visibility_rounded,
                              color: AppTheme.primaryBlue,
                              onTap: () => widget.onAmenitySelected(amenity),
                              tooltip: 'عرض',
                            ),
                            const SizedBox(width: 6),
                            if (widget.onEditAmenity != null)
                              _buildPremiumActionButton(
                                icon: Icons.edit_rounded,
                                color: AppTheme.primaryPurple,
                                onTap: () => widget.onEditAmenity!(amenity),
                                tooltip: 'تعديل',
                              ),
                            const SizedBox(width: 6),
                            if (widget.onAssignAmenity != null)
                              _buildPremiumActionButton(
                                icon: Icons.assignment_rounded,
                                color: AppTheme.primaryBlue,
                                onTap: () => widget.onAssignAmenity!(amenity),
                                tooltip: 'تعيين',
                              ),
                            const SizedBox(width: 6),
                            if (widget.onDeleteAmenity != null)
                              _buildPremiumActionButton(
                                icon: Icons.delete_rounded,
                                color: AppTheme.error,
                                onTap: () => widget.onDeleteAmenity!(amenity),
                                tooltip: 'حذف',
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCostWidget(Amenity amenity) {
    final hasCost = amenity.averageExtraCost != null && amenity.averageExtraCost! > 0;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasCost
            ? [
                AppTheme.success.withOpacity(0.15),
                AppTheme.neonGreen.withOpacity(0.08),
              ]
            : [
                AppTheme.textMuted.withOpacity(0.1),
                AppTheme.textMuted.withOpacity(0.05),
              ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasCost
            ? AppTheme.success.withOpacity(0.3)
            : AppTheme.textMuted.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (hasCost) ...[
            Text(
              '\$',
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.success.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              amenity.averageExtraCost!.toStringAsFixed(0),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ] else ...[
            Icon(
              Icons.money_off_rounded,
              size: 14,
              color: AppTheme.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              'مجاني',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusWidget(Amenity amenity) {
    final isActive = amenity.isActive == true;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // Toggle status functionality
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isActive
              ? [
                  AppTheme.success.withOpacity(0.2),
                  AppTheme.neonGreen.withOpacity(0.1),
                ]
              : [
                  AppTheme.textMuted.withOpacity(0.2),
                  AppTheme.textMuted.withOpacity(0.1),
                ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
              ? AppTheme.success.withOpacity(0.5)
              : AppTheme.textMuted.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppTheme.success.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive ? AppTheme.success : AppTheme.textMuted,
                shape: BoxShape.circle,
                boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppTheme.success.withOpacity(0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isActive ? 'نشط' : 'معطل',
              style: AppTextStyles.caption.copyWith(
                color: isActive ? AppTheme.success : AppTheme.textMuted,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      preferBelow: false,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.9), color.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.15),
                color.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(8), // زوايا حادة هادئة
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedMobileList() {
    final sortedAmenities = _sortedAmenities;
    
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: sortedAmenities.length,
      itemBuilder: (context, index) {
        final amenity = sortedAmenities[index];
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                widget.onAmenitySelected(amenity);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppTheme.isDark
                      ? [
                          AppTheme.darkSurface.withOpacity(0.4),
                          const Color(0xFF1A0E2E).withOpacity(0.2),
                        ]
                      : [
                          AppTheme.lightSurface,
                          AppTheme.lightBackground,
                        ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryPurple.withOpacity(0.15),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header Row
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryPurple.withOpacity(0.2),
                                AppTheme.primaryBlue.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.primaryPurple.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            _getAmenityIcon(amenity.icon),
                            color: AppTheme.primaryPurple,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      amenity.name,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppTheme.textWhite,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryPurple.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '#${amenity.id.substring(0, 6).toUpperCase()}',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppTheme.primaryPurple,
                                        fontSize: 9,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                amenity.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.onEditAmenity != null || widget.onAssignAmenity != null ||widget.onDeleteAmenity != null)
                          PopupMenuButton<String>(
                            icon: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.darkSurface.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.more_vert_rounded,
                                color: AppTheme.textMuted,
                                size: 20,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: AppTheme.isDark ? AppTheme.darkCard : Colors.white,
                            onSelected: (value) {
                              HapticFeedback.selectionClick();
                              if (value == 'edit') {
                                widget.onEditAmenity?.call(amenity);
                              } else if (value == 'assign') {
                                widget.onAssignAmenity?.call(amenity);
                                }
                              else if (value == 'delete') {
                                widget.onDeleteAmenity?.call(amenity);
                              }
                            },
                            itemBuilder: (context) => [
                              if (widget.onEditAmenity != null)
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit_outlined,
                                        size: 18,
                                        color: AppTheme.primaryPurple,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'تعديل',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: AppTheme.textWhite,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                                              if (widget.onEditAmenity != null)
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit_outlined,
                                        size: 18,
                                        color: AppTheme.primaryPurple,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'تعديل',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: AppTheme.textWhite,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (widget.onDeleteAmenity != null)
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: AppTheme.error,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'حذف',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: AppTheme.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryBlue.withOpacity(0.1),
                                  AppTheme.primaryBlue.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppTheme.primaryBlue.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.business_rounded,
                                  size: 18,
                                  color: AppTheme.primaryBlue,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${amenity.propertiesCount ?? 0}',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'عقار',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppTheme.primaryBlue.withOpacity(0.7),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: amenity.averageExtraCost != null && amenity.averageExtraCost! > 0
                                  ? [
                                      AppTheme.success.withOpacity(0.15),
                                      AppTheme.neonGreen.withOpacity(0.08),
                                    ]
                                  : [
                                      AppTheme.textMuted.withOpacity(0.1),
                                      AppTheme.textMuted.withOpacity(0.05),
                                    ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: amenity.averageExtraCost != null && amenity.averageExtraCost! > 0
                                  ? AppTheme.success.withOpacity(0.3)
                                  : AppTheme.textMuted.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  amenity.averageExtraCost != null && amenity.averageExtraCost! > 0
                                    ? Icons.attach_money_rounded
                                    : Icons.money_off_rounded,
                                  size: 18,
                                  color: amenity.averageExtraCost != null && amenity.averageExtraCost! > 0
                                    ? AppTheme.success
                                    : AppTheme.textMuted,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  amenity.averageExtraCost != null && amenity.averageExtraCost! > 0
                                    ? '\$${amenity.averageExtraCost!.toStringAsFixed(0)}'
                                    : 'مجاني',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: amenity.averageExtraCost != null && amenity.averageExtraCost! > 0
                                      ? AppTheme.success
                                      : AppTheme.textMuted,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'التكلفة',
                                  style: AppTextStyles.caption.copyWith(
                                    color: amenity.averageExtraCost != null && amenity.averageExtraCost! > 0
                                      ? AppTheme.success.withOpacity(0.7)
                                      : AppTheme.textMuted.withOpacity(0.7),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildStatusWidget(amenity),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'جاري التحميل...',
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterStats() {
    final totalCount = widget.amenities.length;
    final activeCount = widget.amenities.where((a) => a.isActive == true).length;
    final averageCost = _calculateAverageCost();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkSurface.withOpacity(0.4),
            AppTheme.darkSurface.withOpacity(0.2),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: AppTheme.primaryPurple.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFooterStat(
            icon: Icons.checklist_rounded,
            label: 'المجموع',
            value: totalCount.toString(),
            color: AppTheme.primaryPurple,
          ),
          _buildFooterStat(
            icon: Icons.toggle_on_rounded,
            label: 'نشط',
            value: activeCount.toString(),
            color: AppTheme.success,
          ),
          _buildFooterStat(
            icon: Icons.toggle_off_rounded,
            label: 'معطل',
            value: (totalCount - activeCount).toString(),
            color: AppTheme.textMuted,
          ),
          _buildFooterStat(
            icon: Icons.attach_money_rounded,
            label: 'متوسط التكلفة',
            value: '\$$averageCost',
            color: AppTheme.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildFooterStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.textMuted,
                fontSize: 10,
              ),
            ),
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _calculateAverageCost() {
    if (widget.amenities.isEmpty) return '0';
    
    final costs = widget.amenities
        .where((a) => a.averageExtraCost != null && a.averageExtraCost! > 0)
        .map((a) => a.averageExtraCost!)
        .toList();
    
    if (costs.isEmpty) return '0';
    
    final average = costs.reduce((a, b) => a + b) / costs.length;
    return average.toStringAsFixed(0);
  }

  IconData _getAmenityIcon(String iconName) {
    return AmenityIcons.getIconByName(iconName)?.icon ?? Icons.star_rounded;
  }
}