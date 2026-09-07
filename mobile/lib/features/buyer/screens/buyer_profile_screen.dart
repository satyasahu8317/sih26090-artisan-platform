import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BuyerProfileScreen extends StatelessWidget {
  const BuyerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                child: Column(
                  children: [
                    _buildCompanyCard(),
                    const SizedBox(height: 10),
                    _buildBuyerType(),
                    const SizedBox(height: 10),
                    _buildStats(),
                    const SizedBox(height: 10),
                    _buildCategories(),
                    const SizedBox(height: 10),
                    _buildRecentEnquiries(),
                    const SizedBox(height: 10),
                    _buildOrderHistory(),
                    const SizedBox(height: 12),
                    _buildActionButtons(context),
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
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFFEDE0CC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 16,
                color: Color(0xFF604532),
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
                  'Buyer Profile',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF604532),
                  ),
                ),
                Text(
                  'Business account',
                  style: TextStyle(
                    fontSize: 7,
                    color: Color(0xFF9A806A),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFD2B48C),
              ),
            ),
            child: const Icon(
              Icons.notifications_none,
              size: 17,
              color: Color(0xFF604532),
            ),
          ),
        ],
      ),
    );
  }

  // ================= COMPANY =================

  Widget _buildCompanyCard() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: const Color(0xFFD2B48C),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E5DD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Logo',
                style: TextStyle(
                  fontSize: 7,
                  color: Color(0xFF9A806A),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GiftWala Corp',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF604532),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  '📍 Mumbai, Maharashtra',
                  style: TextStyle(
                    fontSize: 7,
                    color: Color(0xFF9A806A),
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.business_center_outlined,
                      size: 10,
                      color: Color(0xFF487B68),
                    ),
                    SizedBox(width: 3),
                    Text(
                      'Corporate Gifting',
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF487B68),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= BUYER TYPE =================

  Widget _buildBuyerType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BUYER TYPE',
          style: TextStyle(
            fontSize: 7,
            fontWeight: FontWeight.bold,
            letterSpacing: .4,
            color: Color(0xFF9A806A),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _typeCard('🏪', 'Retail Shop', false),
            const SizedBox(width: 6),
            _typeCard('🛍️', 'Boutique', false),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _typeCard('🎁', 'Corporate\nGifting', true),
            const SizedBox(width: 6),
            _typeCard('🔄', 'Reseller', false),
          ],
        ),
      ],
    );
  }

  Widget _typeCard(
    String icon,
    String title,
    bool selected,
  ) {
    return Expanded(
      child: Container(
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFE5F0EA)
              : Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: selected
                ? const Color(0xFF5A927A)
                : const Color(0xFFD2B48C),
          ),
        ),
        child: Row(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF604532),
                ),
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle,
                size: 13,
                color: Color(0xFF487B68),
              ),
          ],
        ),
      ),
    );
  }

  // ================= STATS =================

  Widget _buildStats() {
    return Row(
      children: [
        _statCard(
          '18',
          'Saved',
          Icons.favorite_border,
        ),
        const SizedBox(width: 7),
        _statCard(
          '7',
          'Enquiries Sent',
          Icons.send_outlined,
        ),
        const SizedBox(width: 7),
        _statCard(
          '3',
          'Responded',
          Icons.chat_bubble_outline,
        ),
      ],
    );
  }

  Widget _statCard(
    String number,
    String label,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        height: 68,
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFE0CFB8),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 14,
              color: const Color(0xFFB65B3A),
            ),
            const SizedBox(height: 3),
            Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF604532),
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 6.5,
                color: Color(0xFF9A806A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CATEGORIES =================

  Widget _buildCategories() {
    final categories = [
      ('🏺', 'Pottery'),
      ('🧵', 'Textiles'),
      ('💍', 'Jewellery'),
      ('🎨', 'Paintings'),
      ('🏠', 'Home Decor'),
    ];

    return _section(
      title: 'INTERESTED CRAFT CATEGORIES',
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          ...categories.map(
            (category) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F0E3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFD2B48C),
                ),
              ),
              child: Text(
                '${category.$1}  ${category.$2}',
                style: const TextStyle(
                  fontSize: 7,
                  color: Color(0xFF765944),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFD2B48C),
              ),
            ),
            child: const Text(
              '+ Add',
              style: TextStyle(
                fontSize: 7,
                color: Color(0xFF8B5E34),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= RECENT ENQUIRIES =================

  Widget _buildRecentEnquiries() {
    return _section(
      title: 'RECENT ENQUIRIES',
      child: Column(
        children: [
          _enquiryRow(
            '👩',
            'Sita Devi',
            'Blue Pottery',
            'Replied',
            true,
          ),
          const SizedBox(height: 6),
          _enquiryRow(
            '👨',
            'Ram Lal',
            'Handwoven Textiles',
            'Pending',
            false,
          ),
          const SizedBox(height: 6),
          _enquiryRow(
            '👩',
            'Meena Bai',
            'Lac Jewellery',
            'Pending',
            false,
          ),
        ],
      ),
    );
  }

  Widget _enquiryRow(
    String avatar,
    String name,
    String craft,
    String status,
    bool replied,
  ) {
    return Container(
      height: 43,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: const Color(0xFFE1D0BA),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFFEDE0CC),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                avatar,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 7.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF604532),
                  ),
                ),
                Text(
                  craft,
                  style: const TextStyle(
                    fontSize: 6.5,
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
              color: replied
                  ? const Color(0xFFE5F1EC)
                  : const Color(0xFFF8E9D9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 6.5,
                fontWeight: FontWeight.w600,
                color: replied
                    ? const Color(0xFF3D765F)
                    : const Color(0xFFB65B3A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= ORDER HISTORY =================

  Widget _buildOrderHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE0CFB8),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 19,
            color: Color(0xFFB09A84),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Order History',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9A806A),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Track orders placed directly with artisans.',
                  style: TextStyle(
                    fontSize: 6.5,
                    color: Color(0xFFB09A84),
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
              color: const Color(0xFFF2EBDD),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 6,
                color: Color(0xFFAA927E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= BUTTONS =================

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              context.go('/buyer-home');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB65B3A),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            child: const Text(
              'Browse Products',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF8B5E34),
              side: const BorderSide(
                color: Color(0xFFB65B3A),
              ),
              padding: const EdgeInsets.symmetric(vertical: 11),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            child: const Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ================= SECTION =================

  Widget _section({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE0CFB8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.bold,
              letterSpacing: .4,
              color: Color(0xFF9A806A),
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          items.length,
          (index) {
            final selected = index == 4;

            return GestureDetector(
              onTap: () {
                if (index == 0) {
                  context.go('/buyer-home');
                } else if (index == 1) {
                  context.push('/buyer-search');
                } else if (index == 3) {
                  context.push('/buyer-orders');
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 37,
                    height: 28,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF8B5E34)
                          : Colors.transparent,
                      borderRadius:
                          BorderRadius.circular(8),
                    ),
                    child: Icon(
                      items[index].$1,
                      size: 17,
                      color: selected
                          ? Colors.white
                          : const Color(0xFF9A6C43),
                    ),
                  ),
                  Text(
                    items[index].$2,
                    style: TextStyle(
                      fontSize: 6.5,
                      color: selected
                          ? const Color(0xFF8B5E34)
                          : const Color(0xFF9A806A),
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