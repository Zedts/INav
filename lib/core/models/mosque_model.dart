import 'package:latlong2/latlong.dart';

class MosqueModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final double? rating;
  final bool? openNow;
  final String? iconTag;

  const MosqueModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    this.rating,
    this.openNow,
    this.iconTag,
  });

  LatLng get latLng => LatLng(latitude, longitude);

  String get formattedDistance {
    if (distanceKm < 1.0) {
      final meters = (distanceKm * 1000).round();
      return '$meters m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  String get estimatedWalkingTime {
    final walkingMinutesPerKm = 12;
    final totalMinutes = (distanceKm * walkingMinutesPerKm).round();
    if (totalMinutes < 1) return '< 1 min';
    if (totalMinutes < 60) return '$totalMinutes min';
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  String get dedupeKey {
    final latKey = (latitude * 1000).round();
    final lngKey = (longitude * 1000).round();
    return '${name.trim().toLowerCase()}#$latKey#$lngKey';
  }

  factory MosqueModel.fromJson(
    Map<String, dynamic> json, {
    double? fallbackLat,
    double? fallbackLng,
  }) {
    final normalized = _normalizeJson(json);
    final lat = _parseDouble(normalized, ['lat', 'latitude']) ?? fallbackLat ?? 0.0;
    final lng =
        _parseDouble(normalized, ['lng', 'lon', 'longitude']) ??
        fallbackLng ??
        0.0;
    final distance =
        _parseDouble(normalized, ['distance', 'distance_km', 'distanceKm']) ??
        0.0;
    final rating = _parseDouble(normalized, ['rating', 'score']);
    final openNow = _parseBool(normalized, ['open', 'open_now', 'isOpen']);

    return MosqueModel(
      id:
          _parseString(normalized, ['id', 'place_id', 'masjidId', 'uuid']) ??
          '${lat.toStringAsFixed(4)}_${lng.toStringAsFixed(4)}',
      name: _parseString(normalized, [
        'name',
        'title',
        'masjid_name',
        'masjidName',
        'place_name',
      ]) ?? 'Unknown Mosque',
      address: _parseString(normalized, [
        'address',
        'addr',
        'location',
        'vicinity',
        'formatted_address',
        'street',
      ]) ?? 'Address not available',
      latitude: lat,
      longitude: lng,
      distanceKm: distance,
      rating: rating,
      openNow: openNow,
      iconTag: _parseString(normalized, ['icon_tag', 'icon', 'tag', 'category']),
    );
  }

  static Map<String, dynamic> _normalizeJson(Map<String, dynamic> json) {
    if (json.containsKey('masjidName') || json.containsKey('masjidLocation')) {
      final addressMap = json['masjidAddress'];
      var address = 'Address not available';
      if (addressMap is Map) {
        final description = addressMap['description'];
        if (description is String && description.trim().isNotEmpty) {
          address = description.trim();
        }
      }

      double? lat;
      double? lng;
      final location = json['masjidLocation'];
      if (location is Map) {
        final coordinates = location['coordinates'];
        if (coordinates is List && coordinates.length >= 2) {
          lng = _toDouble(coordinates[0]);
          lat = _toDouble(coordinates[1]);
        }
      }

      final out = <String, dynamic>{
        'id': json['_id'] ?? json['id'],
        'name': json['masjidName'],
        'address': address,
      };
      if (lat != null) out['lat'] = lat;
      if (lng != null) out['lng'] = lng;
      return out;
    }

    if (!json.containsKey('lat') &&
        !json.containsKey('latitude') &&
        json['url'] is String) {
      final coords = _coordsFromGoogleMapsUrl(json['url'] as String);
      if (coords != null) {
        return {
          ...json,
          'lat': coords.$1,
          'lng': coords.$2,
        };
      }
    }

    return json;
  }

  static (double, double)? _coordsFromGoogleMapsUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    final query = uri.queryParameters['query'];
    if (query != null) {
      final parts = query.split(',');
      if (parts.length >= 2) {
        final lat = double.tryParse(parts[0].trim());
        final lng = double.tryParse(parts[1].trim());
        if (lat != null && lng != null) return (lat, lng);
      }
    }

    final q = uri.queryParameters['q'];
    if (q != null) {
      final parts = q.split(',');
      if (parts.length >= 2) {
        final lat = double.tryParse(parts[0].trim());
        final lng = double.tryParse(parts[1].trim());
        if (lat != null && lng != null) return (lat, lng);
      }
    }

    return null;
  }

  static double? _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static String? _parseString(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v == null) continue;
      if (v is String && v.trim().isNotEmpty) return v.trim();
      if (v is num) return v.toString();
    }
    return null;
  }

  static double? _parseDouble(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v == null) continue;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
    }
    return null;
  }

  static bool? _parseBool(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v == null) continue;
      if (v is bool) return v;
      if (v is String) {
        final s = v.trim().toLowerCase();
        if (s == 'true' || s == '1' || s == 'yes' || s == 'open') return true;
        if (s == 'false' || s == '0' || s == 'no' || s == 'closed') {
          return false;
        }
      }
      if (v is num) return v != 0;
    }
    return null;
  }

  MosqueModel copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    double? distanceKm,
    double? rating,
    bool? openNow,
    String? iconTag,
  }) {
    return MosqueModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distanceKm: distanceKm ?? this.distanceKm,
      rating: rating ?? this.rating,
      openNow: openNow ?? this.openNow,
      iconTag: iconTag ?? this.iconTag,
    );
  }
}
