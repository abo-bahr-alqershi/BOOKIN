import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../notifications/presentation/bloc/notification_bloc.dart';
import '../../../notifications/presentation/bloc/notification_event.dart';
import '../../../notifications/presentation/bloc/notification_state.dart';
import '../../../../injection_container.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotificationBloc>()..add(const LoadNotificationsEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الإشعارات'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => context.read<NotificationBloc>().add(const LoadNotificationsEvent()),
            ),
          ],
        ),
        body: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is NotificationLoaded) {
              if (state.notifications.isEmpty) {
                return const Center(child: Text('لا توجد إشعارات'));
              }
              return ListView.separated(
                itemCount: state.notifications.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final n = state.notifications[index];
                  return ListTile(
                    title: Text(n.title),
                    subtitle: Text(n.message),
                    trailing: n.isRead ? const Icon(Icons.done_all, color: Colors.green) : const Icon(Icons.mark_email_unread),
                    onTap: () => context.read<NotificationBloc>().add(MarkNotificationAsReadEvent(notificationId: n.id)),
                  );
                },
              );
            }
            if (state is NotificationError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
