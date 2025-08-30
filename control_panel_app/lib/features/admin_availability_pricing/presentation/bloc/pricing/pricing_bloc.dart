// lib/features/admin_availability_pricing/presentation/bloc/pricing/pricing_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/pricing_rule.dart';
import '../../../domain/entities/seasonal_pricing.dart';
import '../../../domain/usecases/pricing/get_monthly_pricing_usecase.dart';
import '../../../domain/usecases/pricing/update_pricing_usecase.dart';
import '../../../domain/usecases/pricing/bulk_update_pricing_usecase.dart';
import '../../../domain/usecases/pricing/apply_seasonal_pricing_usecase.dart';

part 'pricing_event.dart';
part 'pricing_state.dart';

class PricingBloc extends Bloc<PricingEvent, PricingState> {
  final GetMonthlyPricingUseCase getMonthlyPricingUseCase;
  final UpdatePricingUseCase updatePricingUseCase;
  final BulkUpdatePricingUseCase bulkUpdatePricingUseCase;
  final ApplySeasonalPricingUseCase applySeasonalPricingUseCase;

  PricingBloc({
    required this.getMonthlyPricingUseCase,
    required this.updatePricingUseCase,
    required this.bulkUpdatePricingUseCase,
    required this.applySeasonalPricingUseCase,
  }) : super(PricingInitial()) {
    on<LoadMonthlyPricing>(_onLoadMonthlyPricing);
    on<UpdatePricing>(_onUpdatePricing);
    on<BulkUpdatePricing>(_onBulkUpdatePricing);
    on<ApplySeasonalPricing>(_onApplySeasonalPricing);
    on<SelectPricingUnit>(_onSelectUnit);
    on<ChangePricingMonth>(_onChangeMonth);
  }

  Future<void> _onLoadMonthlyPricing(
    LoadMonthlyPricing event,
    Emitter<PricingState> emit,
  ) async {
    emit(PricingLoading());
    
    final result = await getMonthlyPricingUseCase(
      GetMonthlyPricingParams(
        unitId: event.unitId,
        year: event.year,
        month: event.month,
      ),
    );
    
    result.fold(
      (failure) => emit(PricingError(failure.message)),
      (unitPricing) => emit(PricingLoaded(
        unitPricing: unitPricing,
        selectedUnitId: event.unitId,
        currentYear: event.year,
        currentMonth: event.month,
      )),
    );
  }

  Future<void> _onUpdatePricing(
    UpdatePricing event,
    Emitter<PricingState> emit,
  ) async {
    if (state is PricingLoaded) {
      final currentState = state as PricingLoaded;
      emit(PricingUpdating(
        unitPricing: currentState.unitPricing,
        selectedUnitId: currentState.selectedUnitId,
        currentYear: currentState.currentYear,
        currentMonth: currentState.currentMonth,
      ));
      
      final result = await updatePricingUseCase(event.params);
      
      result.fold(
        (failure) => emit(PricingError(failure.message)),
        (_) {
          add(LoadMonthlyPricing(
            unitId: currentState.selectedUnitId,
            year: currentState.currentYear,
            month: currentState.currentMonth,
          ));
        },
      );
    }
  }

  Future<void> _onBulkUpdatePricing(
    BulkUpdatePricing event,
    Emitter<PricingState> emit,
  ) async {
    if (state is PricingLoaded) {
      final currentState = state as PricingLoaded;
      emit(PricingUpdating(
        unitPricing: currentState.unitPricing,
        selectedUnitId: currentState.selectedUnitId,
        currentYear: currentState.currentYear,
        currentMonth: currentState.currentMonth,
      ));
      
      final result = await bulkUpdatePricingUseCase(event.params);
      
      result.fold(
        (failure) => emit(PricingError(failure.message)),
        (_) {
          add(LoadMonthlyPricing(
            unitId: currentState.selectedUnitId,
            year: currentState.currentYear,
            month: currentState.currentMonth,
          ));
        },
      );
    }
  }

  Future<void> _onApplySeasonalPricing(
    ApplySeasonalPricing event,
    Emitter<PricingState> emit,
  ) async {
    if (state is PricingLoaded) {
      final currentState = state as PricingLoaded;
      emit(PricingUpdating(
        unitPricing: currentState.unitPricing,
        selectedUnitId: currentState.selectedUnitId,
        currentYear: currentState.currentYear,
        currentMonth: currentState.currentMonth,
      ));
      
      final result = await applySeasonalPricingUseCase(event.params);
      
      result.fold(
        (failure) => emit(PricingError(failure.message)),
        (_) {
          add(LoadMonthlyPricing(
            unitId: currentState.selectedUnitId,
            year: currentState.currentYear,
            month: currentState.currentMonth,
          ));
        },
      );
    }
  }

  void _onSelectUnit(
    SelectPricingUnit event,
    Emitter<PricingState> emit,
  ) {
    if (state is PricingLoaded) {
      final currentState = state as PricingLoaded;
      add(LoadMonthlyPricing(
        unitId: event.unitId,
        year: currentState.currentYear,
        month: currentState.currentMonth,
      ));
    }
  }

  void _onChangeMonth(
    ChangePricingMonth event,
    Emitter<PricingState> emit,
  ) {
    if (state is PricingLoaded) {
      final currentState = state as PricingLoaded;
      add(LoadMonthlyPricing(
        unitId: currentState.selectedUnitId,
        year: event.year,
        month: event.month,
      ));
    }
  }
}