import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sendotp_flutter_sdk/sendotp_flutter_sdk.dart';
import '../../../core/config/app_config.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String? role;

  const LoginScreen({super.key, this.role});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize MSG91 OTP Widget SDK
    OTPWidget.initializeWidget(AppConfig.msg91WidgetId, AppConfig.msg91AuthToken);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String get _activeRole {
    final explicit = widget.role;
    if (explicit != null && explicit.isNotEmpty) return explicit.toLowerCase();
    final selected = ref.read(selectedRoleProvider);
    if (selected != null && selected.isNotEmpty) return selected.toLowerCase();
    return 'buyer';
  }

  Future<void> _handleContinueAsGuest(String role) async {
    setState(() {
      _isLoading = true;
    });
    try {
      // 1. Call backend POST /api/auth/guest to create real isolated DB identity & receive real JWT
      await ref.read(authProvider.notifier).loginAsGuest(role);

      // 2. Navigate to role-specific registration/onboarding
      final isArtisan = role == 'seller' || role == 'artisan';
      if (mounted) {
        if (isArtisan) {
          context.go('/artisan/register');
        } else {
          context.go('/buyer/register');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Guest login error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSendOtp() async {
    final rawPhone = _phoneController.text.trim();
    if (rawPhone.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(rawPhone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit mobile number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final role = _activeRole;
      final normalizedRole = (role == 'seller' || role == 'artisan') ? 'ARTISAN' : 'BUYER';

      // MSG91 SDK requires country code without '+' (e.g. 919336005104)
      final identifier = '91$rawPhone';
      final response = await OTPWidget.sendOTP({'identifier': identifier});
      debugPrint('MSG91 sendOTP response: $response');

      if (response != null && response['type'] == 'success') {
        // If invisible OTP already verified the number:
        if (response.containsKey('access-token') || response.containsKey('accessToken')) {
          final accessToken = response['access-token'] ?? response['accessToken'];
          final authResult = await _authService.verifyMsg91AccessToken(
            accessToken: accessToken.toString(),
            role: normalizedRole,
          );
          ref.read(authProvider.notifier).loginAsAuthenticatedUser(
                token: authResult.token,
                role: normalizedRole,
              );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Login successful!')),
            );
            context.go(authResult.redirect);
          }
          return;
        }

        // Standard flow: response['message'] contains reqId
        final reqId = response['message']?.toString() ?? '';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP sent successfully.')),
          );
          context.go('/otp', extra: {
            'phoneNumber': rawPhone,
            'reqId': reqId,
            'role': normalizedRole,
          });
        }
      } else {
        final errorMsg = response?['message']?.toString() ?? 'Failed to send OTP. Please try again.';
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool get _isArtisan => _activeRole == 'seller' || _activeRole == 'artisan';

  @override
  Widget build(BuildContext context) {
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
                  // Logo
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

                  // App name
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

                  // Back to role selection
                  Positioned(
                    top: 18,
                    right: 18,
                    child: IconButton(
                      onPressed: () {
                        context.go('/role');
                      },
                      icon: const Icon(
                        Icons.swap_horiz,
                        color: Colors.white,
                        size: 26,
                      ),
                      tooltip: 'Change role',
                    ),
                  ),

                  // Login heading
                  Positioned(
                    left: 36,
                    bottom: 32,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isArtisan ? 'Artisan Login' : 'Buyer Login',
                          style: const TextStyle(
                            fontFamily: 'Playfair Display',
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isArtisan ? 'कारीगर लॉगिन' : 'ग्राहक लॉगिन',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Craft illustration
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 36),

                    const Text(
                      'Mobile Number *',
                      style: TextStyle(
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
                        borderRadius: BorderRadius.circular(16),
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
                            decoration: const BoxDecoration(
                              color: Color(0xFFF0E2CB),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                bottomLeft: Radius.circular(15),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '🇮🇳',
                                  style: TextStyle(fontSize: 20),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '+91',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF604532),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              decoration: const InputDecoration(
                                hintText: '98765 43210',
                                hintStyle: TextStyle(
                                  color: Color(0xFFB0A39B),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                                counterText: '',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 22,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 7),

                    const Text(
                      'OTP will be sent to this number · OTP इस नंबर पर भेजा जाएगा',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9D8C7D),
                      ),
                    ),

               const SizedBox(height: 24),

                    // Data safety box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F3EE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFCFE4D9),
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            size: 18,
                            color: Color(0xFF6A9D83),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your data is safe\n'
                              'We never share your information. Aadhaar is '
                              'only used for artisan verification. आपकी जानकारी '
                              'सुरक्षित है',
                              style: TextStyle(
                                fontSize: 10,
                                height: 1.35,
                                color: Color(0xFF609078),
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
                        onPressed: _isLoading ? null : _handleSendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF996735),
                          disabledBackgroundColor: const Color(0xFF996735).withValues(alpha: 0.5),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Send OTP →',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),

                    if (AppConfig.enableGuestMode) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : () => _handleContinueAsGuest(_activeRole),
                          icon: Icon(
                            Icons.explore_outlined,
                            size: 20,
                            color: _isArtisan
                                ? const Color(0xFF996735)
                                : const Color(0xFF2E7058),
                          ),
                          label: Text(
                            'Continue as Guest (Demo) →',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _isArtisan
                                  ? const Color(0xFF996735)
                                  : const Color(0xFF2E7058),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: _isArtisan
                                  ? const Color(0xFF996735)
                                  : const Color(0xFF2E7058),
                              width: 1.6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    Center(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9D8C7D),
                          ),
                          children: [
                            TextSpan(
                              text: 'By continuing you agree to our ',
                            ),
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                color: Color(0xFF996735),
                                decoration: TextDecoration.underline,
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
            ),),
          ],
        ),
      ),
    );
  }
}