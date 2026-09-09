import 'package:dio/dio.dart';

import '../../../core/network/token_storage.dart';
import 'auth_api.dart';

/// Thrown when the backend `/api/auth/msg91/verify` call fails, or returns
/// an unexpected/incomplete payload. [message] is safe to show directly to
/// the user.
class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthRepository {
  AuthRepository._();

  static Future<AuthResult> verifyMsg91Token({
    required String accessToken,
    String? role,
  }) async {
    Map<String, dynamic> response;

    try {
      response = await AuthApi.verifyMsg91Token(
        accessToken: accessToken,
        role: role,
      );
    } on DioException catch (e) {
      throw AuthException(_mapDioError(e));
    }

    final token = response['token'];

    if (token is! String || token.isEmpty) {
      throw const AuthException(
        'Authentication token was not returned by server.',
      );
    }

    await TokenStorage.saveToken(token);

    return AuthResult(
      token: token,
      isNewUser: response['isNewUser'] == true,
      redirect: response['redirect'] as String?,
    );
  }static Future<AuthResult> requestMockOtp({
  required String mobileNumber,
  required String role,
}) async {
  try {
    final response = await AuthApi.requestMockOtp(
      mobileNumber: mobileNumber,
      role: role,
    );

    print('MOCK OTP REQUEST RESPONSE: $response');

    return const AuthResult(
      token: '',
      isNewUser: false,
      redirect: null,
    );
  } on DioException catch (e) {
    print('MOCK OTP REQUEST ERROR: ${e.response?.statusCode}');
    print('MOCK OTP REQUEST ERROR DATA: ${e.response?.data}');
    print('MOCK OTP REQUEST ERROR MESSAGE: ${e.message}');

    throw AuthException(_mapDioError(e));
  }
}
static Future<AuthResult> verifyMockOtp({
  required String mobileNumber,
  required String otp,
  required String role,
}) async {
  try {
    final response = await AuthApi.verifyMockOtp(
      mobileNumber: mobileNumber,
      otp: otp,
      role: role,
    );

    print('MOCK OTP VERIFY RESPONSE: $response');

    final token = response['token'];

    if (token is! String || token.isEmpty) {
      throw const AuthException(
        'Authentication token was not returned by server.',
      );
    }

    await TokenStorage.saveToken(token);

    return AuthResult(
      token: token,
      isNewUser: response['isNewUser'] == true,
      redirect: response['redirect'] as String?,
    );
  } on DioException catch (e) {
    print('MOCK OTP ERROR: ${e.response?.data}');
    throw AuthException(_mapDioError(e));
  }
}
  static Future<AuthSession?> verifyStoredSession() async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) return null;

    try {
      final response = await AuthApi.getMe();
      print('ME API RESPONSE: $response');
      final data = response['data'];
      final user = data is Map ? data['user'] : null;
      final role = user is Map ? user['role'] : null;

      if (role is! String || role.isEmpty) {
        throw const AuthException('Authenticated user role was not returned.');
      }

      return AuthSession(role: role);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        await TokenStorage.clearToken();
        throw const AuthSessionException();
      }
      throw AuthException(_mapDioError(e));
    }
  }

  static String _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'The connection timed out. Please check your internet and '
            'try again.';
      case DioExceptionType.connectionError:
        return 'Could not connect to the server. Please check your '
            'internet connection.';
      default:
        break;
    }

    final statusCode = e.response?.statusCode;
    final serverMessage = _extractServerMessage(e.response?.data);

    if (statusCode == 400) {
      return serverMessage ?? 'Invalid request. Please try again.';
    }
    if (statusCode == 401) {
      return serverMessage ?? 'Verification failed. Please request a new OTP.';
    }
    if (statusCode == 403) {
      return serverMessage ?? 'You are not allowed to perform this action.';
    }
    if (statusCode == 404) {
      return serverMessage ?? 'The requested resource was not found.';
    }
    if (statusCode != null && statusCode >= 500) {
      return serverMessage ??
          'The server ran into a problem. Please try again shortly.';
    }

    return serverMessage ?? 'Something went wrong. Please try again.';
  }

  static String? _extractServerMessage(dynamic data) {
    if (data is Map) {
      final message = data['message'] ?? data['error'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    return null;
  }
}

class AuthResult {
  final String token;
  final bool isNewUser;
  final String? redirect;

  const AuthResult({
    required this.token,
    required this.isNewUser,
    this.redirect,
  });
}

class AuthSessionException implements Exception {
  const AuthSessionException();
}

class AuthSession {
  final String role;

  const AuthSession({required this.role});
}