// lib/features/admin_availability_pricing/data/models/availability_model.dart

import '../../domain/entities/availability.dart';

class AvailabilityModel extends Availability {
  const AvailabilityModel({
    String? availabilityId,
    required String unitId,
    required DateTime startDate,
    required DateTime endDate,
    String? startTime,
    String? endTime,
    required AvailabilityStatus status,
    UnavailabilityReason? reason,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super(
          availabilityId: availabilityId,
          unitId: unitId,
          startDate: startDate,
          endDate: endDate,
          startTime: startTime,
          endTime: endTime,
          status: status,
          reason: reason,
          notes: notes,
          createdBy: createdBy,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityModel(
      availabilityId: json['availabilityId'] as String?,
      unitId: json['unitId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      status: _parseStatus(json['status'] as String),
      reason: json['reason'] != null
          ? _parseReason(json['reason'] as String)
          : null,
      notes: json['notes'] as String?,
      createdBy: json['createdBy'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (availabilityId != null) 'availabilityId': availabilityId,
      'unitId': unitId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
      'status': _statusToString(status),
      if (reason != null) 'reason': _reasonToString(reason!),
      if (notes != null) 'notes': notes,
      if (createdBy != null) 'createdBy': createdBy,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  static AvailabilityStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return AvailabilityStatus.available;
      case 'unavailable':
        return AvailabilityStatus.unavailable;
      case 'maintenance':
        return AvailabilityStatus.maintenance;
      case 'blocked':
        return AvailabilityStatus.blocked;
      case 'booked':
        return AvailabilityStatus.booked;
      default:
        return AvailabilityStatus.available;
    }
  }

  static String _statusToString(AvailabilityStatus status) {
    switch (status) {
      case AvailabilityStatus.available:
        return 'available';
      case AvailabilityStatus.unavailable:
        return 'unavailable';
      case AvailabilityStatus.maintenance:
        return 'maintenance';
      case AvailabilityStatus.blocked:
        return 'blocked';
      case AvailabilityStatus.booked:
        return 'booked';
    }
  }

  static UnavailabilityReason _parseReason(String reason) {
    switch (reason.toLowerCase()) {
      case 'maintenance':
        return UnavailabilityReason.maintenance;
      case 'vacation':
        return UnavailabilityReason.vacation;
      case 'private_booking':
      case 'privatebooking':
        return UnavailabilityReason.privateBooking;
      case 'renovation':
        return UnavailabilityReason.renovation;
      default:
        return UnavailabilityReason.other;
    }
  }

  static String _reasonToString(UnavailabilityReason reason) {
    switch (reason) {
      case UnavailabilityReason.maintenance:
        return 'maintenance';
      case UnavailabilityReason.vacation:
        return 'vacation';
      case UnavailabilityReason.privateBooking:
        return 'private_booking';
      case UnavailabilityReason.renovation:
        return 'renovation';
      case UnavailabilityReason.other:
        return 'other';
    }
  }
}