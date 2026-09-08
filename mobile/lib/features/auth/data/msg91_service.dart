import 'package:sendotp_flutter_sdk/sendotp_flutter_sdk.dart';

import '../../../core/config/msg91_config.dart';

/// Thrown for any MSG91 OTP Widget failure: send OTP, retry OTP or verify
/// OTP. [message] is safe to show directly to the user.
class Msg91Exception implements Exception {
  final String message;

  const Msg91Exception(this.message);

  @override
  String toString() => message;
}

/// Result of a successful [Msg91Service.sendOtp] call.
class Msg91SendOtpResult {
  final String reqId;

  const Msg91SendOtpResult({required this.reqId});
}

/// Thin wrapper around the `sendotp_flutter_sdk` (MSG91 OTP Widget) package.
///
/// This is the ONLY place in the app that talks to the MSG91 SDK directly.
/// It never talks to our own backend - see [AuthApi]/[AuthRepository] for
/// that. This keeps the MSG91 SDK isolated from the backend API layer, as
/// required by the app's architecture.
///
/// Reference (verified against the published package + its official
/// example app):
/// https://pub.dev/documentation/sendotp_flutter_sdk/latest
/// https://pub.dev/packages/sendotp_flutter_sdk/example
///
/// `OTPWidget.sendOTP` / `retryOTP` / `verifyOTP` all resolve to a
/// response shaped like `{'type': 'success' | <other>, 'message': <String>}`.
/// On success:
///   - sendOTP's `message` is the `reqId` needed for retry/verify.
///   - verifyOTP's `message` is the MSG91 accessToken (JWT) to send to our
///     backend.
/// On failure, `type` is not `'success'` and `message` holds the error
/// description returned by MSG91.
class Msg91Service {
  Msg91Service._();

  static bool _initialized = false;

  /// Initializes the MSG91 OTP widget using the widgetId/authToken supplied
  /// via --dart-define (see [Msg91Config]). Safe to call more than once.
  static void _ensureInitialized() {
    if (_initialized) return;

    if (!Msg91Config.isConfigured) {
      throw const Msg91Exception(
        'OTP service is not configured on this build. '
        'Missing MSG91 widget ID / auth token.',
      );
    }

    OTPWidget.initializeWidget(
      Msg91Config.widgetId,
      Msg91Config.tokenAuth,
    );
    _initialized = true;
  }

  /// Sends an OTP to the given 10-digit Indian mobile number.
  ///
  /// Returns the MSG91 `reqId`, which must be passed to [verifyOtp] /
  /// [retryOtp] for this OTP attempt.
  static Future<Msg91SendOtpResult> sendOtp(String tenDigitPhone) async {
    _ensureInitialized();

    // MSG91's identifier must be the country code + number, WITHOUT a
    // leading '+' (verified against the SDK's official documentation).
    final identifier = '91$tenDigitPhone';

    dynamic response;
    try {
      response = await OTPWidget.sendOTP({'identifier': identifier});
    } catch (_) {
      throw const Msg91Exception(
        'Could not reach the OTP service. Please check your connection '
        'and try again.',
      );
    }

    if (response == null) {
      throw const Msg91Exception('Failed to send OTP. Please try again.');
    }

    if (response['type'] != 'success') {
      throw Msg91Exception(
        _extractErrorMessage(
          response,
          fallback: 'Failed to send OTP. Please try again.',
        ),
      );
    }

    final reqId = response['message'];
    if (reqId is! String || reqId.isEmpty) {
      throw const Msg91Exception(
        'OTP was sent but no request ID was returned.',
      );
    }

    return Msg91SendOtpResult(reqId: reqId);
  }

  /// Resends/retries an OTP for an existing [reqId].
  ///
  /// [retryChannel] is optional - only pass it if the widget is configured
  /// with more than one channel (SMS-11, VOICE-4, EMAIL-3, WHATSAPP-12).
  static Future<void> retryOtp({
    required String reqId,
    int? retryChannel,
  }) async {
    _ensureInitialized();

    dynamic response;
    try {
      response = await OTPWidget.retryOTP({
        'reqId': reqId,
        if (retryChannel != null) 'retryChannel': retryChannel,
      });
    } catch (_) {
      throw const Msg91Exception(
        'Could not reach the OTP service. Please check your connection '
        'and try again.',
      );
    }

    if (response == null || response['type'] != 'success') {
      throw Msg91Exception(
        _extractErrorMessage(
          response,
          fallback: 'Failed to resend OTP. Please try again.',
        ),
      );
    }
  }

  /// Verifies the [otp] entered by the user against [reqId].
  ///
  /// Returns the MSG91 accessToken on success - this must be sent to our
  /// backend's `/api/auth/msg91/verify` endpoint. The 4-digit OTP itself
  /// is NEVER sent to our backend.
  static Future<String> verifyOtp({
    required String reqId,
    required String otp,
  }) async {
    _ensureInitialized();

    dynamic response;
    try {
      response = await OTPWidget.verifyOTP({'reqId': reqId, 'otp': otp});
    } catch (_) {
      throw const Msg91Exception(
        'Could not reach the OTP service. Please check your connection '
        'and try again.',
      );
    }

    if (response == null) {
      throw const Msg91Exception(
        'OTP verification failed. Please try again.',
      );
    }

    if (response['type'] != 'success') {
      throw Msg91Exception(
        _extractErrorMessage(
          response,
          fallback: 'Invalid or expired OTP. Please try again.',
        ),
      );
    }

    final accessToken = response['message'];
    if (accessToken is! String || accessToken.isEmpty) {
      throw const Msg91Exception(
        'OTP verified but no access token was returned by MSG91.',
      );
    }

    return accessToken;
  }

  static String _extractErrorMessage(
    dynamic response, {
    required String fallback,
  }) {
    try {
      final message = response?['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    } catch (_) {
      // response wasn't map-like; fall through to fallback.
    }
    return fallback;
  }
}
