import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/admin_notification.dart';
import '../bloc/admin_notifications_bloc.dart';
import '../bloc/admin_notifications_event.dart';
import '../bloc/admin_notifications_state.dart';

class AdminNotificationsPage extends StatelessWidget {
  const AdminNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة الإشعارات')), 
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => _CreateOneOffNotificationScreen()));
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.read<AdminNotificationsBloc>().add(const LoadAdminNotificationsStatsEvent()),
                  icon: const Icon(Icons.refresh),
                  label: const Text('تحديث الإحصائيات'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => context.read<AdminNotificationsBloc>().add(const LoadSystemNotificationsEvent()),
                  icon: const Icon(Icons.list),
                  label: const Text('تحميل الإشعارات'),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<AdminNotificationsBloc, AdminNotificationsState>(
              builder: (context, state) {
                if (state is AdminNotificationsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is AdminNotificationsStatsLoaded) {
                  final s = state.stats;
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: s.entries.map((e) => _StatChip(label: e.key, value: e.value)).toList(),
                    ),
                  );
                }
                if (state is AdminSystemNotificationsLoaded) {
                  return _NotificationsList(items: state.items);
                }
                return const Center(child: Text('')); 
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsList extends StatelessWidget {
  final List<AdminNotificationEntity> items;
  const _NotificationsList({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final n = items[index];
        return ListTile(
          title: Text(n.title),
          subtitle: Text(n.message),
          trailing: Text(n.status),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value'));
  }
}

class _CreateOneOffNotificationScreen extends StatefulWidget {
  @override
  State<_CreateOneOffNotificationScreen> createState() => _CreateOneOffNotificationScreenState();
}

class _CreateOneOffNotificationScreenState extends State<_CreateOneOffNotificationScreen> {
  final _titleCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  final _userCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء إشعار')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'العنوان')),
            TextField(controller: _msgCtrl, decoration: const InputDecoration(labelText: 'المحتوى')),
            TextField(controller: _userCtrl, decoration: const InputDecoration(labelText: 'معرف المستلم UUID')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<AdminNotificationsBloc>().add(
                      CreateAdminNotificationEvent(
                        type: 'BookingUpdated',
                        title: _titleCtrl.text,
                        message: _msgCtrl.text,
                        recipientId: _userCtrl.text,
                      ),
                    );
                Navigator.pop(context);
              },
              child: const Text('إرسال'),
            )
          ],
        ),
      ),
    );
  }
}

