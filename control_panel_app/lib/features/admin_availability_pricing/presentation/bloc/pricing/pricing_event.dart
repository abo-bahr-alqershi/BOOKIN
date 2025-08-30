// lib/features/admin_availability_pricing/presentation/bloc/pricing/pricing_event.dart

part of 'pricing_bloc.dart';

abstract class PricingEvent extends Equatable {
  const PricingEvent();

  @override
  List<Object?> get props => [];
}

class LoadMonthlyPricing extends PricingEvent {
  final String unitId;
  final int year;
  final int month;

  const LoadMonthlyPricing({
    required this.unitId,
    required this.year,
    required this.month,
  });

  @override
  List<Object> get props => [unitId, year, month];
}

class UpdatePricing extends PricingEvent {
  final UpdatePricingParams params;

  const UpdatePricing({required this.params});

  @override
  List<Object> get props => [params];
}

class BulkUpdatePricing extends PricingEvent {
  final BulkUpdatePricingParams params;

  const BulkUpdatePricing({required this.params});

  @override
  List<Object> get props => [params];
}

class ApplySeasonalPricing extends PricingEvent {
  final ApplySeasonalPricingParams params;

  const ApplySeasonalPricing({required this.params});

  @override
  List<Object> get props => [params];
}

class SelectPricingUnit extends PricingEvent {
  final String unitId;

  const SelectPricingUnit({required this.unitId});

  @override
  List<Object> get props => [unitId];
}

class ChangePricingMonth extends PricingEvent {
  final int year;
  final int month;

  const ChangePricingMonth({required this.year, required this.month});

  @override
  List<Object> get props => [year, month];
}