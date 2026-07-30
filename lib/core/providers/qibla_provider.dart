import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart';
import 'package:geolocator/geolocator.dart';

import '../models/qibla_model.dart';
import '../services/location_service.dart';
import '../services/qibla_service.dart';

/// Compass sensor state for the Qibla screen
enum CompassStatus {
  /// Sensor starting, waiting for the first reading
  initializing,

  /// Sensor active with good accuracy
  calibrated,

  /// Sensor active but needs calibration (figure-8 hint shown)
  approximate,

  /// Device has no usable rotation sensor
  unavailable,
}

/// Provider for the Qibla Compass screen
///
/// Handles location, Qibla bearing (API + local fallback via [QiblaService])
/// and the live device heading from the rotation sensor.
class QiblaProvider extends ChangeNotifier {
  final LocationService _locationService;
  final QiblaService _qiblaService;
  final Stopwatch _positionFreshness = Stopwatch();

  Position? _currentPosition;
  String _cityName = 'Locating…';
  QiblaModel? _qiblaData;
  bool _loading = false;
  String? _errorMessage;

  // Compass state
  StreamSubscription<OrientationEvent>? _orientationSubscription;
  double _heading = 0; // degrees 0-360, smoothed
  bool _hasHeading = false;
  CompassStatus _compassStatus = CompassStatus.initializing;

  // Accuracy below ~15° is considered calibrated (matches the reference)
  static const double _calibratedAccuracyDeg = 15;

  // Aligned when within 6° of the Qibla bearing (matches the reference)
  static const double _alignedThresholdDeg = 6;

  QiblaProvider({
    LocationService? locationService,
    QiblaService? qiblaService,
  })  : _locationService = locationService ?? LocationService(),
        _qiblaService = qiblaService ?? QiblaService();

  Position? get currentPosition => _currentPosition;
  String get cityName => _cityName;
  QiblaModel? get qiblaData => _qiblaData;
  bool get isLoading => _loading;
  String? get errorMessage => _errorMessage;
  double get heading => _heading;
  bool get hasHeading => _hasHeading;
  CompassStatus get compassStatus => _compassStatus;
  bool get isCompassActive =>
      _hasHeading && _compassStatus != CompassStatus.unavailable;

  /// Signed angular offset (-180..180) between the Qibla bearing and the
  /// current heading. Positive means "turn right".
  double get alignmentOffset {
    final bearing = _qiblaData?.direction;
    if (bearing == null) return 180;
    return ((bearing - _heading + 540) % 360) - 180;
  }

  /// Whether the device is currently facing the Qibla
  bool get isAligned =>
      isCompassActive &&
      _qiblaData != null &&
      alignmentOffset.abs() < _alignedThresholdDeg;

  /// Guidance text shown in the compass center readout
  String get guidanceText {
    if (_compassStatus == CompassStatus.unavailable) {
      return 'Compass unavailable';
    }
    if (!_hasHeading) return 'Hold phone flat';
    if (_qiblaData == null) return 'Locating…';
    final diff = alignmentOffset;
    return diff > 0
        ? 'Turn right ${diff.round()}°'
        : 'Turn left ${(-diff).round()}°';
  }

  /// Load location, city name and Qibla data
  Future<void> initialize() async {
    if (_loading) return;
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final pos = await _locationService.getCurrentPosition();
      _currentPosition = pos;
      _positionFreshness
        ..reset()
        ..start();
      await _resolveCityName(pos.latitude, pos.longitude);
      await _fetchQibla(pos.latitude, pos.longitude);
    } on LocationException catch (e) {
      _errorMessage = _locationErrorMessage(e);
      debugPrint('Qibla location exception: $e');
    } catch (e) {
      _errorMessage =
          'Could not determine your location. Please pull down to refresh.';
      debugPrint('Qibla init error: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Refresh location and Qibla data
  Future<void> refresh({bool forceRefreshLocation = false}) async {
    if (_loading) return;
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    final cached = _currentPosition;
    final stale = !_positionFreshness.isRunning ||
        _positionFreshness.elapsed > const Duration(seconds: 60);
    try {
      double lat;
      double lng;
      if (cached != null && !forceRefreshLocation && !stale) {
        lat = cached.latitude;
        lng = cached.longitude;
      } else {
        final pos = await _locationService.getCurrentPosition();
        _currentPosition = pos;
        _positionFreshness
          ..reset()
          ..start();
        lat = pos.latitude;
        lng = pos.longitude;
        await _resolveCityName(lat, lng);
      }

      await _fetchQibla(lat, lng);
    } on LocationException catch (e) {
      _errorMessage = _locationErrorMessage(e);
      debugPrint('Qibla refresh location exception: $e');
    } catch (e) {
      _errorMessage =
          'Could not refresh Qibla data. Please try again.';
      debugPrint('Qibla refresh error: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _resolveCityName(double lat, double lng) async {
    try {
      final city = await _locationService.getCityFromCoordinates(lat, lng);
      _cityName = city.isNotEmpty ? city : 'Unknown Location';
    } catch (e) {
      _cityName = 'Unknown Location';
      debugPrint('Qibla reverse geocode failed: $e');
    }
  }

  Future<void> _fetchQibla(double lat, double lng) async {
    _qiblaData = await _qiblaService.getQiblaDirection(lat, lng);
  }

  /// Open location settings (used by the error view)
  Future<void> openLocationSettings() =>
      _locationService.openLocationSettings();

  /// Open app settings (used by the error view)
  Future<void> openAppSettings() => _locationService.openAppSettings();

  // ---------------------------------------------------------------------------
  // Compass sensor handling
  // ---------------------------------------------------------------------------

  /// Start listening to the device rotation sensor (called automatically
  /// when the Qibla screen opens — no permission prompt is required)
  void startCompass() {
    if (_orientationSubscription != null) return;

    if (!RotationSensor.isPlatformSupported) {
      _compassStatus = CompassStatus.unavailable;
      notifyListeners();
      return;
    }

    RotationSensor.samplingPeriod = SensorInterval.uiInterval;

    _orientationSubscription = RotationSensor.orientationStream.listen(
      (event) {
        // Azimuth is in radians 0..2π, 0 = north, clockwise-positive
        final degrees =
            (event.eulerAngles.azimuth * 180 / math.pi + 360) % 360;
        _heading = _hasHeading ? _smoothAngle(_heading, degrees, 0.25) : degrees;
        _hasHeading = true;

        // Accuracy is in radians; -1 when the platform can't report it
        final CompassStatus status;
        if (event.accuracy < 0) {
          status = CompassStatus.approximate;
        } else {
          final accuracyDeg = event.accuracy * 180 / math.pi;
          status = accuracyDeg <= _calibratedAccuracyDeg
              ? CompassStatus.calibrated
              : CompassStatus.approximate;
        }
        _compassStatus = status;
        notifyListeners();
      },
      onError: (Object e) {
        debugPrint('Rotation sensor error: $e');
        _orientationSubscription = null;
        _compassStatus = CompassStatus.unavailable;
        _hasHeading = false;
        notifyListeners();
      },
      cancelOnError: true,
    );
    notifyListeners();
  }

  /// Stop listening to the rotation sensor
  void stopCompass() {
    _orientationSubscription?.cancel();
    _orientationSubscription = null;
  }

  /// Exponential smoothing across the 0/360 boundary (same as the reference)
  double _smoothAngle(double current, double target, double factor) {
    final diff = ((target - current + 540) % 360) - 180;
    return (current + diff * factor + 360) % 360;
  }

  String _locationErrorMessage(LocationException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('disabled')) {
      return 'Location services are disabled. Please enable GPS to find the Qibla direction.';
    }
    if (msg.contains('permanently')) {
      return 'Location permission permanently denied. Please enable it in app settings.';
    }
    if (msg.contains('denied')) {
      return 'Location permission denied. Please grant location access to find the Qibla direction.';
    }
    if (msg.contains('timeout')) {
      return 'Location request timed out. Please try again.';
    }
    return e.message;
  }

  @override
  void dispose() {
    _orientationSubscription?.cancel();
    _qiblaService.dispose();
    super.dispose();
  }
}
