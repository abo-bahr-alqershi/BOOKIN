import 'package:bookn_cp_app/core/models/paginated_result.dart';
import 'package:bookn_cp_app/features/admin_properties/domain/entities/property.dart';
import 'package:bookn_cp_app/features/admin_users/domain/entities/user.dart';
import 'package:bookn_cp_app/features/admin_units/domain/entities/unit.dart';
import '../entities/search_filters.dart';

abstract class HelpersRepository {
  Future<PaginatedResult<User>> searchUsers(UserSearchFilters filters);
  Future<PaginatedResult<Property>> searchProperties(PropertySearchFilters filters);
  Future<List<Unit>> searchUnits(UnitSearchFilters filters);
}

