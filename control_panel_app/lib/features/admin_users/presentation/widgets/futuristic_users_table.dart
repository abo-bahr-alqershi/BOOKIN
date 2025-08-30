import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/user.dart';

class FuturisticUsersTable extends StatefulWidget {
  final List<User> users;
  final Function(String) onUserTap;
  final Function(String, bool) onStatusToggle;
  final Function(String, bool) onSort;

  const FuturisticUsersTable({
    super.key,
    required this.users,
    required this.onUserTap,
    required this.onStatusToggle,
    required this.onSort,
  });

  @override
  State<FuturisticUsersTable> createState() => _FuturisticUsersTableState();
}

class _FuturisticUsersTableState extends State<FuturisticUsersTable>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  String? _sortColumn;
  bool _isAscending = true;
  int? _hoveredRow;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          gradient: LinearGradient(
            colors: [
              AppTheme.darkCard.withOpacity(0.7),
              AppTheme.darkCard.withOpacity(0.5),
            ],
          ),
          border: Border.all(
            color: AppTheme.primaryBlue.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Column(
              children: [
                _buildTableHeader(),
                Expanded(
                  child: _buildTableBody(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      child: Row(
        children: [
          _buildHeaderCell('المستخدم', flex: 3, sortKey: 'name'),
          _buildHeaderCell('البريد الإلكتروني', flex: 3, sortKey: 'email'),
          _buildHeaderCell('الهاتف', flex: 2, sortKey: 'phone'),
          _buildHeaderCell('الدور', flex: 2, sortKey: 'role'),
          _buildHeaderCell('تاريخ الإنشاء', flex: 2, sortKey: 'createdAt'),
          _buildHeaderCell('الحالة', flex: 2),
          _buildHeaderCell('الإجراءات', flex: 2),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String title, {
    required int flex,
    String? sortKey,
  }) {
    final isActive = _sortColumn == sortKey;
    
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: sortKey != null
            ? () {
                HapticFeedback.selectionClick();
                setState(() {
                  if (_sortColumn == sortKey) {
                    _isAscending = !_isAscending;
                  } else {
                    _sortColumn = sortKey;
                    _isAscending = true;
                  }
                });
                widget.onSort(sortKey, _isAscending);
              }
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingSmall,
            vertical: AppDimensions.paddingSmall,
          ),
          child: Row(
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isActive
                      ? AppTheme.primaryBlue
                      : AppTheme.textWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (sortKey != null) ...[
                const SizedBox(width: 4),
                Icon(
                  isActive
                      ? (_isAscending
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded)
                      : Icons.unfold_more_rounded,
                  size: 16,
                  color: isActive
                      ? AppTheme.primaryBlue
                      : AppTheme.textMuted.withOpacity(0.5),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableBody() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: widget.users.length,
      itemBuilder: (context, index) {
        final user = widget.users[index];
        final isHovered = _hoveredRow == index;
        
        return MouseRegion(
          onEnter: (_) => setState(() => _hoveredRow = index),
          onExit: (_) => setState(() => _hoveredRow = null),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isHovered
                  ? AppTheme.primaryBlue.withOpacity(0.05)
                  : Colors.transparent,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.darkBorder.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
            ),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onUserTap(user.id);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                  vertical: AppDimensions.paddingSmall,
                ),
                child: Row(
                  children: [
                    _buildUserCell(user, flex: 3),
                    _buildTextCell(user.email, flex: 3),
                    _buildTextCell(user.phone, flex: 2),
                    _buildRoleCell(user.role, flex: 2),
                    _buildDateCell(user.createdAt, flex: 2),
                    _buildStatusCell(user.isActive, flex: 2),
                    _buildActionsCell(user, flex: 2),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserCell(User user, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: user.profileImage != null
                  ? null
                  : AppTheme.primaryGradient,
              border: Border.all(
                color: user.isActive
                    ? AppTheme.success.withOpacity(0.5)
                    : AppTheme.darkBorder,
                width: 1.5,
              ),
            ),
            child: user.profileImage != null
                ? ClipOval(
                    child: Image.network(
                      user.profileImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultAvatar(user.name);
                      },
                    ),
                  )
                : _buildDefaultAvatar(user.name),
          ),
          const SizedBox(width: AppDimensions.paddingSmall),
          Expanded(
            child: Text(
              user.name,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    
    return Center(
      child: Text(
        initial,
        style: AppTextStyles.bodySmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppTheme.textMuted,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildRoleCell(String role, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _getRoleGradient(role),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _getRoleText(role),
          style: AppTextStyles.caption.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildDateCell(DateTime date, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        _formatDate(date),
        style: AppTextStyles.bodySmall.copyWith(
          color: AppTheme.textMuted,
        ),
      ),
    );
  }

  Widget _buildStatusCell(bool isActive, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? AppTheme.success
                  : AppTheme.textMuted,
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
            isActive ? 'نشط' : 'غير نشط',
            style: AppTextStyles.bodySmall.copyWith(
              color: isActive
                  ? AppTheme.success
                  : AppTheme.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCell(User user, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              widget.onStatusToggle(user.id, !user.isActive);
            },
            icon: Icon(
              user.isActive
                  ? Icons.toggle_on_rounded
                  : Icons.toggle_off_rounded,
              color: user.isActive
                  ? AppTheme.success
                  : AppTheme.textMuted,
            ),
            tooltip: user.isActive ? 'إلغاء التفعيل' : 'تفعيل',
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              widget.onUserTap(user.id);
            },
            icon: Icon(
              Icons.visibility_rounded,
              color: AppTheme.primaryBlue,
            ),
            tooltip: 'عرض التفاصيل',
          ),
        ],
      ),
    );
  }

  List<Color> _getRoleGradient(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return [AppTheme.error, AppTheme.primaryViolet];
      case 'owner':
        return [AppTheme.primaryBlue, AppTheme.primaryPurple];
      case 'staff':
        return [AppTheme.warning, AppTheme.neonBlue];
      default:
        return [AppTheme.primaryCyan, AppTheme.neonGreen];
    }
  }

  String _getRoleText(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'مدير';
      case 'owner':
        return 'مالك';
      case 'staff':
        return 'موظف';
      case 'customer':
        return 'عميل';
      default:
        return role;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}