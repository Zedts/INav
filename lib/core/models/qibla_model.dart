import 'package:intl/intl.dart';

/// Model for Qibla direction data
class QiblaModel {
  final double latitude;
  final double longitude;
  final double direction; // Qibla direction in degrees
  final double distanceKm; // Great-circle distance to the Kaaba in km

  const QiblaModel({
    required this.latitude,
    required this.longitude,
    required this.direction,
    this.distanceKm = 0,
  });

  /// Parse from MyQuran API v3 response: GET /qibla/{lat},{lng}
  /// { "status": true, "data": { "latitude", "longitude", "direction" } }
  /// Distance is not returned by the API, so it is passed separately.
  factory QiblaModel.fromJson(
    Map<String, dynamic> json, {
    double distanceKm = 0,
  }) {
    final data = json['data'] as Map<String, dynamic>;
    return QiblaModel(
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      direction: (data['direction'] as num).toDouble(),
      distanceKm: distanceKm,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'latitude': latitude,
        'longitude': longitude,
        'direction': direction,
        'distanceKm': distanceKm,
      },
    };
  }

  /// Get 16-point cardinal direction (N, NNE, NE, ENE, E, ...)
  String get cardinalDirection {
    const directions = [
      'N', 'NNE', 'NE', 'ENE',
      'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW',
      'W', 'WNW', 'NW', 'NNW',
    ];
    final index = ((direction + 11.25) / 22.5).floor() % 16;
    return directions[index];
  }

  /// Formatted distance with thousands separator (e.g. "7,921 km")
  String get formattedDistance =>
      '${NumberFormat('#,##0').format(distanceKm.round())} km';

  @override
  String toString() =>
      'QiblaModel(direction: $direction°, cardinal: $cardinalDirection, distance: $formattedDistance)';
}
