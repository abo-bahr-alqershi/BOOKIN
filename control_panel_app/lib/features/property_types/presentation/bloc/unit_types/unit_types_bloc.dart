import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/unit_types/get_unit_types_by_property_usecase.dart';
import '../../../domain/usecases/unit_types/create_unit_type_usecase.dart';
import '../../../domain/usecases/unit_types/update_unit_type_usecase.dart';
import '../../../domain/usecases/unit_types/delete_unit_type_usecase.dart';
import 'unit_types_event.dart';
import 'unit_types_state.dart';

class UnitTypesBloc extends Bloc<UnitTypesEvent, UnitTypesState> {
  final GetUnitTypesByPropertyUseCase getUnitTypesByProperty;
  final CreateUnitTypeUseCase createUnitType;
  final UpdateUnitTypeUseCase updateUnitType;
  final DeleteUnitTypeUseCase deleteUnitType;

  String? _currentPropertyTypeId;

  UnitTypesBloc({
    required this.getUnitTypesByProperty,
    required this.createUnitType,
    required this.updateUnitType,
    required this.deleteUnitType,
  }) : super(UnitTypesInitial()) {
    on<LoadUnitTypesEvent>(_onLoadUnitTypes);
    on<CreateUnitTypeEvent>(_onCreateUnitType);
    on<UpdateUnitTypeEvent>(_onUpdateUnitType);
    on<DeleteUnitTypeEvent>(_onDeleteUnitType);
    on<SelectUnitTypeEvent>(_onSelectUnitType);
  }

  Future<void> _onLoadUnitTypes(
    LoadUnitTypesEvent event,
    Emitter<UnitTypesState> emit,
  ) async {
    emit(UnitTypesLoading());
    _currentPropertyTypeId = event.propertyTypeId;
    
    final result = await getUnitTypesByProperty(
      GetUnitTypesByPropertyParams(
        propertyTypeId: event.propertyTypeId,
        pageNumber: event.pageNumber,
        pageSize: event.pageSize,
      ),
    );
    
    result.fold(
      (failure) => emit(UnitTypesError(message: failure.message)),
      (paginatedResult) => emit(UnitTypesLoaded(
        unitTypes: paginatedResult.items,
        totalCount: paginatedResult.totalCount,
        currentPage: paginatedResult.currentPage,
      )),
    );
  }

  Future<void> _onCreateUnitType(
    CreateUnitTypeEvent event,
    Emitter<UnitTypesState> emit,
  ) async {
    final currentState = state;
    
    final result = await createUnitType(
      CreateUnitTypeParams(
        propertyTypeId: event.propertyTypeId,
        name: event.name,
        maxCapacity: event.maxCapacity,
        icon: event.icon,
        isHasAdults: event.isHasAdults,
        isHasChildren: event.isHasChildren,
        isMultiDays: event.isMultiDays,
        isRequiredToDetermineTheHour: event.isRequiredToDetermineTheHour,
      ),
    );
    
    result.fold(
      (failure) {
        emit(UnitTypesError(message: failure.message));
        if (currentState is UnitTypesLoaded) {
          emit(currentState);
        }
      },
      (_) {
        if (_currentPropertyTypeId != null) {
          add(LoadUnitTypesEvent(propertyTypeId: _currentPropertyTypeId!));
        }
      },
    );
  }

  Future<void> _onUpdateUnitType(
    UpdateUnitTypeEvent event,
    Emitter<UnitTypesState> emit,
  ) async {
    final currentState = state;
    
    final result = await updateUnitType(
      UpdateUnitTypeParams(
        unitTypeId: event.unitTypeId,
        name: event.name,
        maxCapacity: event.maxCapacity,
        icon: event.icon,
        isHasAdults: event.isHasAdults,
        isHasChildren: event.isHasChildren,
        isMultiDays: event.isMultiDays,
        isRequiredToDetermineTheHour: event.isRequiredToDetermineTheHour,
      ),
    );
    
    result.fold(
      (failure) {
        emit(UnitTypesError(message: failure.message));
        if (currentState is UnitTypesLoaded) {
          emit(currentState);
        }
      },
      (_) {
        if (_currentPropertyTypeId != null) {
          add(LoadUnitTypesEvent(propertyTypeId: _currentPropertyTypeId!));
        }
      },
    );
  }

  Future<void> _onDeleteUnitType(
    DeleteUnitTypeEvent event,
    Emitter<UnitTypesState> emit,
  ) async {
    final currentState = state;
    
    final result = await deleteUnitType(event.unitTypeId);
    
    result.fold(
      (failure) {
        emit(UnitTypesError(message: failure.message));
        if (currentState is UnitTypesLoaded) {
          emit(currentState);
        }
      },
      (_) {
        if (_currentPropertyTypeId != null) {
          add(LoadUnitTypesEvent(propertyTypeId: _currentPropertyTypeId!));
        }
      },
    );
  }

  void _onSelectUnitType(
    SelectUnitTypeEvent event,
    Emitter<UnitTypesState> emit,
  ) {
    if (state is UnitTypesLoaded) {
      final loadedState = state as UnitTypesLoaded;
      
      if (event.unitTypeId == null) {
        emit(loadedState.copyWith(clearSelection: true));
      } else {
        final selectedType = loadedState.unitTypes.firstWhere(
          (type) => type.id == event.unitTypeId,
          orElse: () => loadedState.unitTypes.first,
        );
        emit(loadedState.copyWith(selectedUnitType: selectedType));
      }
    }
  }
}