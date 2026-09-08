import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/buyer_provider.dart';
import '../data/buyer_order_model.dart';

class BuyerOrdersScreen extends ConsumerWidget {
  const BuyerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(buyerMyOrdersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBF7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'My Orders',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D241F),
          ),
        ),
      ),
      body: ordersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => _buildError(
          context,
          ref,
          error,
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return _buildEmpty();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(buyerMyOrdersProvider);
              await ref.read(buyerMyOrdersProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                16,
                12,
                16,
                24,
              ),
              itemCount: orders.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final order = orders[index];

                return _OrderCard(
                  order: order,
                  onTap: () {
                    context.push(
                      '/buyer-order-details',
                      extra: order.id,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8DF),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 38,
                color: Color(0xFF8B5E3C),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No orders yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D241F),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your orders will appear here once you place an order.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF756A63),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    WidgetRef ref,
    Object error,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load orders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check your connection and try again.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(buyerMyOrdersProvider);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final BuyerOrder order;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = order.status ?? 'UNKNOWN';

    final quantity = order.requestedQty?.toString() ?? '—';

    final unitPrice = order.unitPrice != null
        ? '₹${order.unitPrice!.toStringAsFixed(2)}'
        : '—';

    final total = order.unitPrice != null &&
            order.requestedQty != null
        ? '₹${(order.unitPrice! * order.requestedQty!).toStringAsFixed(2)}'
        : '—';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE8DDD5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4E9DF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: Color(0xFF8B5E3C),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2D241F),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _shortId(order.id),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF82766E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusChip(status: status),
                ],
              ),

              const SizedBox(height: 18),

              _InfoRow(
                icon: Icons.inventory_2_outlined,
                label: 'Product ID',
                value: _shortId(order.productId),
              ),

              const SizedBox(height: 10),

              _InfoRow(
                icon: Icons.person_outline,
                label: 'Artisan ID',
                value: _shortId(order.artisanId),
              ),

              const SizedBox(height: 10),

              _InfoRow(
                icon: Icons.format_list_numbered,
                label: 'Quantity',
                value: quantity,
              ),

              const SizedBox(height: 10),

              _InfoRow(
                icon: Icons.currency_rupee,
                label: 'Unit price',
                value: unitPrice,
              ),

              const Divider(
                height: 24,
                color: Color(0xFFEDE3DC),
              ),

              Row(
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF756A63),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    total,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2D241F),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Color(0xFF8B5E3C),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _shortId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Not available';
    }

    if (value.length <= 12) {
      return value;
    }

    return '${value.substring(0, 8)}...';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF8B5E3C),
        ),
        const SizedBox(width: 9),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF756A63),
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3B302A),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final displayStatus = status.replaceAll('_', ' ');

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8DF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        displayStatus,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF8B5E3C),
        ),
      ),
    );
  }
}