import 'package:get_it/get_it.dart';
import '../services/helpers_facade.dart';
import '../../helpers.dart';

HelpersFacade provideHelpersFacade(GetIt sl) {
  return HelpersFacade(
    sl(), // SearchUsersHelper
    sl(), // SearchPropertiesHelper
    sl(), // SearchUnitsHelper
  );
}

