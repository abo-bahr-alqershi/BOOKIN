import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;
import '../../../settings/presentation/bloc/settings_bloc.dart' as st_bloc;
import '../../../settings/presentation/bloc/settings_event.dart' as st_event;
import '../../../settings/presentation/bloc/settings_state.dart' as st_state;
import '../../../settings/domain/entities/app_settings.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<st_bloc.SettingsBloc>(
      create: (_) => di.sl<st_bloc.SettingsBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إعدادات الإشعارات'),
        ),
        body: BlocBuilder<st_bloc.SettingsBloc, st_state.SettingsState>(
          builder: (context, state) {
            if (state is st_state.SettingsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is st_state.SettingsLoaded || state is st_state.SettingsUpdated) {
              final settings = state is st_state.SettingsLoaded
                  ? state.settings
                  : (state as st_state.SettingsUpdated).settings;
              final NotificationSettings notif = settings.notificationSettings;
              return ListView(
                children: [
                  SwitchListTile(
                    title: const Text('إشعارات الحجوزات'),
                    value: notif.bookingNotifications,
                    onChanged: (val) => _update(context, notif.copyWith(bookingNotifications: val)),
                  ),
                  SwitchListTile(
                    title: const Text('إشعارات ترويجية'),
                    value: notif.promotionalNotifications,
                    onChanged: (val) => _update(context, notif.copyWith(promotionalNotifications: val)),
                  ),
                  SwitchListTile(
                    title: const Text('إشعارات البريد الإلكتروني'),
                    value: notif.emailNotifications,
                    onChanged: (val) => _update(context, notif.copyWith(emailNotifications: val)),
                  ),
                  SwitchListTile(
                    title: const Text('إشعارات الرسائل القصيرة'),
                    value: notif.smsNotifications,
                    onChanged: (val) => _update(context, notif.copyWith(smsNotifications: val)),
                  ),
                  SwitchListTile(
                    title: const Text('الإشعارات الدفعية (Push)'),
                    value: notif.pushNotifications,
                    onChanged: (val) => _update(context, notif.copyWith(pushNotifications: val)),
                  ),
                ],
              );
            }
            if (state is st_state.SettingsError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _update(BuildContext context, NotificationSettings newSettings) {
    context.read<st_bloc.SettingsBloc>().add(
          st_event.UpdateNotificationSettingsEvent(newSettings),
        );
  }
}

