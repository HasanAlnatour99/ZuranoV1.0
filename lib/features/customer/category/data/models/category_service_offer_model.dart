import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryServiceOfferModel {
  const CategoryServiceOfferModel({
    required this.id,
    required this.salonId,
    required this.serviceId,
    required this.title,
    required this.salonName,
    required this.durationMinutes,
    required this.city,
    required this.area,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
    required this.geohash,
  });

  final String id;
  final String salonId;
  final String serviceId;
  final String title;
  final String salonName;
  final int durationMinutes;
  final String city;
  final String area;
  final String countryCode;
  final double? latitude;
  final double? longitude;
  final String geohash;

  factory CategoryServiceOfferModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final directLat = _finiteDouble(data['latitude']);
    final directLng = _finiteDouble(data['longitude']);
    final location = data['location'];
    final locationLat = location is GeoPoint ? location.latitude : null;
    final locationLng = location is GeoPoint ? location.longitude : null;
    final latitude = directLat ?? locationLat;
    final longitude = directLng ?? locationLng;
    final hasCompleteGeo = latitude != null && longitude != null;

    return CategoryServiceOfferModel(
      id: doc.id,
      salonId: _trimmedString(data['salonId']),
      serviceId: _trimmedString(data['serviceId']).isNotEmpty
          ? _trimmedString(data['serviceId'])
          : _trimmedString(data['targetId']),
      title: _trimmedString(data['title']),
      salonName: _trimmedString(data['salonName']),
      durationMinutes: (data['durationMinutes'] as num?)?.toInt() ?? 0,
      city: _trimmedString(data['city']),
      area: _trimmedString(data['area']),
      countryCode: _trimmedString(data['countryCode']).toUpperCase(),
      latitude: hasCompleteGeo ? latitude : null,
      longitude: hasCompleteGeo ? longitude : null,
      geohash: _trimmedString(data['geohash']),
    );
  }

  static String _trimmedString(Object? value) {
    if (value is String) {
      return value.trim();
    }
    return '';
  }

  static double? _finiteDouble(Object? value) {
    if (value is num) {
      final parsed = value.toDouble();
      return parsed.isFinite ? parsed : null;
    }
    if (value is String) {
      final parsed = double.tryParse(value.trim());
      return parsed != null && parsed.isFinite ? parsed : null;
    }
    return null;
  }
}
