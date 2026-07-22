import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Service for handling device location and geocoding
/// Follows best practices for permission handling and error management
class LocationService {
  // Create geocoding instance for v5.0.0+
  final Geocoding _geocoding = Geocoding();

  /// Get current device position
  ///
  /// Returns [Position] with latitude, longitude, and accuracy
  /// Throws [LocationException] on error
  Future<Position> getCurrentPosition() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationException(
          'Location services are disabled. Please enable location in settings.',
        );
      }

      // Check and request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw LocationException(
            'Location permission denied. Please grant location access.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw LocationException(
          'Location permission permanently denied. Please enable it in app settings.',
        );
      }

      // Get current position with medium accuracy (balances battery and precision)
      final position =
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              distanceFilter: 100,
            ),
          ).timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw LocationException(
                'Location request timeout. Please try again.',
              );
            },
          );

      return position;
    } on LocationException {
      rethrow;
    } catch (e) {
      throw LocationException('Failed to get location: ${e.toString()}');
    }
  }

  /// Get city name and country from coordinates
  ///
  /// [latitude] - Latitude coordinate
  /// [longitude] - Longitude coordinate
  ///
  /// Returns formatted location string (e.g., "Jakarta, ID")
  /// Throws [LocationException] on error
  Future<String> getCityFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) {
        return 'Unknown Location';
      }

      final place = placemarks.first;
      final city =
          place.locality ??
          place.subAdministrativeArea ??
          place.administrativeArea;
      final country = place.isoCountryCode ?? place.country;

      if (city != null && country != null) {
        return '$city, $country';
      } else if (city != null) {
        return city;
      } else {
        return 'Unknown Location';
      }
    } catch (e) {
      throw LocationException('Failed to get city name: ${e.toString()}');
    }
  }

  /// Get full location details including city, province, and country
  ///
  /// [latitude] - Latitude coordinate
  /// [longitude] - Longitude coordinate
  ///
  /// Returns [LocationDetails] with structured location information
  Future<LocationDetails> getLocationDetails(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) {
        return LocationDetails(
          city: 'Unknown',
          province: 'Unknown',
          country: 'Unknown',
          countryCode: 'XX',
          formattedAddress: 'Unknown Location',
        );
      }

      final place = placemarks.first;

      return LocationDetails(
        city: place.locality ?? place.subAdministrativeArea ?? 'Unknown',
        province: place.administrativeArea ?? 'Unknown',
        country: place.country ?? 'Unknown',
        countryCode: place.isoCountryCode ?? 'XX',
        formattedAddress: _formatAddress(place),
      );
    } catch (e) {
      throw LocationException(
        'Failed to get location details: ${e.toString()}',
      );
    }
  }

  /// Format address from placemark
  String _formatAddress(Placemark place) {
    final parts = <String>[];

    if (place.locality != null) parts.add(place.locality!);
    if (place.administrativeArea != null &&
        place.administrativeArea != place.locality) {
      parts.add(place.administrativeArea!);
    }
    if (place.country != null) parts.add(place.country!);

    return parts.isNotEmpty ? parts.join(', ') : 'Unknown Location';
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check current permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }
}

/// Structured location details
class LocationDetails {
  final String city;
  final String province;
  final String country;
  final String countryCode;
  final String formattedAddress;

  const LocationDetails({
    required this.city,
    required this.province,
    required this.country,
    required this.countryCode,
    required this.formattedAddress,
  });

  /// Get short format (e.g., "Jakarta, ID")
  String get shortFormat => '$city, $countryCode';

  @override
  String toString() => formattedAddress;
}

/// Custom exception for location errors
class LocationException implements Exception {
  final String message;

  LocationException(this.message);

  @override
  String toString() => 'LocationException: $message';
}
