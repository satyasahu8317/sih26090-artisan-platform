import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../orders/data/artisan_order_model.dart';
import '../../orders/providers/orders_provider.dart';

class MyOrdersScreen extends ConsumerStatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  ConsumerState<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends ConsumerState<MyOrdersScreen> {
  static const Color background = Color(0xFFF6F1E7);
  static const Color brown = Color(0xFF8B5E34);
  static const Color darkBrown = Color(0xFF604532);
  static const Color green = Color(0xFF2E7058);
  static const Color border = Color(0xFFD2B48C);
  static const Color lightBrown = Color(0xFFEDE0CC);

  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final status = selectedTab == 1 ? 'COMPLETED' : null;
    final ordersAsync = ref.watch(artisanOrdersProvider(status));

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ordersAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: brown),
                ),
                error: (error, stackTrace) => _ErrorState(
                  onRetry: () => ref.invalidate(artisanOrdersProvider(status)),
                ),
                data: (orders) => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  child: Column(
                    children: [
                      _buildStats(orders),
                      const SizedBox(height: 14),
                      _buildTabs(),
                      const SizedBox(height: 12),
                      if (orders.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Text(
                            'No orders found',
                            style: TextStyle(color: Color(0xFF8B6B52)),
                          ),
                        )
                      else
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

  Widget _buildStats(List<ArtisanOrder> orders) {
    final requestedUnits = orders.fold<int>(
      0,
      (total, order) => total + order.requestedQty,
    );
    final totalAmount = orders.fold<double>(
      0,
      (total, order) => total + (order.totalAmount ?? 0),
    );

    return Row(
      children: [
        Expanded(
          child: _statCard(
            value: '${orders.length}',
            label: 'Orders\nActive',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statCard(
            value: '$requestedUnits',
            label: 'Units\nPending',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statCard(
            value: _formatAmount(totalAmount),
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
              title: 'Active',
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
              title: 'Completed',
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

  // ───────────────── ORDER CARD ─────────────────

  Widget _buildOrderCard(ArtisanOrder order) {
    final bool completed = order.status == 'COMPLETED';

    return GestureDetector(
      onTap: () {
        context.push(
          '/order-track',
          extra: {
            'orderId': order.id,
            'status': order.status,
            'requestedQty': order.requestedQty,
          },
        );
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
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: brown,
                    size: 22,
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
                              order.buyer.businessName,
                              style: const TextStyle(
                                color: darkBrown,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 3),

                      Text(
                        order.id,
                        style: const TextStyle(
                          color: Color(0xFF9A8575),
                          fontSize: 8,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Row(
                        children: [
                          Text(
                            order.status,
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
                order.product?.displayName ?? 'Order product',
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
                    '${order.requestedQty} units',
                  ),
                ),
                Expanded(
                  child: _orderInfo(
                    Icons.currency_rupee,
                    _formatAmount(order.totalAmount),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 9),

            const SizedBox(height: 2),

            Text(
              order.buyer.name,
              style: const TextStyle(
                color: Color(0xFF9A8575),
                fontSize: 9,
              ),
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

  String _formatAmount(double? amount) {
    if (amount == null) return 'Not specified';
    return '₹${amount.toStringAsFixed(amount == amount.roundToDouble() ? 0 : 2)}';
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

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Unable to load orders',
            style: TextStyle(
              color: Color(0xFF604532),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}