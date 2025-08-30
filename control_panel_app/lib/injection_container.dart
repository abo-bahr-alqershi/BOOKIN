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

// Features - Property Types
import 'features/property_types/presentation/bloc/property_types/property_types_bloc.dart';
import 'features/property_types/presentation/bloc/unit_types/unit_types_bloc.dart';
import 'features/property_types/presentation/bloc/unit_type_fields/unit_type_fields_bloc.dart';
import 'features/property_types/domain/repositories/property_types_repository.dart' as pt_domain;
import 'features/property_types/domain/repositories/unit_types_repository.dart' as ut_domain;
import 'features/property_types/domain/repositories/unit_type_fields_repository.dart' as utf_domain;
import 'features/property_types/data/repositories/property_types_repository_impl.dart' as pt_data;
import 'features/property_types/data/repositories/unit_types_repository_impl.dart' as ut_data;
import 'features/property_types/data/repositories/unit_type_fields_repository_impl.dart' as utf_data;
import 'features/property_types/data/datasources/property_types_remote_datasource.dart' as pt_ds;
import 'features/property_types/data/datasources/unit_types_remote_datasource.dart' as ut_ds;
import 'features/property_types/data/datasources/unit_type_fields_remote_datasource.dart' as utf_ds;
import 'features/property_types/domain/usecases/property_types/get_all_property_types_usecase.dart' as pt_uc;
import 'features/property_types/domain/usecases/property_types/create_property_type_usecase.dart' as pt_uc3;
import 'features/property_types/domain/usecases/property_types/update_property_type_usecase.dart' as pt_uc4;
import 'features/property_types/domain/usecases/property_types/delete_property_type_usecase.dart' as pt_uc5;
import 'features/property_types/domain/usecases/unit_types/get_unit_types_by_property_usecase.dart' as ut_uc1;
import 'features/property_types/domain/usecases/unit_types/create_unit_type_usecase.dart' as ut_uc2;
import 'features/property_types/domain/usecases/unit_types/update_unit_type_usecase.dart' as ut_uc3;
import 'features/property_types/domain/usecases/unit_types/delete_unit_type_usecase.dart' as ut_uc4;
import 'features/property_types/domain/usecases/fields/get_fields_by_unit_type_usecase.dart' as utf_uc1;
import 'features/property_types/domain/usecases/fields/create_field_usecase.dart' as utf_uc2;
import 'features/property_types/domain/usecases/fields/update_field_usecase.dart' as utf_uc3;
import 'features/property_types/domain/usecases/fields/delete_field_usecase.dart' as utf_uc4;

// Features - Admin Services
import 'features/admin_services/presentation/bloc/services_bloc.dart';
import 'features/admin_services/data/datasources/services_remote_datasource.dart';
import 'features/admin_services/data/repositories/services_repository_impl.dart';
import 'features/admin_services/domain/repositories/services_repository.dart';
import 'features/admin_services/domain/usecases/create_service_usecase.dart' as as_uc1;
import 'features/admin_services/domain/usecases/update_service_usecase.dart' as as_uc2;
import 'features/admin_services/domain/usecases/delete_service_usecase.dart' as as_uc3;
import 'features/admin_services/domain/usecases/get_services_by_property_usecase.dart' as as_uc4;
import 'features/admin_services/domain/usecases/get_service_details_usecase.dart' as as_uc5;
import 'features/admin_services/domain/usecases/get_services_by_type_usecase.dart' as as_uc6;

// Features - Admin Reviews
import 'features/admin_reviews/presentation/bloc/reviews_list/reviews_list_bloc.dart' as ar_list_bloc;
import 'features/admin_reviews/presentation/bloc/review_details/review_details_bloc.dart' as ar_details_bloc;
import 'features/admin_reviews/presentation/bloc/review_response/review_response_bloc.dart' as ar_resp_bloc;
import 'features/admin_reviews/data/datasources/reviews_remote_datasource.dart' as ar_ds_remote;
import 'features/admin_reviews/data/datasources/reviews_local_datasource.dart' as ar_ds_local;
import 'features/admin_reviews/data/repositories/reviews_repository_impl.dart' as ar_repo_impl;
import 'features/admin_reviews/domain/repositories/reviews_repository.dart' as ar_repo;
import 'features/admin_reviews/domain/usecases/get_all_reviews_usecase.dart' as ar_uc1;
import 'features/admin_reviews/domain/usecases/approve_review_usecase.dart' as ar_uc2;
import 'features/admin_reviews/domain/usecases/delete_review_usecase.dart' as ar_uc3;
import 'features/admin_reviews/domain/usecases/get_review_details_usecase.dart' as ar_uc4;
import 'features/admin_reviews/domain/usecases/get_review_responses_usecase.dart' as ar_uc5;
import 'features/admin_reviews/domain/usecases/respond_to_review_usecase.dart' as ar_uc6;
import 'features/admin_reviews/domain/usecases/delete_review_response_usecase.dart' as ar_uc7;

// Features - Admin Amenities (standalone)
import 'features/admin_amenities/presentation/bloc/amenities_bloc.dart' as aa_bloc;
import 'features/admin_amenities/data/datasources/amenities_remote_datasource.dart' as aa_ds_remote;
import 'features/admin_amenities/data/repositories/amenities_repository_impl.dart' as aa_repo_impl;
import 'features/admin_amenities/domain/repositories/amenities_repository.dart' as aa_repo;
import 'features/admin_amenities/domain/usecases/create_amenity_usecase.dart' as aa_uc1;
import 'features/admin_amenities/domain/usecases/update_amenity_usecase.dart' as aa_uc2;
import 'features/admin_amenities/domain/usecases/delete_amenity_usecase.dart' as aa_uc3;
import 'features/admin_amenities/domain/usecases/get_all_amenities_usecase.dart' as aa_uc4;
import 'features/admin_amenities/domain/usecases/assign_amenity_to_property_usecase.dart' as aa_uc5;

// Features - Admin Properties
import 'features/admin_properties/presentation/bloc/properties/properties_bloc.dart' as ap_bloc;
import 'features/admin_properties/presentation/bloc/amenities/amenities_bloc.dart' as ap_am_bloc;
import 'features/admin_properties/presentation/bloc/policies/policies_bloc.dart' as ap_po_bloc;
import 'features/admin_properties/presentation/bloc/property_types/property_types_bloc.dart' as ap_pt_bloc;
import 'features/admin_properties/domain/repositories/properties_repository.dart' as ap_repo;
import 'features/admin_properties/domain/repositories/amenities_repository.dart' as ap_am_repo;
import 'features/admin_properties/domain/repositories/policies_repository.dart' as ap_po_repo;
import 'features/admin_properties/domain/repositories/property_types_repository.dart' as ap_pt_repo;
import 'features/admin_properties/data/repositories/properties_repository_impl.dart' as ap_repo_impl;
import 'features/admin_properties/data/repositories/amenities_repository_impl.dart' as ap_am_repo_impl;
import 'features/admin_properties/data/repositories/policies_repository_impl.dart' as ap_po_repo_impl;
import 'features/admin_properties/data/repositories/property_types_repository_impl.dart' as ap_pt_repo_impl;
import 'features/admin_properties/data/datasources/properties_remote_datasource.dart' as ap_ds_prop_remote;
import 'features/admin_properties/data/datasources/properties_local_datasource.dart' as ap_ds_prop_local;
import 'features/admin_properties/data/datasources/amenities_remote_datasource.dart' as ap_ds_am_remote;
import 'features/admin_properties/data/datasources/policies_remote_datasource.dart' as ap_ds_po_remote;
import 'features/admin_properties/data/datasources/property_types_remote_datasource.dart' as ap_ds_pt_remote;
import 'features/admin_properties/domain/usecases/properties/get_all_properties_usecase.dart' as ap_uc_prop1;
import 'features/admin_properties/domain/usecases/properties/create_property_usecase.dart' as ap_uc_prop2;
import 'features/admin_properties/domain/usecases/properties/update_property_usecase.dart' as ap_uc_prop3;
import 'features/admin_properties/domain/usecases/properties/delete_property_usecase.dart' as ap_uc_prop4;
import 'features/admin_properties/domain/usecases/properties/approve_property_usecase.dart' as ap_uc_prop5;
import 'features/admin_properties/domain/usecases/properties/reject_property_usecase.dart' as ap_uc_prop6;
import 'features/admin_properties/domain/usecases/amenities/get_amenities_usecase.dart' as ap_uc_am1;
import 'features/admin_properties/domain/usecases/amenities/create_amenity_usecase.dart' as ap_uc_am2;
import 'features/admin_properties/domain/usecases/amenities/update_amenity_usecase.dart' as ap_uc_am3;
import 'features/admin_properties/domain/usecases/amenities/delete_amenity_usecase.dart' as ap_uc_am4;
import 'features/admin_properties/domain/usecases/amenities/assign_amenity_to_property_usecase.dart' as ap_uc_am5;
import 'features/admin_properties/domain/usecases/policies/get_policies_usecase.dart' as ap_uc_po1;
import 'features/admin_properties/domain/usecases/policies/create_policy_usecase.dart' as ap_uc_po2;
import 'features/admin_properties/domain/usecases/policies/update_policy_usecase.dart' as ap_uc_po3;
import 'features/admin_properties/domain/usecases/policies/delete_policy_usecase.dart' as ap_uc_po4;
import 'features/admin_properties/domain/usecases/property_types/get_property_types_usecase.dart' as ap_uc_pt1;
import 'features/admin_properties/domain/usecases/property_types/create_property_type_usecase.dart' as ap_uc_pt2;
import 'features/admin_properties/domain/usecases/property_types/update_property_type_usecase.dart' as ap_uc_pt3;
import 'features/admin_properties/domain/usecases/property_types/delete_property_type_usecase.dart' as ap_uc_pt4;

final sl = GetIt.instance;

Future<void> init() async {
	// Features - Auth
	_initAuth();

	// Features - Chat
	_initChat();

	// Features - Admin Units
	_initAdminUnits();

	// Features - Property Types
	_initPropertyTypes();

	// Features - Admin Properties
	_initAdminProperties();

	// Features - Admin Services
	_initAdminServices();

	// Features - Admin Reviews
	_initAdminReviews();

	// Features - Admin Amenities (standalone)
	_initAdminAmenities();

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

void _initPropertyTypes() {
  // Blocs
  sl.registerFactory(() => PropertyTypesBloc(
        getAllPropertyTypes: sl<pt_uc.GetAllPropertyTypesUseCase>(),
        createPropertyType: sl<pt_uc3.CreatePropertyTypeUseCase>(),
        updatePropertyType: sl<pt_uc4.UpdatePropertyTypeUseCase>(),
        deletePropertyType: sl<pt_uc5.DeletePropertyTypeUseCase>(),
      ));
  sl.registerFactory(() => UnitTypesBloc(
        getUnitTypesByProperty: sl<ut_uc1.GetUnitTypesByPropertyUseCase>(),
        createUnitType: sl<ut_uc2.CreateUnitTypeUseCase>(),
        updateUnitType: sl<ut_uc3.UpdateUnitTypeUseCase>(),
        deleteUnitType: sl<ut_uc4.DeleteUnitTypeUseCase>(),
      ));
  sl.registerFactory(() => UnitTypeFieldsBloc(
        getFieldsByUnitType: sl<utf_uc1.GetFieldsByUnitTypeUseCase>(),
        createField: sl<utf_uc2.CreateFieldUseCase>(),
        updateField: sl<utf_uc3.UpdateFieldUseCase>(),
        deleteField: sl<utf_uc4.DeleteFieldUseCase>(),
      ));

  // Use cases - property types
  sl.registerLazySingleton<pt_uc.GetAllPropertyTypesUseCase>(() => pt_uc.GetAllPropertyTypesUseCase(sl()));
  sl.registerLazySingleton<pt_uc3.CreatePropertyTypeUseCase>(() => pt_uc3.CreatePropertyTypeUseCase(sl()));
  sl.registerLazySingleton<pt_uc4.UpdatePropertyTypeUseCase>(() => pt_uc4.UpdatePropertyTypeUseCase(sl()));
  sl.registerLazySingleton<pt_uc5.DeletePropertyTypeUseCase>(() => pt_uc5.DeletePropertyTypeUseCase(sl()));

  // Use cases - unit types
  sl.registerLazySingleton<ut_uc1.GetUnitTypesByPropertyUseCase>(() => ut_uc1.GetUnitTypesByPropertyUseCase(sl()));
  sl.registerLazySingleton<ut_uc2.CreateUnitTypeUseCase>(() => ut_uc2.CreateUnitTypeUseCase(sl()));
  sl.registerLazySingleton<ut_uc3.UpdateUnitTypeUseCase>(() => ut_uc3.UpdateUnitTypeUseCase(sl()));
  sl.registerLazySingleton<ut_uc4.DeleteUnitTypeUseCase>(() => ut_uc4.DeleteUnitTypeUseCase(sl()));

  // Use cases - fields
  sl.registerLazySingleton<utf_uc1.GetFieldsByUnitTypeUseCase>(() => utf_uc1.GetFieldsByUnitTypeUseCase(sl()));
  sl.registerLazySingleton<utf_uc2.CreateFieldUseCase>(() => utf_uc2.CreateFieldUseCase(sl()));
  sl.registerLazySingleton<utf_uc3.UpdateFieldUseCase>(() => utf_uc3.UpdateFieldUseCase(sl()));
  sl.registerLazySingleton<utf_uc4.DeleteFieldUseCase>(() => utf_uc4.DeleteFieldUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<pt_domain.PropertyTypesRepository>(() => pt_data.PropertyTypesRepositoryImpl(
        remoteDataSource: sl(),
        networkInfo: sl(),
      ));
  sl.registerLazySingleton<ut_domain.UnitTypesRepository>(() => ut_data.UnitTypesRepositoryImpl(
        remoteDataSource: sl(),
        networkInfo: sl(),
      ));
  sl.registerLazySingleton<utf_domain.UnitTypeFieldsRepository>(() => utf_data.UnitTypeFieldsRepositoryImpl(
        remoteDataSource: sl(),
        networkInfo: sl(),
      ));

  // Data sources
  sl.registerLazySingleton<pt_ds.PropertyTypesRemoteDataSource>(() => pt_ds.PropertyTypesRemoteDataSourceImpl(apiClient: sl()));
  sl.registerLazySingleton<ut_ds.UnitTypesRemoteDataSource>(() => ut_ds.UnitTypesRemoteDataSourceImpl(apiClient: sl()));
  sl.registerLazySingleton<utf_ds.UnitTypeFieldsRemoteDataSource>(() => utf_ds.UnitTypeFieldsRemoteDataSourceImpl(apiClient: sl()));
}

void _initAdminProperties() {
  // Blocs
  sl.registerFactory(() => ap_bloc.PropertiesBloc(
        getAllProperties: sl<ap_uc_prop1.GetAllPropertiesUseCase>(),
        createProperty: sl<ap_uc_prop2.CreatePropertyUseCase>(),
        updateProperty: sl<ap_uc_prop3.UpdatePropertyUseCase>(),
        deleteProperty: sl<ap_uc_prop4.DeletePropertyUseCase>(),
        approveProperty: sl<ap_uc_prop5.ApprovePropertyUseCase>(),
        rejectProperty: sl<ap_uc_prop6.RejectPropertyUseCase>(),
      ));
  sl.registerFactory(() => ap_am_bloc.AmenitiesBloc(
        getAmenities: sl<ap_uc_am1.GetAmenitiesUseCase>(),
        createAmenity: sl<ap_uc_am2.CreateAmenityUseCase>(),
        updateAmenity: sl<ap_uc_am3.UpdateAmenityUseCase>(),
        deleteAmenity: sl<ap_uc_am4.DeleteAmenityUseCase>(),
        assignAmenityToProperty: sl<ap_uc_am5.AssignAmenityToPropertyUseCase>(),
      ));
  sl.registerFactory(() => ap_po_bloc.PoliciesBloc(
        getPolicies: sl<ap_uc_po1.GetPoliciesUseCase>(),
        createPolicy: sl<ap_uc_po2.CreatePolicyUseCase>(),
        updatePolicy: sl<ap_uc_po3.UpdatePolicyUseCase>(),
        deletePolicy: sl<ap_uc_po4.DeletePolicyUseCase>(),
      ));
  sl.registerFactory(() => ap_pt_bloc.PropertyTypesBloc(
        getPropertyTypes: sl<ap_uc_pt1.GetPropertyTypesUseCase>(),
        createPropertyType: sl<ap_uc_pt2.CreatePropertyTypeUseCase>(),
        updatePropertyType: sl<ap_uc_pt3.UpdatePropertyTypeUseCase>(),
        deletePropertyType: sl<ap_uc_pt4.DeletePropertyTypeUseCase>(),
      ));

  // Use cases - properties
  sl.registerLazySingleton<ap_uc_prop1.GetAllPropertiesUseCase>(() => ap_uc_prop1.GetAllPropertiesUseCase(sl()));
  sl.registerLazySingleton<ap_uc_prop2.CreatePropertyUseCase>(() => ap_uc_prop2.CreatePropertyUseCase(sl()));
  sl.registerLazySingleton<ap_uc_prop3.UpdatePropertyUseCase>(() => ap_uc_prop3.UpdatePropertyUseCase(sl()));
  sl.registerLazySingleton<ap_uc_prop4.DeletePropertyUseCase>(() => ap_uc_prop4.DeletePropertyUseCase(sl()));
  sl.registerLazySingleton<ap_uc_prop5.ApprovePropertyUseCase>(() => ap_uc_prop5.ApprovePropertyUseCase(sl()));
  sl.registerLazySingleton<ap_uc_prop6.RejectPropertyUseCase>(() => ap_uc_prop6.RejectPropertyUseCase(sl()));

  // Use cases - amenities
  sl.registerLazySingleton<ap_uc_am1.GetAmenitiesUseCase>(() => ap_uc_am1.GetAmenitiesUseCase(sl()));
  sl.registerLazySingleton<ap_uc_am2.CreateAmenityUseCase>(() => ap_uc_am2.CreateAmenityUseCase(sl()));
  sl.registerLazySingleton<ap_uc_am3.UpdateAmenityUseCase>(() => ap_uc_am3.UpdateAmenityUseCase(sl()));
  sl.registerLazySingleton<ap_uc_am4.DeleteAmenityUseCase>(() => ap_uc_am4.DeleteAmenityUseCase(sl()));
  sl.registerLazySingleton<ap_uc_am5.AssignAmenityToPropertyUseCase>(() => ap_uc_am5.AssignAmenityToPropertyUseCase(sl()));

  // Use cases - policies
  sl.registerLazySingleton<ap_uc_po1.GetPoliciesUseCase>(() => ap_uc_po1.GetPoliciesUseCase(sl()));
  sl.registerLazySingleton<ap_uc_po2.CreatePolicyUseCase>(() => ap_uc_po2.CreatePolicyUseCase(sl()));
  sl.registerLazySingleton<ap_uc_po3.UpdatePolicyUseCase>(() => ap_uc_po3.UpdatePolicyUseCase(sl()));
  sl.registerLazySingleton<ap_uc_po4.DeletePolicyUseCase>(() => ap_uc_po4.DeletePolicyUseCase(sl()));

  // Use cases - property types
  sl.registerLazySingleton<ap_uc_pt1.GetPropertyTypesUseCase>(() => ap_uc_pt1.GetPropertyTypesUseCase(sl()));
  sl.registerLazySingleton<ap_uc_pt2.CreatePropertyTypeUseCase>(() => ap_uc_pt2.CreatePropertyTypeUseCase(sl()));
  sl.registerLazySingleton<ap_uc_pt3.UpdatePropertyTypeUseCase>(() => ap_uc_pt3.UpdatePropertyTypeUseCase(sl()));
  sl.registerLazySingleton<ap_uc_pt4.DeletePropertyTypeUseCase>(() => ap_uc_pt4.DeletePropertyTypeUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<ap_repo.PropertiesRepository>(() => ap_repo_impl.PropertiesRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
        networkInfo: sl(),
      ));
  sl.registerLazySingleton<ap_am_repo.AmenitiesRepository>(() => ap_am_repo_impl.AmenitiesRepositoryImpl(
        remoteDataSource: sl(),
        networkInfo: sl(),
      ));
  sl.registerLazySingleton<ap_po_repo.PoliciesRepository>(() => ap_po_repo_impl.PoliciesRepositoryImpl(
        remoteDataSource: sl(),
        networkInfo: sl(),
      ));
  sl.registerLazySingleton<ap_pt_repo.PropertyTypesRepository>(() => ap_pt_repo_impl.PropertyTypesRepositoryImpl(
        remoteDataSource: sl(),
        networkInfo: sl(),
      ));

  // Data sources
  sl.registerLazySingleton<ap_ds_prop_remote.PropertiesRemoteDataSource>(() => ap_ds_prop_remote.PropertiesRemoteDataSourceImpl(apiClient: sl()));
  sl.registerLazySingleton<ap_ds_prop_local.PropertiesLocalDataSource>(() => ap_ds_prop_local.PropertiesLocalDataSourceImpl(sharedPreferences: sl()));
  sl.registerLazySingleton<ap_ds_am_remote.AmenitiesRemoteDataSource>(() => ap_ds_am_remote.AmenitiesRemoteDataSourceImpl(apiClient: sl()));
  sl.registerLazySingleton<ap_ds_po_remote.PoliciesRemoteDataSource>(() => ap_ds_po_remote.PoliciesRemoteDataSourceImpl(apiClient: sl()));
  sl.registerLazySingleton<ap_ds_pt_remote.PropertyTypesRemoteDataSource>(() => ap_ds_pt_remote.PropertyTypesRemoteDataSourceImpl(apiClient: sl()));
}

void _initAdminServices() {
  // Bloc
  sl.registerFactory(() => ServicesBloc(
        createServiceUseCase: sl<as_uc1.CreateServiceUseCase>(),
        updateServiceUseCase: sl<as_uc2.UpdateServiceUseCase>(),
        deleteServiceUseCase: sl<as_uc3.DeleteServiceUseCase>(),
        getServicesByPropertyUseCase: sl<as_uc4.GetServicesByPropertyUseCase>(),
        getServiceDetailsUseCase: sl<as_uc5.GetServiceDetailsUseCase>(),
        getServicesByTypeUseCase: sl<as_uc6.GetServicesByTypeUseCase>(),
      ));

  // Use cases
  sl.registerLazySingleton<as_uc1.CreateServiceUseCase>(() => as_uc1.CreateServiceUseCase(sl()));
  sl.registerLazySingleton<as_uc2.UpdateServiceUseCase>(() => as_uc2.UpdateServiceUseCase(sl()));
  sl.registerLazySingleton<as_uc3.DeleteServiceUseCase>(() => as_uc3.DeleteServiceUseCase(sl()));
  sl.registerLazySingleton<as_uc4.GetServicesByPropertyUseCase>(() => as_uc4.GetServicesByPropertyUseCase(sl()));
  sl.registerLazySingleton<as_uc5.GetServiceDetailsUseCase>(() => as_uc5.GetServiceDetailsUseCase(sl()));
  sl.registerLazySingleton<as_uc6.GetServicesByTypeUseCase>(() => as_uc6.GetServicesByTypeUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ServicesRepository>(() => ServicesRepositoryImpl(remoteDataSource: sl()));

  // Data source
  sl.registerLazySingleton<ServicesRemoteDataSource>(() => ServicesRemoteDataSourceImpl(apiClient: sl()));
}

void _initAdminReviews() {
  // Blocs
  sl.registerFactory(() => ar_list_bloc.ReviewsListBloc(
        getAllReviews: sl<ar_uc1.GetAllReviewsUseCase>(),
        approveReview: sl<ar_uc2.ApproveReviewUseCase>(),
        deleteReview: sl<ar_uc3.DeleteReviewUseCase>(),
      ));
  sl.registerFactory(() => ar_details_bloc.ReviewDetailsBloc(
        getReviewDetails: sl<ar_uc4.GetReviewDetailsUseCase>(),
        getReviewResponses: sl<ar_uc5.GetReviewResponsesUseCase>(),
        respondToReview: sl<ar_uc6.RespondToReviewUseCase>(),
        deleteReviewResponse: sl<ar_uc7.DeleteReviewResponseUseCase>(),
      ));
  sl.registerFactory(() => ar_resp_bloc.ReviewResponseBloc(
        respondToReview: sl<ar_uc6.RespondToReviewUseCase>(),
      ));

  // Use cases
  sl.registerLazySingleton<ar_uc1.GetAllReviewsUseCase>(() => ar_uc1.GetAllReviewsUseCase(sl()));
  sl.registerLazySingleton<ar_uc2.ApproveReviewUseCase>(() => ar_uc2.ApproveReviewUseCase(sl()));
  sl.registerLazySingleton<ar_uc3.DeleteReviewUseCase>(() => ar_uc3.DeleteReviewUseCase(sl()));
  sl.registerLazySingleton<ar_uc4.GetReviewDetailsUseCase>(() => ar_uc4.GetReviewDetailsUseCase(sl()));
  sl.registerLazySingleton<ar_uc5.GetReviewResponsesUseCase>(() => ar_uc5.GetReviewResponsesUseCase(sl()));
  sl.registerLazySingleton<ar_uc6.RespondToReviewUseCase>(() => ar_uc6.RespondToReviewUseCase(sl()));
  sl.registerLazySingleton<ar_uc7.DeleteReviewResponseUseCase>(() => ar_uc7.DeleteReviewResponseUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ar_repo.ReviewsRepository>(() => ar_repo_impl.ReviewsRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
      ));

  // Data sources
  sl.registerLazySingleton<ar_ds_remote.ReviewsRemoteDataSource>(() => ar_ds_remote.ReviewsRemoteDataSourceImpl(apiClient: sl()));
  sl.registerLazySingleton<ar_ds_local.ReviewsLocalDataSource>(() => ar_ds_local.ReviewsLocalDataSourceImpl(sharedPreferences: sl()));
}

void _initAdminAmenities() {
  // Bloc
  sl.registerFactory(() => aa_bloc.AmenitiesBloc(
        createAmenityUseCase: sl<aa_uc1.CreateAmenityUseCase>(),
        updateAmenityUseCase: sl<aa_uc2.UpdateAmenityUseCase>(),
        deleteAmenityUseCase: sl<aa_uc3.DeleteAmenityUseCase>(),
        getAllAmenitiesUseCase: sl<aa_uc4.GetAllAmenitiesUseCase>(),
        assignAmenityToPropertyUseCase: sl<aa_uc5.AssignAmenityToPropertyUseCase>(),
        repository: sl(),
      ));

  // Use cases
  sl.registerLazySingleton<aa_uc1.CreateAmenityUseCase>(() => aa_uc1.CreateAmenityUseCase(sl()));
  sl.registerLazySingleton<aa_uc2.UpdateAmenityUseCase>(() => aa_uc2.UpdateAmenityUseCase(sl()));
  sl.registerLazySingleton<aa_uc3.DeleteAmenityUseCase>(() => aa_uc3.DeleteAmenityUseCase(sl()));
  sl.registerLazySingleton<aa_uc4.GetAllAmenitiesUseCase>(() => aa_uc4.GetAllAmenitiesUseCase(sl()));
  sl.registerLazySingleton<aa_uc5.AssignAmenityToPropertyUseCase>(() => aa_uc5.AssignAmenityToPropertyUseCase(sl()));

  // Repository
  sl.registerLazySingleton<aa_repo.AmenitiesRepository>(() => aa_repo_impl.AmenitiesRepositoryImpl(remoteDataSource: sl()));

  // Data source
  sl.registerLazySingleton<aa_ds_remote.AmenitiesRemoteDataSource>(() => aa_ds_remote.AmenitiesRemoteDataSourceImpl(apiClient: sl()));
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