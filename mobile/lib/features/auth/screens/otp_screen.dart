import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sendotp_flutter_sdk/sendotp_flutter_sdk.dart';
import '../services/auth_service.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String reqId;
  final String role;

  const OtpScreen({
    super.key,
    this.phoneNumber = '',
    this.reqId = '',
    this.role = 'BUYER',
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());

  final List<FocusNode> _focusNodes =
      List.generate(4, (_) => FocusNode());

  final AuthService _authService = AuthService();
  Timer? _timer;
  int _secondsRemaining = 30;
  bool _isVerifying = false;
  bool _isResending = false;
  late String _currentReqId;

  @override
  void initState() {
    super.initState();
    _currentReqId = widget.reqId;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();

    setState(() {
      _secondsRemaining = 30;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }

    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Trigger verify automatically when all 4 digits are entered
    if (_otp.length == 4) {
      _handleVerifyOtp();
    }
  }

  String get _otp {
    return _controllers.map((controller) => controller.text).join();
  }

  Future<void> _handleVerifyOtp() async {
    if (_otp.length != 4 || _isVerifying) return;

    setState(() {
      _isVerifying = true;
    });

    try {
      // 1. Verify OTP with MSG91 SDK
      final payload = {
        'reqId': _currentReqId,
        'otp': _otp,
      };
      debugPrint('Verifying OTP with payload: $payload');

      final response = await OTPWidget.verifyOTP(payload);
      debugPrint('MSG91 verifyOTP response: $response');

      if (response != null && response['type'] == 'success') {
        // 2. Extract accessToken from MSG91 response
        // MSG91 SDK returns the verification token in 'access-token', 'accessToken', or 'message'
        final accessToken = response['access-token'] ??
            response['accessToken'] ??
            response['message'];

        if (accessToken == null || accessToken.toString().trim().isEmpty) {
          throw Exception('MSG91 verification succeeded but no access token was returned.');
        }

        // 3. POST accessToken to Node.js backend: POST /api/auth/msg91/verify
        final authResult = await _authService.verifyMsg91AccessToken(
          accessToken: accessToken.toString(),
          role: widget.role.isNotEmpty ? widget.role : 'BUYER',
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP verified successfully! Welcome to Kalamitr.'),
            backgroundColor: Color(0xFF2E7058),
          ),
        );

        // 4. Navigate according to backend redirect (e.g. /buyer/home)
        context.go(authResult.redirect);
      } else {
        final errorMsg = response?['message']?.toString() ?? 'Invalid OTP. Please check and try again.';
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  Future<void> _handleRetryOtp([int? channel]) async {
    if (_isResending) return;

    setState(() {
      _isResending = true;
    });

    try {
      // Retry OTP with selected communication channel (SMS: 11, Voice: 4, WhatsApp: 12)
      // If channel is null, respects default widget configuration without specifying retryChannel
      final payload = <String, dynamic>{
        'reqId': _currentReqId,
      };
      if (channel != null) {
        payload['retryChannel'] = channel;
      }
      debugPrint('Retrying OTP with payload: $payload');

      final response = await OTPWidget.retryOTP(payload);
      debugPrint('MSG91 retryOTP response: $response');

      if (response != null && response['type'] == 'success') {
        if (response['message'] != null && response['message'].toString().trim().isNotEmpty) {
          _currentReqId = response['message'].toString();
        }
        _startTimer();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP resent successfully.'),
              backgroundColor: Color(0xFF8B5E34),
            ),
          );
        }
      } else {
        final msg = response?['message']?.toString() ?? 'Failed to resend OTP. Please try again.';
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();

    for (final controller in _controllers) {
      controller.dispose();
    }

    for (final node in _focusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF9F4E9);
    const brown = Color(0xFF8B5E34);
    const darkBrown = Color(0xFF5C4033);
    const lightBrown = Color(0xFFD2B48C);
    const greyBrown = Color(0xFF9B8B7A);

    final displayPhone = widget.phoneNumber.length == 10
        ? '+91 ${widget.phoneNumber.substring(0, 2)} ${widget.phoneNumber.substring(2, 4)} ${widget.phoneNumber.substring(4, 7)} ${widget.phoneNumber.substring(7)}'
        : widget.phoneNumber.isNotEmpty
            ? '+91 ${widget.phoneNumber}'
            : '+91 93 36 005 104';

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // ---------------- HEADER ----------------
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: lightBrown,
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        context.go('/login');
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: darkBrown,
                        size: 24,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Verify Mobile Number',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: darkBrown,
                        ),
                      ),
                      Text(
                        'मोबाइल नंबर सत्यापित करें',
                        style: TextStyle(
                          fontSize: 13,
                          color: greyBrown,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ---------------- OTP ICON ----------------
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: brown,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.mail_outline,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),

                  Positioned(
                    top: -12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDEFD6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: lightBrown,
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        'OTP: ****',
                        style: TextStyle(
                          color: brown,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ---------------- TITLE ----------------
              const Text(
                'Enter OTP',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: darkBrown,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                '4-digit code sent to',
                style: TextStyle(
                  fontSize: 18,
                  color: greyBrown,
                ),
              ),

              const SizedBox(height: 8),

              // ---------------- PHONE ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    displayPhone,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: brown,
                    ),
                  ),

                  const SizedBox(width: 6),

                  GestureDetector(
                    onTap: () {
                      context.go('/login');
                    },
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: brown,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ---------------- OTP INPUTS ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  4,
                  (index) {
                    return SizedBox(
                      width: 64,
                      height: 64,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: darkBrown,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.zero,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: lightBrown,
                              width: 1.6,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: brown,
                              width: 1.6,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          _onOtpChanged(value, index);
                        },
                      ),
                    );
                  },
                ),
              ),

              // ---------------- VERIFY OTP ----------------
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_otp.length == 4 && !_isVerifying)
                      ? _handleVerifyOtp
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5E34),
                    disabledBackgroundColor:
                        const Color(0xFF8B5E34).withValues(alpha: 0.4),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Verify OTP →',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // ---------------- DOTS ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (index) => Container(
                    width: 14,
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: lightBrown,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // ---------------- RESEND ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 18,
                    color: greyBrown,
                  ),

                  const SizedBox(width: 6),

                  Text(
                    _secondsRemaining > 0
                        ? 'Resend in '
                        : 'Resend ',
                    style: const TextStyle(
                      fontSize: 14,
                      color: greyBrown,
                    ),
                  ),

                  if (_secondsRemaining > 0)
                    Text(
                      '${_secondsRemaining}s',
                      style: const TextStyle(
                        fontSize: 14,
                        color: brown,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: _isResending ? null : () => _handleRetryOtp(),
                      child: Text(
                        _isResending ? 'Sending...' : 'now',
                        style: const TextStyle(
                          fontSize: 14,
                          color: brown,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 14),

              // ---------------- OTP METHODS ----------------
              Row(
                children: [
                  _buildOtpMethod(
                    icon: Icons.sms_outlined,
                    title: 'SMS',
                    subtitle: 'Text message',
                    onTap: () => _handleRetryOtp(11),
                  ),

                  const SizedBox(width: 8),

                  _buildOtpMethod(
                    icon: Icons.phone_android,
                    title: 'WhatsApp',
                    subtitle: 'Instant',
                    onTap: () => _handleRetryOtp(12),
                  ),

                  const SizedBox(width: 8),

                  _buildOtpMethod(
                    icon: Icons.phone,
                    title: 'Voice Call',
                    subtitle: 'For low-literacy',
                    onTap: () => _handleRetryOtp(4),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ---------------- SECURITY ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.shield_outlined,
                    size: 17,
                    color: Color(0xFF3D8B70),
                  ),

                  SizedBox(width: 7),

                  Text(
                    'Secured by Kalamitr · 256-bit encryption',
                    style: TextStyle(
                      fontSize: 12,
                      color: greyBrown,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpMethod({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 95,
          decoration: BoxDecoration(
            color: const Color(0xFFEDE4D2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFEDE4D2),
              width: 1.6,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: const Color(0xFF8B5E34),
              ),

              const SizedBox(height: 5),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5C4033),
                ),
              ),

              const SizedBox(height: 2),

              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF8B5E34),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}