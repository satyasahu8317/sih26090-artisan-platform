import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/buyer_provider.dart';
import '../data/buyer_order_model.dart';

class BuyerOrderDetailsScreen extends ConsumerWidget {
  final String orderId;

  const BuyerOrderDetailsScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync =
        ref.watch(buyerOrderDetailProvider(orderId));

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E7),
      body: orderAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 42,
                color: Color(0xFFB65B3A),
              ),
              const SizedBox(height: 10),
              const Text(
                'Unable to load order',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF604532),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(
                    buyerOrderDetailProvider(orderId),
                  );
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (order) => _buildOrderScreen(
          context,
          order,
        ),
      ),
    );
  }

  Widget _buildOrderScreen(
    BuildContext context,
    BuyerOrder order,
  ) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                16,
                10,
                16,
                25,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _buildOrderHeader(order),
                  const SizedBox(height: 12),
                  _buildProductCard(order),
                  const SizedBox(height: 14),
                  _buildProgress(order),
                  const SizedBox(height: 14),
                  _buildDeliveryDetails(),
                  const SizedBox(height: 14),
                  _buildPaymentDetails(order),
                  const SizedBox(height: 14),
                  _buildBuyerProtection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF6F1E7),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFD2B48C),
            width: 0.7,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFEDE0CC),
                borderRadius:
                    BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 17,
                color: Color(0xFF604532),
              ),
            ),
          ),
          const SizedBox(width: 9),
          const Expanded(
            child: Text(
              'Order Details',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF604532),
              ),
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(9),
              border: Border.all(
                color: const Color(0xFFD2B48C),
              ),
            ),
            child: const Icon(
              Icons.more_horiz,
              size: 18,
              color: Color(0xFF604532),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHeader(BuyerOrder order) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                order.id,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF9A806A),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Qty ${order.requestedQty ?? '-'}',
                style: const TextStyle(
                  fontSize: 8,
                  color: Color(0xFF765944),
                ),
              ),
            ],
          ),
        ),
        _statusChip(order.status),
      ],
    );
  }

  Widget _statusChip(String? status) {
    final value = status ?? 'Unknown';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE0CC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.circle,
            size: 6,
            color: Color(0xFF8B5E34),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w700,
              color: Color(0xFF8B5E34),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuyerOrder order) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD2B48C),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFFE8D8C0),
              borderRadius:
                  BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Color(0xFF9B7653),
              size: 28,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Product ${order.productId ?? '-'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF604532),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Artisan ${order.artisanId ?? '-'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 7,
                    color: Color(0xFF9A806A),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '₹${_formatPrice(order.unitPrice)} × ${order.requestedQty ?? 0}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B5E34),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double? price) {
    if (price == null) return '-';

    return price
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'\.00$'), '');
  }

  Widget _buildProgress(BuyerOrder order) {
    final status =
        (order.status ?? '').toUpperCase();

    final steps = [
      ('Placed', true),
      (
        'Confirmed',
        [
          'CONFIRMED',
          'ACCEPTED',
          'PARTIALLY_ACCEPTED',
          'FULFILLING',
          'COMPLETED',
        ].contains(status),
      ),
      (
        'Making',
        [
          'FULFILLING',
          'COMPLETED',
        ].contains(status),
      ),
      ('Shipped', false),
      (
        'Delivered',
        status == 'COMPLETED',
      ),
    ];

    return _sectionCard(
      title: 'Order Progress',
      child: Column(
        children: [
          Row(
            children: List.generate(
              steps.length * 2 - 1,
              (index) {
                if (index.isOdd) {
                  final leftCompleted =
                      steps[index ~/ 2].$2;
                  final rightCompleted =
                      steps[(index ~/ 2) + 1].$2;

                  return Expanded(
                    child: Container(
                      height: 2,
                      color: leftCompleted &&
                              rightCompleted
                          ? const Color(0xFF8B5E34)
                          : const Color(0xFFD8C5AC),
                    ),
                  );
                }

                final stepIndex = index ~/ 2;
                final completed =
                    steps[stepIndex].$2;

                return Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: completed
                        ? const Color(0xFF8B5E34)
                        : const Color(0xFFE9DCC9),
                    shape: BoxShape.circle,
                  ),
                  child: completed
                      ? const Icon(
                          Icons.check,
                          size: 11,
                          color: Colors.white,
                        )
                      : null,
                );
              },
            ),
          ),
          const SizedBox(height: 7),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: steps.map((step) {
              return Text(
                step.$1,
                style: TextStyle(
                  fontSize: 6.5,
                  fontWeight: step.$2
                      ? FontWeight.w700
                      : FontWeight.w400,
                  color: step.$2
                      ? const Color(0xFF604532)
                      : const Color(0xFFAA927E),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryDetails() {
    return _sectionCard(
      title: 'Delivery Details',
      child: Column(
        children: [
          _infoRow(
            Icons.calendar_today_outlined,
            'Expected delivery',
            'Not available',
          ),
          const Divider(
            height: 18,
            color: Color(0xFFF0E4D1),
          ),
          _infoRow(
            Icons.local_shipping_outlined,
            'Tracking ID',
            'Not available',
          ),
          const Divider(
            height: 18,
            color: Color(0xFFF0E4D1),
          ),
          _infoRow(
            Icons.location_on_outlined,
            'Delivery address',
            'Not available',
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails(BuyerOrder order) {
    final quantity = order.requestedQty ?? 0;
    final unitPrice = order.unitPrice ?? 0;
    final total = quantity * unitPrice;

    return _sectionCard(
      title: 'Payment Details',
      child: Column(
        children: [
          _priceRow(
            'Unit price',
            '₹${_formatPrice(order.unitPrice)}',
          ),
          const SizedBox(height: 7),
          _priceRow(
            'Quantity',
            '$quantity',
          ),
          const Divider(
            height: 18,
            color: Color(0xFFF0E4D1),
          ),
          _priceRow(
            'Total',
            '₹${_formatPrice(total)}',
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBuyerProtection() {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFE5F1EC),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: const Color(0xFFC5DED4),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.shield_outlined,
            size: 20,
            color: Color(0xFF3D765F),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Buyer protection',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3D765F),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Order information is shown from the backend.',
                  style: TextStyle(
                    fontSize: 7,
                    color: Color(0xFF668A7B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD2B48C),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: Color(0xFF9B806B),
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF9B6137),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 8,
              color: Color(0xFF9A806A),
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: Color(0xFF604532),
          ),
        ),
      ],
    );
  }

  Widget _priceRow(
    String title,
    String value, {
    bool bold = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 8,
              color: const Color(0xFF9A806A),
              fontWeight:
                  bold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 8.5,
            fontWeight:
                bold ? FontWeight.w700 : FontWeight.w500,
            color: const Color(0xFF604532),
          ),
        ),
      ],
    );
  }
}