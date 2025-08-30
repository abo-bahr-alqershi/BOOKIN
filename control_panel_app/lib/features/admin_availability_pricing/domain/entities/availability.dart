// lib/features/admin_availability_pricing/domain/entities/availability.dart

import 'package:equatable/equatable.dart';

enum AvailabilityStatus {
  available,
  unavailable,
  maintenance,
  blocked,
  booked,
}

enum UnavailabilityReason {
  maintenance,
  vacation,
  privateBooking,
  renovation,
  other,
}

class Availability extends Equatable {
  final String? availabilityId;
  final String unitId;
  final DateTime startDate;
  final DateTime endDate;
  final String? startTime;
  final String? endTime;
  final AvailabilityStatus status;
  final UnavailabilityReason? reason;
  final String? notes;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Availability({
    this.availabilityId,
    required this.unitId,
    required this.startDate,
    required this.endDate,
    this.startTime,
    this.endTime,
    required this.status,
    this.reason,
    this.notes,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  Availability copyWith({
    String? availabilityId,
    String? unitId,
    DateTime? startDate,
    DateTime? endDate,
    String? startTime,
    String? endTime,
    AvailabilityStatus? status,
    UnavailabilityReason? reason,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Availability(
      availabilityId: availabilityId ?? this.availabilityId,
      unitId: unitId ?? this.unitId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        availabilityId,
        unitId,
        startDate,
        endDate,
        startTime,
        endTime,
        status,
        reason,
        notes,
        createdBy,
        createdAt,
        updatedAt,
      ];
}