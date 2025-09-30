// lib/features/notifications/presentation/pages/notification_settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Map<String, bool> _settings = {
    'push_enabled': true,
    'email_enabled': true,
    'sms_enabled': false,
    'booking_updates': true,
    'payment_updates': true,
    'promotion_updates': false,
    'system_updates': true,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadSettings();
  }

  void _loadSettings() {
    context.read<NotificationBloc>().add(
          const LoadNotificationSettingsEvent(),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: _buildAppBar(),
      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationSettingsLoaded) {
            setState(() {
              _settings = state.settings;
            });
          } else if (state is NotificationOperationSuccess) {
            _showSuccessSnackBar(state.message);
          } else if (state is NotificationError) {
            _showErrorSnackBar(state.message);
          }
        },
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const LoadingWidget(
              type: LoadingType.futuristic,
              message: 'جاري تحميل الإعدادات...',
            );
          }

          return _buildSettingsContent();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.darkBackground,
      elevation: 0,
      title: Text(
        'إعدادات الإشعارات',
        style: AppTextStyles.heading2.copyWith(
          color: AppTheme.textWhite,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          CupertinoIcons.arrow_left,
          color: AppTheme.textWhite,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _saveSettings,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    'حفظ',
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('طرق الإشعار'),
          const SizedBox(height: 16),
          _buildNotificationMethodsSection(),
          const SizedBox(height: 32),
          _buildSectionTitle('أنواع الإشعارات'),
          const SizedBox(height: 16),
          _buildNotificationTypesSection(),
          const SizedBox(height: 32),
          _buildQuickActionsSection(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: AppTextStyles.heading3.copyWith(
          color: AppTheme.textWhite,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildNotificationMethodsSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.2),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              _buildSettingTile(
                icon: CupertinoIcons.bell_fill,
                title: 'إشعارات التطبيق',
                subtitle: 'تلقي إشعارات فورية على جهازك',
                settingKey: 'push_enabled',
                iconGradient: [AppTheme.primaryBlue, AppTheme.primaryCyan],
              ),
              _buildDivider(),
              _buildSettingTile(
                icon: CupertinoIcons.mail_solid,
                title: 'البريد الإلكتروني',
                subtitle: 'تلقي الإشعارات عبر البريد الإلكتروني',
                settingKey: 'email_enabled',
                iconGradient: [AppTheme.primaryPurple, AppTheme.primaryViolet],
              ),
              _buildDivider(),
              _buildSettingTile(
                icon: CupertinoIcons.device_phone_portrait,
                title: 'الرسائل النصية',
                subtitle: 'تلقي رسائل SMS للتحديثات المهمة',
                settingKey: 'sms_enabled',
                iconGradient: [AppTheme.success, AppTheme.neonGreen],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationTypesSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.2),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              _buildSettingTile(
                icon: CupertinoIcons.calendar,
                title: 'تحديثات الحجوزات',
                subtitle: 'إشعارات حول حجوزاتك وتغييراتها',
                settingKey: 'booking_updates',
                iconGradient: [AppTheme.info, AppTheme.neonBlue],
              ),
              _buildDivider(),
              _buildSettingTile(
                icon: CupertinoIcons.creditcard_fill,
                title: 'تحديثات المدفوعات',
                subtitle: 'إشعارات المعاملات المالية',
                settingKey: 'payment_updates',
                iconGradient: [AppTheme.warning, const Color(0xFFFFD700)],
              ),
              _buildDivider(),
              _buildSettingTile(
                icon: CupertinoIcons.gift_fill,
                title: 'العروض والخصومات',
                subtitle: 'عروض خاصة وخصومات حصرية',
                settingKey: 'promotion_updates',
                iconGradient: [AppTheme.error, const Color(0xFFFF69B4)],
              ),
              _buildDivider(),
              _buildSettingTile(
                icon: CupertinoIcons.gear_solid,
                title: 'تحديثات النظام',
                subtitle: 'إشعارات مهمة حول النظام',
                settingKey: 'system_updates',
                iconGradient: [AppTheme.textMuted, AppTheme.darkBorder],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withValues(alpha: 0.05),
            AppTheme.primaryPurple.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.info_circle_fill,
            color: AppTheme.primaryBlue,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            'نصيحة',
            style: AppTextStyles.heading3.copyWith(
              color: AppTheme.textWhite,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'قم بتفعيل الإشعارات المهمة فقط لتجنب الإزعاج والحصول على تجربة أفضل',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String settingKey,
    required List<Color> iconGradient,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: iconGradient),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: iconGradient.first.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.9,
            child: CupertinoSwitch(
              value: _settings[settingKey] ?? false,
              onChanged: (value) {
                HapticFeedback.lightImpact();
                setState(() {
                  _settings[settingKey] = value;
                });
              },
              activeTrackColor: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: AppTheme.darkBorder.withValues(alpha: 0.1),
    );
  }

  void _saveSettings() {
    HapticFeedback.mediumImpact();
    context.read<NotificationBloc>().add(
          UpdateNotificationSettingsEvent(settings: _settings),
        );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.check_mark,
                color: AppTheme.success,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.darkCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.xmark,
                color: AppTheme.error,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.darkCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
