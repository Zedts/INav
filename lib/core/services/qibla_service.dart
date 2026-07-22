import '../models/qibla_model.dart';
import 'api_service.dart';
import 'dart:math' as math;

/// Service for calculating Qibla direction
/// Note: MyQuran API v2 does not have qibla endpoints, using local calculation
class QiblaService {
  final ApiService _apiService;

  // Kaaba coordinates (Mecca, Saudi Arabia)
  static const double _kaabaLatitude = 21.422487;
  static const double _kaabaLongitude = 39.826206;

  QiblaService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  /// Calculate Qibla direction for given coordinates
  ///
  /// [latitude] - Latitude of the location
  /// [longitude] - Longitude of the location
  ///
  /// Returns [QiblaModel] with direction in degrees
  /// Throws [ApiException] on error
  Future<QiblaModel> getQiblaDirection(
    double latitude,
    double longitude,
  ) async {
    try {
      final direction = _calculateQiblaDirection(latitude, longitude);

      return QiblaModel(
        latitude: latitude,
        longitude: longitude,
        direction: direction,
      );
    } catch (e) {
      throw ApiException(
        'Failed to calculate Qibla direction: ${e.toString()}',
      );
    }
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
