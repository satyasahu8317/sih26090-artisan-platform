import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/providers/auth_provider.dart';

class BuyerHomeScreen extends ConsumerWidget {
  const BuyerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final buyerName = authState.guestName ?? 'Guest Buyer';
    const primaryGreen = Color(0xFF2E7058);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E7),
      body: SafeArea(
        child: Column(
          children: [
            // ── Guest Mode Banner ──
            if (authState.isGuest)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFFE8F3EE),
                child: Row(
                  children: [
                    const Icon(Icons.explore, size: 16, color: primaryGreen),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Demo Mode (Buyer Experience)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: primaryGreen,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        ref.read(authProvider.notifier).exitGuestMode();
                        context.go('/role');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Exit Demo',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Main Content ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 18),

                    // Header
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Namaste, $buyerName 🙏',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontFamily: 'Playfair Display',
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2E4035),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Discover verified GI-tagged handmade crafts',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF7A8B80),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFD2B48C)),
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: primaryGreen,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Search bar
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFD2B48C)),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(width: 14),
                          Icon(Icons.search, color: Color(0xFF9B806B)),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Search pottery, handloom, brassware...',
                              style: TextStyle(
                                color: Color(0xFF9B806B),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Featured Artisan Story
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2E7058), Color(0xFF1E4C3B)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'FEATURED ARTISAN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Sita Devi · Madhubani Heritage',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Crafting authentic Mithila paintings on handmade paper for 28 years in Madhubani, Bihar.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Categories Title
                    const Text(
                      'Browse by Craft',
                      style: TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2E4035),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Categories Grid
                    Row(
                      children: [
                        _buildCategoryCard('🏺', 'Blue Pottery', 'Jaipur'),
                        const SizedBox(width: 10),
                        _buildCategoryCard('🧵', 'Handloom', 'Chanderi'),
                        const SizedBox(width: 10),
                        _buildCategoryCard('🪵', 'Woodcraft', 'Saharanpur'),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Sample Products
                    const Text(
                      'Authentic Creations',
                      style: TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2E4035),
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildProductTile(
                      context,
                      title: 'Traditional Terracotta Water Pitcher',
                      artisan: 'Ramdas Kumbhar · Gorakhpur',
                      price: '₹ 850',
                    ),

                    const SizedBox(height: 10),

                    _buildProductTile(
                      context,
                      title: 'Hand-woven Silk Zari Dupatta',
                      artisan: 'Anandi Bai · Chanderi',
                      price: '₹ 3,200',
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String emoji, String title, String region) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD2B48C)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2E4035),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              region,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF9B806B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductTile(
    BuildContext context, {
    required String title,
    required String artisan,
    required String price,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD2B48C)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFEDE0CC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.image_outlined,
              color: Color(0xFF8B5E34),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E4035),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  artisan,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9B806B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7058),
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Demo Guest Mode: Login with mobile to place real orders & enquiries.',
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2E7058),
              side: const BorderSide(color: Color(0xFF2E7058)),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: const Size(60, 32),
            ),
            child: const Text('Enquire', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
