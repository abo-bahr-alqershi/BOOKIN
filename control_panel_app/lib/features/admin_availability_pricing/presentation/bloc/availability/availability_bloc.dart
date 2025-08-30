// lib/features/admin_availability_pricing/presentation/bloc/availability/availability_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/unit_availability.dart';
import '../../../domain/entities/availability.dart';
import '../../../domain/entities/booking_conflict.dart';
import '../../../domain/usecases/availability/get_monthly_availability_usecase.dart';
import '../../../domain/usecases/availability/update_availability_usecase.dart';
import '../../../domain/usecases/availability/bulk_update_availability_usecase.dart';
import '../../../domain/usecases/availability/check_availability_usecase.dart';
import '../../../domain/repositories/availability_repository.dart' as availability_repo;

part 'availability_event.dart';
part 'availability_state.dart';

class AvailabilityBloc extends Bloc<AvailabilityEvent, AvailabilityState> {
  final GetMonthlyAvailabilityUseCase getMonthlyAvailabilityUseCase;
  final UpdateAvailabilityUseCase updateAvailabilityUseCase;
  final BulkUpdateAvailabilityUseCase bulkUpdateAvailabilityUseCase;
  final CheckAvailabilityUseCase checkAvailabilityUseCase;

  AvailabilityBloc({
    required this.getMonthlyAvailabilityUseCase,
    required this.updateAvailabilityUseCase,
    required this.bulkUpdateAvailabilityUseCase,
    required this.checkAvailabilityUseCase,
  }) : super(AvailabilityInitial()) {
    on<LoadMonthlyAvailability>(_onLoadMonthlyAvailability);
    on<UpdateAvailability>(_onUpdateAvailability);
    on<BulkUpdateAvailability>(_onBulkUpdateAvailability);
    on<CheckAvailability>(_onCheckAvailability);
    on<SelectUnit>(_onSelectUnit);
    on<ChangeMonth>(_onChangeMonth);
  }

  Future<void> _onLoadMonthlyAvailability(
    LoadMonthlyAvailability event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(AvailabilityLoading());
    
    final result = await getMonthlyAvailabilityUseCase(
      GetMonthlyAvailabilityParams(
        unitId: event.unitId,
        year: event.year,
        month: event.month,
      ),
    );
    
    result.fold(
      (failure) => emit(AvailabilityError(failure.message)),
      (unitAvailability) => emit(AvailabilityLoaded(
        unitAvailability: unitAvailability,
        selectedUnitId: event.unitId,
        currentYear: event.year,
        currentMonth: event.month,
      )),
    );
  }

  Future<void> _onUpdateAvailability(
    UpdateAvailability event,
    Emitter<AvailabilityState> emit,
  ) async {
    if (state is AvailabilityLoaded) {
      final currentState = state as AvailabilityLoaded;
      emit(AvailabilityUpdating(
        unitAvailability: currentState.unitAvailability,
        selectedUnitId: currentState.selectedUnitId,
        currentYear: currentState.currentYear,
        currentMonth: currentState.currentMonth,
      ));
      
      final result = await updateAvailabilityUseCase(
        UpdateAvailabilityParams(availability: event.availability),
      );
      
      result.fold(
        (failure) => emit(AvailabilityError(failure.message)),
        (_) {
          // Reload the monthly availability after successful update
          add(LoadMonthlyAvailability(
            unitId: currentState.selectedUnitId,
            year: currentState.currentYear,
            month: currentState.currentMonth,
          ));
        },
      );
    }
  }

  Future<void> _onBulkUpdateAvailability(
    BulkUpdateAvailability event,
    Emitter<AvailabilityState> emit,
  ) async {
    if (state is AvailabilityLoaded) {
      final currentState = state as AvailabilityLoaded;
      emit(AvailabilityUpdating(
        unitAvailability: currentState.unitAvailability,
        selectedUnitId: currentState.selectedUnitId,
        currentYear: currentState.currentYear,
        currentMonth: currentState.currentMonth,
      ));
      
      final result = await bulkUpdateAvailabilityUseCase(
        BulkUpdateAvailabilityParams(
          unitId: event.unitId,
          periods: event.periods
              .map((p) => availability_repo.AvailabilityPeriod(
                    startDate: p.startDate,
                    endDate: p.endDate,
                    status: p.status,
                    reason: p.reason,
                    notes: p.notes,
                    overwriteExisting: p.overwriteExisting,
                  ))
              .toList(),
          overwriteExisting: event.overwriteExisting,
        ),
      );
      
      result.fold(
        (failure) => emit(AvailabilityError(failure.message)),
        (_) {
          // Reload the monthly availability after successful update
          add(LoadMonthlyAvailability(
            unitId: currentState.selectedUnitId,
            year: currentState.currentYear,
            month: currentState.currentMonth,
          ));
        },
      );
    }
  }

  Future<void> _onCheckAvailability(
    CheckAvailability event,
    Emitter<AvailabilityState> emit,
  ) async {
    final result = await checkAvailabilityUseCase(
      CheckAvailabilityParams(
        unitId: event.unitId,
        checkIn: event.checkIn,
        checkOut: event.checkOut,
        adults: event.adults,
        children: event.children,
        includePricing: event.includePricing,
      ),
    );
    
    result.fold(
      (failure) => emit(AvailabilityError(failure.message)),
      (response) {
        if (state is AvailabilityLoaded) {
          final currentState = state as AvailabilityLoaded;
          emit(currentState.copyWith(
            availabilityCheckResponse: response,
          ));
        }
      },
    );
  }

  void _onSelectUnit(
    SelectUnit event,
    Emitter<AvailabilityState> emit,
  ) {
    if (state is AvailabilityLoaded) {
      final currentState = state as AvailabilityLoaded;
      add(LoadMonthlyAvailability(
        unitId: event.unitId,
        year: currentState.currentYear,
        month: currentState.currentMonth,
      ));
    }
  }

  void _onChangeMonth(
    ChangeMonth event,
    Emitter<AvailabilityState> emit,
  ) {
    if (state is AvailabilityLoaded) {
      final currentState = state as AvailabilityLoaded;
      add(LoadMonthlyAvailability(
        unitId: currentState.selectedUnitId,
        year: event.year,
        month: event.month,
      ));
    }
  }
}