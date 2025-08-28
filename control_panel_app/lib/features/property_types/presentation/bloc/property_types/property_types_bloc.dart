import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/property_types/get_all_property_types_usecase.dart';
import '../../../domain/usecases/property_types/create_property_type_usecase.dart';
import '../../../domain/usecases/property_types/update_property_type_usecase.dart';
import '../../../domain/usecases/property_types/delete_property_type_usecase.dart';
import 'property_types_event.dart';
import 'property_types_state.dart';

class PropertyTypesBloc extends Bloc<PropertyTypesEvent, PropertyTypesState> {
  final GetAllPropertyTypesUseCase getAllPropertyTypes;
  final CreatePropertyTypeUseCase createPropertyType;
  final UpdatePropertyTypeUseCase updatePropertyType;
  final DeletePropertyTypeUseCase deletePropertyType;

  PropertyTypesBloc({
    required this.getAllPropertyTypes,
    required this.createPropertyType,
    required this.updatePropertyType,
    required this.deletePropertyType,
  }) : super(PropertyTypesInitial()) {
    on<LoadPropertyTypesEvent>(_onLoadPropertyTypes);
    on<CreatePropertyTypeEvent>(_onCreatePropertyType);
    on<UpdatePropertyTypeEvent>(_onUpdatePropertyType);
    on<DeletePropertyTypeEvent>(_onDeletePropertyType);
    on<SelectPropertyTypeEvent>(_onSelectPropertyType);
  }

  Future<void> _onLoadPropertyTypes(
    LoadPropertyTypesEvent event,
    Emitter<PropertyTypesState> emit,
  ) async {
    emit(PropertyTypesLoading());
    
    final result = await getAllPropertyTypes(
      GetAllPropertyTypesParams(
        pageNumber: event.pageNumber,
        pageSize: event.pageSize,
      ),
    );
    
    result.fold(
      (failure) => emit(PropertyTypesError(message: failure.message)),
      (paginatedResult) => emit(PropertyTypesLoaded(
        propertyTypes: paginatedResult.items,
        totalCount: paginatedResult.totalCount,
        currentPage: paginatedResult.currentPage,
      )),
    );
  }

  Future<void> _onCreatePropertyType(
    CreatePropertyTypeEvent event,
    Emitter<PropertyTypesState> emit,
  ) async {
    final currentState = state;
    emit(PropertyTypeOperationLoading());
    
    final result = await createPropertyType(
      CreatePropertyTypeParams(
        name: event.name,
        description: event.description,
        defaultAmenities: event.defaultAmenities,
        icon: event.icon,
      ),
    );
    
    result.fold(
      (failure) {
        emit(PropertyTypeOperationError(message: failure.message));
        if (currentState is PropertyTypesLoaded) {
          emit(currentState);
        }
      },
      (_) {
        emit(const PropertyTypeOperationSuccess(message: 'تم إضافة نوع الكيان بنجاح'));
        add(const LoadPropertyTypesEvent());
      },
    );
  }

  Future<void> _onUpdatePropertyType(
    UpdatePropertyTypeEvent event,
    Emitter<PropertyTypesState> emit,
  ) async {
    final currentState = state;
    emit(PropertyTypeOperationLoading());
    
    final result = await updatePropertyType(
      UpdatePropertyTypeParams(
        propertyTypeId: event.propertyTypeId,
        name: event.name,
        description: event.description,
        defaultAmenities: event.defaultAmenities,
        icon: event.icon,
      ),
    );
    
    result.fold(
      (failure) {
        emit(PropertyTypeOperationError(message: failure.message));
        if (currentState is PropertyTypesLoaded) {
          emit(currentState);
        }
      },
      (_) {
        emit(const PropertyTypeOperationSuccess(message: 'تم تحديث نوع الكيان بنجاح'));
        add(const LoadPropertyTypesEvent());
      },
    );
  }

  Future<void> _onDeletePropertyType(
    DeletePropertyTypeEvent event,
    Emitter<PropertyTypesState> emit,
  ) async {
    final currentState = state;
    emit(PropertyTypeOperationLoading());
    
    final result = await deletePropertyType(event.propertyTypeId);
    
    result.fold(
      (failure) {
        emit(PropertyTypeOperationError(message: failure.message));
        if (currentState is PropertyTypesLoaded) {
          emit(currentState);
        }
      },
      (_) {
        emit(const PropertyTypeOperationSuccess(message: 'تم حذف نوع الكيان بنجاح'));
        add(const LoadPropertyTypesEvent());
      },
    );
  }

  void _onSelectPropertyType(
    SelectPropertyTypeEvent event,
    Emitter<PropertyTypesState> emit,
  ) {
    if (state is PropertyTypesLoaded) {
      final loadedState = state as PropertyTypesLoaded;
      
      if (event.propertyTypeId == null) {
        emit(loadedState.copyWith(clearSelection: true));
      } else {
        final selectedType = loadedState.propertyTypes.firstWhere(
          (type) => type.id == event.propertyTypeId,
          orElse: () => loadedState.propertyTypes.first,
        );
        emit(loadedState.copyWith(selectedPropertyType: selectedType));
      }
    }
  }
}