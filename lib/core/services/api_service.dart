import 'dart:convert';
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
              throw ApiException('Request timeout', statusCode: 408);
            },
          );

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: ${e.toString()}');
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
            data['message'] as String? ?? 'API request failed',
            statusCode: response.statusCode,
          );
        }

        return data;
      } catch (e) {
        if (e is ApiException) rethrow;
        throw ApiException('Failed to parse response: ${e.toString()}');
      }
    } else {
      throw ApiException(
        'HTTP ${response.statusCode}: ${response.reasonPhrase}',
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
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() =>
      'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}
