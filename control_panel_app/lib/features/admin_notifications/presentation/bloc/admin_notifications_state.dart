import '../../../notifications/domain/entities/notification.dart' as common_notif;
import '../../domain/entities/admin_notification.dart';

abstract class AdminNotificationsState {
  const AdminNotificationsState();
}

class AdminNotificationsInitial extends AdminNotificationsState {
  const AdminNotificationsInitial();
}

class AdminNotificationsLoading extends AdminNotificationsState {
  const AdminNotificationsLoading();
}

class AdminSystemNotificationsLoaded extends AdminNotificationsState {
  final List<AdminNotificationEntity> items;
  final int totalCount;
  const AdminSystemNotificationsLoaded({required this.items, required this.totalCount});
}

class AdminUserNotificationsLoaded extends AdminNotificationsState {
  final List<AdminNotificationEntity> items;
  final int totalCount;
  const AdminUserNotificationsLoaded({required this.items, required this.totalCount});
}

class AdminNotificationsStatsLoaded extends AdminNotificationsState {
  final Map<String, int> stats;
  const AdminNotificationsStatsLoaded(this.stats);
}

class AdminNotificationsSuccess extends AdminNotificationsState {
  final String message;
  const AdminNotificationsSuccess(this.message);
}

class AdminNotificationsError extends AdminNotificationsState {
  final String message;
  const AdminNotificationsError(this.message);
}

