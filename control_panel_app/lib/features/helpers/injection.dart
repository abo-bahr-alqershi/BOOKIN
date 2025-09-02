import 'package:get_it/get_it.dart';
import 'package:bookn_cp_app/features/admin_users/data/datasources/users_remote_datasource.dart';
import 'package:bookn_cp_app/features/admin_properties/data/datasources/properties_remote_datasource.dart';
import 'package:bookn_cp_app/features/admin_units/data/datasources/units_remote_datasource.dart';
import 'data/repositories/helpers_repository_impl.dart';
import 'domain/repositories/helpers_repository.dart';
import 'domain/usecases/helpers_usecases.dart';

void registerHelpersFeature(GetIt sl) {
  sl.registerLazySingleton<HelpersRepository>(() => HelpersRepositoryImpl(
        usersRemote: sl<UsersRemoteDataSource>(),
        propertiesRemote: sl<PropertiesRemoteDataSource>(),
        unitsRemote: sl<UnitsRemoteDataSource>(),
      ));

  sl.registerFactory(() => SearchUsersHelper(sl()));
  sl.registerFactory(() => SearchPropertiesHelper(sl()));
  sl.registerFactory(() => SearchUnitsHelper(sl()));
}

