import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
                'The request timed out. Please check your connection and try again.',
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
        'No internet connection. Please check your network and try again.',
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
          'No internet connection. Please check your network and try again.',
          isNetworkError: true,
        );
      }
      throw ApiException(
        'Something went wrong while contacting the server. Please try again.',
      );
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
            'The service could not process the request. Please try again later.',
            statusCode: response.statusCode,
          );
        }

        return data;
      } catch (e) {
        if (e is ApiException) rethrow;
        debugPrint('ApiService parse error: $e');
        throw ApiException(
          'Received an unexpected response from the server. Please try again later.',
        );
      }
    } else {
      debugPrint(
        'ApiService HTTP ${response.statusCode}: ${response.reasonPhrase}',
      );
      throw ApiException(
        response.statusCode >= 500
            ? 'The server is currently unavailable. Please try again later.'
            : 'The requested data could not be loaded. Please try again later.',
        statusCode: response.statusCode,
      );
    }
  }

  /// Dispose HTTP client
  void dispose() {
    _client.close();
  }
}

/// Custom exception for API errors
///
/// [message] is always safe to show directly to the user (no URLs,
/// stack traces, or internal details).
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final bool isNetworkError;

  ApiException(this.message, {this.statusCode, this.isNetworkError = false});

  @override
  String toString() => message;
}
