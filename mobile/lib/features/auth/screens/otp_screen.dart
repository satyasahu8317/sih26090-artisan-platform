import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sih26090_mobile/core/storage/session_storage.dart';

import '../data/auth_repository.dart';
import '../utils/auth_navigation.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../../../l10n/generated/app_localizations.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({
    super.key,
    required this.phone,
    required this.reqId,
  });

  final String phone;

  // Kept for route compatibility.
  // In demo mode this will be "mock".
  final String reqId;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  // Demo backend OTP = 123456
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  Timer? _timer;
  int _secondsRemaining = 8;

  bool _isVerifying = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();

    setState(() {
      _secondsRemaining = 8;
    });

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (_secondsRemaining > 0) {
          setState(() {
            _secondsRemaining--;
          });
        } else {
          timer.cancel();
        }
      },
    );
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Automatically verify once all 6 digits are entered.
    if (_otp.length == 6 && !_isVerifying) {
      _verifyOtp();
    }
  }

  String get _otp {
    return _controllers
        .map((controller) => controller.text)
        .join();
  }

  String get _maskedPhone {
    final phone = widget.phone;

    if (phone.length != 10) {
      return phone;
    }

    return '${phone.substring(0, 2)}XXXXX${phone.substring(7)}';
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _verifyOtp() async {
    if (_isVerifying || _otp.length != 6) {
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      final selectedRole =
          ref.read(selectedRoleProvider);

      final backendRole =
          mapSelectedRoleToBackendRole(selectedRole);

      // Demo backend OTP verification.
      // Expected OTP: 123456
      final authResult =
          await AuthRepository.verifyMockOtp(
        mobileNumber: widget.phone,
        otp: _otp,
        role: backendRole,
      );
await SessionStorage.saveSession(
  role: backendRole,
);
      if (!mounted) return;

      final route = resolvePostAuthRoute(
        isNewUser: authResult.isNewUser,
        selectedRole: selectedRole,
        backendRedirect: authResult.redirect,
      );

      context.go(route);
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError(
        'Something went wrong. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    if (_isResending) return;

    setState(() {
      _isResending = true;
    });

    try {
      final selectedRole =
          ref.read(selectedRoleProvider);

      final backendRole =
          mapSelectedRoleToBackendRole(selectedRole);

      await AuthRepository.requestMockOtp(
        mobileNumber: widget.phone,
        role: backendRole,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'OTP resent. Use 123456 for demo.',
          ),
        ),
      );

      for (final controller in _controllers) {
        controller.clear();
      }

      _startTimer();

      _focusNodes.first.requestFocus();
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError(
        'Failed to resend OTP. Please try again.',
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
    final l10n = AppLocalizations.of(context)!;

    const backgroundColor = Color(0xFFF9F4E9);
    const brown = Color(0xFF8B5E34);
    const darkBrown = Color(0xFF5C4033);
    const lightBrown = Color(0xFFD2B48C);
    const greyBrown = Color(0xFF9B8B7A);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 24),
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
                      borderRadius:
                          BorderRadius.circular(12),
                      border: Border.all(
                        color: lightBrown,
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
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.verifyMobileNumber,
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: darkBrown,
                        ),
                      ),
                      Text(
                        l10n.verifyMobileNumber,
                        style: const TextStyle(
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
                      borderRadius:
                          BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset:
                              const Offset(0, 4),
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
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(12),
                        border: Border.all(
                          color: lightBrown,
                        ),
                      ),
                      child: const Text(
                        'OTP: ******',
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
              Text(
                l10n.enterOtp,
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: darkBrown,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                l10n.codeSentTo,
                style: const TextStyle(
                  fontSize: 20,
                  color: greyBrown,
                ),
              ),

              const SizedBox(height: 8),

              // ---------------- PHONE ----------------
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Text(
                    '+91 $_maskedPhone',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: brown,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFFFE8DF),
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: Text(
                      l10n.change,
                      style: const TextStyle(
                        color: Color(0xFFD85C35),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ---------------- DIVIDER ----------------
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: lightBrown,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    child: Text(
                      l10n.otpValid,
                      style: const TextStyle(
                        fontSize: 14,
                        color: greyBrown,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: lightBrown,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ---------------- OTP BOXES ----------------
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                  (index) {
                    return SizedBox(
                      width: 44,
                      height: 58,
                      child: TextField(
                        controller:
                            _controllers[index],
                        focusNode:
                            _focusNodes[index],
                        keyboardType:
                            TextInputType.number,
                        textAlign:
                            TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.w600,
                          color: darkBrown,
                        ),
                        decoration:
                            InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              EdgeInsets.zero,
                          enabledBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              14,
                            ),
                            borderSide:
                                const BorderSide(
                              color: lightBrown,
                              width: 1.6,
                            ),
                          ),
                          focusedBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              14,
                            ),
                            borderSide:
                                const BorderSide(
                              color: brown,
                              width: 1.6,
                            ),
                          ),
                        ),
                        onChanged:
                            (value) {
                          _onOtpChanged(
                            value,
                            index,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ---------------- VERIFY OTP ----------------
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      (_otp.length == 6 &&
                              !_isVerifying)
                          ? _verifyOtp
                          : null,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor: brown,
                    disabledBackgroundColor:
                        brown.withValues(
                      alpha: 0.4,
                    ),
                    foregroundColor:
                        Colors.white,
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          '${l10n.verify} OTP →',
                          style:
                              const TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // ---------------- DOTS ----------------
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: List.generate(
                  6,
                  (index) => Container(
                    width: 10,
                    height: 4,
                    margin:
                        const EdgeInsets.symmetric(
                      horizontal: 3,
                    ),
                    decoration:
                        BoxDecoration(
                      color: index <
                              _otp.length
                          ? brown
                          : lightBrown,
                      borderRadius:
                          BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // ---------------- RESEND ----------------
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 18,
                    color: greyBrown,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _secondsRemaining > 0
                        ? '${l10n.resendOtp} in '
                        : '${l10n.resendOtp} ',
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
                        fontWeight:
                            FontWeight.w600,
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: _isResending
                          ? null
                          : _resendOtp,
                      child: Text(
                        _isResending
                            ? 'Sending…'
                            : 'now',
                        style:
                            const TextStyle(
                          fontSize: 14,
                          color: brown,
                          fontWeight:
                              FontWeight.w600,
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
                  ),
                  const SizedBox(width: 8),
                  _buildOtpMethod(
                    icon:
                        Icons.phone_android,
                    title: 'WhatsApp',
                    subtitle: 'Instant',
                  ),
                  const SizedBox(width: 8),
                  _buildOtpMethod(
                    icon: Icons.phone,
                    title: 'Voice Call',
                    subtitle:
                        'For low-literacy',
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ---------------- SECURITY ----------------
              const Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
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
  }) {
    return Expanded(
      child: Container(
        height: 95,
        decoration: BoxDecoration(
          color: const Color(0xFFEDE4D2),
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFEDE4D2),
            width: 1.6,
          ),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: const Color(0xFFD2B48C),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w600,
                color: Color(0xFFD2B48C),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFD2B48C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}