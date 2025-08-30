import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';

class UserRoleSelector extends StatefulWidget {
  final String? currentRole;
  final Function(String) onRoleSelected;

  const UserRoleSelector({
    super.key,
    this.currentRole,
    required this.onRoleSelected,
  });

  @override
  State<UserRoleSelector> createState() => _UserRoleSelectorState();
}

class _UserRoleSelectorState extends State<UserRoleSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  String? _selectedRole;
  
  final List<Map<String, dynamic>> _roles = [
    {
      'id': 'admin',
      'name': 'مدير',
      'description': 'صلاحيات كاملة على النظام',
      'icon': Icons.admin_panel_settings_rounded,
      'gradient': [AppTheme.error, AppTheme.primaryViolet],
    },
    {
      'id': 'owner',
      'name': 'مالك',
      'description': 'مالك كيان أو عقار',
      'icon': Icons.business_rounded,
      'gradient': [AppTheme.primaryBlue, AppTheme.primaryPurple],
    },
    {
      'id': 'staff',
      'name': 'موظف',
      'description': 'موظف في كيان أو عقار',
      'icon': Icons.badge_rounded,
      'gradient': [AppTheme.warning, AppTheme.neonBlue],
    },
    {
      'id': 'customer',
      'name': 'عميل',
      'description': 'مستخدم عادي للخدمة',
      'icon': Icons.person_rounded,
      'gradient': [AppTheme.primaryCyan, AppTheme.neonGreen],
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.currentRole;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
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
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(_slideAnimation),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.darkCard.withOpacity(0.95),
                AppTheme.darkCard.withOpacity(0.85),
              ],
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusXLarge),
            ),
            border: Border.all(
              color: AppTheme.primaryBlue.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusXLarge),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Column(
                children: [
                  _buildHandle(),
                  _buildHeader(),
                  Expanded(
                    child: _buildRolesList(),
                  ),
                  _buildActions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppTheme.textMuted.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.security_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceMedium),
          Text(
            'اختر دور المستخدم',
            style: AppTextStyles.heading3.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRolesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
      ),
      itemCount: _roles.length,
      itemBuilder: (context, index) {
        final role = _roles[index];
        final isSelected = _selectedRole == role['id'];
        
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value,
                child: _buildRoleCard(role, isSelected),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRoleCard(Map<String, dynamic> role, bool isSelected) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedRole = role['id'];
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: AppDimensions.spaceMedium),
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    (role['gradient'] as List<Color>)[0].withOpacity(0.2),
                    (role['gradient'] as List<Color>)[1].withOpacity(0.1),
                  ],
                )
              : LinearGradient(
                  colors: [
                    AppTheme.darkSurface.withOpacity(0.6),
                    AppTheme.darkSurface.withOpacity(0.4),
                  ],
                ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(
            color: isSelected
                ? (role['gradient'] as List<Color>)[0].withOpacity(0.5)
                : AppTheme.darkBorder.withOpacity(0.3),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (role['gradient'] as List<Color>)[0].withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: role['gradient'] as List<Color>,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: (role['gradient'] as List<Color>)[0].withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                role['icon'] as IconData,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: AppDimensions.spaceMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role['name'] as String,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppTheme.textWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role['description'] as String,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: role['gradient'] as List<Color>,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.darkBorder.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'إلغاء',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spaceMedium),
          Expanded(
            child: Container(
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
              child: ElevatedButton(
                onPressed: _selectedRole != null
                    ? () {
                        HapticFeedback.lightImpact();
                        widget.onRoleSelected(_selectedRole!);
                        Navigator.of(context).pop();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.paddingMedium,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                ),
                child: Text(
                  'تأكيد',
                  style: AppTextStyles.buttonLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}