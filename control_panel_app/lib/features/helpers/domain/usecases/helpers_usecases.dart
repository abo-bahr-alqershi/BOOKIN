import 'package:dartz/dartz.dart';
import 'package:bookn_cp_app/core/error/failures.dart';
import 'package:bookn_cp_app/core/models/paginated_result.dart';
import 'package:bookn_cp_app/core/usecases/usecase.dart';
import 'package:bookn_cp_app/features/admin_properties/domain/entities/property.dart';
import 'package:bookn_cp_app/features/admin_users/domain/entities/user.dart';
import 'package:bookn_cp_app/features/admin_units/domain/entities/unit.dart';
import '../entities/search_filters.dart';
import '../repositories/helpers_repository.dart';

class SearchUsersHelper implements UseCase<PaginatedResult<User>, UserSearchFilters> {
  final HelpersRepository repository;
  SearchUsersHelper(this.repository);
  @override
  Future<Either<Failure, PaginatedResult<User>>> call(UserSearchFilters params) {
    return repository.searchUsers(params).then(Right.new).catchError((e) => Left(_mapError(e)));
  }
}

class SearchPropertiesHelper implements UseCase<PaginatedResult<Property>, PropertySearchFilters> {
  final HelpersRepository repository;
  SearchPropertiesHelper(this.repository);
  @override
  Future<Either<Failure, PaginatedResult<Property>>> call(PropertySearchFilters params) {
    return repository.searchProperties(params).then(Right.new).catchError((e) => Left(_mapError(e)));
  }
}

class SearchUnitsHelper implements UseCase<List<Unit>, UnitSearchFilters> {
  final HelpersRepository repository;
  SearchUnitsHelper(this.repository);
  @override
  Future<Either<Failure, List<Unit>>> call(UnitSearchFilters params) {
    return repository.searchUnits(params).then(Right.new).catchError((e) => Left(_mapError(e)));
  }
}

Failure _mapError(Object e) {
  if (e is Failure) return e;
  return ServerFailure(e.toString());
}

