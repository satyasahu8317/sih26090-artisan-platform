import 'package:flutter/material.dart';
import '../products/screens/add_product_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final Color background = const Color(0xFFF6F1E7);
  final Color brown = const Color(0xFF8B5E34);
  final Color darkBrown = const Color(0xFF604532);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Stack(
              children: [
                // ---------------- MAIN CONTENT ----------------
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 105),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),

                        const SizedBox(height: 16),

                        _buildShopOverview(),

                        const SizedBox(height: 16),

                        _buildAIAssistant(),

                        const SizedBox(height: 16),

                        _buildQuickActions(),

                        const SizedBox(height: 16),

                        _buildBuyerOpportunity(),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // ---------------- BOTTOM NAV ----------------
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildBottomNavigation(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Namaste 🙏',
                style: TextStyle(
                  fontSize: 13,
                  color: const Color(0xFF9B806B),
                ),
              ),

              const SizedBox(height: 2),

              Text(
                'Sita Devi 👋',
                style: TextStyle(
                  fontSize: 26,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                  color: darkBrown,
                  fontFamily: 'serif',
                ),
              ),
            ],
          ),
        ),

        // Notification
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              const Center(
                child: Text(
                  '🔔',
                  style: TextStyle(fontSize: 20),
                ),
              ),

              Positioned(
                right: 9,
                top: 8,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFFB52B16),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================
  // SHOP OVERVIEW
  // =========================================================

  Widget _buildShopOverview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      decoration: BoxDecoration(
        color: brown,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Shop Overview',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFF6E9D8),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: '📦',
                  value: '12',
                  label: 'Products',
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _buildStatCard(
                  icon: '⌛',
                  value: '2',
                  label: 'Pending',
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _buildStatCard(
                  icon: '💸',
                  value: '₹12,450',
                  label: 'Total Sales',
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddProductScreen(),
      ),
    );
  },

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF941E0B),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                '+  Add Product',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String value,
    required String label,
  }) {
    return Container(
      height: 84,
      padding: const EdgeInsets.fromLTRB(10, 9, 8, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF9B6B3E),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 17),
          ),

          const Spacer(),

          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFFF3E5D3),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // AI BUSINESS ASSISTANT
  // =========================================================

  Widget _buildAIAssistant() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE0C59F),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Text(
            '✦',
            style: TextStyle(
              fontSize: 22,
              color: Colors.black,
            ),
          ),

          const SizedBox(width: 10),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Business Assistant',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF604532),
                  ),
                ),

                SizedBox(height: 3),

                Text(
                  '2 products are ready to\npublish.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.25,
                    color: Color(0xFFA58C77),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF0E1CC),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Review',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8B5E34),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // QUICK ACTIONS
  // =========================================================

  Widget _buildQuickActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: '🏺',
                title: 'My Catalog',
                subtitle: '12 products',
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _buildActionCard(
                icon: '▣',
                title: 'Orders & Enquiries',
                subtitle: '3 new',
                iconBackground: const Color(0xFFE8F0D6),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: '🔔',
                title: 'Notifications',
                subtitle: '3 New Updates',
                iconBackground: const Color(0xFFF7E4C1),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _buildActionCard(
                icon: '👤',
                title: 'My Profile',
                subtitle: 'View & Edit',
                iconBackground: const Color(0xFFE6EED2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String icon,
    required String title,
    required String subtitle,
    Color iconBackground = const Color(0xFFF5E1D0),
  }) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE0C59F),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              icon,
              style: const TextStyle(fontSize: 17),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF604532),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF9B806B),
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.chevron_right,
            size: 18,
            color: Color(0xFF8B5E34),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BUYER OPPORTUNITY
  // =========================================================

  Widget _buildBuyerOpportunity() {
    return Container(
      width: double.infinity,
      height: 124,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFFBE4B8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 125, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '✦',
                      style: TextStyle(
                        fontSize: 17,
                        color: Color(0xFF941E0B),
                      ),
                    ),

                    const SizedBox(width: 5),

                    const Text(
                      'New Buyer Opportunity',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8B5E34),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                const Text(
                  '120 Blue Pottery pieces',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF604532),
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Jaipur, Rajasthan  •  Delivery in 15 days',
                  style: TextStyle(
                    fontSize: 8,
                    color: Color(0xFF8B6B52),
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  '₹ 700 – ₹ 900 / piece',
                  style: TextStyle(
                    fontSize: 9,
                    color: Color(0xFF604532),
                  ),
                ),

                const Spacer(),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF941E0B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'View Opportunity  ›',
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Temporary pottery illustration.
          // Later replace this with the actual Figma/exported image.
          Positioned(
            right: 8,
            bottom: 3,
            child: SizedBox(
              width: 105,
              height: 115,
              child: Center(
                child: Text(
                  '🏺',
                  style: TextStyle(
                    fontSize: 78,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BOTTOM NAVIGATION
  // =========================================================

  Widget _buildBottomNavigation() {
    return Container(
      height: 87,
      decoration: BoxDecoration(
        color: background,
        border: const Border(
          top: BorderSide(
            color: Color(0xFFD9C6A9),
            width: 0.8,
          ),
        ),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildNavItem(
                  index: 0,
                  icon: Icons.home_filled,
                  label: 'Home',
                ),
              ),

              Expanded(
                child: _buildNavItem(
                  index: 1,
                  icon: Icons.menu_book_rounded,
                  label: 'Catalog',
                ),
              ),

              // Space for center +
              const SizedBox(width: 76),

              Expanded(
                child: _buildNavItem(
                  index: 2,
                  icon: Icons.shopping_bag_rounded,
                  label: 'Orders',
                ),
              ),

              Expanded(
                child: _buildNavItem(
                  index: 3,
                  icon: Icons.person_rounded,
                  label: 'Profile',
                ),
              ),
            ],
          ),

          // Center + button
          Positioned(
            top: -11,
            child: GestureDetector(
              onTap: () {
                // TODO: Open Add Product
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF941E0B),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: 50,
          height: 58,
          margin: const EdgeInsets.only(top: 14),
          decoration: BoxDecoration(
            color: isSelected ? brown : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF8B5E34),
              ),

              const SizedBox(height: 3),

              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF8B6B52),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}