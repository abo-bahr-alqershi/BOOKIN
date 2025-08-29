part of 'units_list_bloc.dart';

abstract class UnitsListEvent extends Equatable {
  const UnitsListEvent();

  @override
  List<Object?> get props => [];
}

class LoadUnitsEvent extends UnitsListEvent {
  final int? pageNumber;
  final int? pageSize;

  const LoadUnitsEvent({
    this.pageNumber,
    this.pageSize,
  });

  @override
  List<Object?> get props => [pageNumber, pageSize];
}

class SearchUnitsEvent extends UnitsListEvent {
  final String query;

  const SearchUnitsEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

class FilterUnitsEvent extends UnitsListEvent {
  final Map<String, dynamic> filters;

  const FilterUnitsEvent({required this.filters});

  @override
  List<Object?> get props => [filters];
}

class DeleteUnitEvent extends UnitsListEvent {
  final String unitId;

  const DeleteUnitEvent({required this.unitId});

  @override
  List<Object?> get props => [unitId];
}

class RefreshUnitsEvent extends UnitsListEvent {}