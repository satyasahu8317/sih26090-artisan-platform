import 'package:flutter/material.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  int selectedFilter = 0;

  final List<String> filters = [
    'All',
    'Published',
    'Pending',
    'Draft',
  ];

  final List<Map<String, dynamic>> products = [
    {
      'name': 'Blue Pottery Vase',
      'price': '₹800–₹1,200',
      'status': 'Published',
      'views': '4,650',
      'enquiries': '7',
      'image': 'assets/images/vase.png',
    },
    {
      'name': 'Clay Pot',
      'price': '₹500–₹900',
      'status': 'Pending',
      'views': '',
      'enquiries': '',
      'image': 'assets/images/clay_pot.png',
    },
    {
      'name': 'Decorative Plate',
      'price': '₹700–₹1,200',
      'status': 'Published',
      'views': '2,340',
      'enquiries': '3',
      'image': 'assets/images/plate.png',
    },
    {
      'name': 'Woven Bag',
      'price': '₹400–₹600',
      'status': 'Draft',
      'views': '',
      'enquiries': '',
      'image': 'assets/images/bag.png',
    },
    {
      'name': 'Bangle Set',
      'price': '₹300–₹500',
      'status': 'Published',
      'views': '1,120',
      'enquiries': '5',
      'image': 'assets/images/bangles.png',
    },
  ];

  List<Map<String, dynamic>> get filteredProducts {
    if (selectedFilter == 0) {
      return products;
    }

    final selectedStatus = filters[selectedFilter];

    return products
        .where((product) => product['status'] == selectedStatus)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF8F3EE);
    const brown = Color(0xFF8B5E34);
    const darkBrown = Color(0xFF5C4033);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ---------------- HEADER ----------------
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Catalog',
                      style: TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        color: darkBrown,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'मेरी सूची',
                      style: TextStyle(
                        fontSize: 13,
                        color: brown.withOpacity(0.65),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ---------------- FILTERS ----------------
            SizedBox(
              height: 44,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                itemBuilder: (context, index) {
                  final isSelected = selectedFilter == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedFilter = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 17,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? brown : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isSelected
                              ? brown
                              : const Color(0xFFD2B48C),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        filters[index],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : darkBrown,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // ---------------- PRODUCT LIST ----------------
            Expanded(
              child: filteredProducts.isEmpty
                  ? const Center(
                      child: Text(
                        'No products found',
                        style: TextStyle(
                          color: Color(0xFF8B6B52),
                          fontSize: 15,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        return _productCard(
                          product: filteredProducts[index],
                          brown: brown,
                          darkBrown: darkBrown,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // ---------------- BOTTOM NAVIGATION ----------------
      bottomNavigationBar: _bottomNavigationBar(
        brown: brown,
        darkBrown: darkBrown,
      ),

      // ---------------- ADD BUTTON ----------------
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add Product screen navigation later
        },
        backgroundColor: const Color(0xFF8B2E13),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 29,
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
    );
  }

  // ============================================================
  // PRODUCT CARD
  // ============================================================

  Widget _productCard({
    required Map<String, dynamic> product,
    required Color brown,
    required Color darkBrown,
  }) {
    final status = product['status'] as String;

    Color statusTextColor;
    Color statusBackground;

    switch (status) {
      case 'Pending':
        statusTextColor = const Color(0xFFD65F38);
        statusBackground = const Color(0xFFFFE5DC);
        break;

      case 'Draft':
        statusTextColor = const Color(0xFF80664F);
        statusBackground = const Color(0xFFEDE1D1);
        break;

      default:
        statusTextColor = const Color(0xFF43866B);
        statusBackground = const Color(0xFFDDF1E8);
    }

    return Container(
      height: 76,
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD2B48C),
          width: 0.7,
        ),
      ),
      child: Row(
        children: [
          // IMAGE
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: Color(0xFFC4774C),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Icon(
                _getProductIcon(product['name']),
                size: 34,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),

          // CONTENT
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(11, 9, 9, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product['name'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: darkBrown,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),

                      // STATUS
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            color: statusTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    product['price'],
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: brown,
                    ),
                  ),

                  const Spacer(),

                  if (product['views'] != '')
                    Row(
                      children: [
                        Icon(
                          Icons.visibility_outlined,
                          size: 11,
                          color: darkBrown.withOpacity(0.65),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          product['views'],
                          style: TextStyle(
                            fontSize: 8.5,
                            color: darkBrown.withOpacity(0.65),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 10,
                          color: darkBrown.withOpacity(0.65),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          product['enquiries'],
                          style: TextStyle(
                            fontSize: 8.5,
                            color: darkBrown.withOpacity(0.65),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // ARROW
          Padding(
            padding: const EdgeInsets.only(right: 9),
            child: Icon(
              Icons.chevron_right,
              size: 19,
              color: brown.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRODUCT ICON
  // ============================================================

  IconData _getProductIcon(String name) {
    switch (name) {
      case 'Blue Pottery Vase':
        return Icons.local_florist_outlined;

      case 'Clay Pot':
        return Icons.ramen_dining_outlined;

      case 'Decorative Plate':
        return Icons.dinner_dining_outlined;

      case 'Woven Bag':
        return Icons.shopping_bag_outlined;

      case 'Bangle Set':
        return Icons.circle_outlined;

      default:
        return Icons.image_outlined;
    }
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _bottomNavigationBar({
    required Color brown,
    required Color darkBrown,
  }) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Color(0xFFF8F3EE),
        border: Border(
          top: BorderSide(
            color: Color(0xFFD2B48C),
            width: 0.6,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            icon: Icons.home_outlined,
            label: 'Home',
            selected: false,
            brown: brown,
          ),

          _navItem(
            icon: Icons.description_outlined,
            label: 'Catalog',
            selected: true,
            brown: brown,
          ),

          const SizedBox(width: 55),

          _navItem(
            icon: Icons.shopping_bag_outlined,
            label: 'Orders',
            selected: false,
            brown: brown,
          ),

          _navItem(
            icon: Icons.person_outline,
            label: 'Profile',
            selected: false,
            brown: brown,
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required bool selected,
    required Color brown,
  }) {
    return SizedBox(
      width: 55,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 21,
            color: selected ? brown : const Color(0xFF96785D),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 8.5,
              fontWeight:
                  selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? brown : const Color(0xFF96785D),
            ),
          ),
        ],
      ),
    );
  }
}