import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class AuthApiException implements Exception {
  const AuthApiException(this.message, this.statusCode);

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class AuthApi {
  AuthApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path) => Uri.parse('${AppConfig.apiBaseUrl}$path');

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _client
          .post(
            _uri(path),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));

      final decoded = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AuthApiException(
          decoded['message']?.toString() ?? 'Authentication request failed',
          response.statusCode,
        );
      }
      return decoded;
    } on AuthApiException {
      rethrow;
    } on FormatException {
      throw const AuthApiException('The server returned an invalid response', null);
    } catch (_) {
      throw const AuthApiException(
        'Unable to reach the authentication service. Check your connection.',
        null,
      );
    }
  }

  Future<String> sendOtp(String identifier) async {
    final response = await _post(
      '/api/auth/msg91/send-otp',
      {'identifier': identifier},
    );
    if (response['type'] != 'success') {
      throw const AuthApiException('MSG91 could not send the OTP', null);
    }
    return response['message'].toString();
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String reqId,
    required String otp,
  }) => _post(
        '/api/auth/msg91/verify-otp',
        {'reqId': reqId, 'otp': otp},
      );

  Future<void> resendOtp(String reqId) async {
    final response = await _post(
      '/api/auth/msg91/retry-otp',
      {'reqId': reqId},
    );
    if (response['type'] != 'success') {
      throw const AuthApiException('MSG91 could not resend the OTP', null);
    }
  }

  Future<Map<String, dynamic>> verifyAccessToken(String accessToken) => _post(
        '/api/auth/msg91/verify',
        {'accessToken': accessToken, 'role': 'BUYER'},
      );
}