import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bookn_cp_app/core/bloc/theme/theme_bloc.dart';

// Core
import 'core/network/api_client.dart';
import 'core/network/network_info.dart';

// Services
import 'services/local_storage_service.dart';
import 'services/location_service.dart';
import 'services/notification_service.dart';
import 'services/analytics_service.dart';
import 'services/deep_link_service.dart';
import 'services/websocket_service.dart';
import 'services/connectivity_service.dart';

// Features - Auth
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/reset_password_usecase.dart';
import 'features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/domain/usecases/update_profile_usecase.dart';
import 'features/auth/domain/usecases/upload_user_image_usecase.dart';
import 'features/auth/domain/usecases/change_password_usecase.dart';

// Features - Chat
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'features/chat/domain/repositories/chat_repository.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/data/datasources/chat_remote_datasource.dart';
import 'features/chat/data/datasources/chat_local_datasource.dart';
import 'features/chat/domain/usecases/get_conversations_usecase.dart';
import 'features/chat/domain/usecases/get_messages_usecase.dart';
import 'features/chat/domain/usecases/send_message_usecase.dart';
import 'features/chat/domain/usecases/create_conversation_usecase.dart';
import 'features/chat/domain/usecases/delete_conversation_usecase.dart';
import 'features/chat/domain/usecases/archive_conversation_usecase.dart';
import 'features/chat/domain/usecases/unarchive_conversation_usecase.dart';
import 'features/chat/domain/usecases/delete_message_usecase.dart';
import 'features/chat/domain/usecases/edit_message_usecase.dart';
import 'features/chat/domain/usecases/add_reaction_usecase.dart';
import 'features/chat/domain/usecases/remove_reaction_usecase.dart';
import 'features/chat/domain/usecases/mark_as_read_usecase.dart';
import 'features/chat/domain/usecases/upload_attachment_usecase.dart';
import 'features/chat/domain/usecases/search_chats_usecase.dart';
import 'features/chat/domain/usecases/get_available_users_usecase.dart';
import 'features/chat/domain/usecases/get_admin_users_usecase.dart';
import 'features/chat/domain/usecases/update_user_status_usecase.dart';
import 'features/chat/domain/usecases/get_chat_settings_usecase.dart';
import 'features/chat/domain/usecases/update_chat_settings_usecase.dart';

// Features - Admin Units
import 'features/admin_units/presentation/bloc/units_list/units_list_bloc.dart';
import 'features/admin_units/presentation/bloc/unit_form/unit_form_bloc.dart';
import 'features/admin_units/presentation/bloc/unit_details/unit_details_bloc.dart';
import 'features/admin_units/domain/repositories/units_repository.dart';
import 'features/admin_units/data/repositories/units_repository_impl.dart';
import 'features/admin_units/data/datasources/units_remote_datasource.dart';
import 'features/admin_units/data/datasources/units_local_datasource.dart';
import 'features/admin_units/domain/usecases/get_units_usecase.dart';
import 'features/admin_units/domain/usecases/get_unit_details_usecase.dart';
import 'features/admin_units/domain/usecases/create_unit_usecase.dart';
import 'features/admin_units/domain/usecases/update_unit_usecase.dart';
import 'features/admin_units/domain/usecases/delete_unit_usecase.dart';
import 'features/admin_units/domain/usecases/get_unit_types_by_property_usecase.dart';
import 'features/admin_units/domain/usecases/get_unit_fields_usecase.dart';
import 'features/admin_units/domain/usecases/assign_unit_to_sections_usecase.dart';

final sl = GetIt.instance;

Future<void> init() async {
	// Features - Auth
	_initAuth();

	// Features - Chat
	_initChat();

	// Features - Admin Units
	_initAdminUnits();

	// Theme
  _initTheme();

	// Core
	_initCore();
	
	// External
	await _initExternal();
}

void _initAuth() {
	// Bloc
	sl.registerFactory(
		() => AuthBloc(
			loginUseCase: sl(),
			registerUseCase: sl(),
			logoutUseCase: sl(),
			resetPasswordUseCase: sl(),
			checkAuthStatusUseCase: sl(),
			getCurrentUserUseCase: sl(),
			updateProfileUseCase: sl(),
			uploadUserImageUseCase: sl(),
			changePasswordUseCase: sl(),
		),
	);
	
	// Use cases
	sl.registerLazySingleton(() => LoginUseCase(sl()));
	sl.registerLazySingleton(() => RegisterUseCase(sl()));
	sl.registerLazySingleton(() => LogoutUseCase(sl()));
	sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
	sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl()));
	sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
	sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
	sl.registerLazySingleton(() => UploadUserImageUseCase(sl()));
	sl.registerLazySingleton(() => ChangePasswordUseCase(sl()));
	
	// Repository
	sl.registerLazySingleton<AuthRepository>(
		() => AuthRepositoryImpl(
			remoteDataSource: sl(),
			localDataSource: sl(),
			internetConnectionChecker: sl(),
		),
	);
	
	// Data sources
	sl.registerLazySingleton<AuthRemoteDataSource>(
		() => AuthRemoteDataSourceImpl(apiClient: sl()),
	);
	sl.registerLazySingleton<AuthLocalDataSource>(
		() => AuthLocalDataSourceImpl(sharedPreferences: sl()),
	);
}

void _initChat() {
	// Bloc
	sl.registerFactory(
		() => ChatBloc(
			getConversationsUseCase: sl(),
			getMessagesUseCase: sl(),
			sendMessageUseCase: sl(),
			createConversationUseCase: sl(),
			deleteConversationUseCase: sl(),
			archiveConversationUseCase: sl(),
			unarchiveConversationUseCase: sl(),
			deleteMessageUseCase: sl(),
			editMessageUseCase: sl(),
			addReactionUseCase: sl(),
			removeReactionUseCase: sl(),
			markAsReadUseCase: sl(),
			uploadAttachmentUseCase: sl(),
			searchChatsUseCase: sl(),
			getAvailableUsersUseCase: sl(),
			getAdminUsersUseCase: sl(),
			updateUserStatusUseCase: sl(),
			getChatSettingsUseCase: sl(),
			updateChatSettingsUseCase: sl(),
			webSocketService: sl(),
		),
	);

	// Use cases
	sl.registerLazySingleton(() => GetConversationsUseCase(sl()));
	sl.registerLazySingleton(() => GetMessagesUseCase(sl()));
	sl.registerLazySingleton(() => SendMessageUseCase(sl()));
	sl.registerLazySingleton(() => CreateConversationUseCase(sl()));
	sl.registerLazySingleton(() => DeleteConversationUseCase(sl()));
	sl.registerLazySingleton(() => ArchiveConversationUseCase(sl()));
	sl.registerLazySingleton(() => UnarchiveConversationUseCase(sl()));
	sl.registerLazySingleton(() => DeleteMessageUseCase(sl()));
	sl.registerLazySingleton(() => EditMessageUseCase(sl()));
	sl.registerLazySingleton(() => AddReactionUseCase(sl()));
	sl.registerLazySingleton(() => RemoveReactionUseCase(sl()));
	sl.registerLazySingleton(() => MarkAsReadUseCase(sl()));
	sl.registerLazySingleton(() => UploadAttachmentUseCase(sl()));
	sl.registerLazySingleton(() => SearchChatsUseCase(sl()));
	sl.registerLazySingleton(() => GetAvailableUsersUseCase(sl()));
	sl.registerLazySingleton(() => GetAdminUsersUseCase(sl()));
	sl.registerLazySingleton(() => UpdateUserStatusUseCase(sl()));
	sl.registerLazySingleton(() => GetChatSettingsUseCase(sl()));
	sl.registerLazySingleton(() => UpdateChatSettingsUseCase(sl()));

	// Repository
	sl.registerLazySingleton<ChatRepository>(
		() => ChatRepositoryImpl(
			remoteDataSource: sl(),
			localDataSource: sl(),
			internetConnectionChecker: sl(),
		),
	);

	// Data sources
	sl.registerLazySingleton<ChatRemoteDataSource>(
		() => ChatRemoteDataSourceImpl(apiClient: sl()),
	);
	sl.registerLazySingleton<ChatLocalDataSource>(
		() => ChatLocalDataSourceImpl(),
	);

	// WebSocket Service
	sl.registerLazySingleton(() => ChatWebSocketService(
		authLocalDataSource: sl(),
	));
}

void _initAdminUnits() {
  // Blocs
  sl.registerFactory(() => UnitsListBloc(
        getUnitsUseCase: sl(),
        deleteUnitUseCase: sl(),
      ));
  sl.registerFactory(() => UnitFormBloc(
        createUnitUseCase: sl(),
        updateUnitUseCase: sl(),
        getUnitTypesByPropertyUseCase: sl(),
        getUnitFieldsUseCase: sl(),
      ));
  sl.registerFactory(() => UnitDetailsBloc(
        getUnitDetailsUseCase: sl(),
        deleteUnitUseCase: sl(),
        assignUnitToSectionsUseCase: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetUnitsUseCase(sl()));
  sl.registerLazySingleton(() => GetUnitDetailsUseCase(sl()));
  sl.registerLazySingleton(() => CreateUnitUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUnitUseCase(sl()));
  sl.registerLazySingleton(() => DeleteUnitUseCase(sl()));
  sl.registerLazySingleton(() => GetUnitTypesByPropertyUseCase(sl()));
  sl.registerLazySingleton(() => GetUnitFieldsUseCase(sl()));
  sl.registerLazySingleton(() => AssignUnitToSectionsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<UnitsRepository>(() => UnitsRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
        networkInfo: sl(),
      ));

  // Data sources
  sl.registerLazySingleton<UnitsRemoteDataSource>(() => UnitsRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<UnitsLocalDataSource>(() => UnitsLocalDataSourceImpl(sharedPreferences: sl()));
}

void _initTheme() {
  // Bloc
  sl.registerFactory(
    () => ThemeBloc(
      prefs: sl(),
    ),
  );
}

void _initCore() {
	// Network
	sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
	
	// API Client
	sl.registerLazySingleton<ApiClient>(() => ApiClient(sl()));
	
	// Services
	sl.registerLazySingleton(() => LocalStorageService(sl()));
	sl.registerLazySingleton(() => LocationService());
	sl.registerLazySingleton(() => NotificationService());
	sl.registerLazySingleton(() => AnalyticsService());
	sl.registerLazySingleton(() => DeepLinkService());
	sl.registerLazySingleton(() => ConnectivityService());
}

Future<void> _initExternal() async {
	// Shared Preferences
	final sharedPreferences = await SharedPreferences.getInstance();
	sl.registerLazySingleton(() => sharedPreferences);
	
	// Dio
	sl.registerLazySingleton(() => Dio());
	
	// Internet Connection Checker
	sl.registerLazySingleton(() => InternetConnectionChecker());
}