import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  static const Color background = Color(0xFFF6F1E7);
  static const Color brown = Color(0xFF8B5E34);
  static const Color darkBrown = Color(0xFF604532);
  static const Color green = Color(0xFF2E7058);
  static const Color red = Color(0xFFB52B12);
  static const Color border = Color(0xFFD2B48C);
  static const Color lightBrown = Color(0xFFEDE0CC);

  int selectedTab = 0;

  final List<Map<String, dynamic>> activeOrders = [
    {
      'buyer': 'GiftWala Corp',
      'product': 'Blue Pottery Gift Box Set',
      'orderId': 'ORD-1041',
      'status': 'In Production',
      'amount': '₹1,28,800',
      'units': '280 units',
      'location': 'Mumbai',
      'deadline': 'Pack by 15 Feb 2025',
      'progress': 42,
      'overdue': true,
      'icon': '🎁',
    },
    {
      'buyer': 'RangBazaar',
      'product': 'Madhubani Wall Art Set',
      'orderId': 'ORD-1038',
      'status': 'Packing',
      'amount': '₹72,000',
      'units': '60 units',
      'location': 'Delhi',
      'deadline': 'Pack by 22 Feb 2025',
      'progress': 85,
      'overdue': true,
      'icon': '🎨',
    },
    {
      'buyer': 'Chokhi Dhani Resort',
      'product': 'Terracotta Décor Set',
      'orderId': 'ORD-1034',
      'status': 'In Production',
      'amount': '₹45,600',
      'units': '120 units',
      'location': 'Jaipur',
      'deadline': 'Pack by 1 Mar 2025',
      'progress': 20,
      'overdue': true,
      'icon': '🏺',
    },
  ];

  final List<Map<String, dynamic>> completedOrders = [
    {
      'buyer': 'CraftHouse',
      'product': 'Handmade Pottery Set',
      'orderId': 'ORD-1028',
      'status': 'Completed',
      'amount': '₹36,000',
      'units': '80 units',
      'location': 'Delhi',
      'deadline': 'Delivered',
      'progress': 100,
      'overdue': false,
      'icon': '🏺',
    },
    {
      'buyer': 'Artisan Hub',
      'product': 'Blue Pottery Vase',
      'orderId': 'ORD-1022',
      'status': 'Completed',
      'amount': '₹24,000',
      'units': '40 units',
      'location': 'Mumbai',
      'deadline': 'Delivered',
      'progress': 100,
      'overdue': false,
      'icon': '🎨',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final orders = selectedTab == 0 ? activeOrders : completedOrders;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  children: [
                    _buildStats(),

                    const SizedBox(height: 14),

                    _buildTabs(),

                    const SizedBox(height: 12),

                    if (selectedTab == 0) ...[
                      _buildAttentionCard(),
                      const SizedBox(height: 12),
                    ],

                    ...orders.map(
                      (order) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildOrderCard(order),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ───────────────── HEADER ─────────────────

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: brown,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ORDERS',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'My Orders',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.more_horiz,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── STATS ─────────────────

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            value: '3',
            label: 'Orders\nActive',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statCard(
            value: '468',
            label: 'Units\nPending',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statCard(
            value: '₹2,46,400',
            label: 'Expected\nEarnings',
            smallValue: true,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String value,
    required String label,
    bool smallValue = false,
  }) {
    return Container(
      height: 78,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: darkBrown,
              fontSize: smallValue ? 13 : 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9A8575),
              fontSize: 9,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── TABS ─────────────────

  Widget _buildTabs() {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8DED0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _tabButton(
              title: 'Active (3)',
              selected: selectedTab == 0,
              onTap: () {
                setState(() {
                  selectedTab = 0;
                });
              },
            ),
          ),
          Expanded(
            child: _tabButton(
              title: 'Completed (2)',
              selected: selectedTab == 1,
              onTap: () {
                setState(() {
                  selectedTab = 1;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected ? darkBrown : const Color(0xFF9A8575),
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ───────────────── ATTENTION ─────────────────

  Widget _buildAttentionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0DD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE6C59C),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE1B8),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              color: Color(0xFFB06A18),
              size: 17,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              '1 order needs attention',
              style: TextStyle(
                color: darkBrown,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: brown,
            size: 20,
          ),
        ],
      ),
    );
  }

  // ───────────────── ORDER CARD ─────────────────

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final int progress = order['progress'] as int;
    final bool overdue = order['overdue'] as bool;
    final bool completed = order['status'] == 'Completed';

    return GestureDetector(
      onTap: () {
        context.push('/order-track');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: lightBrown,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order['icon'],
                    style: const TextStyle(fontSize: 21),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              order['buyer'],
                              style: const TextStyle(
                                color: darkBrown,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (overdue)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE1DB),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'URGENT',
                                style: TextStyle(
                                  color: red,
                                  fontSize: 7,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 3),

                      Text(
                        order['orderId'],
                        style: const TextStyle(
                          color: Color(0xFF9A8575),
                          fontSize: 8,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Row(
                        children: [
                          Text(
                            order['status'],
                            style: TextStyle(
                              color: completed ? green : brown,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Icon(
                            Icons.circle,
                            size: 4,
                            color: completed ? green : brown,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 11),

            Container(
              width: double.infinity,
              height: 1,
              color: const Color(0xFFF0E9DF),
            ),

            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                order['product'],
                style: const TextStyle(
                  color: darkBrown,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 7),

            Row(
              children: [
                Expanded(
                  child: _orderInfo(
                    Icons.inventory_2_outlined,
                    order['units'],
                  ),
                ),
                Expanded(
                  child: _orderInfo(
                    Icons.currency_rupee,
                    order['amount'],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 9),

            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 13,
                  color: Color(0xFF9A8575),
                ),
                const SizedBox(width: 4),
                Text(
                  order['location'],
                  style: const TextStyle(
                    color: Color(0xFF9A8575),
                    fontSize: 9,
                  ),
                ),
                const Spacer(),
                Text(
                  order['deadline'],
                  style: TextStyle(
                    color: overdue ? red : green,
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 9),

            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      minHeight: 5,
                      backgroundColor: const Color(0xFFE8E0D6),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        completed ? green : brown,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$progress%',
                  style: TextStyle(
                    color: completed ? green : brown,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _orderInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 13,
          color: const Color(0xFF9A8575),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: darkBrown,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ───────────────── BOTTOM NAV ─────────────────

  Widget _buildBottomNav() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF7),
        border: Border(
          top: BorderSide(
            color: border.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          _navItem(
            icon: Icons.home_outlined,
            label: 'Home',
            onTap: () => context.go('/home'),
          ),
          _navItem(
            icon: Icons.inventory_2_outlined,
            label: 'Catalog',
            onTap: () => context.go('/my-catalog'),
          ),

          Expanded(
            child: GestureDetector(
              onTap: () => context.go('/add-product'),
              child: Center(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: brown,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
              ),
            ),
          ),

          _navItem(
            icon: Icons.shopping_bag_outlined,
            label: 'Orders',
            selected: true,
            onTap: () {},
          ),
          _navItem(
            icon: Icons.person_outline,
            label: 'Profile',
            onTap: () => context.push('/artisan-profile'),
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? brown : const Color(0xFF9A8575),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: selected ? brown : const Color(0xFF9A8575),
                fontSize: 8,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}