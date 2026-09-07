import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  String selectedCategory = 'All';

  final List<Map<String, dynamic>> products = [
    {
      'name': 'Jaipur Blue Pottery Vase',
      'artisan': 'Sita Devi · Jaipur',
      'price': '₹850',
      'oldPrice': 'up to ₹1,200',
      'rating': '4.8',
      'reviews': '126',
      'category': 'Pottery',
      'image': 'assets/images/products/blue_pottery_vase.png',
      'saved': 'Saved 2 days ago',
      'available': true,
    },
    {
      'name': 'Kantha Embroidery Stole',
      'artisan': 'Rekha Bai · Kolkata',
      'price': '₹1,200',
      'oldPrice': 'up to ₹1,800',
      'rating': '4.9',
      'reviews': '88',
      'category': 'Textiles',
      'image': 'assets/images/products/kantha_stole.png',
      'saved': 'Saved 5 days ago',
      'available': true,
    },
    {
      'name': 'Silver Lac Bangles Set',
      'artisan': 'Sunita · Jaipur',
      'price': '₹550',
      'oldPrice': 'up to ₹850',
      'rating': '4.7',
      'reviews': '54',
      'category': 'Jewellery',
      'image': 'assets/images/products/lac_bangles.png',
      'saved': 'Saved 1 week ago',
      'available': true,
    },
    {
      'name': 'Carved Sheesham Tray',
      'artisan': 'Vijay Kumar · Saharanpur',
      'price': '₹980',
      'oldPrice': 'up to ₹1,400',
      'rating': '4.6',
      'reviews': '42',
      'category': 'Woodcraft',
      'image': 'assets/images/products/sheesham_tray.png',
      'saved': 'Saved 3 weeks ago',
      'available': true,
    },
    {
      'name': 'Dhokra Tribal Elephant',
      'artisan': 'Ram Lal · Bastar',
      'price': '₹680',
      'oldPrice': 'up to ₹980',
      'rating': '4.8',
      'reviews': '19',
      'category': 'Metalwork',
      'image': 'assets/images/products/dhokra_elephant.png',
      'saved': 'Saved 1 month ago',
      'available': true,
    },
    {
      'name': 'Madhubani Wall Painting',
      'artisan': 'Meena Bai · Madhubani',
      'price': '₹1,100',
      'oldPrice': 'Out of Stock',
      'rating': '4.7',
      'reviews': '31',
      'category': 'Paintings',
      'image': 'assets/images/products/madhubani.png',
      'saved': 'Saved 1 month ago',
      'available': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final availableProducts =
        products.where((p) => p['available'] == true).toList();

    final unavailableProducts =
        products.where((p) => p['available'] == false).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildCategoryFilters(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCartBar(availableProducts.length),
                    const SizedBox(height: 9),

                    ...availableProducts.map(
                      (product) => Padding(
                        padding: const EdgeInsets.only(bottom: 9),
                        child: _buildProductCard(product),
                      ),
                    ),

                    if (unavailableProducts.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      const Text(
                        'CURRENTLY UNAVAILABLE (1)',
                        style: TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                          letterSpacing: .5,
                          color: Color(0xFF9A806A),
                        ),
                      ),
                      const SizedBox(height: 7),

                      ...unavailableProducts.map(
                        (product) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildUnavailableCard(product),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  // ================= HEADER =================

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: const BoxDecoration(
        color: Color(0xFF8B5E34),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 9),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MY WISHLIST',
                  style: TextStyle(
                    fontSize: 7,
                    letterSpacing: 1,
                    color: Color(0xFFDCC7A9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  '6 Saved Items',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '5 in stock · 1 unavailable',
                  style: TextStyle(
                    fontSize: 7,
                    color: Color(0xFFEADCC9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 31,
            height: 31,
            decoration: BoxDecoration(
              color: const Color(0xFFB65B3A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.favorite,
              size: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ================= FILTERS =================

  Widget _buildCategoryFilters() {
    final categories = [
      'All',
      'Pottery',
      'Textiles',
      'Jewellery',
      'Paintings',
    ];

    return Container(
      height: 43,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      color: const Color(0xFFF6F1E7),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = selectedCategory == category;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF8B5E34)
                    : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF8B5E34)
                      : const Color(0xFFD2B48C),
                ),
              ),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? Colors.white
                      : const Color(0xFF765944),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= CART BAR =================

  Widget _buildCartBar(int count) {
    return Container(
      height: 39,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF1E5D1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFD9C19D),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              '5 available items · ₹4,260 total',
              style: TextStyle(
                fontSize: 7,
                color: Color(0xFF765944),
              ),
            ),
          ),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(
              Icons.shopping_cart_outlined,
              size: 12,
            ),
            label: const Text(
              'Add All',
              style: TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF76502F),
              side: const BorderSide(
                color: Color(0xFFB58B5C),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 5,
              ),
              minimumSize: Size.zero,
              tapTargetSize:
                  MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  // ================= PRODUCT CARD =================

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE0CFB8),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductImage(product['image']),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product['name'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF604532),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.favorite,
                          size: 14,
                          color: Color(0xFFB65B3A),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'by ${product['artisan']}',
                      style: const TextStyle(
                        fontSize: 6.5,
                        color: Color(0xFF9A806A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 10,
                          color: Color(0xFFC68A2D),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${product['rating']} (${product['reviews']})',
                          style: const TextStyle(
                            fontSize: 6.5,
                            color: Color(0xFF765944),
                          ),
                        ),
                        const SizedBox(width: 5),
                        _categoryTag(product['category']),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      product['price'],
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF604532),
                      ),
                    ),
                    Text(
                      product['oldPrice'],
                      style: const TextStyle(
                        fontSize: 6.5,
                        color: Color(0xFFAA927E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  '♡  ${product['saved']}',
                  style: const TextStyle(
                    fontSize: 6.5,
                    color: Color(0xFFAA927E),
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      const Color(0xFF487B68),
                  side: const BorderSide(
                    color: Color(0xFF487B68),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize:
                      MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  'Add to Cart',
                  style: TextStyle(
                    fontSize: 6.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              TextButton(
                onPressed: () {
                  context.push('/buyer-product-detail');
                },
                style: TextButton.styleFrom(
                  foregroundColor:
                      const Color(0xFF8B5E34),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 5,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize:
                      MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'View Details ›',
                  style: TextStyle(
                    fontSize: 6.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= UNAVAILABLE =================

  Widget _buildUnavailableCard(
    Map<String, dynamic> product,
  ) {
    return Container(
      height: 75,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1ECE3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE0D4C3),
        ),
      ),
      child: Row(
        children: [
          _buildProductImage(
            product['image'],
            unavailable: true,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF806F60),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'by ${product['artisan']}',
                  style: const TextStyle(
                    fontSize: 6.5,
                    color: Color(0xFFAA927E),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Currently out of stock',
                  style: TextStyle(
                    fontSize: 6.5,
                    color: Color(0xFFB65B3A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.close,
            size: 13,
            color: Color(0xFFB65B3A),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(
    String path, {
    bool unavailable = false,
  }) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFE9D8C0),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        path,
        fit: BoxFit.cover,
        color: unavailable
            ? Colors.white.withValues(alpha: .45)
            : null,
        colorBlendMode:
            unavailable ? BlendMode.saturation : null,
        errorBuilder: (_, __, ___) {
          return const Center(
            child: Icon(
              Icons.image_outlined,
              color: Color(0xFFB99A77),
              size: 25,
            ),
          );
        },
      ),
    );
  }

  Widget _categoryTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF4E9D8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 5.5,
          color: Color(0xFF8B5E34),
        ),
      ),
    );
  }

  // ================= BOTTOM NAV =================

  Widget _buildBottomNavigation(BuildContext context) {
    final items = [
      (Icons.home_rounded, 'Home'),
      (Icons.search_rounded, 'Search'),
      (Icons.grid_view_rounded, 'Categories'),
      (Icons.shopping_bag_rounded, 'Orders'),
      (Icons.person_rounded, 'Profile'),
    ];

    return Container(
      height: 62,
      decoration: const BoxDecoration(
        color: Color(0xFFF6F1E7),
        border: Border(
          top: BorderSide(
            color: Color(0xFFD2B48C),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceAround,
        children: List.generate(
          items.length,
          (index) {
            return GestureDetector(
              onTap: () {
                if (index == 0) {
                  context.go('/buyer-home');
                } else if (index == 1) {
                  context.push('/buyer-search');
                } else if (index == 3) {
                  context.push('/buyer-orders');
                } else if (index == 4) {
                  context.push('/buyer-profile');
                }
              },
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    items[index].$1,
                    size: 17,
                    color: const Color(0xFF9A6C43),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    items[index].$2,
                    style: const TextStyle(
                      fontSize: 6.5,
                      color: Color(0xFF9A806A),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}