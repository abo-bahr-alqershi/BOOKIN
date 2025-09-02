import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/models/paginated_result.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/get_all_users_usecase.dart';
import '../../../domain/usecases/create_user_usecase.dart';
import '../../../domain/usecases/assign_role_usecase.dart';
import '../../../domain/usecases/activate_user_usecase.dart';
import '../../../domain/usecases/deactivate_user_usecase.dart';

part 'users_list_event.dart';
part 'users_list_state.dart';

class UsersListBloc extends Bloc<UsersListEvent, UsersListState> {
  final GetAllUsersUseCase _getAllUsersUseCase;
  final CreateUserUseCase _createUserUseCase;
  final AssignRoleUseCase _assignRoleUseCase;
  final ActivateUserUseCase _activateUserUseCase;
  final DeactivateUserUseCase _deactivateUserUseCase;

  static const int _pageSize = 20;
  List<User> _allUsers = [];
  int _currentPage = 1;
  bool _hasMoreData = true;
  String? _lastSearchTerm;
  String? _lastRoleFilter;
  bool? _lastActiveFilter;

  UsersListBloc({
    required GetAllUsersUseCase getAllUsersUseCase,
    required ActivateUserUseCase activateUserUseCase,
    required DeactivateUserUseCase deactivateUserUseCase,
    required CreateUserUseCase createUserUseCase,
    required AssignRoleUseCase assignRoleUseCase,
  })  : _getAllUsersUseCase = getAllUsersUseCase,
        _activateUserUseCase = activateUserUseCase,
        _deactivateUserUseCase = deactivateUserUseCase,
        _createUserUseCase = createUserUseCase,
        _assignRoleUseCase = assignRoleUseCase,
        super(UsersListInitial()) {
    on<LoadUsersEvent>(_onLoadUsers);
    on<LoadMoreUsersEvent>(_onLoadMoreUsers);
    on<RefreshUsersEvent>(_onRefreshUsers);
    on<SearchUsersEvent>(_onSearchUsers);
    on<FilterUsersEvent>(_onFilterUsers);
    on<ToggleUserStatusEvent>(_onToggleUserStatus);
    on<SortUsersEvent>(_onSortUsers);
    on<CreateUserEvent>(_onCreateUser);
  }

  Future<void> _onLoadUsers(
    LoadUsersEvent event,
    Emitter<UsersListState> emit,
  ) async {
    emit(UsersListLoading());
    
    _currentPage = 1;
    _allUsers = [];
    _hasMoreData = true;
    
    final result = await _getAllUsersUseCase(
      GetAllUsersParams(
        pageNumber: _currentPage,
        pageSize: _pageSize,
      ),
    );

    result.fold(
      (failure) => emit(UsersListError(message: failure.message)),
      (paginatedResult) {
        _allUsers = paginatedResult.items;
        _hasMoreData = paginatedResult.pageNumber < paginatedResult.totalPages;
        
        emit(UsersListLoaded(
          users: _allUsers,
          hasMore: _hasMoreData,
          totalCount: paginatedResult.totalCount,
          isLoadingMore: false,
        ));
      },
    );
  }

  Future<void> _onLoadMoreUsers(
    LoadMoreUsersEvent event,
    Emitter<UsersListState> emit,
  ) async {
    if (state is! UsersListLoaded || !_hasMoreData) return;
    
    final currentState = state as UsersListLoaded;
    emit(currentState.copyWith(isLoadingMore: true));
    
    _currentPage++;
    
    final result = await _getAllUsersUseCase(
      GetAllUsersParams(
        pageNumber: _currentPage,
        pageSize: _pageSize,
        searchTerm: _lastSearchTerm,
        roleId: _lastRoleFilter,
        isActive: _lastActiveFilter,
      ),
    );

    result.fold(
      (failure) {
        _currentPage--;
        emit(currentState.copyWith(isLoadingMore: false));
      },
      (paginatedResult) {
        _allUsers.addAll(paginatedResult.items);
        _hasMoreData = paginatedResult.pageNumber < paginatedResult.totalPages;
        
        emit(UsersListLoaded(
          users: _allUsers,
          hasMore: _hasMoreData,
          totalCount: paginatedResult.totalCount,
          isLoadingMore: false,
        ));
      },
    );
  }

  Future<void> _onRefreshUsers(
    RefreshUsersEvent event,
    Emitter<UsersListState> emit,
  ) async {
    if (state is UsersListLoaded) {
      _currentPage = 1;
      _allUsers = [];
      _hasMoreData = true;
      
      final result = await _getAllUsersUseCase(
        GetAllUsersParams(
          pageNumber: _currentPage,
          pageSize: _pageSize,
          searchTerm: _lastSearchTerm,
          roleId: _lastRoleFilter,
          isActive: _lastActiveFilter,
        ),
      );

      result.fold(
        (failure) => emit(UsersListError(message: failure.message)),
        (paginatedResult) {
          _allUsers = paginatedResult.items;
          _hasMoreData = paginatedResult.pageNumber < paginatedResult.totalPages;
          
          emit(UsersListLoaded(
            users: _allUsers,
            hasMore: _hasMoreData,
            totalCount: paginatedResult.totalCount,
            isLoadingMore: false,
          ));
        },
      );
    }
  }

  Future<void> _onSearchUsers(
    SearchUsersEvent event,
    Emitter<UsersListState> emit,
  ) async {
    emit(UsersListLoading());
    
    _currentPage = 1;
    _allUsers = [];
    _hasMoreData = true;
    _lastSearchTerm = event.searchTerm;
    
    final result = await _getAllUsersUseCase(
      GetAllUsersParams(
        pageNumber: _currentPage,
        pageSize: _pageSize,
        searchTerm: event.searchTerm,
        roleId: _lastRoleFilter,
        isActive: _lastActiveFilter,
      ),
    );

    result.fold(
      (failure) => emit(UsersListError(message: failure.message)),
      (paginatedResult) {
        _allUsers = paginatedResult.items;
        _hasMoreData = paginatedResult.pageNumber < paginatedResult.totalPages;
        
        emit(UsersListLoaded(
          users: _allUsers,
          hasMore: _hasMoreData,
          totalCount: paginatedResult.totalCount,
          isLoadingMore: false,
        ));
      },
    );
  }

  Future<void> _onFilterUsers(
    FilterUsersEvent event,
    Emitter<UsersListState> emit,
  ) async {
    emit(UsersListLoading());
    
    _currentPage = 1;
    _allUsers = [];
    _hasMoreData = true;
    _lastRoleFilter = event.roleId;
    _lastActiveFilter = event.isActive;
    
    final result = await _getAllUsersUseCase(
      GetAllUsersParams(
        pageNumber: _currentPage,
        pageSize: _pageSize,
        searchTerm: _lastSearchTerm,
        roleId: event.roleId,
        isActive: event.isActive,
        createdAfter: event.createdAfter,
        createdBefore: event.createdBefore,
      ),
    );

    result.fold(
      (failure) => emit(UsersListError(message: failure.message)),
      (paginatedResult) {
        _allUsers = paginatedResult.items;
        _hasMoreData = paginatedResult.pageNumber < paginatedResult.totalPages;
        
        emit(UsersListLoaded(
          users: _allUsers,
          hasMore: _hasMoreData,
          totalCount: paginatedResult.totalCount,
          isLoadingMore: false,
        ));
      },
    );
  }

  Future<void> _onToggleUserStatus(
    ToggleUserStatusEvent event,
    Emitter<UsersListState> emit,
  ) async {
    if (state is! UsersListLoaded) return;
    
    final currentState = state as UsersListLoaded;
    
    final result = event.activate
        ? await _activateUserUseCase(ActivateUserParams(userId: event.userId))
        : await _deactivateUserUseCase(DeactivateUserParams(userId: event.userId));

    result.fold(
      (failure) {
        // Show error but keep current state
      },
      (success) {
        if (success) {
          // Update user status in the list
          final updatedUsers = _allUsers.map((user) {
            if (user.id == event.userId) {
              return user.copyWith(isActive: event.activate);
            }
            return user;
          }).toList();
          
          _allUsers = updatedUsers;
          
          emit(UsersListLoaded(
            users: _allUsers,
            hasMore: _hasMoreData,
            totalCount: currentState.totalCount,
            isLoadingMore: false,
          ));
        }
      },
    );
  }

  Future<void> _onSortUsers(
    SortUsersEvent event,
    Emitter<UsersListState> emit,
  ) async {
    emit(UsersListLoading());
    
    _currentPage = 1;
    _allUsers = [];
    _hasMoreData = true;
    
    final result = await _getAllUsersUseCase(
      GetAllUsersParams(
        pageNumber: _currentPage,
        pageSize: _pageSize,
        searchTerm: _lastSearchTerm,
        roleId: _lastRoleFilter,
        isActive: _lastActiveFilter,
        sortBy: event.sortBy,
        isAscending: event.isAscending,
      ),
    );

    result.fold(
      (failure) => emit(UsersListError(message: failure.message)),
      (paginatedResult) {
        _allUsers = paginatedResult.items;
        _hasMoreData = paginatedResult.pageNumber < paginatedResult.totalPages;
        
        emit(UsersListLoaded(
          users: _allUsers,
          hasMore: _hasMoreData,
          totalCount: paginatedResult.totalCount,
          isLoadingMore: false,
        ));
      },
    );
  }

  Future<void> _onCreateUser(
    CreateUserEvent event,
    Emitter<UsersListState> emit,
  ) async {
    // Keep UX simple: attempt to create then refresh list
    final result = await _createUserUseCase(CreateUserParams(
      name: event.name,
      email: event.email,
      password: event.password,
      phone: event.phone,
      profileImage: event.profileImage,
    ));

    await result.fold(
      (_) async {},
      (userId) async {
        if (event.roleId != null && event.roleId!.isNotEmpty) {
          await _assignRoleUseCase(AssignRoleParams(userId: userId, roleId: event.roleId!));
        }
        add(RefreshUsersEvent());
      },
    );
  }
}