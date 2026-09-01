import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productName;
  final String price;
  final String imageUrl;
  final String description;
  final String artisanName;
  final String location;
  final int views;
  final int enquiries;
  final int likes;
  final bool isVerified;

  const ProductDetailScreen({
    super.key,
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.artisanName,
    required this.location,
    required this.views,
    required this.enquiries,
    required this.likes,
    this.isVerified = true,
  });

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF6F1E7);
    const brown = Color(0xFF6B4735);
    const primaryBrown = Color(0xFF8B5E34);
    const borderColor = Color(0xFFD2B48C);
    const green = Color(0xFF287B65);
    const orange = Color(0xFFB85C38);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --------------------------------------------------
                    // PRODUCT IMAGE
                    // --------------------------------------------------
                    Stack(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 250,
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) {
                                    return Container(
                                      color: const Color(0xFFD07B4D),
                                      child: const Icon(
                                        Icons.image_outlined,
                                        size: 60,
                                        color: Colors.white70,
                                      ),
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }

                                    return Container(
                                      color: const Color(0xFFD07B4D),
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: const Color(0xFFD07B4D),
                                  child: const Icon(
                                    Icons.image_outlined,
                                    size: 60,
                                    color: Colors.white70,
                                  ),
                                ),
                        ),

                        // Back button
                        Positioned(
                          top: 14,
                          left: 16,
                          child: _circleButton(
                            icon: Icons.arrow_back,
                            onTap: () => Navigator.pop(context),
                          ),
                        ),

                        // Edit image button
                        Positioned(
                          top: 14,
                          right: 16,
                          child: _circleButton(
                            icon: Icons.edit,
                            onTap: () {
                              // Edit product action later
                            },
                          ),
                        ),

                        // Published badge
                        Positioned(
                          left: 16,
                          bottom: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Published',
                              style: TextStyle(
                                color: green,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // --------------------------------------------------
                    // MAIN CONTENT
                    // --------------------------------------------------
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product name
                          Text(
                            productName,
                            style: const TextStyle(
                              color: brown,
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'serif',
                            ),
                          ),

                          const SizedBox(height: 5),

                          // Price
                          Text(
                            price,
                            style: const TextStyle(
                              color: primaryBrown,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'serif',
                            ),
                          ),

                          const SizedBox(height: 18),

                          // --------------------------------------------------
                          // STATS
                          // --------------------------------------------------
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  icon: '👁️',
                                  value: _formatNumber(views),
                                  label: 'Views',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  icon: '💬',
                                  value: _formatNumber(enquiries),
                                  label: 'Enquiries',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  icon: '❤️',
                                  value: _formatNumber(likes),
                                  label: 'Likes',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // --------------------------------------------------
                          // ABOUT PRODUCT
                          // --------------------------------------------------
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: borderColor,
                                width: 0.8,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'ABOUT THIS PRODUCT',
                                  style: TextStyle(
                                    color: Color(0xFF9A8A78),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  description,
                                  style: const TextStyle(
                                    color: brown,
                                    fontSize: 15,
                                    height: 1.55,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // --------------------------------------------------
                          // ARTISAN CARD
                          // --------------------------------------------------
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: borderColor,
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF1E4CF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '👩',
                                      style: TextStyle(fontSize: 27),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 13),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        artisanName,
                                        style: const TextStyle(
                                          color: brown,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Text(
                                            '📍',
                                            style: TextStyle(fontSize: 13),
                                          ),
                                          const SizedBox(width: 3),
                                          Expanded(
                                            child: Text(
                                              location,
                                              style: const TextStyle(
                                                color: Color(0xFF9A8A78),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                if (isVerified)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 11,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE5F2ED),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      '✓ Verified',
                                      style: TextStyle(
                                        color: green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
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

            // --------------------------------------------------
            // BOTTOM ACTIONS
            // --------------------------------------------------
            Container(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
              decoration: const BoxDecoration(
                color: backgroundColor,
                border: Border(
                  top: BorderSide(
                    color: borderColor,
                    width: 0.8,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 64,
                      child: OutlinedButton(
                        onPressed: () {
                          // Edit action later
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryBrown,
                          side: const BorderSide(
                            color: primaryBrown,
                            width: 1.6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          '✏️ Edit',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: SizedBox(
                      height: 64,
                      child: OutlinedButton(
                        onPressed: () {
                          _showUnpublishDialog(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: orange,
                          side: const BorderSide(
                            color: orange,
                            width: 1.6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Unpublish',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

  // --------------------------------------------------
  // HELPERS
  // --------------------------------------------------

  static Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.9),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            size: 19,
            color: const Color(0xFF6B4735),
          ),
        ),
      ),
    );
  }

  static String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(number % 1000 == 0 ? 0 : 1)}K';
    }
    return number.toString();
  }

  static void _showUnpublishDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF6F1E7),
          title: const Text(
            'Unpublish product?',
            style: TextStyle(
              color: Color(0xFF6B4735),
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'This product will no longer be visible to buyers.',
            style: TextStyle(
              color: Color(0xFF6B4735),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // API call will come here later
              },
              child: const Text(
                'Unpublish',
                style: TextStyle(
                  color: Color(0xFFB85C38),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD2B48C),
          width: 0.8,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF6B4735),
              fontSize: 17,
              fontWeight: FontWeight.w700,
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9A8A78),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}