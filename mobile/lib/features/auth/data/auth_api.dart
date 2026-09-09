import '../../../core/network/api_client.dart';

class AuthApi {
  AuthApi._();

  static Future<Map<String, dynamic>> verifyMsg91Token({
    required String accessToken,
    String? role,
  }) async {
    final response = await ApiClient.dio.post(
      '/api/auth/msg91/verify',
      data: {
        'accessToken': accessToken,
        if (role != null) 'role': role,
      },
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  static Future<Map<String, dynamic>> requestMockOtp({
    required String mobileNumber,
    required String role,
  }) async {
    final response = await ApiClient.dio.post(
      '/api/auth/mobile',
      data: {
        'mobileNumber': mobileNumber,
        'role': role,
      },
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  static Future<Map<String, dynamic>> verifyMockOtp({
    required String mobileNumber,
    required String otp,
    required String role,
  }) async {
    final response = await ApiClient.dio.post(
      '/api/auth/verify-otp',
      data: {
        'mobileNumber': mobileNumber,
        'otp': otp,
        'role': role,
      },
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  static Future<Map<String, dynamic>> getMe() async {
    final response = await ApiClient.dio.get(
      '/api/auth/me',
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }
}