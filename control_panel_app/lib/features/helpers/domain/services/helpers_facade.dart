import 'package:bookn_cp_app/core/models/paginated_result.dart';
import 'package:bookn_cp_app/features/admin_users/domain/entities/user.dart';
import 'package:bookn_cp_app/features/admin_properties/domain/entities/property.dart';
import 'package:bookn_cp_app/features/admin_units/domain/entities/unit.dart';
import '../entities/search_filters.dart';
import '../usecases/helpers_usecases.dart';

class HelpersFacade {
  final SearchUsersHelper _searchUsers;
  final SearchPropertiesHelper _searchProperties;
  final SearchUnitsHelper _searchUnits;

  HelpersFacade(
    this._searchUsers,
    this._searchProperties,
    this._searchUnits,
  );

  Future<PaginatedResult<User>> searchUsers(UserSearchFilters filters) async {
    final result = await _searchUsers(filters);
    return result.fold((l) => throw Exception(l.message), (r) => r);
  }

  Future<PaginatedResult<Property>> searchProperties(PropertySearchFilters filters) async {
    final result = await _searchProperties(filters);
    return result.fold((l) => throw Exception(l.message), (r) => r);
  }

  Future<List<Unit>> searchUnits(UnitSearchFilters filters) async {
    final result = await _searchUnits(filters);
    return result.fold((l) => throw Exception(l.message), (r) => r);
  }
}

