import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'package:bookn_cp_app/injection_container.dart' as di;
import 'core/bloc/app_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/connectivity_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize services
  await di.init();
  
  // Initialize connectivity service
  await ConnectivityService().initialize();
  
  // Initialize AppBloc after dependency injection
  AppBloc.initialize();
  AppBloc.initializeEvents();
  
  // Services are initialized via dependency injection
  // await LocalStorageService.init();
  // await NotificationService.init();
  // await CrashReportingService.init();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const YemenBookingApp());
}