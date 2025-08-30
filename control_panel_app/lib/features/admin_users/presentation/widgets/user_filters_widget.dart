import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';

class UserFiltersWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;

  const UserFiltersWidget({
    super.key,
    required this.onApplyFilters,
  });

  @override
  State<UserFiltersWidget> createState() => _UserFiltersWidgetState();
}

class _UserFiltersWidgetState extends State<UserFiltersWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  
  String? _selectedRole;
  bool? _isActive;
  DateTime? _createdAfter;
  DateTime? _createdBefore;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -0.2),
        end: Offset.zero,
      ).animate(_slideAnimation),
      child: FadeTransition(
        opacity: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.darkCard.withOpacity(0.7),
                AppTheme.darkCard.withOpacity(0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: Border.all(
              color: AppTheme.primaryBlue.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterHeader(),
                  const SizedBox(height: AppDimensions.spaceMedium),
                  _buildFilterOptions(),
                  const SizedBox(height: AppDimensions.spaceMedium),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.filter_list_rounded,
            size: 20,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: AppDimensions.spaceSmall),
        Text(
          'فلترة المستخدمين',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterOptions() {
    return Wrap(
      spacing: AppDimensions.spaceMedium,
      runSpacing: AppDimensions.spaceMedium,
      children: [
        _buildRoleFilter(),
        _buildStatusFilter(),
        _buildDateFilter(),
      ],
    );
  }

  Widget _buildRoleFilter() {
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSmall,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkSurface.withOpacity(0.6),
            AppTheme.darkSurface.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRole,
          hint: Text(
            'الدور',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
          icon: Icon(
            Icons.arrow_drop_down_rounded,
            color: AppTheme.primaryBlue,
          ),
          dropdownColor: AppTheme.darkCard,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textWhite,
          ),
          items: [
            DropdownMenuItem(
              value: null,
              child: Text('الكل'),
            ),
            DropdownMenuItem(
              value: 'admin',
              child: Text('مدير'),
            ),
            DropdownMenuItem(
              value: 'owner',
              child: Text('مالك'),
            ),
            DropdownMenuItem(
              value: 'staff',
              child: Text('موظف'),
            ),
            DropdownMenuItem(
              value: 'customer',
              child: Text('عميل'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedRole = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSmall,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkSurface.withOpacity(0.6),
            AppTheme.darkSurface.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<bool?>(
          value: _isActive,
          hint: Text(
            'الحالة',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
          icon: Icon(
            Icons.arrow_drop_down_rounded,
            color: AppTheme.primaryBlue,
          ),
          dropdownColor: AppTheme.darkCard,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textWhite,
          ),
          items: [
            DropdownMenuItem(
              value: null,
              child: Text('الكل'),
            ),
            DropdownMenuItem(
              value: true,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('نشط'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: false,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.textMuted,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('غير نشط'),
                ],
              ),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _isActive = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildDateFilter() {
    return Row(
      children: [
        _buildDatePicker(
          label: 'من تاريخ',
          date: _createdAfter,
          onChanged: (date) {
            setState(() {
              _createdAfter = date;
            });
          },
        ),
        const SizedBox(width: AppDimensions.spaceSmall),
        _buildDatePicker(
          label: 'إلى تاريخ',
          date: _createdBefore,
          onChanged: (date) {
            setState(() {
              _createdBefore = date;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required Function(DateTime?) onChanged,
  }) {
    return GestureDetector(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
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
        
        if (pickedDate != null) {
          onChanged(pickedDate);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingSmall,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkSurface.withOpacity(0.6),
              AppTheme.darkSurface.withOpacity(0.4),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: AppTheme.darkBorder.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(width: 8),
            Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : label,
              style: AppTextStyles.bodySmall.copyWith(
                color: date != null
                    ? AppTheme.textWhite
                    : AppTheme.textMuted,
              ),
            ),
            if (date != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => onChanged(null),
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _resetFilters,
          child: Text(
            'إعادة تعيين',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.spaceSmall),
        Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: _applyFilters,
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('تطبيق'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
                vertical: AppDimensions.paddingSmall,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedRole = null;
      _isActive = null;
      _createdAfter = null;
      _createdBefore = null;
    });
    
    widget.onApplyFilters({});
  }

  void _applyFilters() {
    widget.onApplyFilters({
      'roleId': _selectedRole,
      'isActive': _isActive,
      'createdAfter': _createdAfter,
      'createdBefore': _createdBefore,
    });
  }
}