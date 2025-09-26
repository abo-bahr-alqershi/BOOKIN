import '../../domain/entities/property_in_section.dart' as domain;

class PropertyInSectionModel {
  final String id;
  final String sectionId;
  final String propertyId;
  final String propertyName;
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final String propertyType;
  final int starRating;
  final double averageRating;
  final int reviewsCount;
  final double basePrice;
  final String currency;
  final String? mainImageUrl;
  final String? mainImageId;
  final List<String> additionalImages;
  final String? shortDescription;
  final int displayOrder;
  final bool isFeatured;
  final double? discountPercentage;
  final String? promotionalText;
  final String? badge;
  final String? badgeColor;
  final DateTime? displayFrom;
  final DateTime? displayUntil;
  final int priority;
  final int viewsFromSection;
  final int clickCount;
  final double? conversionRate;
  final Map<String, dynamic>? metadata;

  const PropertyInSectionModel({
    required this.id,
    required this.sectionId,
    required this.propertyId,
    required this.propertyName,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.propertyType,
    required this.starRating,
    required this.averageRating,
    required this.reviewsCount,
    required this.basePrice,
    required this.currency,
    this.mainImageUrl,
    this.additionalImages = const [],
    this.mainImageId,
    this.shortDescription,
    required this.displayOrder,
    this.isFeatured = false,
    this.discountPercentage,
    this.promotionalText,
    this.badge,
    this.badgeColor,
    this.displayFrom,
    this.displayUntil,
    this.priority = 0,
    this.viewsFromSection = 0,
    this.clickCount = 0,
    this.conversionRate,
    this.metadata,
  });

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static DateTime? _toDate(dynamic v) {
    if (v == null || v.toString().isEmpty) return null;
    return DateTime.tryParse(v.toString());
  }

  factory PropertyInSectionModel.fromJson(Map<String, dynamic> json) {
    List<String> _images = [];
    final additional = json['additionalImages'];
    if (additional is String && additional.trim().isNotEmpty) {
      // Expect JSON array in string
      try {
        _images = List<String>.from((additional as String)
            .replaceAll('\n', '')
            .replaceAll('\r', '')
            .trim()
            .replaceAll('"', '"'));
      } catch (_) {
        _images = const [];
      }
    } else if (additional is List) {
      _images = additional.whereType<String>().toList();
    }
    return PropertyInSectionModel(
      id: json['id']?.toString() ?? '',
      sectionId: json['sectionId']?.toString() ?? '',
      propertyId: json['propertyId']?.toString() ?? '',
      propertyName: json['propertyName']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      latitude: _toDouble(json['latitude']) ?? 0,
      longitude: _toDouble(json['longitude']) ?? 0,
      propertyType: json['propertyType']?.toString() ?? '',
      starRating: (json['starRating'] is int)
          ? json['starRating']
          : int.tryParse('${json['starRating'] ?? 0}') ?? 0,
      averageRating: _toDouble(json['averageRating']) ?? 0,
      reviewsCount: (json['reviewsCount'] is int)
          ? json['reviewsCount']
          : int.tryParse('${json['reviewsCount'] ?? 0}') ?? 0,
      basePrice: _toDouble(json['minPrice'] ?? json['basePrice']) ?? 0,
      currency: json['currency']?.toString() ?? '',
      mainImageUrl: json['mainImageUrl']?.toString(),
      mainImageId: json['mainImageId']?.toString(),
      additionalImages: _images,
      shortDescription: json['shortDescription']?.toString(),
      displayOrder: (json['displayOrder'] is int)
          ? json['displayOrder']
          : int.tryParse('${json['displayOrder'] ?? 0}') ?? 0,
      isFeatured: json['isFeatured'] == true,
      discountPercentage: _toDouble(json['discountPercentage']),
      promotionalText: json['promotionalText']?.toString(),
      badge: json['badge']?.toString(),
      badgeColor: json['badgeColor']?.toString(),
      displayFrom: _toDate(json['displayFrom']),
      displayUntil: _toDate(json['displayUntil']),
      priority: (json['priority'] is int)
          ? json['priority']
          : int.tryParse('${json['priority'] ?? 0}') ?? 0,
      viewsFromSection: (json['viewsFromSection'] is int)
          ? json['viewsFromSection']
          : int.tryParse('${json['viewsFromSection'] ?? 0}') ?? 0,
      clickCount: (json['clickCount'] is int)
          ? json['clickCount']
          : int.tryParse('${json['clickCount'] ?? 0}') ?? 0,
      conversionRate: _toDouble(json['conversionRate']),
      metadata: json['metadata'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sectionId': sectionId,
        'propertyId': propertyId,
        'propertyName': propertyName,
        'address': address,
        'city': city,
        'latitude': latitude,
        'longitude': longitude,
        'propertyType': propertyType,
        'starRating': starRating,
        'averageRating': averageRating,
        'reviewsCount': reviewsCount,
        'basePrice': basePrice,
        'currency': currency,
        'mainImageUrl': mainImageUrl,
        'additionalImages': additionalImages,
        'mainImageId': mainImageId,
        'shortDescription': shortDescription,
        'displayOrder': displayOrder,
        'isFeatured': isFeatured,
        'discountPercentage': discountPercentage,
        'promotionalText': promotionalText,
        'badge': badge,
        'badgeColor': badgeColor,
        'displayFrom': displayFrom?.toIso8601String(),
        'displayUntil': displayUntil?.toIso8601String(),
        'priority': priority,
        'viewsFromSection': viewsFromSection,
        'clickCount': clickCount,
        'conversionRate': conversionRate,
        'metadata': metadata,
      };

  domain.PropertyInSection toEntity() => domain.PropertyInSection(
        id: id,
        sectionId: sectionId,
        propertyId: propertyId,
        propertyName: propertyName,
        address: address,
        city: city,
        latitude: latitude,
        longitude: longitude,
        propertyType: propertyType,
        starRating: starRating,
        averageRating: averageRating,
        reviewsCount: reviewsCount,
        basePrice: basePrice,
        currency: currency,
        mainImageUrl: mainImageUrl,
        additionalImages: additionalImages,
        shortDescription: shortDescription,
        displayOrder: displayOrder,
        isFeatured: isFeatured,
        discountPercentage: discountPercentage,
        promotionalText: promotionalText,
        badge: badge,
        badgeColor: badgeColor,
        displayFrom: displayFrom,
        displayUntil: displayUntil,
        priority: priority,
        viewsFromSection: viewsFromSection,
        clickCount: clickCount,
        conversionRate: conversionRate,
        metadata: metadata,
      );
}

