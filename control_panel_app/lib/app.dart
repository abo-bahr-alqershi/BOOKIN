import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:bookn_cp_app/core/bloc/theme/theme_bloc.dart';
import 'package:bookn_cp_app/core/bloc/theme/theme_state.dart';
import 'package:bookn_cp_app/features/chat/presentation/providers/typing_indicator_provider.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_manager.dart';
import 'routes/app_router.dart';
import 'injection_container.dart' as di;
import 'core/bloc/app_bloc.dart';
// Removed settings bloc dependency
import 'core/theme/app_theme.dart';

class YemenBookingApp extends StatelessWidget {
  const YemenBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TypingIndicatorProvider(),
        ),
        ...AppBloc.providers,
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
            bloc: AppBloc.theme,
            builder: (context, themeState) {
              return MaterialApp.router(
                title: 'Yemen Booking',
                debugShowCheckedModeBanner: false,
                theme: ThemeData.light(),
                darkTheme: ThemeData.dark(),
                themeMode: themeState.themeMode,
                locale: const Locale('ar', 'YE'),
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: LocaleManager.supportedLocales,
                routerConfig: AppRouter.build(context),
                builder: (context, child) {
                  AppTheme.init(context, mode: themeState.themeMode);
                  return child!;
                },
              );
            },
      ),
    );
      
  }
}

// Settings feature removed: hardcode defaults
