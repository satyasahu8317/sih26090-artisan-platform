import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/auth_repository.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../utils/auth_navigation.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phoneController =
      TextEditingController();

  bool _isSendingOtp = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();

    if (phone.length != 10 || int.tryParse(phone) == null) {
      _showError(
        'Please enter a valid 10-digit mobile number.',
      );
      return;
    }

    setState(() => _isSendingOtp = true);

    try {
      final selectedRole =
          ref.read(selectedRoleProvider);

      final backendRole =
          mapSelectedRoleToBackendRole(selectedRole);

      await AuthRepository.requestMockOtp(
        mobileNumber: phone,
        role: backendRole,
      );

      if (!mounted) return;

      context.go(
        '/otp',
        extra: {
          'phone': phone,
          'reqId': 'mock',
        },
      );
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError(
        'Something went wrong. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _isSendingOtp = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E7),
      body: SafeArea(
        child: Column(
          children: [
            // ───────── TOP LOGIN IMAGE ─────────
            Container(
              height: 307,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFD8C5B4),
                    Color(0xFFBA794C),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 18,
                    left: 19,
                    child: Image.asset(
                      'assets/images/auth/login_logo.png',
                      width: 89,
                      height: 51,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const Positioned(
                    top: 25,
                    left: 70,
                    child: Text(
                      'Kalamitr',
                      style: TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 27,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  Positioned(
                    left: 40,
                    bottom: 43,
                    child: Text(
                      l10n.login,
                      style: const TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 41,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  Positioned(
                    right: 28,
                    bottom: 20,
                    child: Image.asset(
                      'assets/images/auth/art.png',
                      width: 150,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),

            // ───────── FORM AREA ─────────
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 36),

                      Text(
                        l10n.mobileNumber,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF604532),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Phone field
                      Container(
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFD8B47A),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 123,
                              height: double.infinity,
                              decoration:
                                  const BoxDecoration(
                                color: Color(0xFFF0E2CB),
                                borderRadius:
                                    BorderRadius.only(
                                  topLeft:
                                      Radius.circular(15),
                                  bottomLeft:
                                      Radius.circular(15),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '🇮🇳',
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '+91',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight:
                                          FontWeight.w600,
                                      color:
                                          Color(0xFF604532),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller:
                                    _phoneController,
                                keyboardType:
                                    TextInputType.phone,
                                maxLength: 10,
                                decoration:
                                    const InputDecoration(
                                  hintText: '98765 43210',
                                  hintStyle: TextStyle(
                                    color:
                                        Color(0xFFB0A39B),
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                  counterText: '',
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.symmetric(
                                    horizontal: 22,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 7),

                      Text(
                        l10n.otpWillBeSent,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9D8C7D),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Data safety box
                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F3EE),
                          borderRadius:
                              BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFCFE4D9),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons
                                  .verified_user_outlined,
                              size: 18,
                              color: Color(0xFF6A9D83),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.yourDataIsSafe,
                                style: const TextStyle(
                                  fontSize: 10,
                                  height: 1.35,
                                  color:
                                      Color(0xFF609078),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Send OTP
                      SizedBox(
                        width: double.infinity,
                        height: 66,
                        child: ElevatedButton(
                          onPressed: _isSendingOtp
                              ? null
                              : _sendOtp,
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF996735),
                            disabledBackgroundColor:
                                const Color(0xFF996735)
                                    .withValues(alpha: 0.6),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                          ),
                          child: _isSendingOtp
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  l10n.sendOtp,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Center(
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF9D8C7D),
                            ),
                            children: [
                              TextSpan(
                                text:
                                    'By continuing you agree to our ',
                              ),
                              TextSpan(
                                text: 'Terms of Service',
                                style: TextStyle(
                                  color:
                                      Color(0xFF996735),
                                  decoration:
                                      TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}