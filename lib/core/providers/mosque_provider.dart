import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../errors/error_messages.dart';
import '../models/mosque_model.dart';
import '../services/location_service.dart';
import '../services/mosque_service.dart';
import '../databases/app_database.dart';
import 'package:sqflite/sqflite.dart';

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
  final List<MosqueModel> _favoriteSnapshots = [];
  int? _userId;
  bool _isSidebarOpen = false;

  MosqueProvider({
    LocationService? locationService,
    MosqueService? mosqueService,
  }) : _locationService = locationService ?? LocationService(),
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
    return List.unmodifiable(_favoriteSnapshots);
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
      // Service messages are already user-friendly and consistent
      _errorMessage = e.message;
      debugPrint('Location exception: $e');
    } on MosqueServiceException catch (e) {
      _errorMessage = e.message;
      debugPrint('Mosque service exception: $e');
    } catch (e) {
      _errorMessage = friendlyErrorMessage(
        e,
        fallback: ErrorMessages.mosquesLoadFailed,
      );
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
    final stale =
        !_positionFreshness.isRunning ||
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
      // Service messages are already user-friendly and consistent
      _errorMessage = e.message;
      debugPrint('Refresh location exception: $e');
    } on MosqueServiceException catch (e) {
      _errorMessage = e.message;
      debugPrint('Refresh mosque service exception: $e');
    } catch (e) {
      _errorMessage = friendlyErrorMessage(
        e,
        fallback: ErrorMessages.mosquesLoadFailed,
      );
      debugPrint('Refresh error: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  @Deprecated('Use refresh() instead')
  Future<void> refreshNearbyMosques({bool forceRefreshLocation = true}) =>
      refresh(forceRefreshLocation: forceRefreshLocation);

  Future<void> _loadNearby(double lat, double lng) async {
    final results = await _mosqueService.findNearby(lat, lng);
    if (results.isEmpty) {
      _nearbyMosques = [];
      _errorMessage = ErrorMessages.noMosquesFound;
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

  Future<void> setUser(int? userId) async {
    if (_userId == userId) return;
    _userId = userId;
    _favoriteMosqueIds.clear();
    _favoriteSnapshots.clear();
    if (userId != null) {
      final rows = await (await AppDatabase.database).query(
        'mosque_favorites',
        where: 'user_id=?',
        whereArgs: [userId],
      );
      for (final row in rows) {
        final m = MosqueModel(
          id: row['mosque_id'] as String,
          name: row['name'] as String,
          address: (row['address'] as String?) ?? 'Address not available',
          latitude: row['latitude'] as double,
          longitude: row['longitude'] as double,
          distanceKm: 0,
        );
        _favoriteSnapshots.add(m);
        _favoriteMosqueIds.add(m.id);
      }
    }
    notifyListeners();
  }

  Future<void> toggleFavoriteMosque(MosqueModel mosque) async {
    final mosqueId = mosque.id;
    final idx = _favoriteMosqueIds.indexOf(mosqueId);
    if (idx >= 0) {
      _favoriteMosqueIds.removeAt(idx);
      _favoriteSnapshots.removeWhere((m) => m.id == mosqueId);
      if (_userId != null)
        await (await AppDatabase.database).delete(
          'mosque_favorites',
          where: 'user_id=? AND mosque_id=?',
          whereArgs: [_userId, mosqueId],
        );
    } else {
      _favoriteMosqueIds.add(mosqueId);
      _favoriteSnapshots.add(mosque);
      if (_userId != null)
        await (await AppDatabase.database).insert('mosque_favorites', {
          'user_id': _userId,
          'mosque_id': mosqueId,
          'name': mosque.name,
          'latitude': mosque.latitude,
          'longitude': mosque.longitude,
          'address': mosque.address,
          'created_at': DateTime.now().millisecondsSinceEpoch,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    notifyListeners();
  }

  Future<void> toggleFavorite(String mosqueId) async {
    final mosque = _mosqueById(mosqueId);
    if (mosque != null) await toggleFavoriteMosque(mosque);
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
      _errorMessage = ErrorMessages.locationNotReady;
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
      _errorMessage = ErrorMessages.mapsUnavailable;
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
