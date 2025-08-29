part of 'units_list_bloc.dart';

abstract class UnitsListState extends Equatable {
  const UnitsListState();

  @override
  List<Object?> get props => [];
}

class UnitsListInitial extends UnitsListState {}

class UnitsListLoading extends UnitsListState {}

class UnitsListLoaded extends UnitsListState {
  final List<Unit> units;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final String? searchQuery;
  final Map<String, dynamic>? filters;

  const UnitsListLoaded({
    required this.units,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
    this.searchQuery,
    this.filters,
  });

  @override
  List<Object?> get props => [
        units,
        totalCount,
        currentPage,
        pageSize,
        searchQuery,
        filters,
      ];
}

class UnitsListError extends UnitsListState {
  final String message;

  const UnitsListError({required this.message});

  @override
  List<Object?> get props => [message];
}