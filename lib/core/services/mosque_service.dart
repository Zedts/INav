import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../errors/app_exceptions.dart';
import '../errors/error_messages.dart';
import '../models/mosque_model.dart';

// Keep existing `import 'mosque_service.dart'` sites working
export '../errors/app_exceptions.dart' show MosqueServiceException;

class MosqueService {
  final http.Client _httpClient;
  final String _primaryBaseUrl;
  final String _secondaryBaseUrl;
  final Duration _timeout;

  MosqueService({
    http.Client? httpClient,
    String? primaryBaseUrl,
    String? secondaryBaseUrl,
    Duration? timeout,
  })  : _httpClient = httpClient ?? http.Client(),
        _primaryBaseUrl =
            primaryBaseUrl ??
            dotenv.env['MOSQUE_FINDER_API_BASE_URL']!,
        _secondaryBaseUrl =
            secondaryBaseUrl ??
            dotenv.env['MOSQUE_FINDER_API_BASE_URL_ALT']!,
        _timeout = timeout ?? const Duration(seconds: 20);

  Future<List<MosqueModel>> findNearby(
    double lat,
    double lng, {
    double radiusKm = 5.0,
    int limit = 20,
  }) async {
    final results = await Future.wait([
      _queryPrimary(lat, lng, radiusKm, limit),
      _querySecondary(lat, lng, radiusKm, limit),
    ]);

    final combined = <MosqueModel>[
      ...?results[0].mosques,
      ...?results[1].mosques,
    ];

    if (combined.isEmpty) {
      // If every source failed because of connectivity, surface a friendly
      // network message instead of a misleading "no mosques found" state.
      final allNetworkFailures =
          results.every((r) => r.mosques == null && r.isNetworkError);
      if (allNetworkFailures) {
        throw MosqueServiceException(ErrorMessages.noInternet);
      }
      return [];
    }

    final enriched = combined
        .map(
          (m) => m.copyWith(
            distanceKm:
                m.distanceKm > 0
                    ? m.distanceKm
                    : _distanceKm(lat, lng, m.latitude, m.longitude),
          ),
        )
        .toList();

    final deduped = <String, MosqueModel>{};
    for (final m in enriched) {
      deduped[m.dedupeKey] = m;
    }

    final sorted = deduped.values.toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    return sorted.take(limit).toList();
  }

  static final _distance = const Distance();

  static double _distanceKm(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    final meters = _distance(
      LatLng(lat1, lng1),
      LatLng(lat2, lng2),
    );
    return meters / 1000.0;
  }

  Future<_MosqueQueryResult> _queryPrimary(
    double lat,
    double lng,
    double radiusKm,
    int limit,
  ) async {
    try {
      final uri = Uri.parse(_primaryBaseUrl).replace(
        queryParameters: {
          'lat': lat.toString(),
          'lon': lng.toString(),
          'radius': radiusKm.toString(),
          'limit': limit.toString(),
        },
      );
      final response = await _httpClient.get(uri).timeout(_timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint(
          'Primary mosque API HTTP ${response.statusCode}: $uri',
        );
      }
      return _MosqueQueryResult(
        _parseResponse(response.body, response.statusCode, lat, lng),
      );
    } on TimeoutException catch (e, st) {
      debugPrint('Primary mosque API timeout: $e $st');
      return const _MosqueQueryResult(null, isNetworkError: true);
    } on SocketException catch (e, st) {
      debugPrint('Primary mosque API socket: $e $st');
      return const _MosqueQueryResult(null, isNetworkError: true);
    } on http.ClientException catch (e, st) {
      debugPrint('Primary mosque API client: $e $st');
      return const _MosqueQueryResult(null, isNetworkError: true);
    } on FormatException catch (e, st) {
      debugPrint('Primary mosque API parse: $e $st');
      return const _MosqueQueryResult(null);
    } catch (e, st) {
      debugPrint('Primary mosque API unknown: $e $st');
      return const _MosqueQueryResult(null);
    }
  }

  Future<_MosqueQueryResult> _querySecondary(
    double lat,
    double lng,
    double radiusKm,
    int limit,
  ) async {
    try {
      final base = Uri.parse(_secondaryBaseUrl);
      final path =
          base.path.contains('/v1/masjids/search')
              ? base.path
              : '/v1/masjids/search';
      final uri = base.replace(
        path: path,
        queryParameters: {
          'lat': lat.toString(),
          'lng': lng.toString(),
          'rad': (radiusKm * 1000).round().toString(),
        },
      );
      final response = await _httpClient.get(uri).timeout(_timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint(
          'Secondary mosque API HTTP ${response.statusCode}: $uri',
        );
      }
      final parsed = _parseResponse(response.body, response.statusCode, lat, lng);
      if (parsed == null) return const _MosqueQueryResult(null);
      return _MosqueQueryResult(parsed.take(limit).toList());
    } on TimeoutException catch (e, st) {
      debugPrint('Secondary mosque API timeout: $e $st');
      return const _MosqueQueryResult(null, isNetworkError: true);
    } on SocketException catch (e, st) {
      debugPrint('Secondary mosque API socket: $e $st');
      return const _MosqueQueryResult(null, isNetworkError: true);
    } on http.ClientException catch (e, st) {
      debugPrint('Secondary mosque API client: $e $st');
      return const _MosqueQueryResult(null, isNetworkError: true);
    } on FormatException catch (e, st) {
      debugPrint('Secondary mosque API parse: $e $st');
      return const _MosqueQueryResult(null);
    } catch (e, st) {
      debugPrint('Secondary mosque API unknown: $e $st');
      return const _MosqueQueryResult(null);
    }
  }

  List<MosqueModel>? _parseResponse(
    String body,
    int statusCode,
    double fallbackLat,
    double fallbackLng,
  ) {
    if (statusCode < 200 || statusCode >= 300) return null;
    if (body.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(body);
      final list = _extractList(decoded);
      if (list == null) return null;
      final out = <MosqueModel>[];
      for (final item in list) {
        if (item is! Map<String, dynamic>) continue;
        try {
          out.add(
            MosqueModel.fromJson(
              item,
              fallbackLat: fallbackLat,
              fallbackLng: fallbackLng,
            ),
          );
        } catch (_) {
          continue;
        }
      }
      return out.isEmpty ? null : out;
    } on FormatException {
      return null;
    } catch (e) {
      debugPrint('Unknown JSON parse error: $e');
      return null;
    }
  }

  List<dynamic>? _extractList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      const candidates = [
        'data',
        'mosques',
        'masjids',
        'results',
        'items',
        'places',
        'nearby',
      ];
      for (final key in candidates) {
        final v = decoded[key];
        if (v is List) return v;
        if (v is Map<String, dynamic>) {
          for (final inner in candidates) {
            final w = v[inner];
            if (w is List) return w;
          }
        }
      }
    }
    return null;
  }
}

/// Internal result of a single mosque API query, letting [MosqueService]
/// tell the difference between "no data" and a connectivity failure.
class _MosqueQueryResult {
  final List<MosqueModel>? mosques;
  final bool isNetworkError;

  const _MosqueQueryResult(this.mosques, {this.isNetworkError = false});
}

class MapLauncherService {
  static Future<bool> launchDirections({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String travelMode = 'walking',
  }) async {
    final dest = '$destLat,$destLng';
    final origin = '$originLat,$originLng';

    final androidNav = Uri(
      scheme: 'google.navigation',
      queryParameters: {'q': dest, 'mode': _navMode(travelMode)},
    );

    try {
      if (Platform.isAndroid) {
        if (await canLaunchUrl(androidNav)) {
          return await launchUrl(
            androidNav,
            mode: LaunchMode.externalApplication,
          );
        }
      }
    } catch (e, st) {
      debugPrint('Google navigation intent skipped: $e $st');
    }

    final modeParam =
        (travelMode == 'walking')
            ? 'walking'
            : (travelMode == 'driving' ? 'driving' : 'transit');
    final universal = Uri.https(
      'www.google.com',
      '/maps/dir/',
      {
        'api': '1',
        'origin': origin,
        'destination': dest,
        'travelmode': modeParam,
      },
    );

    try {
      if (await canLaunchUrl(universal)) {
        return await launchUrl(
          universal,
          mode: LaunchMode.externalApplication,
        );
      }
      return await launchUrl(
        universal,
        mode: LaunchMode.platformDefault,
      );
    } catch (e, st) {
      debugPrint('Unable to launch maps: $e $st');
      return false;
    }
  }

  static String _navMode(String travelMode) {
    switch (travelMode) {
      case 'driving':
        return 'd';
      case 'transit':
        return 'r';
      case 'walking':
      default:
        return 'w';
    }
  }

  static Future<bool> launchPoint({
    required double destLat,
    required double destLng,
    required String label,
  }) async {
    final query = Uri.encodeQueryComponent('$destLat,$destLng ($label)');
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e, st) {
      debugPrint('Unable to open maps: $e $st');
      return false;
    }
  }
}

@visibleForTesting
LatLng latLngForTest(double lat, double lng) => LatLng(lat, lng);
