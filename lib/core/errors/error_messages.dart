import 'app_exceptions.dart';

/// Single source of truth for every user-facing error message in the app.
///
/// Rule: the SAME error must always produce the SAME message, no matter
/// which screen or feature it happens in. Never hard-code an error string
/// elsewhere — add it here and reference the constant.
class ErrorMessages {
  ErrorMessages._();

  // ---------------------------------------------------------------------
  // Network / API
  // ---------------------------------------------------------------------
  static const String noInternet =
      'No internet connection. Please check your network and try again.';
  static const String requestTimeout =
      'The request timed out. Please check your connection and try again.';
  static const String serverUnavailable =
      'The server is currently unavailable. Please try again later.';
  static const String dataUnavailable =
      'The requested data could not be loaded. Please try again later.';
  static const String unexpectedResponse =
      'Received an unexpected response from the server. Please try again later.';
  static const String requestRejected =
      'The service could not process the request. Please try again later.';
  static const String serverContactFailed =
      'Something went wrong while contacting the server. Please try again.';
  static const String genericTryAgain =
      'Something went wrong. Please try again.';

  // ---------------------------------------------------------------------
  // Location
  // ---------------------------------------------------------------------
  static const String locationServicesDisabled =
      'Location services are disabled. Please enable GPS in settings.';
  static const String locationPermissionDenied =
      'Location permission denied. Please grant location access in settings.';
  static const String locationPermissionPermanentlyDenied =
      'Location permission permanently denied. Please enable it in app settings.';
  static const String locationTimeout =
      'The location request timed out. Please try again.';
  static const String locationUnavailable =
      'Could not determine your location. Please try again.';
  static const String cityLookupFailed =
      'Could not look up your city name. Please try again.';
  static const String locationDetailsFailed =
      'Could not look up your location details. Please try again.';
  static const String locationNotReady =
      'Your location is not available. Please refresh first.';

  // ---------------------------------------------------------------------
  // Feature-specific fallbacks (parse / unknown errors)
  // ---------------------------------------------------------------------
  static const String prayerTimesUnreadable =
      'Unable to read the prayer times data. Please try again later.';
  static const String prayerDataFailed =
      'Something went wrong while loading prayer data. Please try again.';
  static const String calendarUnavailable =
      'Unable to load the Islamic calendar. Please try again later.';
  static const String qiblaUnavailable =
      'Unable to determine the Qibla direction. Please try again.';
  static const String qiblaLoadFailed =
      'Something went wrong while loading the Qibla direction. Please try again.';
  static const String surahListFailed =
      'Unable to load the surah list. Please try again later.';
  static const String verseUnavailable =
      'Unable to load the verse of the day. Please try again later.';
  static const String mosquesLoadFailed =
      'Something went wrong while finding nearby mosques. Please try again.';
  static const String noMosquesFound =
      'No mosques found nearby. Try again later or from a different area.';

  // ---------------------------------------------------------------------
  // Actions / media
  // ---------------------------------------------------------------------
  static const String mapsUnavailable =
      'Unable to open Maps. Google Maps may not be installed.';
  static const String audioPlaybackFailed =
      'Unable to play audio. Please try again.';
  static const String audioStopFailed =
      'Unable to stop. Please try again.';
  static const String audioUnavailableForSurah =
      'Audio unavailable for this Surah';
}

/// Broad category of an error, derived from its user-facing message.
/// Used by the UI to pick a consistent icon/title for the same error.
enum ErrorCategory { offline, timeout, location, generic }

/// Classify a user-facing error message into an [ErrorCategory].
ErrorCategory categorizeErrorMessage(String message) {
  final lower = message.toLowerCase();
  if (lower.contains('internet') || lower.contains('network')) {
    return ErrorCategory.offline;
  }
  if (lower.contains('permission') ||
      lower.contains('location services') ||
      lower.contains('gps') ||
      lower.contains('your location')) {
    return ErrorCategory.location;
  }
  if (lower.contains('timed out') || lower.contains('timeout')) {
    return ErrorCategory.timeout;
  }
  return ErrorCategory.generic;
}

/// Convert ANY error into a message that is safe to show to the user.
///
/// App exceptions already carry friendly messages and pass through
/// unchanged; raw platform errors (sockets, timeouts, ...) are mapped to
/// the shared constants; anything unknown falls back to [fallback].
String friendlyErrorMessage(
  Object error, {
  String fallback = ErrorMessages.genericTryAgain,
}) {
  if (error is ApiException) return error.message;
  if (error is LocationException) return error.message;
  if (error is MosqueServiceException) return error.message;

  final msg = error.toString();
  if (msg.contains('SocketException') ||
      msg.contains('Failed host lookup') ||
      msg.contains('Connection refused') ||
      msg.contains('Network is unreachable') ||
      msg.contains('No internet')) {
    return ErrorMessages.noInternet;
  }
  if (msg.contains('TimeoutException') ||
      msg.contains('timed out') ||
      msg.contains('timeout')) {
    return ErrorMessages.requestTimeout;
  }
  return fallback;
}
