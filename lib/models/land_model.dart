import 'package:cloud_firestore/cloud_firestore.dart';

class LandModel {
  final String id;
  final String title;
  final String province;
  final String district;
  final String municipality;
  final double areaRopani;
  final String soilType;
  final String waterSource;
  final bool hasIrrigation;
  final double leasePriceMonthly;
  final String status;
  final String imageUrl;
  final String semanticLabel;
  final bool isVerified;
  final String category;
  final String ownerName;
  final double ownerRating;
  final double? latitude;
  final double? longitude;
  final String description;
  final List<String> imageUrls;
  final List<String> landFeatures;
  final List<String> suggestedCrops;

  const LandModel({
    required this.id,
    required this.title,
    required this.province,
    required this.district,
    required this.municipality,
    required this.areaRopani,
    required this.soilType,
    required this.waterSource,
    required this.hasIrrigation,
    required this.leasePriceMonthly,
    required this.status,
    required this.imageUrl,
    required this.semanticLabel,
    required this.isVerified,
    required this.category,
    required this.ownerName,
    required this.ownerRating,
    this.latitude,
    this.longitude,
    this.description = '',
    this.imageUrls = const [],
    this.landFeatures = const [],
    this.suggestedCrops = const [],
  });

  factory LandModel.fromMap(Map<String, dynamic> map) {
    return LandModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      province: map['province'] as String? ?? '',
      district: map['district'] as String? ?? '',
      municipality: map['municipality'] as String? ?? '',
      areaRopani: (map['area_ropani'] as num? ?? 0).toDouble(),
      soilType: map['soil_type'] as String? ?? '',
      waterSource: map['water_source'] as String? ?? '',
      hasIrrigation: map['has_irrigation'] as bool? ?? false,
      leasePriceMonthly: (map['lease_price_monthly'] as num? ?? 0).toDouble(),
      status: map['status'] as String? ?? 'approved',
      imageUrl: map['image_url'] as String? ?? '',
      semanticLabel: map['semantic_label'] as String? ?? '',
      isVerified: map['is_verified'] as bool? ?? false,
      category: map['category'] as String? ?? 'Other',
      ownerName: map['owner_name'] as String? ?? '',
      ownerRating: (map['owner_rating'] as num? ?? 0).toDouble(),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }

  /// Build from a Firestore DocumentSnapshot — field names match Firestore schema
  factory LandModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return LandModel(
      id:                 doc.id,
      title:              d['title']              as String? ?? '',
      province:           d['province']           as String? ?? '',
      district:           d['district']           as String? ?? d['location'] as String? ?? '',
      municipality:       d['municipality']       as String? ?? '',
      areaRopani:         (d['areaBigha']         as num? ?? d['area'] as num? ?? 0).toDouble(),
      soilType:           d['soilType']           as String? ?? '',
      waterSource:        d['waterSource']        as String? ?? '',
      hasIrrigation:      d['hasIrrigation']      as bool? ?? false,
      leasePriceMonthly:  (d['pricePerBigha']     as num? ?? d['price'] as num? ?? 0).toDouble(),
      status:             d['status']             as String? ?? 'active',
      imageUrl:           d['imageUrl']           as String? ?? d['image_url'] as String? ?? '',
      semanticLabel:      d['title']              as String? ?? '',
      isVerified:         d['isVerified']         as bool? ?? false,
      category:           d['category']           as String? ?? 'Other',
      ownerName:          d['ownerName']          as String? ?? '',
      ownerRating:        (d['ownerRating']       as num? ?? 0).toDouble(),
      latitude:           (d['latitude']          as num?)?.toDouble(),
      longitude:          (d['longitude']         as num?)?.toDouble(),
      description:        d['description']        as String? ?? '',
      imageUrls:          List<String>.from(d['imageUrls']      as List? ?? []),
      landFeatures:       List<String>.from(d['landFeatures']   as List? ?? []),
      suggestedCrops:     List<String>.from(d['suggestedCrops'] as List? ?? []),
    );
  }
}
