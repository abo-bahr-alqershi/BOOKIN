import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_notification_usecase.dart';
import '../../domain/usecases/broadcast_notification_usecase.dart';
import '../../domain/usecases/delete_notification_usecase.dart';
import '../../domain/usecases/resend_notification_usecase.dart';
import '../../domain/usecases/get_system_notifications_usecase.dart';
import '../../domain/usecases/get_user_notifications_usecase.dart';
import '../../domain/usecases/get_notifications_stats_usecase.dart';
import 'admin_notifications_event.dart';
import 'admin_notifications_state.dart';

class AdminNotificationsBloc extends Bloc<AdminNotificationsEvent, AdminNotificationsState> {
  final CreateAdminNotificationUseCase createUseCase;
  final BroadcastAdminNotificationUseCase broadcastUseCase;
  final DeleteAdminNotificationUseCase deleteUseCase;
  final ResendAdminNotificationUseCase resendUseCase;
  final GetSystemAdminNotificationsUseCase getSystemUseCase;
  final GetUserAdminNotificationsUseCase getUserUseCase;
  final GetAdminNotificationsStatsUseCase getStatsUseCase;

  AdminNotificationsBloc({
    required this.createUseCase,
    required this.broadcastUseCase,
    required this.deleteUseCase,
    required this.resendUseCase,
    required this.getSystemUseCase,
    required this.getUserUseCase,
    required this.getStatsUseCase,
  }) : super(const AdminNotificationsInitial()) {
    on<LoadSystemNotificationsEvent>((event, emit) async {
      emit(const AdminNotificationsLoading());
      final res = await getSystemUseCase(page: event.page, pageSize: event.pageSize, type: event.type, status: event.status);
      res.fold(
        (l) => emit(AdminNotificationsError(l.message ?? 'فشل تحميل إشعارات النظام')),
        (r) => emit(AdminSystemNotificationsLoaded(items: r.items, totalCount: r.totalCount)),
      );
    });

    on<LoadUserNotificationsEvent>((event, emit) async {
      emit(const AdminNotificationsLoading());
      final res = await getUserUseCase(userId: event.userId, page: event.page, pageSize: event.pageSize, isRead: event.isRead);
      res.fold(
        (l) => emit(AdminNotificationsError(l.message ?? 'فشل تحميل إشعارات المستخدم')),
        (r) => emit(AdminUserNotificationsLoaded(items: r.items, totalCount: r.totalCount)),
      );
    });

    on<CreateAdminNotificationEvent>((event, emit) async {
      final res = await createUseCase(type: event.type, title: event.title, message: event.message, recipientId: event.recipientId);
      res.fold(
        (l) => emit(AdminNotificationsError(l.message ?? 'فشل إنشاء الإشعار')),
        (r) => emit(const AdminNotificationsSuccess('تم إنشاء الإشعار')),
      );
    });

    on<BroadcastAdminNotificationEvent>((event, emit) async {
      final res = await broadcastUseCase(
        type: event.type,
        title: event.title,
        message: event.message,
        targetAll: event.targetAll,
        userIds: event.userIds,
        roles: event.roles,
        scheduledFor: event.scheduledFor,
      );
      res.fold(
        (l) => emit(AdminNotificationsError(l.message ?? 'فشل بث الإشعار')),
        (r) => emit(AdminNotificationsSuccess('تم بث الإشعار لعدد $r مستخدم')),
      );
    });

    on<DeleteAdminNotificationEvent>((event, emit) async {
      final res = await deleteUseCase(event.notificationId);
      res.fold(
        (l) => emit(AdminNotificationsError(l.message ?? 'فشل حذف الإشعار')),
        (r) => emit(const AdminNotificationsSuccess('تم حذف الإشعار')),
      );
    });

    on<ResendAdminNotificationEvent>((event, emit) async {
      final res = await resendUseCase(event.notificationId);
      res.fold(
        (l) => emit(AdminNotificationsError(l.message ?? 'فشل إعادة إرسال الإشعار')),
        (r) => emit(const AdminNotificationsSuccess('تمت إعادة الإرسال')),
      );
    });

    on<LoadAdminNotificationsStatsEvent>((event, emit) async {
      final res = await getStatsUseCase();
      res.fold(
        (l) => emit(AdminNotificationsError(l.message ?? 'فشل تحميل الإحصائيات')),
        (r) => emit(AdminNotificationsStatsLoaded(r)),
      );
    });
  }
}

