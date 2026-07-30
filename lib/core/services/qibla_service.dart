import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import '../models/qibla_model.dart';
import 'api_service.dart';
import 'dart:math' as math;

/// Service for calculating Qibla direction
///
/// Primary source: MyQuran API v3 endpoint GET /qibla/{lat},{lng}
/// Fallback: local great-circle bearing calculation (works offline)
/// Distance to the Kaaba is always computed locally (the API doesn't return it)
class QiblaService {
  final ApiService _apiService;

  // Kaaba coordinates (Mecca, Saudi Arabia)
  static const double _kaabaLatitude = 21.422487;
  static const double _kaabaLongitude = 39.826206;

  QiblaService({ApiService? apiService})
    : _apiService = apiService ??
          ApiService(
            baseUrl: dotenv.env['MYQURAN_API_BASE_URL_ALT']!,
          );

  /// Get Qibla direction for given coordinates
  ///
  /// [latitude] - Latitude of the location
  /// [longitude] - Longitude of the location
  ///
  /// Returns [QiblaModel] with direction in degrees and distance in km
  /// Throws [ApiException] on error
  Future<QiblaModel> getQiblaDirection(
    double latitude,
    double longitude,
  ) async {
    final distanceKm = _calculateDistanceKm(latitude, longitude);

    // Try the v3 API first, fall back to local calculation on any failure
    try {
      final json = await _apiService.get('/qibla/$latitude,$longitude');
      return QiblaModel.fromJson(json, distanceKm: distanceKm);
    } on ApiException catch (e) {
      debugPrint('Qibla API unavailable, using local calculation: $e');
    } catch (e) {
      debugPrint('Qibla API error, using local calculation: $e');
    }

    try {
      final direction = _calculateQiblaDirection(latitude, longitude);

      return QiblaModel(
        latitude: latitude,
        longitude: longitude,
        direction: direction,
        distanceKm: distanceKm,
      );
    } catch (e) {
      debugPrint('Qibla local calculation failed: $e');
      throw ApiException(
        'Unable to determine the Qibla direction. Please try again.',
      );
    }
  }

  /// Great-circle distance from the given coordinates to the Kaaba in km
  double _calculateDistanceKm(double lat, double lng) {
    return Geolocator.distanceBetween(
          lat,
          lng,
          _kaabaLatitude,
          _kaabaLongitude,
        ) /
        1000;
  }

  /// Calculate Qibla direction using spherical trigonometry
  /// Returns angle in degrees (0-360) from North
  double _calculateQiblaDirection(double lat, double lng) {
    // Convert to radians
    final latRad = _degreesToRadians(lat);
    final lngRad = _degreesToRadians(lng);
    final kaabaLatRad = _degreesToRadians(_kaabaLatitude);
    final kaabaLngRad = _degreesToRadians(_kaabaLongitude);

    // Calculate delta longitude
    final deltaLng = kaabaLngRad - lngRad;

    // Calculate bearing using spherical law of sines
    final y = math.sin(deltaLng) * math.cos(kaabaLatRad);
    final x =
        math.cos(latRad) * math.sin(kaabaLatRad) -
        math.sin(latRad) * math.cos(kaabaLatRad) * math.cos(deltaLng);

    final bearingRad = math.atan2(y, x);

    // Convert to degrees and normalize to 0-360
    double bearing = _radiansToDegrees(bearingRad);
    bearing = (bearing + 360) % 360;

    return bearing;
  }

  double _degreesToRadians(double degrees) => degrees * math.pi / 180.0;
  double _radiansToDegrees(double radians) => radians * 180.0 / math.pi;

  /// Dispose service
  void dispose() {
    _apiService.dispose();
  }
}
