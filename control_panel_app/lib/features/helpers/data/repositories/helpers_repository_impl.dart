import 'package:bookn_cp_app/core/models/paginated_result.dart';
import 'package:bookn_cp_app/features/admin_properties/data/datasources/properties_remote_datasource.dart';
import 'package:bookn_cp_app/features/admin_properties/data/models/property_model.dart';
import 'package:bookn_cp_app/features/admin_properties/domain/entities/property.dart';
import 'package:bookn_cp_app/features/admin_units/data/datasources/units_remote_datasource.dart';
import 'package:bookn_cp_app/features/admin_units/data/models/unit_model.dart';
import 'package:bookn_cp_app/features/admin_units/domain/entities/unit.dart';
import 'package:bookn_cp_app/features/admin_users/data/datasources/users_remote_datasource.dart';
import 'package:bookn_cp_app/features/admin_users/data/models/user_model.dart';
import 'package:bookn_cp_app/features/admin_users/domain/entities/user.dart';
import '../../domain/entities/search_filters.dart';
import '../../domain/repositories/helpers_repository.dart';

class HelpersRepositoryImpl implements HelpersRepository {
  final UsersRemoteDataSource usersRemote;
  final PropertiesRemoteDataSource propertiesRemote;
  final UnitsRemoteDataSource unitsRemote;

  HelpersRepositoryImpl({
    required this.usersRemote,
    required this.propertiesRemote,
    required this.unitsRemote,
  });

  @override
  Future<PaginatedResult<User>> searchUsers(UserSearchFilters f) async {
    final result = await usersRemote.getAllUsers(
      pageNumber: f.pageNumber,
      pageSize: f.pageSize,
      searchTerm: f.searchTerm,
      sortBy: f.sortBy,
      isAscending: f.isAscending,
      roleId: f.roleId,
      isActive: f.isActive,
      createdAfter: f.createdAfter,
      createdBefore: f.createdBefore,
      lastLoginAfter: f.lastLoginAfter,
      loyaltyTier: f.loyaltyTier,
      minTotalSpent: f.minTotalSpent,
    );
    return result as PaginatedResult<User>;
  }

  @override
  Future<PaginatedResult<Property>> searchProperties(PropertySearchFilters f) async {
    final result = await propertiesRemote.getAllProperties(
      pageNumber: f.pageNumber,
      pageSize: f.pageSize,
      searchTerm: f.searchTerm,
      propertyTypeId: f.propertyTypeId,
      minPrice: f.minPrice,
      maxPrice: f.maxPrice,
      sortBy: f.sortBy,
      isAscending: f.isAscending,
      amenityIds: f.amenityIds,
      starRatings: f.starRatings,
      minAverageRating: f.minAverageRating,
      isApproved: f.isApproved,
      hasActiveBookings: f.hasActiveBookings,
    );
    return result as PaginatedResult<Property>;
  }

  @override
  Future<List<Unit>> searchUnits(UnitSearchFilters f) async {
    final result = await unitsRemote.getUnits(
      pageNumber: f.pageNumber,
      pageSize: f.pageSize,
      propertyId: f.propertyId,
      unitTypeId: f.unitTypeId,
      isAvailable: f.isAvailable,
      minPrice: f.minPrice,
      maxPrice: f.maxPrice,
      searchQuery: f.searchQuery,
    );
    return result.map<Unit>((e) => e as Unit).toList();
  }
}

