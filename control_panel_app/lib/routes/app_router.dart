import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bookn_cp_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bookn_cp_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:bookn_cp_app/features/auth/presentation/pages/login_page.dart';
import 'package:bookn_cp_app/features/chat/presentation/widgets/conversation_loader.dart';
import 'package:bookn_cp_app/presentation/screens/futuristic_main_screen.dart';
import 'package:bookn_cp_app/presentation/screens/splash_screen.dart';
// Removed imports for deleted features
// Removed unused imports
import 'package:bookn_cp_app/features/auth/presentation/pages/register_page.dart';
import 'package:bookn_cp_app/features/auth/presentation/pages/forgot_password_page.dart';
// Removed imports for deleted features
import 'package:bookn_cp_app/features/chat/presentation/pages/chat_page.dart';
import 'package:bookn_cp_app/features/chat/presentation/pages/new_conversation_page.dart';
import 'package:bookn_cp_app/features/chat/presentation/pages/conversations_page.dart';
import 'package:bookn_cp_app/features/chat/domain/entities/conversation.dart';
import 'package:bookn_cp_app/features/auth/presentation/pages/change_password_page.dart';
import 'package:bookn_cp_app/features/auth/presentation/pages/edit_profile_page.dart';
// Removed settings pages imports
// Admin Units pages
import 'package:bookn_cp_app/features/admin_units/presentation/pages/units_list_page.dart';
import 'package:bookn_cp_app/features/admin_units/presentation/pages/create_unit_page.dart';
import 'package:bookn_cp_app/features/admin_units/presentation/pages/edit_unit_page.dart';
import 'package:bookn_cp_app/features/admin_units/presentation/pages/unit_details_page.dart';
import 'package:bookn_cp_app/features/admin_units/presentation/bloc/units_list/units_list_bloc.dart';
import 'package:bookn_cp_app/features/admin_units/presentation/bloc/unit_form/unit_form_bloc.dart';
import 'package:bookn_cp_app/features/admin_units/presentation/bloc/unit_details/unit_details_bloc.dart';
import 'package:bookn_cp_app/injection_container.dart' as di;
// Property Types page and blocs
import 'package:bookn_cp_app/features/property_types/presentation/pages/property_types_page.dart';
import 'package:bookn_cp_app/features/property_types/presentation/bloc/property_types/property_types_bloc.dart';
import 'package:bookn_cp_app/features/property_types/presentation/bloc/property_types/property_types_event.dart';
import 'package:bookn_cp_app/features/property_types/presentation/bloc/unit_types/unit_types_bloc.dart';
import 'package:bookn_cp_app/features/property_types/presentation/bloc/unit_type_fields/unit_type_fields_bloc.dart';
// removed wrong properties pages imports (files do not exist)
import 'package:bookn_cp_app/features/admin_services/presentation/pages/admin_services_page.dart';
import 'package:bookn_cp_app/features/admin_amenities/presentation/pages/amenities_management_page.dart';
import 'package:bookn_cp_app/features/admin_reviews/presentation/pages/reviews_list_page.dart';
import 'package:bookn_cp_app/features/admin_reviews/presentation/pages/review_details_page.dart';
import 'package:bookn_cp_app/features/admin_reviews/domain/entities/review.dart';
import 'package:bookn_cp_app/features/admin_reviews/presentation/bloc/reviews_list/reviews_list_bloc.dart' as ar_list_bloc;
import 'package:bookn_cp_app/features/admin_reviews/presentation/bloc/review_details/review_details_bloc.dart' as ar_details_bloc;
import 'package:bookn_cp_app/features/admin_services/presentation/bloc/services_bloc.dart';
import 'package:bookn_cp_app/features/admin_amenities/presentation/bloc/amenities_bloc.dart' as aa_bloc;
// Admin Audit Logs page & bloc
import 'package:bookn_cp_app/features/admin_audit_logs/presentation/pages/audit_logs_page.dart' as al_pages;
import 'package:bookn_cp_app/features/admin_audit_logs/presentation/bloc/audit_logs_bloc.dart' as al_bloc;
// Admin Properties pages & blocs
import 'package:bookn_cp_app/features/admin_properties/presentation/pages/properties_list_page.dart' as ap_pages;
import 'package:bookn_cp_app/features/admin_properties/presentation/pages/create_property_page.dart' as ap_pages;
import 'package:bookn_cp_app/features/admin_properties/presentation/pages/edit_property_page.dart' as ap_pages;
import 'package:bookn_cp_app/features/admin_properties/presentation/pages/property_details_page.dart' as ap_pages;
import 'package:bookn_cp_app/features/admin_properties/presentation/bloc/properties/properties_bloc.dart' as ap_bloc;
import 'package:bookn_cp_app/features/admin_properties/presentation/bloc/property_types/property_types_bloc.dart' as ap_prop_pt_bloc;

class AppRouter {
  static GoRouter build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    return GoRouter(
      initialLocation: '/',
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = context.read<AuthBloc>().state;
        final goingToLogin = state.matchedLocation == '/login';
        final goingToRegister = state.matchedLocation == '/register';
        final goingToForgot = state.matchedLocation == '/forgot-password';
        final isSplash = state.matchedLocation == '/';
        final isProtected = _protectedPaths.any((p) => state.matchedLocation.startsWith(p));

        if (isSplash) return null;

        if (authState is AuthUnauthenticated && isProtected && !(goingToLogin || goingToRegister || goingToForgot)) {
          return '/login';
        }

        if (authState is AuthAuthenticated && (goingToLogin || goingToRegister || goingToForgot)) {
          return '/main';
        }

        return null;
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) {
            return const SplashScreen();
          },
        ),
        // Onboarding removed
        GoRoute(
          path: '/main',
          builder: (BuildContext context, GoRouterState state) {
            return const MainScreen();
          },
        ),
        GoRoute(
          path: '/login',
          builder: (BuildContext context, GoRouterState state) {
            return const Scaffold(
              body: Center(
                child: LoginPage(),
              ),
            );
          },
        ),
        GoRoute(
          path: '/register',
          builder: (BuildContext context, GoRouterState state) {
            final params = state.extra is Map<String, dynamic>
                ? state.extra as Map<String, dynamic>
                : {"isFirst": false};
            return RegisterPage(
              isFirst: params["isFirst"] ?? false,
            );
          },
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (BuildContext context, GoRouterState state) {
            return const ForgotPasswordPage();
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (BuildContext context, GoRouterState state) {
            return const Scaffold(
              body: Center(
                child: Text('الملف الشخصي'),
              ),
            );
          },
        ),
        GoRoute(
          path: '/profile/edit',
          builder: (BuildContext context, GoRouterState state) {
            return const EditProfilePage();
          },
        ),
        GoRoute(
          path: '/profile/change-password',
          builder: (BuildContext context, GoRouterState state) {
            return const ChangePasswordPage();
          },
        ),
        // Settings routes removed
        // Removed review and search routes
        // Removed property routes
        // Removed booking routes

        // قائمة المحادثات
        GoRoute(
          path: '/conversations',
          builder: (context, state) {
            return const ConversationsPage();
          },
        ),

        // Admin Units - list
        GoRoute(
          path: '/admin/units',
          builder: (context, state) {
            return BlocProvider<UnitsListBloc>(
              create: (_) => di.sl<UnitsListBloc>()..add(LoadUnitsEvent()),
              child: const UnitsListPage(),
            );
          },
        ),

        // Admin Units - create
        GoRoute(
          path: '/admin/units/create',
          builder: (context, state) {
            return BlocProvider<UnitFormBloc>(
              create: (_) => di.sl<UnitFormBloc>()..add(const InitializeFormEvent()),
              child: const CreateUnitPage(),
            );
          },
        ),

        // Admin Units - edit
        GoRoute(
          path: '/admin/units/:unitId/edit',
          builder: (context, state) {
            final unitId = state.pathParameters['unitId']!;
            return BlocProvider<UnitFormBloc>(
              create: (_) => di.sl<UnitFormBloc>()..add(InitializeFormEvent(unitId: unitId)),
              child: EditUnitPage(unitId: unitId),
            );
          },
        ),

        // Admin Units - details
        GoRoute(
          path: '/admin/units/:unitId',
          builder: (context, state) {
            final unitId = state.pathParameters['unitId']!;
            return BlocProvider<UnitDetailsBloc>(
              create: (_) => di.sl<UnitDetailsBloc>()..add(LoadUnitDetailsEvent(unitId: unitId)),
              child: UnitDetailsPage(unitId: unitId),
            );
          },
        ),

        // Property Types Management
        GoRoute(
          path: '/admin/property-types',
          builder: (context, state) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => di.sl<PropertyTypesBloc>()..add(const LoadPropertyTypesEvent())),
                BlocProvider(create: (_) => di.sl<UnitTypesBloc>()),
                BlocProvider(create: (_) => di.sl<UnitTypeFieldsBloc>()),
              ],
              child: const PropertyTypesPage(),
            );
          },
        ),

        // Admin Properties
        GoRoute(
          path: '/admin/properties',
          builder: (context, state) {
            return BlocProvider<ap_bloc.PropertiesBloc>(
              create: (_) => di.sl<ap_bloc.PropertiesBloc>()..add(const ap_bloc.LoadPropertiesEvent()),
              child: const ap_pages.PropertiesListPage(),
            );
          },
        ),
        GoRoute(
          path: '/admin/properties/create',
          builder: (context, state) {
            return MultiBlocProvider(
              providers: [
                BlocProvider<ap_bloc.PropertiesBloc>(create: (_) => di.sl<ap_bloc.PropertiesBloc>()),
                BlocProvider<ap_prop_pt_bloc.PropertyTypesBloc>(create: (_) => di.sl<ap_prop_pt_bloc.PropertyTypesBloc>()),
              ],
              child: const ap_pages.CreatePropertyPage(),
            );
          },
        ),
        GoRoute(
          path: '/admin/properties/:propertyId',
          builder: (context, state) {
            final propertyId = state.pathParameters['propertyId']!;
            return BlocProvider<ap_bloc.PropertiesBloc>(
              create: (_) => di.sl<ap_bloc.PropertiesBloc>(),
              child: ap_pages.PropertyDetailsPage(propertyId: propertyId),
            );
          },
        ),
        GoRoute(
          path: '/admin/properties/:propertyId/edit',
          builder: (context, state) {
            final propertyId = state.pathParameters['propertyId']!;
            return MultiBlocProvider(
              providers: [
                BlocProvider<ap_bloc.PropertiesBloc>(create: (_) => di.sl<ap_bloc.PropertiesBloc>()),
                BlocProvider<ap_prop_pt_bloc.PropertyTypesBloc>(create: (_) => di.sl<ap_prop_pt_bloc.PropertyTypesBloc>()),
              ],
              child: ap_pages.EditPropertyPage(propertyId: propertyId),
            );
          },
        ),

        // Admin Services
        GoRoute(
          path: '/admin/services',
          builder: (context, state) {
            return BlocProvider<ServicesBloc>(
              create: (_) => di.sl<ServicesBloc>(),
              child: const AdminServicesPage(),
            );
          },
        ),

        // Admin Amenities (standalone management)
        GoRoute(
          path: '/admin/amenities',
          builder: (context, state) {
            return BlocProvider<aa_bloc.AmenitiesBloc>(
              create: (_) => di.sl<aa_bloc.AmenitiesBloc>(),
              child: const AmenitiesManagementPage(),
            );
          },
        ),

        // Admin Reviews list
        GoRoute(
          path: '/admin/reviews',
          builder: (context, state) {
            return BlocProvider<ar_list_bloc.ReviewsListBloc>(
              create: (_) => di.sl<ar_list_bloc.ReviewsListBloc>(),
              child: const ReviewsListPage(),
            );
          },
        ),

        // Admin Audit Logs
        GoRoute(
          path: '/admin/audit-logs',
          builder: (context, state) {
            return BlocProvider<al_bloc.AuditLogsBloc>(
              create: (_) => di.sl<al_bloc.AuditLogsBloc>(),
              child: const al_pages.AuditLogsPage(),
            );
          },
        ),

        // Admin Review details
        GoRoute(
          path: '/admin/reviews/details',
          builder: (context, state) {
            final review = state.extra as Review;
            return BlocProvider<ar_details_bloc.ReviewDetailsBloc>(
              create: (_) => di.sl<ar_details_bloc.ReviewDetailsBloc>(),
              child: ReviewDetailsPage(review: review),
            );
          },
        ),

        // محادثة جديدة
        GoRoute(
          path: '/conversations/new',
          builder: (context, state) {
            return const NewConversationPage();
          },
        ),

        // صفحة المحادثة
        GoRoute(
          path: '/chat/:conversationId',
          builder: (context, state) {
            final conversationId = state.pathParameters['conversationId']!;
            final conversation = state.extra as Conversation?;
            
            if (conversation != null) {
              return ChatPage(conversation: conversation);
            }
            
            // إذا لم تمرر المحادثة كـ extra، قم بتحميلها
            return ConversationLoader(conversationId: conversationId);
          },
        ),
      ],
    );
  }


  static const List<String> _protectedPaths = <String>[
    '/profile',
    '/conversations',
    '/chat',
  ];
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}