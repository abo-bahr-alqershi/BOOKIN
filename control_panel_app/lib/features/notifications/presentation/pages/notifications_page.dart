import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/notification_service.dart';
import '../../../../injection_container.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> with TickerProviderStateMixin {
  late final NotificationService _notifications;
  bool _permissionGranted = true;

  @override
  void initState() {
    super.initState();
    _notifications = sl<NotificationService>();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final allowed = await _notifications.areNotificationsEnabled();
    if (mounted) setState(() => _permissionGranted = allowed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('الإشعارات'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => context.go('/notifications/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!_permissionGranted)
              _buildPermissionCard(),
            Expanded(
              child: _buildPlaceholder(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_off_rounded, color: AppTheme.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'الإشعارات غير مفعّلة. قم بتفعيلها للحصول على آخر التحديثات.',
              style: TextStyle(color: AppTheme.textLight),
            ),
          ),
          TextButton(
            onPressed: () async {
              await _notifications.openNotificationSettings();
              _checkPermission();
            },
            child: const Text('تفعيل'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none_rounded, size: 64, color: AppTheme.textMuted),
          const SizedBox(height: 12),
          Text(
            'لا توجد إشعارات حالياً',
            style: TextStyle(color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}

