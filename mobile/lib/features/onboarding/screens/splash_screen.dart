import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../auth/data/auth_repository.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../core/storage/session_storage.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _startSessionCheck();
  }


Future<void> _startSessionCheck() async {
  await Future<void>.delayed(const Duration(seconds: 2));
  if (!mounted) return;

  if (SessionStorage.isLoggedIn) {
    final role = SessionStorage.role;

    if (role == 'ARTISAN') {
      context.go('/home');
    } else if (role == 'BUYER') {
      context.go('/buyer-home');
    } else {
      context.go('/language');
    }
  } else {
    context.go('/language');
  }
}
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E7),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // Logo
            Image.asset(
              'assets/images/mitr_logo.png',
              width: 230,
              height: 230,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 35),

            // Tag
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEDE0CC),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFD2B48C),
                ),
              ),
              child: Text(
                l10n.splashTagline,
                style: TextStyle(
                  color: Color(0xFF8B5E34),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const Spacer(),

            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _dot(false),
                const SizedBox(width: 6),
                _dot(false),
                const SizedBox(width: 6),
                _dot(true),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _dot(bool active) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? const Color(0xFF8B5E34)
            : const Color(0xFFD2B48C),
      ),
    );
  }
}