part of 'users_list_bloc.dart';

abstract class UsersListEvent extends Equatable {
  const UsersListEvent();

  @override
  List<Object?> get props => [];
}

class LoadUsersEvent extends UsersListEvent {}

class LoadMoreUsersEvent extends UsersListEvent {}

class RefreshUsersEvent extends UsersListEvent {}

class SearchUsersEvent extends UsersListEvent {
  final String searchTerm;

  const SearchUsersEvent({required this.searchTerm});

  @override
  List<Object> get props => [searchTerm];
}

class FilterUsersEvent extends UsersListEvent {
  final String? roleId;
  final bool? isActive;
  final DateTime? createdAfter;
  final DateTime? createdBefore;

  const FilterUsersEvent({
    this.roleId,
    this.isActive,
    this.createdAfter,
    this.createdBefore,
  });

  @override
  List<Object?> get props => [roleId, isActive, createdAfter, createdBefore];
}

class ToggleUserStatusEvent extends UsersListEvent {
  final String userId;
  final bool activate;

  const ToggleUserStatusEvent({
    required this.userId,
    required this.activate,
  });

  @override
  List<Object> get props => [userId, activate];
}

class SortUsersEvent extends UsersListEvent {
  final String sortBy;
  final bool isAscending;

  const SortUsersEvent({
    required this.sortBy,
    required this.isAscending,
  });

  @override
  List<Object> get props => [sortBy, isAscending];
}

class CreateUserEvent extends UsersListEvent {
  final String name;
  final String email;
  final String password;
  final String phone;
  final String? profileImage;
  final String? role;

  const CreateUserEvent({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    this.profileImage,
    this.role,
  });

  @override
  List<Object?> get props => [name, email, password, phone, profileImage, role];
}

class DeleteUserEvent extends UsersListEvent {
  final String userId;

  const DeleteUserEvent(this.userId);

  @override
  List<Object> get props => [userId];
}