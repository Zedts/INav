import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../models/mosque_model.dart';
import '../services/location_service.dart';
import '../services/mosque_service.dart';

class MosqueProvider extends ChangeNotifier {
  final LocationService _locationService;
  final MosqueService _mosqueService;
  final Stopwatch _positionFreshness = Stopwatch();

  LatLng? _userLatLng;
  String _cityName = 'Locating…';
  List<MosqueModel> _nearbyMosques = [];
  bool _loading = false;
  String? _errorMessage;
  bool _isMapExpanded = false;
  String? _selectedMosqueId;
  String? _featuredMosqueId;
  final List<String> _favoriteMosqueIds = [];
  bool _isSidebarOpen = false;

  MosqueProvider({
    LocationService? locationService,
    MosqueService? mosqueService,
  })  : _locationService = locationService ?? LocationService(),
        _mosqueService = mosqueService ?? MosqueService();

  LatLng? get userLatLng => _userLatLng;
  String get cityName => _cityName;
  List<MosqueModel> get nearbyMosques => List.unmodifiable(_nearbyMosques);
  MosqueModel? get nearestMosque =>
      _nearbyMosques.isNotEmpty ? _nearbyMosques.first : null;
  bool get isLoading => _loading;
  String? get errorMessage => _errorMessage;
  bool get isMapExpanded => _isMapExpanded;
  String? get selectedMosqueId => _selectedMosqueId;
  bool get isSidebarOpen => _isSidebarOpen;
  List<String> get favoriteMosqueIds => List.unmodifiable(_favoriteMosqueIds);

  MosqueModel? get selectedMosque => _mosqueById(_selectedMosqueId);

  MosqueModel? get featuredMosque {
    if (_featuredMosqueId != null) {
      final m = _mosqueById(_featuredMosqueId);
      if (m != null) return m;
    }
    return nearestMosque;
  }

  bool get isFeaturedOverridden {
    final nearest = nearestMosque;
    if (nearest == null || _featuredMosqueId == null) return false;
    return _featuredMosqueId != nearest.id;
  }

  List<MosqueModel> get favoriteMosques {
    return _favoriteMosqueIds
        .map(_mosqueById)
        .whereType<MosqueModel>()
        .toList();
  }

  MosqueModel? _mosqueById(String? id) {
    if (id == null) return null;
    final idx = _nearbyMosques.indexWhere((m) => m.id == id);
    return idx == -1 ? null : _nearbyMosques[idx];
  }

  Future<void> initialize() async {
    if (_loading) return;
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final pos = await _locationService.getCurrentPosition();
      _userLatLng = LatLng(pos.latitude, pos.longitude);
      _positionFreshness
        ..reset()
        ..start();
      try {
        final city = await _locationService.getCityFromCoordinates(
          pos.latitude,
          pos.longitude,
        );
        _cityName = city.isNotEmpty ? city : 'Unknown Location';
      } catch (e) {
        _cityName = 'Unknown Location';
        debugPrint('Reverse geocode lookup failed: $e');
      }

      await _loadNearby(pos.latitude, pos.longitude);
    } on LocationException catch (e) {
      _errorMessage = _locationErrorMessage(e);
      debugPrint('Location exception: $e');
    } on MosqueServiceException catch (e) {
      _errorMessage = e.message;
      debugPrint('Mosque service exception: $e');
    } catch (e) {
      _errorMessage =
          'Something went wrong while finding nearby mosques. Please pull down to refresh.';
      debugPrint('Mosque init error: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh({bool forceRefreshLocation = false}) async {
    if (_loading) return;
    _loading = true;
    _errorMessage = null;
    resetFeaturedToNearest(silent: true);
    notifyListeners();

    double lat;
    double lng;
    final cached = _userLatLng;
    final stale = !_positionFreshness.isRunning ||
        _positionFreshness.elapsed > const Duration(seconds: 60);
    try {
      if (cached != null && !forceRefreshLocation && !stale) {
        lat = cached.latitude;
        lng = cached.longitude;
      } else {
        final pos = await _locationService.getCurrentPosition();
        _userLatLng = LatLng(pos.latitude, pos.longitude);
        _positionFreshness
          ..reset()
          ..start();
        lat = pos.latitude;
        lng = pos.longitude;
        try {
          final city = await _locationService.getCityFromCoordinates(lat, lng);
          if (city.isNotEmpty) _cityName = city;
        } catch (_) {}
      }

      await _loadNearby(lat, lng);
      resetFeaturedToNearest(silent: true);
    } on LocationException catch (e) {
      _errorMessage = _refreshLocationErrorMessage(e);
      debugPrint('Refresh location exception: $e');
    } on MosqueServiceException catch (e) {
      _errorMessage = e.message;
      debugPrint('Refresh mosque service exception: $e');
    } catch (e) {
      _errorMessage =
          'Could not refresh nearby mosques. Check your connection.';
      debugPrint('Refresh error: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  @Deprecated('Use refresh() instead')
  Future<void> refreshNearbyMosques({bool forceRefreshLocation = true}) =>
      refresh(forceRefreshLocation: forceRefreshLocation);

  String _locationErrorMessage(LocationException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('permission') || msg.contains('denied')) {
      return 'Location permission denied. Please enable location access in Settings to find nearby mosques.';
    }
    if (msg.contains('disabled') || msg.contains('turned off')) {
      return 'Location services are disabled. Please turn on GPS to find nearby mosques.';
    }
    return 'Could not determine your location. Please pull down to refresh.';
  }

  String _refreshLocationErrorMessage(LocationException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('permission') || msg.contains('denied')) {
      return 'Location permission denied. Please enable it in Settings.';
    }
    if (msg.contains('disabled')) {
      return 'Location services are disabled. Enable GPS and try again.';
    }
    return 'Could not refresh nearby mosques. Check your connection.';
  }

  Future<void> _loadNearby(double lat, double lng) async {
    final results = await _mosqueService.findNearby(lat, lng);
    if (results.isEmpty) {
      _nearbyMosques = [];
      _errorMessage =
          'No mosques found nearby. Try again later or from a different area.';
    } else {
      _nearbyMosques = results;
    }
  }

  void toggleMapExpanded() {
    _isMapExpanded = !_isMapExpanded;
    notifyListeners();
  }

  void setMapExpanded(bool expanded) {
    _isMapExpanded = expanded;
    notifyListeners();
  }

  void setFeaturedMosque(MosqueModel mosque) {
    _featuredMosqueId = mosque.id;
    _selectedMosqueId = mosque.id;
    notifyListeners();
  }

  void resetFeaturedToNearest({bool silent = false}) {
    _featuredMosqueId = null;
    _selectedMosqueId = nearestMosque?.id;
    if (!silent) notifyListeners();
  }

  void selectMosque(MosqueModel mosque) {
    setFeaturedMosque(mosque);
  }

  void clearSelection() {
    resetFeaturedToNearest();
  }

  void toggleFavorite(String mosqueId) {
    final idx = _favoriteMosqueIds.indexOf(mosqueId);
    if (idx >= 0) {
      _favoriteMosqueIds.removeAt(idx);
    } else {
      _favoriteMosqueIds.add(mosqueId);
    }
    notifyListeners();
  }

  void toggleFavoriteMosque(MosqueModel mosque) {
    toggleFavorite(mosque.id);
  }

  bool isFavorite(String mosqueId) => _favoriteMosqueIds.contains(mosqueId);

  void openSidebar() {
    _isSidebarOpen = true;
    notifyListeners();
  }

  void closeSidebar() {
    _isSidebarOpen = false;
    notifyListeners();
  }

  void toggleSidebar() {
    _isSidebarOpen = !_isSidebarOpen;
    notifyListeners();
  }

  Future<bool> navigateTo(MosqueModel mosque) async {
    final here = _userLatLng;
    if (here == null) {
      _errorMessage = 'Your location is not available. Please refresh first.';
      notifyListeners();
      return false;
    }
    final ok = await MapLauncherService.launchDirections(
      originLat: here.latitude,
      originLng: here.longitude,
      destLat: mosque.latitude,
      destLng: mosque.longitude,
      travelMode: 'walking',
    );
    if (!ok) {
      _errorMessage =
          'Unable to open Maps. Google Maps app may not be installed.';
      notifyListeners();
    }
    return ok;
  }

  Future<bool> openMosqueInMaps(MosqueModel mosque) async {
    return MapLauncherService.launchPoint(
      destLat: mosque.latitude,
      destLng: mosque.longitude,
      label: mosque.name,
    );
  }

  Future<void> openLocationSettings() async {
    try {
      await _locationService.openAppSettings();
    } catch (e) {
      debugPrint('Failed to open settings: $e');
    }
  }

  @override
  void dispose() {
    _positionFreshness.stop();
    super.dispose();
  }
}
