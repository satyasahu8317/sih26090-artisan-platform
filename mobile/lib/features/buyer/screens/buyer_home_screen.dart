import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key});

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  int selectedCategory = 0;
  int selectedNav = 0;

  final List<String> categories = [
    'All',
    '🏺 Pottery',
    '🧵 Textiles',
    '💍 Jewellery',
    '🏮 Decor',
  ];

  final List<Map<String, String>> products = [
    {
      'name': 'Blue Pottery Vase',
      'rating': '4.8',
      'reviews': '126',
      'price': '₹800–₹1,200',
      'artisan': 'Sita Devi',
      'image':
          'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?w=500',
    },
    {
      'name': 'Handwoven Silk Scarf',
      'rating': '4.9',
      'reviews': '89',
      'price': '₹1,500–₹2,000',
      'artisan': 'Meena Kumari',
      'image':
          'https://images.unsplash.com/photo-1601924994987-69e26d50dc26?w=500',
    },
    {
      'name': 'Brass Bangle Set',
      'rating': '4.7',
      'reviews': '204',
      'price': '₹300–₹500',
      'artisan': 'Lakshmi Bai',
      'image':
          'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=500',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E7),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildSearchBar(),
                    const SizedBox(height: 14),
                    _buildCategoryChips(),
                    const SizedBox(height: 14),
                    _buildArtisanBanner(),
                    const SizedBox(height: 18),
                    _buildSectionTitle('Top Categories'),
                    const SizedBox(height: 10),
                    _buildTopCategories(),
                    const SizedBox(height: 18),
                    _buildSectionTitle('Popular Products'),
                    const SizedBox(height: 10),
                    _buildPopularProducts(),
                  ],
                ),
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  // ---------------- HEADER ----------------

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Namaste 🙏',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9A806A),
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Find unique\nhandmade products',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 24,
                  height: 1.05,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5C4033),
                ),
              ),
            ],
          ),
        ),
   GestureDetector(
  onTap: () {
    context.push('/buyer-notification');
  },
  child: Container(
    width: 42,
    height: 42,
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: const Center(
      child: Text(
        '🔔',
        style: TextStyle(fontSize: 20),
      ),
    ),
  ),
),
      ],
    );
  }

  // ---------------- SEARCH ----------------
Widget _buildSearchBar() {
  return GestureDetector(
    onTap: () {
      context.push('/buyer-search');
    },
    child: Container(
      height: 52,
 
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFD2B48C),
          width: 1.3,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(
            Icons.search,
            size: 22,
            color: Colors.black,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Search products, categories...',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFFB79A7A),
              ),
            ),
          ),
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0E4D1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.mic,
              size: 19,
              color: Color(0xFF9B6137),
            ),
          ),
        ],
      ),
   ) );
  }

  // ---------------- CATEGORY CHIPS ----------------

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 28,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          final isSelected = selectedCategory == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF8B5E34)
                    : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color(0xFFD2B48C),
                ),
              ),
              child: Text(
                categories[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF654936),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------- BANNER ----------------

  Widget _buildArtisanBanner() {
    return Container(
      height: 172,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF8B5E34),
            Color(0xFFB85C38),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 7,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 120, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Support Artisans.\nBuy Handmade.',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 19,
                    height: 1.15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Discover authentic crafts from Indian\nartisans.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.25,
                    color: Color(0xFFF8EDE0),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Explore Now →',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B5E34),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Decorative handmade pot
          Positioned(
            right: 48,
            bottom: 10,
            child: Container(
              width: 55,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF9D542F),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                border: Border.all(
                  color: const Color(0xFFD9A15F),
                  width: 2,
                ),
              ),
              child: const Center(
                child: Text(
                  '🏺',
                  style: TextStyle(fontSize: 25),
                ),
              ),
            ),
          ),

          Positioned(
            right: 4,
            top: 0,
            child: const Text(
              '🖐️',
              style: TextStyle(fontSize: 60),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- SECTION TITLE ----------------

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'serif',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF5C4033),
      ),
    );
  }

  // ---------------- TOP CATEGORIES ----------------

  Widget _buildTopCategories() {
    final categoryData = [
      ('🏺', 'Pottery'),
      ('🧵', 'Textiles'),
      ('💍', 'Jewellery'),
      ('🌺', 'Decor'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: categoryData.map((category) {
        return Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFFD2B48C),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                category.$1,
                style: const TextStyle(fontSize: 27),
              ),
              const SizedBox(height: 2),
              Text(
                category.$2,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF654936),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ---------------- PRODUCTS ----------------

  Widget _buildPopularProducts() {
    return SizedBox(
      height: 154,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return _buildProductCard(products[index]);
        },
      ),
    );
  }

  Widget _buildProductCard(Map<String, String> product) {
  return GestureDetector(
    onTap: () {
      context.push('/buyer-product-detail');
    },
    child: Container(
      width: 105,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: const Color(0xFFD2B48C),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 72,
            width: double.infinity,
            child: Image.network(
              product['image']!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return 
                Container(
                  color: const Color(0xFFE8D8C0),
                  child: const Center(
                    child: Icon(
                      Icons.image_outlined,
                      color: Color(0xFF9B7653),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(7, 5, 5, 3),
            child: Text(
              product['name']!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5C4033),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: Row(
              children: [
                const Icon(
                  Icons.star,
                  size: 10,
                  color: Color(0xFFE89A17),
                ),
                const SizedBox(width: 2),
                Text(
                  '${product['rating']} (${product['reviews']})',
                  style: const TextStyle(
                    fontSize: 8,
                    color: Color(0xFF765E4A),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(7, 2, 5, 0),
            child: Text(
              product['price']!,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B5E34),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(7, 1, 5, 0),
            child: Text(
              'by ${product['artisan']}',
              style: const TextStyle(
                fontSize: 8,
                color: Color(0xFF9A806A),
              ),
            ),
          ),
        ],
      ),
   ), );
  }

  // ---------------- BOTTOM NAV ----------------

  Widget _buildBottomNavigation() {
    final items = [
      (Icons.home_rounded, 'Home'),
      (Icons.search_rounded, 'Search'),
      (Icons.grid_view_rounded, 'Categories'),
      (Icons.shopping_bag_rounded, 'Orders'),
      (Icons.person_rounded, 'Profile'),
    ];

    return Container(
      height: 78,
      decoration: const BoxDecoration(
        color: Color(0xFFF6F1E7),
        border: Border(
          top: BorderSide(
            color: Color(0xFFD2B48C),
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          items.length,
          (index) {
            final selected = selectedNav == index;

            return GestureDetector(
            onTap: () {
  setState(() {
    selectedNav = index;
  });

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
              child: SizedBox(
                width: 62,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 50,
                      height: 40,
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF8B5E34)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        items[index].$1,
                        size: 22,
                        color: selected
                            ? Colors.white
                            : const Color(0xFF9A6C43),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      items[index].$2,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                        color: selected
                            ? const Color(0xFF8B5E34)
                            : const Color(0xFF9A806A),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}