lib/
├── app.dart
├── main.dart
├── injection_container.dart                         # Dependency Injection
├── presentation/
│   └── screens/
│       ├── main_screen.dart                     # الشاشة الرئيسية مع Bottom Navigation
│       └── splash_screen.dart                 # شاشة البداية
│
├── core/
│   ├── bloc/
│   │   └── app_bloc.dart
│   ├── constants/
│   │   ├── api_constants.dart
│   │   ├── app_constants.dart
│   │   ├── route_constants.dart
│   │   └── storage_constants.dart
│   ├── enums/
│   │   ├── booking_status.dart
│   │   ├── payment_method_enum.dart
│   │   ├── section_target_enum.dart
│   │   └── section_type_enum.dart
│   ├── error/
│   │   ├── error_handler.dart
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── localization/
│   │   ├── app_localizations.dart
│   │   ├── locale_manager.dart
│   │   └── l10n/
│   │       ├── app_ar.arb
│   │       └── app_en.arb
│   ├── network/
│   │   ├── api_client.dart
│   │   ├── api_interceptors.dart
│   │   ├── api_exceptions.dart
│   │   └── network_info.dart
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_dimensions.dart
│   │   ├── app_text_styles.dart
│   │   ├── app_theme.dart
│   │   └── app_theme.dart
│   ├── utils/
│   │   ├── color_extensions.dart
│   │   ├── date_utils.dart
│   │   ├── formatters.dart
│   │   ├── image_utils.dart
│   │   ├── location_utils.dart
│   │   ├── price_calculator.dart
│   │   ├── request_logger.dart
│   │   └── validators.dart
│   ├── models/
│   │   ├── paginated_result.dart
│   │   └── result_dto.dart
│   └── widgets/
│       ├── app_bar_widget.dart
│       ├── cached_image_widget.dart
│       ├── empty_widget.dart
│       ├── error_widget.dart
│       ├── loading_widget.dart
│       ├── price_widget.dart
│       └── rating_widget.dart
│
├── features/
|   ├── admin_properties/
|   |   ├── data/
|   |   │   ├── datasources/
|   |   │   │   ├── properties_local_datasource.dart
|   |   │   │   ├── properties_remote_datasource.dart
|   |   │   │   ├── property_types_remote_datasource.dart
|   |   │   │   ├── amenities_remote_datasource.dart
|   |   │   │   ├── policies_remote_datasource.dart
|   |   │   │   └── property_images_remote_datasource.dart
|   |   │   ├── models/
|   |   │   │   ├── property_model.dart
|   |   │   │   ├── property_type_model.dart
|   |   │   │   ├── amenity_model.dart
|   |   │   │   ├── policy_model.dart
|   |   │   │   ├── property_image_model.dart
|   |   │   │   ├── property_search_model.dart
|   |   │   │   └── map_marker_model.dart
|   |   │   └── repositories/
|   |   │       ├── properties_repository_impl.dart
|   |   │       ├── property_types_repository_impl.dart
|   |   │       ├── amenities_repository_impl.dart
|   |   │       └── policies_repository_impl.dart
|   |   ├── domain/
|   |   │   ├── entities/
|   |   │   │   ├── property.dart
|   |   │   │   ├── property_type.dart
|   |   │   │   ├── amenity.dart
|   |   │   │   ├── policy.dart
|   |   │   │   ├── property_image.dart
|   |   │   │   ├── property_search_result.dart
|   |   │   │   └── map_location.dart
|   |   │   ├── repositories/
|   |   │   │   ├── properties_repository.dart
|   |   │   │   ├── property_types_repository.dart
|   |   │   │   ├── amenities_repository.dart
|   |   │   │   └── policies_repository.dart
|   |   │   └── usecases/
|   |   │       ├── properties/
|   |   │       │   ├── create_property_usecase.dart
|   |   │       │   ├── update_property_usecase.dart
|   |   │       │   ├── delete_property_usecase.dart
|   |   │       │   ├── get_all_properties_usecase.dart
|   |   │       │   ├── get_property_details_usecase.dart
|   |   │       │   ├── approve_property_usecase.dart
|   |   │       │   ├── reject_property_usecase.dart
|   |   │       │   └── search_properties_usecase.dart
|   |   │       ├── property_types/
|   |   │       │   ├── create_property_type_usecase.dart
|   |   │       │   ├── update_property_type_usecase.dart
|   |   │       │   ├── delete_property_type_usecase.dart
|   |   │       │   └── get_property_types_usecase.dart
|   |   │       ├── amenities/
|   |   │       │   ├── create_amenity_usecase.dart
|   |   │       │   ├── update_amenity_usecase.dart
|   |   │       │   ├── delete_amenity_usecase.dart
|   |   │       │   ├── get_amenities_usecase.dart
|   |   │       │   └── assign_amenity_to_property_usecase.dart
|   |   │       └── policies/
|   |   │           ├── create_policy_usecase.dart
|   |   │           ├── update_policy_usecase.dart
|   |   │           ├── delete_policy_usecase.dart
|   |   │           └── get_policies_usecase.dart
|   |   └── presentation/
|   |       ├── bloc/
|   |       │   ├── properties/
|   |       │   │   ├── properties_bloc.dart
|   |       │   │   ├── properties_event.dart
|   |       │   │   └── properties_state.dart
|   |       │   ├── property_types/
|   |       │   │   ├── property_types_bloc.dart
|   |       │   │   ├── property_types_event.dart
|   |       │   │   └── property_types_state.dart
|   |       │   ├── amenities/
|   |       │   │   ├── amenities_bloc.dart
|   |       │   │   ├── amenities_event.dart
|   |       │   │   └── amenities_state.dart
|   |       │   └── policies/
|   |       │       ├── policies_bloc.dart
|   |       │       ├── policies_event.dart
|   |       │       └── policies_state.dart
|   |       ├── pages/
|   |       │   ├── properties_list_page.dart
|   |       │   ├── property_details_page.dart
|   |       │   ├── create_property_page.dart
|   |       │   ├── edit_property_page.dart
|   |       │   ├── property_types_page.dart
|   |       │   ├── amenities_management_page.dart
|   |       │   └── policies_management_page.dart
|   |       └── widgets/
|   |           ├── property_card_widget.dart
|   |           ├── futuristic_property_table.dart
|   |           ├── property_filters_widget.dart
|   |           ├── property_map_view.dart
|   |           ├── property_image_gallery.dart
|   |           ├── amenity_selector_widget.dart
|   |           ├── policy_editor_widget.dart
|   |           └── property_stats_card.dart
|   |   
|   |   
│   ├── admin_property_types/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── property_types_remote_datasource.dart
│   │   │   │   ├── unit_types_remote_datasource.dart
│   │   │   │   └── unit_type_fields_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── property_type_model.dart
│   │   │   │   ├── unit_type_model.dart
│   │   │   │   └── unit_type_field_model.dart
│   │   │   └── repositories/
│   │   │       ├── property_types_repository_impl.dart
│   │   │       ├── unit_types_repository_impl.dart
│   │   │       └── unit_type_fields_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── property_type.dart
│   │   │   │   ├── unit_type.dart
│   │   │   │   └── unit_type_field.dart
│   │   │   ├── repositories/
│   │   │   │   ├── property_types_repository.dart
│   │   │   │   ├── unit_types_repository.dart
│   │   │   │   └── unit_type_fields_repository.dart
│   │   │   └── usecases/
│   │   │       ├── property_types/
│   │   │       │   ├── get_all_property_types_usecase.dart
│   │   │       │   ├── create_property_type_usecase.dart
│   │   │       │   ├── update_property_type_usecase.dart
│   │   │       │   └── delete_property_type_usecase.dart
│   │   │       ├── unit_types/
│   │   │       │   ├── get_unit_types_by_property_usecase.dart
│   │   │       │   ├── create_unit_type_usecase.dart
│   │   │       │   ├── update_unit_type_usecase.dart
│   │   │       │   └── delete_unit_type_usecase.dart
│   │   │       └── fields/
│   │   │           ├── get_fields_by_unit_type_usecase.dart
│   │   │           ├── create_field_usecase.dart
│   │   │           ├── update_field_usecase.dart
│   │   │           └── delete_field_usecase.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── property_types/
│   │       │   │   ├── property_types_bloc.dart
│   │       │   │   ├── property_types_event.dart
│   │       │   │   └── property_types_state.dart
│   │       │   ├── unit_types/
│   │       │   │   ├── unit_types_bloc.dart
│   │       │   │   ├── unit_types_event.dart
│   │       │   │   └── unit_types_state.dart
│   │       │   └── unit_type_fields/
│   │       │       ├── unit_type_fields_bloc.dart
│   │       │       ├── unit_type_fields_event.dart
│   │       │       └── unit_type_fields_state.dart
│   │       ├── pages/
│   │       │   └── admin_property_types_page.dart
│   │       └── widgets/
│   │           ├── property_type_card.dart
│   │           ├── unit_type_card.dart
│   │           ├── unit_type_field_card.dart
│   │           ├── property_type_modal.dart
│   │           ├── unit_type_modal.dart 
│   │           ├── unit_type_field_modal.dart
│   │           ├── icon_picker_modal.dart
│   │           └── futuristic_stats_card.dart
│   │   
│   ├── admin_units/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── units_local_datasource.dart
│   │   │   │   └── units_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── unit_model.dart
│   │   │   │   ├── unit_type_model.dart
│   │   │   │   ├── unit_field_value_model.dart
│   │   │   │   ├── money_model.dart
│   │   │   │   └── pricing_method_model.dart
│   │   │   └── repositories/
│   │   │       └── units_repository_impl.dart
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── unit.dart
│   │   │   │   ├── unit_type.dart
│   │   │   │   ├── unit_field_value.dart
│   │   │   │   ├── money.dart
│   │   │   │   └── pricing_method.dart
│   │   │   ├── repositories/
│   │   │   │   └── units_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_units_usecase.dart
│   │   │       ├── get_unit_details_usecase.dart
│   │   │       ├── create_unit_usecase.dart
│   │   │       ├── update_unit_usecase.dart
│   │   │       ├── delete_unit_usecase.dart
│   │   │       ├── get_unit_types_by_property_usecase.dart
│   │   │       ├── get_unit_fields_usecase.dart
│   │   │       └── assign_unit_to_sections_usecase.dart
│   │   │
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── units_list/
│   │       │   │   ├── units_list_bloc.dart
│   │       │   │   ├── units_list_event.dart
│   │       │   │   └── units_list_state.dart
│   │       │   ├── unit_form/
│   │       │   │   ├── unit_form_bloc.dart
│   │       │   │   ├── unit_form_event.dart
│   │       │   │   └── unit_form_state.dart
│   │       │   └── unit_details/
│   │       │       ├── unit_details_bloc.dart
│   │       │       ├── unit_details_event.dart
│   │       │       └── unit_details_state.dart
│   │       ├── pages/
│   │       │   ├── units_list_page.dart
│   │       │   ├── unit_details_page.dart
│   │       │   ├── create_unit_page.dart
│   │       │   ├── edit_unit_page.dart
│   │       │   └── unit_gallery_page.dart
│   │       └── widgets/
│   │           ├── futuristic_unit_card.dart
│   │           ├── futuristic_units_table.dart
│   │           ├── futuristic_unit_map_view.dart
│   │           ├── unit_form_widget.dart
│   │           ├── dynamic_fields_widget.dart
│   │           ├── capacity_selector_widget.dart
│   │           ├── pricing_form_widget.dart
│   │           ├── features_tags_widget.dart
│   │           ├── unit_filters_widget.dart
│   │           ├── unit_stats_card.dart
│   │           └── assign_sections_modal.dart
│   │ 
│   │   
│   ├── admin_amenities/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── amenities_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── amenity_model.dart
│   │   │   └── repositories/
│   │   │       └── amenities_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── amenity.dart
│   │   │   ├── repositories/
│   │   │   │   └── amenities_repository.dart
│   │   │   └── usecases/
│   │   │       ├── create_amenity_usecase.dart
│   │   │       ├── update_amenity_usecase.dart
│   │   │       ├── delete_amenity_usecase.dart
│   │   │       ├── get_all_amenities_usecase.dart
│   │   │       └── assign_amenity_to_property_usecase.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── amenities_bloc.dart
│   │       │   ├── amenities_event.dart
│   │       │   └── amenities_state.dart
│   │       ├── pages/
│   │       │   └── amenities_management_page.dart
│   │       ├── utils/
│   │       │   └── amenity_icons.dart
│   │       └── widgets/
│   │           ├── futuristic_amenity_card.dart
│   │           ├── futuristic_amenities_table.dart
│   │           ├── amenity_form_dialog.dart
│   │           ├── amenity_filters_widget.dart
│   │           └── amenity_stats_card.dart
│   │ 
│   │ 
│   ├── admin_services/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── services_local_datasource.dart
│   │   │   │   └── services_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── service_model.dart
│   │   │   │   ├── service_details_model.dart
│   │   │   │   ├── money_model.dart
│   │   │   │   └── pricing_model.dart
│   │   │   └── repositories/
│   │   │       └── services_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── service.dart
│   │   │   │   ├── service_details.dart
│   │   │   │   ├── money.dart
│   │   │   │   └── pricing_model.dart
│   │   │   ├── repositories/
│   │   │   │   └── services_repository.dart
│   │   │   └── usecases/
│   │   │       ├── create_service_usecase.dart
│   │   │       ├── update_service_usecase.dart
│   │   │       ├── delete_service_usecase.dart
│   │   │       ├── get_services_by_property_usecase.dart
│   │   │       ├── get_service_details_usecase.dart
│   │   │       └── get_services_by_type_usecase.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── services_bloc.dart
│   │       │   ├── services_event.dart
│   │       │   └── services_state.dart
│   │       ├── pages/
│   │       │   └── admin_services_page.dart
│   │       ├── widgets/
│   │       │   ├── futuristic_service_card.dart
│   │       │   ├── futuristic_services_table.dart
│   │       │   ├── service_form_dialog.dart
│   │       │   ├── service_icon_picker.dart
│   │       │   ├── service_details_dialog.dart
│   │       │   ├── service_stats_card.dart
│   │       │   └── service_filters_widget.dart
│   │       └── utils/
│   │           └── service_icons.dart
│   │
│   ├── notifications/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├─ notification_local_datasource.dart
│   │   │   │   └─ notification_remote_datasource.dart
│   │   │   ├─ models/
│   │   │   │   └─ notification_model.dart
│   │   │   └─ repositories/
│   │   │       └─ notification_repository_impl.dart
│   │   ├── domain/
│   │   │   ├─ entities/
│   │   │   │   └─ notification.dart
│   │   │   ├─ repositories/
│   │   │   │   └─ notification_repository.dart
│   │   │   └─ usecases/
│   │   │       ├─ dismiss_notification_usecase.dart
│   │   │       ├─ get_notifications_usecase.dart
│   │   │       ├─ mark_as_read_usecase.dart
│   │   │       └─ update_notification_settings_usecase.dart
│   │   └─ presentation/
│   │       ├─ bloc/
│   │       │   ├─ notification_bloc.dart
│   │       │   ├─ notification_event.dart
│   │       │   └─ notification_state.dart
│   │       ├─ pages/
│   │       │   ├─ notification_settings_page.dart
│   │       │   └─ notifications_page.dart
│   │       └─ widgets/
│   │           ├─ notification_badge_widget.dart
│   │           ├─ notification_filter_widget.dart
│   │           └─ notification_item_widget.dart
│   │
│   └── settings/
│       ├── data/
│       │   ├── datasources/
│       │   │   └─ settings_local_datasource.dart
│       │   ├─ models/
│       │   │   └─ app_settings_model.dart
│       │   └─ repositories/
│       │       └─ settings_repository_impl.dart
│       ├─ domain/
│       │   ├─ entities/
│       │   │   └─ app_settings.dart
│       │   ├─ repositories/
│       │   │   └─ settings_repository.dart
│       │   └─ usecases/
│       │       ├─ get_settings_usecase.dart
│       │       ├─ update_language_usecase.dart
│       │       ├─ update_notification_settings_usecase.dart
│       │       └ update_theme_usecase.dart
│       └─ presentation/
│           ├─ bloc/
│           │   ├─ settings_bloc.dart
│           │   ├─ settings_event.dart
│           │   └─ settings_state.dart
│           ├─ pages/
│           │   ├─ about_page.dart
│           │   ├─ language_settings_page.dart
│           │   ├─ privacy_policy_page.dart
│           │   └─ settings_page.dart
│           └─ widgets/
│               ├─ language_selector_widget.dart
│               ├─ settings_item_widget.dart
│               └─ theme_selector_widget.dart
│
├── routes/
│   ├── app_router.dart
│   ├── route_animations.dart
│   └── route_guards.dart
│
├── services/
│   ├── analytics_service.dart
│   ├── crash_reporting_service.dart
│   ├── deep_link_service.dart
│   ├── local_storage_service.dart
│   ├── location_service.dart
│   ├── notification_service.dart
│   └─ websocket_service.dart

# ملفات إضافية مهمة


assets/
├── images/
│   ├── logo.png
│   ├── splash_screen.png
│   └── placeholders/
├── icons/
│   ├── amenity_icons/
│   └── category_icons/
├── animations/
│   ├── loading.json
│   └── success.json
└── fonts/
    ├── arabic_font.ttf
    └── english_font.ttf

# ملفات التكوين

pubspec.yaml
analysis_options.yaml
.env
.env.production

مثال عن الفيوتشرز
│   ├── favorites/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── favorites_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── favorite_property_model.dart
│   │   │   └── repositories/
│   │   │       └── favorites_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── favorite_property.dart
│   │   │   ├── repositories/
│   │   │   │   └── favorites_repository.dart
│   │   │   └── usecases/
│   │   │       ├── add_to_favorites_usecase.dart
│   │   │       ├── get_favorites_usecase.dart
│   │   │       └── remove_from_favorites_usecase.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── favorites_bloc.dart
│   │       │   ├── favorites_event.dart
│   │       │   └── favorites_state.dart
│   │       ├── pages/
│   │       │   └── favorites_page.dart
│   │       └── widgets/
│   │           ├── favorite_button_widget.dart
│   │           └── favorite_property_card_widget.dart