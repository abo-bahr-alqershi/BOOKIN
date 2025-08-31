import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../../../services/local_storage_service.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';

class SelectCityCurrencyPage extends StatefulWidget {
  const SelectCityCurrencyPage({super.key});

  @override
  State<SelectCityCurrencyPage> createState() => _SelectCityCurrencyPageState();
}

class _SelectCityCurrencyPageState extends State<SelectCityCurrencyPage> {
  final _cities = const ['صنعاء', 'عدن', 'تعز', 'حضرموت', 'الحديدة'];
  final _currencies = const ['YER', 'SAR', 'USD'];
  String? _city;
  String? _currency;

  @override
  void initState() {
    super.initState();
    final storage = sl<LocalStorageService>();
    _city = storage.getSelectedCity().isNotEmpty ? storage.getSelectedCity() : null;
    _currency = storage.getSelectedCurrency();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('اختيار المدينة والعملة'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('اختر مدينتك', style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _buildDropdown<String>(
              value: _city,
              hint: 'اختر المدينة',
              items: _cities,
              onChanged: (v) => setState(() => _city = v),
            ),
            const SizedBox(height: 16),
            Text('اختر عملتك', style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _buildDropdown<String>(
              value: _currency,
              hint: 'اختر العملة',
              items: _currencies,
              onChanged: (v) => setState(() => _currency = v),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _city == null || _currency == null ? null : _continue,
                child: const Text('متابعة'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({required T? value, required String hint, required List<T> items, required ValueChanged<T?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.inputBackground,
        border: Border.all(color: AppTheme.inputBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<T>(
        value: value,
        items: items.map((e) => DropdownMenuItem<T>(value: e, child: Text('$e'))).toList(),
        onChanged: onChanged,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        hint: Text(hint),
      ),
    );
  }

  Future<void> _continue() async {
    final storage = sl<LocalStorageService>();
    await storage.saveSelectedCity(_city!);
    await storage.saveSelectedCurrency(_currency!);
    await storage.setOnboardingCompleted(true);
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      if (!mounted) return;
      context.go('/main');
    } else {
      if (!mounted) return;
      context.go('/login');
    }
  }
}

