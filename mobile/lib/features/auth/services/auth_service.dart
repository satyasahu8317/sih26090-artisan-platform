import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';

class AuthResponse {
  final String token;
  final bool isNewUser;
  final String redirect;

  AuthResponse({
    required this.token,
    required this.isNewUser,
    required this.redirect,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String? ?? '',
      isNewUser: json['isNewUser'] as bool? ?? false,
      redirect: json['redirect'] as String? ?? '/buyer/home',
    );
  }
}

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _jwtStorageKey = 'app_jwt_token';

  /// Verifies the MSG91 widget accessToken with the backend
  /// and persists the application JWT.
  Future<AuthResponse> verifyMsg91AccessToken({
    required String accessToken,
    String role = 'BUYER',
  }) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/api/auth/msg91/verify');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'accessToken': accessToken,
          'role': role,
        }),
      ).timeout(const Duration(seconds: 15));

      Map<String, dynamic> responseBody = {};
      try {
        responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        responseBody = {'message': response.body};
      }

      if (response.statusCode == 200) {
        final authResult = AuthResponse.fromJson(responseBody);
        if (authResult.token.isNotEmpty) {
          await _storage.write(key: _jwtStorageKey, value: authResult.token);
        }
        return authResult;
      } else if (response.statusCode == 401) {
        throw const HttpException('Invalid or expired MSG91 session. Please try again.');
      } else if (response.statusCode == 403) {
        throw const HttpException('Access forbidden. Invalid role permissions.');
      } else {
        final msg = responseBody['message'] ?? 'Authentication failed with status ${response.statusCode}';
        throw HttpException(msg.toString());
      }
    } on SocketException {
      throw const SocketException('Unable to reach backend server. Please check your network connection.');
    }
  }

  /// Performs real database-backed guest authentication.
  /// Calls POST /api/auth/guest, stores the application JWT in secure storage,
  /// and returns the authentication details.
  Future<Map<String, dynamic>> loginAsGuest(String role) async {
    final normalizedRole = role.toUpperCase() == 'ARTISAN' || role.toLowerCase() == 'seller'
        ? 'ARTISAN'
        : 'BUYER';
    final url = Uri.parse('${AppConfig.apiBaseUrl}/api/auth/guest');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'role': normalizedRole}),
      ).timeout(const Duration(seconds: 15));

      Map<String, dynamic> responseBody = {};
      try {
        responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        responseBody = {'message': response.body};
      }

      if (response.statusCode == 200 && responseBody['success'] == true) {
        final token = responseBody['token'] as String? ?? '';
        if (token.isNotEmpty) {
          await _storage.write(key: _jwtStorageKey, value: token);
        }
        return {
          'token': token,
          'isGuest': responseBody['isGuest'] as bool? ?? true,
          'role': responseBody['role'] as String? ?? normalizedRole,
        };
      } else {
        final msg = responseBody['message'] ?? 'Guest login failed with status ${response.statusCode}';
        throw HttpException(msg.toString());
      }
    } on SocketException {
      throw const SocketException('Unable to reach backend server. Please check your network connection.');
    }
  }

  /// Updates the authenticated buyer's own profile via PATCH /api/v1/buyers/me
  Future<void> updateBuyerProfile(Map<String, dynamic> data) async {
    final token = await getSavedToken();
    if (token == null || token.isEmpty) {
      throw const HttpException('No auth token available. Please log in.');
    }

    final url = Uri.parse('${AppConfig.apiBaseUrl}/api/v1/buyers/me');
    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw HttpException('Failed to update buyer profile: ${response.body}');
    }
  }

  /// Updates the authenticated artisan's own profile via PATCH /api/v1/artisans/me
  Future<void> updateArtisanProfile(Map<String, dynamic> data) async {
    final token = await getSavedToken();
    if (token == null || token.isEmpty) {
      throw const HttpException('No auth token available. Please log in.');
    }

    final url = Uri.parse('${AppConfig.apiBaseUrl}/api/v1/artisans/me');
    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw HttpException('Failed to update artisan profile: ${response.body}');
    }
  }

  /// Retrieves the stored application JWT
  Future<String?> getSavedToken() async {
    return await _storage.read(key: _jwtStorageKey);
  }

  /// Clears the stored application JWT on logout
  Future<void> logout() async {
    await _storage.delete(key: _jwtStorageKey);
  }
}
