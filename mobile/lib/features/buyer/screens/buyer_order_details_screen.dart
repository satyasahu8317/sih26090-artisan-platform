import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BuyerOrderDetailsScreen extends StatelessWidget {
  const BuyerOrderDetailsScreen({super.key});

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
                padding: const EdgeInsets.fromLTRB(
                  16,
                  10,
                  16,
                  25,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderHeader(),
                    const SizedBox(height: 12),
                    _buildProductCard(),
                    const SizedBox(height: 14),
                    _buildProgress(),
                    const SizedBox(height: 14),
                    _buildDeliveryDetails(),
                    const SizedBox(height: 14),
                    _buildPaymentDetails(),
                    const SizedBox(height: 14),
                    _buildBuyerProtection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 10),
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
                borderRadius: BorderRadius.circular(9),
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
              borderRadius: BorderRadius.circular(9),
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

  // ------------------------------------------------------------
  // ORDER HEADER
  // ------------------------------------------------------------

  Widget _buildOrderHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ORD-2847',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF9A806A),
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Ordered 20 Aug 2026 · Qty 2',
                style: TextStyle(
                  fontSize: 8,
                  color: Color(0xFF765944),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE0CC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.circle,
                size: 6,
                color: Color(0xFF8B5E34),
              ),
              SizedBox(width: 4),
              Text(
                'Making',
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF8B5E34),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // PRODUCT
  // ------------------------------------------------------------

  Widget _buildProductCard() {
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
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: Image.network(
              'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?w=300',
              width: 68,
              height: 68,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return Container(
                  width: 68,
                  height: 68,
                  color: const Color(0xFFE8D8C0),
                  child: const Icon(
                    Icons.image_outlined,
                    color: Color(0xFF9B7653),
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 10),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Blue Pottery Vase',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF604532),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'by Sita Devi · Jaipur, Rajasthan',
                  style: TextStyle(
                    fontSize: 7,
                    color: Color(0xFF9A806A),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '₹2,120',
                  style: TextStyle(
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

  // ------------------------------------------------------------
  // PROGRESS
  // ------------------------------------------------------------

  Widget _buildProgress() {
    final steps = [
      ('Placed', true),
      ('Confirmed', true),
      ('Making', true),
      ('Shipped', false),
      ('Delivered', false),
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
                  return Expanded(
                    child: Container(
                      height: 2,
                      color: index < 5
                          ? const Color(0xFF8B5E34)
                          : const Color(0xFFD8C5AC),
                    ),
                  );
                }

                final stepIndex = index ~/ 2;
                final completed = steps[stepIndex].$2;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: steps.map(
              (step) {
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
              },
            ).toList(),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // DELIVERY
  // ------------------------------------------------------------

  Widget _buildDeliveryDetails() {
    return _sectionCard(
      title: 'Delivery Details',
      child: Column(
        children: [
          _infoRow(
            Icons.calendar_today_outlined,
            'Expected delivery',
            '5 Sep 2026',
          ),
          const Divider(
            height: 18,
            color: Color(0xFFF0E4D1),
          ),
          _infoRow(
            Icons.local_shipping_outlined,
            'Tracking ID',
            'INDC-84928',
          ),
          const Divider(
            height: 18,
            color: Color(0xFFF0E4D1),
          ),
          _infoRow(
            Icons.location_on_outlined,
            'Delivery address',
            'Mumbai, Maharashtra',
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // PAYMENT
  // ------------------------------------------------------------

  Widget _buildPaymentDetails() {
    return _sectionCard(
      title: 'Payment Details',
      child: Column(
        children: [
          _priceRow(
            'Product price',
            '₹2,000',
          ),
          const SizedBox(height: 7),
          _priceRow(
            'Delivery',
            '₹80',
          ),
          const Divider(
            height: 18,
            color: Color(0xFFF0E4D1),
          ),
          _priceRow(
            'Total paid',
            '₹2,080',
            bold: true,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 13,
                color: Color(0xFF3D765F),
              ),
              const SizedBox(width: 5),
              const Text(
                'Payment successful',
                style: TextStyle(
                  fontSize: 7,
                  color: Color(0xFF3D765F),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // BUYER PROTECTION
  // ------------------------------------------------------------

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
                  'Full refund if not as described · 7-day returns',
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

  // ------------------------------------------------------------
  // HELPERS
  // ------------------------------------------------------------

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
        crossAxisAlignment: CrossAxisAlignment.start,
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