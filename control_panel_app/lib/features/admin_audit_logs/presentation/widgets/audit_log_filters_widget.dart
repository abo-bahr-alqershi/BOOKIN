// lib/features/admin_audit_logs/presentation/widgets/audit_log_filters_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';

class AuditLogFiltersWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onFilterApplied;

  const AuditLogFiltersWidget({
    super.key,
    required this.onFilterApplied,
  });

  @override
  State<AuditLogFiltersWidget> createState() => _AuditLogFiltersWidgetState();
}

class _AuditLogFiltersWidgetState extends State<AuditLogFiltersWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _selectedOperationType;
  
  final List<String> _operationTypes = [
    'CREATE',
    'UPDATE',
    'DELETE',
    'LOGIN',
    'LOGOUT',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
    
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutQuart),
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.darkCard.withOpacity(0.6),
                    AppTheme.darkCard.withOpacity(0.4),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryBlue.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildSearchField(),
                        const SizedBox(height: 16),
                        _buildUserIdField(),
                        const SizedBox(height: 16),
                        _buildDateRangeSelector(),
                        const SizedBox(height: 16),
                        _buildOperationTypeSelector(),
                        const SizedBox(height: 24),
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.filter_list_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'فلترة السجلات',
          style: AppTextStyles.heading3.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'البحث',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.darkSurface.withOpacity(0.5),
                AppTheme.darkSurface.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.darkBorder.withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: TextField(
            controller: _searchController,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
            ),
            decoration: InputDecoration(
              hintText: 'ابحث في السجلات...',
              hintStyle: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.textMuted.withOpacity(0.5),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppTheme.textMuted.withOpacity(0.5),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserIdField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'معرف المستخدم',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.darkSurface.withOpacity(0.5),
                AppTheme.darkSurface.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.darkBorder.withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: TextField(
            controller: _userIdController,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
            ),
            decoration: InputDecoration(
              hintText: 'أدخل معرف المستخدم',
              hintStyle: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.textMuted.withOpacity(0.5),
              ),
              prefixIcon: Icon(
                Icons.person_outline_rounded,
                color: AppTheme.textMuted.withOpacity(0.5),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الفترة الزمنية',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: 'من',
                date: _fromDate,
                onTap: () => _selectDate(true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateField(
                label: 'إلى',
                date: _toDate,
                onTap: () => _selectDate(false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkSurface.withOpacity(0.5),
              AppTheme.darkSurface.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: date != null
                ? AppTheme.primaryBlue.withOpacity(0.3)
                : AppTheme.darkBorder.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: date != null
                  ? AppTheme.primaryBlue
                  : AppTheme.textMuted.withOpacity(0.5),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                date != null
                    ? '${date.day}/${date.month}/${date.year}'
                    : label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: date != null
                      ? AppTheme.textWhite
                      : AppTheme.textMuted.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نوع العملية',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _operationTypes.map((type) {
            final isSelected = _selectedOperationType == type;
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedOperationType = isSelected ? null : type;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? AppTheme.primaryGradient
                      : LinearGradient(
                          colors: [
                            AppTheme.darkSurface.withOpacity(0.5),
                            AppTheme.darkSurface.withOpacity(0.3),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryBlue.withOpacity(0.5)
                        : AppTheme.darkBorder.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  type,
                  style: AppTextStyles.caption.copyWith(
                    color: isSelected ? Colors.white : AppTheme.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _clearFilters,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.darkSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.darkBorder.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
              child: Center(
                child: Text(
                  'مسح',
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: _applyFilters,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'تطبيق',
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _selectDate(bool isFromDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.primaryBlue,
              surface: AppTheme.darkCard,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  void _clearFilters() {
    HapticFeedback.mediumImpact();
    setState(() {
      _searchController.clear();
      _userIdController.clear();
      _fromDate = null;
      _toDate = null;
      _selectedOperationType = null;
    });
  }

  void _applyFilters() {
    HapticFeedback.mediumImpact();
    widget.onFilterApplied({
      'searchTerm': _searchController.text.isNotEmpty ? _searchController.text : null,
      'userId': _userIdController.text.isNotEmpty ? _userIdController.text : null,
      'from': _fromDate,
      'to': _toDate,
      'operationType': _selectedOperationType,
    });
  }
}