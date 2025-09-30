import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/admin_notifications_bloc.dart';
import '../bloc/admin_notifications_event.dart';

class CreateAdminNotificationPage extends StatefulWidget {
  const CreateAdminNotificationPage({super.key});

  @override
  State<CreateAdminNotificationPage> createState() => _CreateAdminNotificationPageState();
}

class _CreateAdminNotificationPageState extends State<CreateAdminNotificationPage> {
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

