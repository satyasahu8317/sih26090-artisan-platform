import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/onboarding_provider.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState
    extends ConsumerState<RoleSelectionScreen> {
  static const Color backgroundColor = Color(0xFFF6F1E7);
  static const Color brown = Color(0xFF8B5E34);
  static const Color green = Color(0xFF2E7058);
  static const Color darkBrown = Color(0xFF5C4033);

  bool _isGuestLoading = false;

  void _navigateToLogin(String role) {
    ref.read(selectedRoleProvider.notifier).state = role;
    context.go('/login', extra: {'role': role});
  }

  Future<void> _enterGuest(String role) async {
    setState(() {
      _isGuestLoading = true;
    });
    try {
      await ref.read(authProvider.notifier).loginAsGuest(role);
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
          _isGuestLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    // Riverpod se selected role ko listen kar rahe hain
    final selectedRole = ref.watch(selectedRoleProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Logo
              Image.asset(
                'assets/images/mitr_logo.png',
                height: 85,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 14),

              // Heading
              const Text(
                'How will you use\nKalamitr ?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 26,
                  height: 1.05,
                  fontWeight: FontWeight.w700,
                  color: darkBrown,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              const Text(
                'Choose what you want to do and we’ll personalize your experience.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.2,
                  color: Color(0xFF7D6B5C),
                ),
              ),

              const SizedBox(height: 20),

              // Role cards
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SELLER / ARTISAN
                  Expanded(
                    child: _RoleCard(
                      imagePath:
                          'assets/images/auth/artist_side.png',
                      icon: Icons.shopping_basket_outlined,
                      title: 'Seller / Artisan',
                      description:
                          'Sell your handmade\nproducts',
                      feature:
                          'Reach more buyers\nCreate listing with AI',
                      buttonText: 'Continue as Seller',
                      color: brown,
                      isSelected: selectedRole == 'seller',

                      onTap: () {
                        _navigateToLogin('seller');
                      },
                    ),
                  ),

                  const SizedBox(width: 14),

                  // BUYER
                  Expanded(
                    child: _RoleCard(
                      imagePath:
                          'assets/images/auth/buyer_side.png',
                      icon: Icons.shopping_bag_outlined,
                      title: 'Buyer',
                      description:
                          'Discover handmade\nproducts',
                      feature:
                          'Explore artisans\nbuy authentic crafts',
                      buttonText: 'Continue as Buyer',
                      color: green,
                      isSelected: selectedRole == 'buyer',

                      onTap: () {
                        _navigateToLogin('buyer');
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Bottom Continue button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: selectedRole == null
                      ? null
                      : () {
                          _navigateToLogin(selectedRole);
                        },                  style: ElevatedButton.styleFrom(
                    backgroundColor: brown,
                    disabledBackgroundColor: brown.withValues(alpha: .45),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Continue  →',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              if (AppConfig.enableGuestMode) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isGuestLoading ? null : () => _enterGuest('seller'),
                        icon: const Icon(Icons.palette_outlined, size: 16),
                        label: const Text(
                          'Guest Artisan',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: brown,
                          side: const BorderSide(color: brown, width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isGuestLoading ? null : () => _enterGuest('buyer'),
                        icon: const Icon(Icons.shopping_bag_outlined, size: 16),
                        label: const Text(
                          'Guest Buyer',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: green,
                          side: const BorderSide(color: green, width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual Seller / Buyer card
class _RoleCard extends StatelessWidget {
  final String imagePath;
  final IconData icon;
  final String title;
  final String description;
  final String feature;
  final String buttonText;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.imagePath,
    required this.icon,
    required this.title,
    required this.description,
    required this.feature,
    required this.buttonText,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F1E7),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: isSelected ? color : Colors.black54,
            width: isSelected ? 2 : 0.7,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Image
            SizedBox(
              height: 110,
              width: double.infinity,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),

            // Card content
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              child: Column(
                children: [
                  // Circular icon
                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD8C9AA),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 24,
                      color: color,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.15,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Feature box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 13,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            feature,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 9.5,
                              height: 1.1,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Card button
                  SizedBox(
                    width: double.infinity,
                    height: 34,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            buttonText,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}