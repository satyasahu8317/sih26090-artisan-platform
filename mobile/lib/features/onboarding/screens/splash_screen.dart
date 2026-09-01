import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              child: const Text(
                'AI-Powered Craft Marketplace',
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