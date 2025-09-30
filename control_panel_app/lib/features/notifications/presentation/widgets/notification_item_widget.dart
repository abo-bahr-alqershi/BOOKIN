import 'package:flutter/material.dart';
import '../../domain/entities/notification.dart';

class NotificationItemWidget extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationItemWidget({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(notification.title),
      subtitle: Text(notification.message),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!notification.isRead)
            const Icon(Icons.circle, size: 10, color: Colors.red),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onDismiss,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
