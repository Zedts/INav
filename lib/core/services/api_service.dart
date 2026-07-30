import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../errors/app_exceptions.dart';
import '../errors/error_messages.dart';

// Keep existing `import 'api_service.dart'` sites working for ApiException
export '../errors/app_exceptions.dart' show ApiException;

/// Base API service for handling HTTP requests
class ApiService {
  static final String _defaultBaseUrl =
      dotenv.env['MYQURAN_API_BASE_URL']!;

  final String _baseUrl;
  final http.Client _client;

  ApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? _defaultBaseUrl;

  /// GET request with error handling
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');

      final response = await _client
          .get(url, headers: {'Accept': 'application/json', ...?headers})
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw ApiException(
                ErrorMessages.requestTimeout,
                statusCode: 408,
                isNetworkError: true,
              );
            },
          );

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } on http.ClientException catch (e) {
      // Covers SocketException wrapped by the http package (no internet,
      // DNS failure, connection refused). Log details, never expose the URL.
      debugPrint('ApiService network error on $endpoint: $e');
      throw ApiException(
        ErrorMessages.noInternet,
        isNetworkError: true,
      );
    } catch (e) {
      debugPrint('ApiService unexpected error on $endpoint: $e');
      final msg = e.toString();
      if (msg.contains('SocketException') ||
          msg.contains('Failed host lookup') ||
          msg.contains('Connection refused') ||
          msg.contains('Network is unreachable')) {
        throw ApiException(
          ErrorMessages.noInternet,
          isNetworkError: true,
        );
      }
      throw ApiException(ErrorMessages.serverContactFailed);
    }
  }

  /// Handle HTTP response and errors
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Check if API returned status: false
        if (data['status'] == false) {
          throw ApiException(
            ErrorMessages.requestRejected,
            statusCode: response.statusCode,
          );
        }

        return data;
      } catch (e) {
        if (e is ApiException) rethrow;
        debugPrint('ApiService parse error: $e');
        throw ApiException(ErrorMessages.unexpectedResponse);
      }
    } else {
      debugPrint(
        'ApiService HTTP ${response.statusCode}: ${response.reasonPhrase}',
      );
      throw ApiException(
        response.statusCode >= 500
            ? ErrorMessages.serverUnavailable
            : ErrorMessages.dataUnavailable,
        statusCode: response.statusCode,
      );
    }
  }

  /// Dispose HTTP client
  void dispose() {
    _client.close();
  }
}
