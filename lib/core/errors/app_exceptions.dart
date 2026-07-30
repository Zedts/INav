/// Shared application exceptions.
///
/// Every exception here carries a [message] that is ALWAYS safe to show
/// directly to the user (no URLs, stack traces, or internal details).
library;

/// Exception for API/network errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final bool isNetworkError;

  ApiException(this.message, {this.statusCode, this.isNetworkError = false});

  @override
  String toString() => message;
}

/// Exception for device location errors
class LocationException implements Exception {
  final String message;

  LocationException(this.message);

  @override
  String toString() => message;
}

/// Exception for mosque finder errors
class MosqueServiceException implements Exception {
  final String message;

  MosqueServiceException(this.message);

  @override
  String toString() => message;
}
