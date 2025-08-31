import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/notification_service.dart';
import '../../../../injection_container.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  late final NotificationService _notifications;
  bool _enabled = true;

  @override
  void initState() {
    super.initState();
    _notifications = sl<NotificationService>();
    _init();
  }

  Future<void> _init() async {
    _enabled = await _notifications.areNotificationsEnabled();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('إعدادات الإشعارات'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingTile(
            title: 'تفعيل الإشعارات',
            subtitle: 'السماح باستقبال الإشعارات',
            value: _enabled,
            onChanged: (v) async {
              await _notifications.openNotificationSettings();
              _init();
            },
          ),
          const SizedBox(height: 8),
          _buildActionTile(
            title: 'مسح كل الإشعارات المحلية',
            icon: Icons.clear_all_rounded,
            onTap: () => _notifications.cancelAllNotifications(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({required String title, String? subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.w600)),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({required String title, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.darkBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.info),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: TextStyle(color: AppTheme.textWhite))),
            Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}

