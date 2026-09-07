import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BuyerProductDetailScreen extends StatelessWidget {
  const BuyerProductDetailScreen({super.key});

  static const String productImage =
      'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?w=900';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E7),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageHeader(context),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product name
                          const Text(
                            'Blue Pottery Vase',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF5C4033),
                            ),
                          ),

                          const SizedBox(height: 5),

                          // Rating
                          Row(
                            children: [
                              ...List.generate(
                                5,
                                (index) => const Icon(
                                  Icons.star,
                                  size: 13,
                                  color: Color(0xFFE89A17),
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                '4.8',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF604532),
                                ),
                              ),
                              const Text(
                                '  ·  126 reviews',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF9A806A),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 7),

                          const Text(
                            '₹800',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF8B5E34),
                            ),
                          ),

                          const SizedBox(height: 13),

                          _buildArtisanCard(),

                          const SizedBox(height: 13),

                          _buildAboutProduct(),

                          const SizedBox(height: 13),

                          _buildProductDetails(),

                          const SizedBox(height: 13),

                          // Authentic product
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5F1EC),
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(
                                color: const Color(0xFFC5DED4),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.verified_outlined,
                                  size: 19,
                                  color: Color(0xFF3D765F),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Authentic Handmade Product',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF3D765F),
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Verified by KalaMitr · AI quality-checked',
                                        style: TextStyle(
                                          fontSize: 7.5,
                                          color: Color(0xFF668A7B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom actions
            _buildBottomActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageHeader(BuildContext context) {
    return SizedBox(
      height: 260,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              productImage,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return Container(
                  color: const Color(0xFFE5D5BF),
                  child: const Icon(
                    Icons.image_outlined,
                    size: 50,
                    color: Color(0xFF9B7653),
                  ),
                );
              },
            ),
          ),

          // Back
          Positioned(
            top: 12,
            left: 12,
            child: _roundButton(
              icon: Icons.arrow_back,
              onTap: () => context.pop(),
            ),
          ),

          // Share
          Positioned(
            top: 12,
            right: 12,
            child: _roundButton(
              icon: Icons.share_outlined,
              onTap: () {},
            ),
          ),

          // Wishlist
          Positioned(
            right: 12,
            bottom: 12,
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border,
                size: 20,
                color: Color(0xFFB65B3A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtisanCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD2B48C),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFFEDE0CC),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '👩',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),

          const SizedBox(width: 9),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sita Devi',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF604532),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  '📍 Jaipur, Rajasthan · Pottery',
                  style: TextStyle(
                    fontSize: 8,
                    color: Color(0xFF9A806A),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 7,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE5F1EC),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Text(
              '✓ Verified',
              style: TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3D765F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutProduct() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD2B48C),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ABOUT THIS PRODUCT',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: Color(0xFF9B806B),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Handcrafted blue pottery vase made using '
            'traditional techniques by skilled artisans of '
            'Jaipur, Rajasthan. Each piece is unique, '
            'hand-painted with floral motifs using natural '
            'mineral colours.',
            style: TextStyle(
              fontSize: 9,
              height: 1.5,
              color: Color(0xFF604532),
            ),
          ),
          SizedBox(height: 7),
          Text(
            'जयपुर के कारीगरों द्वारा पारंपरिक तकनीकों का उपयोग '
            'करके बनाई गई हाथ से बनी नीली मिट्टी की सजावट।',
            style: TextStyle(
              fontSize: 9,
              height: 1.5,
              color: Color(0xFF806F60),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD2B48C),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PRODUCT DETAILS',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: Color(0xFF9B806B),
            ),
          ),
          SizedBox(height: 10),
          _DetailRow(
            label: 'Category',
            value: 'Pottery',
          ),
          _DetailRow(
            label: 'Material',
            value: 'Blue Pottery Clay',
          ),
          _DetailRow(
            label: 'Origin',
            value: 'Jaipur, Rajasthan',
          ),
          _DetailRow(
            label: 'Dimensions',
            value: '~25cm height',
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 9, 14, 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF6F1E7),
        border: Border(
          top: BorderSide(
            color: Color(0xFFD2B48C),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                context.push('/chat-with-seller');
              },
              icon: const Icon(
                Icons.chat_bubble_outline,
                size: 15,
              ),
              label: const Text('Enquire'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF8B5E34),
                side: const BorderSide(
                  color: Color(0xFF8B5E34),
                ),
                minimumSize: const Size(
                  double.infinity,
                  46,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.shopping_bag_outlined,
                size: 15,
              ),
              label: const Text('Add to Cart'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3D765F),
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(
                  double.infinity,
                  46,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 19,
          color: const Color(0xFF604532),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 8,
                color: Color(0xFF9A806A),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: Color(0xFF604532),
            ),
          ),
        ],
      ),
    );
  }
}