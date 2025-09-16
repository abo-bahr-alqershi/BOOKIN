import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_details.dart';
import 'booking_model.dart';

class BookingDetailsModel extends BookingDetails {
  const BookingDetailsModel({
    required super.booking,
    required super.payments,
    required super.services,
    super.activities,
    super.guestInfo,
    super.unitDetails,
    super.propertyDetails,
  });

  factory BookingDetailsModel.fromJson(Map<String, dynamic> json) {
    return BookingDetailsModel(
      booking: BookingModel.fromJson(json['booking'] ?? json),
      payments: (json['payments'] as List? ?? [])
          .map((p) => PaymentModel.fromJson(p))
          .toList(),
      services: (json['services'] as List? ?? [])
          .map((s) => ServiceModel.fromJson(s))
          .toList(),
      activities: (json['activities'] as List? ?? [])
          .map((a) => BookingActivityModel.fromJson(a))
          .toList(),
      guestInfo: json['guestInfo'] != null
          ? GuestInfoModel.fromJson(json['guestInfo'])
          : null,
      unitDetails: json['unitDetails'] != null
          ? UnitDetailsModel.fromJson(json['unitDetails'])
          : null,
      propertyDetails: json['propertyDetails'] != null
          ? PropertyDetailsModel.fromJson(json['propertyDetails'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking': (booking as BookingModel).toJson(),
      'payments': payments.map((p) => (p as PaymentModel).toJson()).toList(),
      'services': services.map((s) => (s as ServiceModel).toJson()).toList(),
      'activities':
          activities.map((a) => (a as BookingActivityModel).toJson()).toList(),
      if (guestInfo != null)
        'guestInfo': (guestInfo as GuestInfoModel).toJson(),
      if (unitDetails != null)
        'unitDetails': (unitDetails as UnitDetailsModel).toJson(),
      if (propertyDetails != null)
        'propertyDetails': (propertyDetails as PropertyDetailsModel).toJson(),
    };
  }
}

/// 💳 Model للدفعة
class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.bookingId,
    required super.amount,
    required super.transactionId,
    required super.method,
    required super.status,
    required super.paymentDate,
    super.refundReason,
    super.refundedAt,
    super.receiptUrl,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id']?.toString() ?? '',
      bookingId: json['bookingId']?.toString() ?? '',
      amount: MoneyModel.fromJson(json['amount']),
      transactionId: json['transactionId'] ?? '',
      method: json['method'] ?? 'Cash',
      status: json['status'] ?? 'Pending',
      paymentDate: DateTime.parse(json['paymentDate']),
      refundReason: json['refundReason'],
      refundedAt: json['refundedAt'] != null
          ? DateTime.parse(json['refundedAt'])
          : null,
      receiptUrl: json['receiptUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'amount': (amount as MoneyModel).toJson(),
      'transactionId': transactionId,
      'method': method,
      'status': status,
      'paymentDate': paymentDate.toIso8601String(),
      if (refundReason != null) 'refundReason': refundReason,
      if (refundedAt != null) 'refundedAt': refundedAt!.toIso8601String(),
      if (receiptUrl != null) 'receiptUrl': receiptUrl,
    };
  }
}

/// 🛎️ Model للخدمة
class ServiceModel extends Service {
  const ServiceModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.quantity,
    super.icon,
    super.category,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: MoneyModel.fromJson(json['price']),
      quantity: json['quantity'] ?? 1,
      icon: json['icon'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': (price as MoneyModel).toJson(),
      'quantity': quantity,
      if (icon != null) 'icon': icon,
      if (category != null) 'category': category,
    };
  }
}

/// 📝 Model لنشاط الحجز
class BookingActivityModel extends BookingActivity {
  const BookingActivityModel({
    required super.id,
    required super.action,
    required super.description,
    required super.timestamp,
    super.userId,
    super.userName,
  });

  factory BookingActivityModel.fromJson(Map<String, dynamic> json) {
    return BookingActivityModel(
      id: json['id']?.toString() ?? '',
      action: json['action'] ?? '',
      description: json['description'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      userId: json['userId']?.toString(),
      userName: json['userName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      if (userId != null) 'userId': userId,
      if (userName != null) 'userName': userName,
    };
  }
}

/// 👤 Model لمعلومات الضيف
class GuestInfoModel extends GuestInfo {
  const GuestInfoModel({
    required super.name,
    required super.email,
    required super.phone,
    super.nationality,
    super.idNumber,
    super.idType,
    super.address,
  });

  factory GuestInfoModel.fromJson(Map<String, dynamic> json) {
    return GuestInfoModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      nationality: json['nationality'],
      idNumber: json['idNumber'],
      idType: json['idType'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      if (nationality != null) 'nationality': nationality,
      if (idNumber != null) 'idNumber': idNumber,
      if (idType != null) 'idType': idType,
      if (address != null) 'address': address,
    };
  }
}

/// 🏠 Model لتفاصيل الوحدة
class UnitDetailsModel extends UnitDetails {
  const UnitDetailsModel({
    required super.id,
    required super.name,
    required super.type,
    required super.capacity,
    required super.amenities,
    required super.images,
    super.description,
    super.location,
  });

  factory UnitDetailsModel.fromJson(Map<String, dynamic> json) {
    return UnitDetailsModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      capacity: json['capacity'] ?? 1,
      amenities: List<String>.from(json['amenities'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      description: json['description'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'capacity': capacity,
      'amenities': amenities,
      'images': images,
      if (description != null) 'description': description,
      if (location != null) 'location': location,
    };
  }
}

/// 🏢 Model لتفاصيل العقار
class PropertyDetailsModel extends PropertyDetails {
  const PropertyDetailsModel({
    required super.id,
    required super.name,
    required super.address,
    super.phone,
    super.email,
    super.checkInTime,
    super.checkOutTime,
    super.policies,
  });

  factory PropertyDetailsModel.fromJson(Map<String, dynamic> json) {
    return PropertyDetailsModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'],
      email: json['email'],
      checkInTime: json['checkInTime'],
      checkOutTime: json['checkOutTime'],
      policies: json['policies'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (checkInTime != null) 'checkInTime': checkInTime,
      if (checkOutTime != null) 'checkOutTime': checkOutTime,
      if (policies != null) 'policies': policies,
    };
  }
}
