import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  final List<String> _recentSearches = [
    'Blue Pottery Vase',
    'Silk Saree',
    'Madhubani Painting',
  ];

  final List<Map<String, String>> _trending = [
    {'name': 'Handwoven Stoles', 'change': '42%'},
    {'name': 'Brass Figurines', 'change': '28%'},
    {'name': 'Jaipur Blue Pottery', 'change': '21%'},
    {'name': 'Warli Wall Art', 'change': '18%'},
    {'name': 'Dhokra Jewellery', 'change': '15%'},
  ];

  final List<Map<String, String>> _products = [
    {
      'name': 'Blue Pottery Vase',
      'artisan': 'Sita Devi · Jaipur',
      'price': '₹800–₹1,200',
      'rating': '4.8',
      'image':
          'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?w=300',
    },
    {
      'name': 'Handwoven Silk Scarf',
      'artisan': 'Meena Kumari · Varanasi',
      'price': '₹1,500–₹2,000',
      'rating': '4.9',
      'image':
          'https://images.unsplash.com/photo-1601924994987-69e26d50dc26?w=300',
    },
    {
      'name': 'Brass Bangle Set',
      'artisan': 'Lakshmi Bai · Jaipur',
      'price': '₹300–₹500',
      'rating': '4.7',
      'image':
          'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=300',
    },
  ];

  final List<Map<String, dynamic>> _collections = [
    {
      'name': 'Wedding Gifts',
      'icon': '💍',
    },
    {
      'name': 'Corporate Gifting',
      'icon': '🎁',
    },
    {
      'name': 'Festive Picks',
      'icon': '🏺',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String value) {
    final query = value.trim();

    if (query.isEmpty) return;

    setState(() {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);

      if (_recentSearches.length > 3) {
        _recentSearches.removeLast();
      }
    });

    _searchController.clear();

    FocusScope.of(context).unfocus();
  }

  void _clearRecentSearches() {
    setState(() {
      _recentSearches.clear();
    });
  }

  void _removeRecentSearch(String search) {
    setState(() {
      _recentSearches.remove(search);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E7),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 13),
                    _buildSearchBar(),
                    const SizedBox(height: 18),
                    _buildRecentSearches(),
                    const SizedBox(height: 18),
                    _buildTrending(),
                    const SizedBox(height: 18),
                    _buildShopCollections(),
                    const SizedBox(height: 18),
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

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget _buildHeader() {
    return const Text(
      'Discover crafts',
      style: TextStyle(
        fontFamily: 'serif',
        fontSize: 21,
        fontWeight: FontWeight.bold,
        color: Color(0xFF5C4033),
      ),
    );
  }

  // ------------------------------------------------------------
  // SEARCH BAR
  // ------------------------------------------------------------

  Widget _buildSearchBar() {
    return Container(
      height: 43,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: const Color(0xFFD2B48C),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 11),
          const Icon(
            Icons.search,
            size: 18,
            color: Color(0xFF8B6B51),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: _performSearch,
              decoration: const InputDecoration(
                hintText: 'Pottery, Sarees, Madhubani...',
                hintStyle: TextStyle(
                  fontSize: 9,
                  color: Color(0xFFB59C87),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            width: 29,
            height: 29,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF0E4D1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.mic_none_rounded,
              size: 16,
              color: Color(0xFF9B6137),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // RECENT SEARCHES
  // ------------------------------------------------------------

  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Recent searches',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF604532),
              ),
            ),
            const Spacer(),
            if (_recentSearches.isNotEmpty)
              GestureDetector(
                onTap: _clearRecentSearches,
                child: const Text(
                  'Clear all',
                  style: TextStyle(
                    fontSize: 7,
                    color: Color(0xFFB65B3A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 7),

        if (_recentSearches.isEmpty)
          const Text(
            'No recent searches',
            style: TextStyle(
              fontSize: 8,
              color: Color(0xFFAA927E),
            ),
          )
        else
          ..._recentSearches.map(
            (search) => _buildRecentSearchItem(search),
          ),
      ],
    );
  }

  Widget _buildRecentSearchItem(String search) {
    return Container(
      height: 31,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: const Color(0xFFD2B48C),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.history,
            size: 13,
            color: Color(0xFFB0967E),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              search,
              style: const TextStyle(
                fontSize: 8,
                color: Color(0xFF765944),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _removeRecentSearch(search),
            child: const Icon(
              Icons.close,
              size: 13,
              color: Color(0xFFB0967E),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // TRENDING
  // ------------------------------------------------------------

  Widget _buildTrending() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trending now 🔥',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF604532),
          ),
        ),
        const SizedBox(height: 7),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: const Color(0xFFD2B48C),
            ),
          ),
          child: Column(
            children: List.generate(
              _trending.length,
              (index) {
                final item = _trending[index];

                return Container(
                  height: 33,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                  ),
                  decoration: BoxDecoration(
                    border: index == _trending.length - 1
                        ? null
                        : const Border(
                            bottom: BorderSide(
                              color: Color(0xFFF0E4D1),
                            ),
                          ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: index == 0
                                ? const Color(0xFFB65B3A)
                                : const Color(0xFF9A806A),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item['name']!,
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF604532),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5F1EC),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '↑ ${item['change']}',
                          style: const TextStyle(
                            fontSize: 6.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3D765F),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // SHOP COLLECTIONS
  // ------------------------------------------------------------

  Widget _buildShopCollections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shop collections',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF604532),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 58,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _collections.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: 7),
            itemBuilder: (context, index) {
              final collection = _collections[index];

              return Container(
                width: 94,
                decoration: BoxDecoration(
                  color: index == 0
                      ? const Color(0xFFE8C75D)
                      : index == 1
                          ? const Color(0xFF8B5E34)
                          : const Color(0xFFB65B3A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      collection['icon'],
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      collection['name'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // POPULAR PRODUCTS
  // ------------------------------------------------------------

  Widget _buildPopularProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular right now',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF604532),
          ),
        ),
        const SizedBox(height: 8),

        ..._products.map(
          (product) => _buildPopularProductCard(product),
        ),
      ],
    );
  }

  Widget _buildPopularProductCard(
    Map<String, String> product,
  ) {
    return GestureDetector(
      onTap: () {
        context.push('/buyer-product-detail');
      },
      child: Container(
        height: 67,
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFD2B48C),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Image.network(
                product['image']!,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return Container(
                    width: 52,
                    height: 52,
                    color: const Color(0xFFE8D8C0),
                    child: const Icon(
                      Icons.image_outlined,
                      size: 20,
                      color: Color(0xFF9B7653),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 9),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name']!,
                    style: const TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF604532),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'by ${product['artisan']}',
                    style: const TextStyle(
                      fontSize: 6.5,
                      color: Color(0xFF9A806A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    product['price']!,
                    style: const TextStyle(
                      fontSize: 7.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B5E34),
                    ),
                  ),
                ],
              ),
            ),

            Row(
              children: [
                const Icon(
                  Icons.star,
                  size: 10,
                  color: Color(0xFFE89A17),
                ),
                const SizedBox(width: 2),
                Text(
                  product['rating']!,
                  style: const TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF765944),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BOTTOM NAV
  // ------------------------------------------------------------

  Widget _buildBottomNavigation() {
    final items = [
      (Icons.home_rounded, 'Home'),
      (Icons.search_rounded, 'Search'),
      (Icons.grid_view_rounded, 'Categories'),
      (Icons.shopping_bag_rounded, 'Orders'),
      (Icons.person_rounded, 'Profile'),
    ];

    return Container(
      height: 65,
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
            final selected = index == 1;

            return GestureDetector(
              onTap: () {
                if (index == 0) {
                  context.go('/buyer-home');
                }
              },
              child: SizedBox(
                width: 55,
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 38,
                      height: 30,
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF8B5E34)
                            : Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(9),
                      ),
                      child: Icon(
                        items[index].$1,
                        size: 18,
                        color: selected
                            ? Colors.white
                            : const Color(0xFF9A6C43),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      items[index].$2,
                      style: TextStyle(
                        fontSize: 7.5,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
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