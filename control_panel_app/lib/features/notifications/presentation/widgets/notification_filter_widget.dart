import 'package:flutter/material.dart';

class NotificationFilterWidget extends StatelessWidget {
  final String? selectedType;
  final ValueChanged<String?> onChanged;

  const NotificationFilterWidget({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const types = <String?>[null, 'BOOKING_CREATED', 'PAYMENT_UPDATE', 'PROMOTION'];
    return DropdownButton<String?>(
      value: selectedType,
      hint: const Text('نوع الإشعارات'),
      items: types
          .map((t) => DropdownMenuItem<String?>(
                value: t,
                child: Text(t == null ? 'الكل' : t),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}

