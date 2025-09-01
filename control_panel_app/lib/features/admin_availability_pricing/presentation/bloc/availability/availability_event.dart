// lib/features/admin_availability_pricing/presentation/bloc/availability/availability_event.dart

part of 'availability_bloc.dart';

abstract class AvailabilityEvent extends Equatable {
  const AvailabilityEvent();

  @override
  List<Object?> get props => [];
}

class LoadMonthlyAvailability extends AvailabilityEvent {
  final String unitId;
  final int year;
  final int month;

  const LoadMonthlyAvailability({
    required this.unitId,
    required this.year,
    required this.month,
  });

  @override
  List<Object> get props => [unitId, year, month];
}

class UpdateAvailability extends AvailabilityEvent {
  final UnitAvailabilityEntry availability;

  const UpdateAvailability({required this.availability});

  @override
  List<Object> get props => [availability];
}

class BulkUpdateAvailability extends AvailabilityEvent {
  final String unitId;
  final List<AvailabilityPeriod> periods;
  final bool overwriteExisting;

  const BulkUpdateAvailability({
    required this.unitId,
    required this.periods,
    required this.overwriteExisting,
  });

  @override
  List<Object> get props => [unitId, periods, overwriteExisting];
}

class CheckAvailability extends AvailabilityEvent {
  final String unitId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int? adults;
  final int? children;
  final bool? includePricing;

  const CheckAvailability({
    required this.unitId,
    required this.checkIn,
    required this.checkOut,
    this.adults,
    this.children,
    this.includePricing,
  });

  @override
  List<Object?> get props => [unitId, checkIn, checkOut, adults, children, includePricing];
}

class SelectUnit extends AvailabilityEvent {
  final String unitId;

  const SelectUnit({required this.unitId});

  @override
  List<Object> get props => [unitId];
}

class ChangeMonth extends AvailabilityEvent {
  final int year;
  final int month;

  const ChangeMonth({required this.year, required this.month});

  @override
  List<Object> get props => [year, month];
}