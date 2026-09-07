import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BuyerPaymentScreen extends StatelessWidget {
  const BuyerPaymentScreen({super.key});

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
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
                child: Column(
                  children: [
                    _buildOrderSummary(),
                    const SizedBox(height: 10),
                    _buildDeliveryAddress(),
                    const SizedBox(height: 14),
                    _buildTotal(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF8B5E34),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(
                  Icons.arrow_back,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CHECKOUT',
                      style: TextStyle(
                        fontSize: 7,
                        letterSpacing: 1,
                        color: Color(0xFFEADCC9),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Payment',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0D6B8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '🔒 Secure',
                  style: TextStyle(
                    fontSize: 6.5,
                    color: Color(0xFF39745D),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _step('✓', 'Cart', true),
              _line(true),
              _step('✓', 'Address', true),
              _line(true),
              _step('3', 'Payment', true),
              _line(false),
              _step('4', 'Confirm', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _step(String number, String title, bool active) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFF39745D)
                : const Color(0xFFC7A982),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 7,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          title,
          style: TextStyle(
            fontSize: 5.5,
            color: active
                ? Colors.white
                : const Color(0xFFDCC7AC),
          ),
        ),
      ],
    );
  }

  Widget _line(bool active) {
    return Expanded(
      child: Container(
        height: 1,
        margin: const EdgeInsets.only(
          left: 4,
          right: 4,
          bottom: 13,
        ),
        color: active
            ? const Color(0xFF39745D)
            : const Color(0xFFC7A982),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF604532),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 7,
                    color: Color(0xFF8B5E34),
                  ),
                ),
              ),
            ],
          ),

          const Divider(
            color: Color(0xFFE7D8C5),
            height: 10,
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8D4B9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    '🏺',
                    style: TextStyle(fontSize: 22),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Blue Pottery Gift Box Set',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF604532),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Sita Devi · Jaipur · GI Certified',
                      style: TextStyle(
                        fontSize: 6,
                        color: Color(0xFF967D67),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      '280 units × ₹460',
                      style: TextStyle(
                        fontSize: 6,
                        color: Color(0xFF967D67),
                      ),
                    ),
                  ],
                ),
              ),

              const Text(
                '₹1,28,800',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF604532),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _priceRow('Subtotal', '₹1,28,800'),
          _priceRow('GST (12%)', '₹15,456'),
          _priceRow('Shipping', 'Free',
              valueColor: const Color(0xFF39745D)),
          _priceRow('Platform fee', '₹2,576'),

          const Divider(
            color: Color(0xFFE7D8C5),
            height: 14,
          ),

          _priceRow(
            'Total to Pay',
            '₹1,46,832',
            bold: true,
            valueSize: 13,
          ),
        ],
      ),
    );
  }

  Widget _priceRow(
    String label,
    String value, {
    bool bold = false,
    double valueSize = 7,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: bold ? 8 : 7,
                fontWeight:
                    bold ? FontWeight.bold : FontWeight.normal,
                color: bold
                    ? const Color(0xFF604532)
                    : const Color(0xFF967D67),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: valueSize,
              fontWeight:
                  bold ? FontWeight.bold : FontWeight.w500,
              color: valueColor ??
                  (bold
                      ? const Color(0xFF8B5E34)
                      : const Color(0xFF765E4A)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Deliver To',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF604532),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Change',
                  style: TextStyle(
                    fontSize: 7,
                    color: Color(0xFF8B5E34),
                  ),
                ),
              ),
            ],
          ),

          const Divider(
            color: Color(0xFFE7D8C5),
            height: 8,
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3EFE8),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(
                  Icons.business_outlined,
                  size: 15,
                  color: Color(0xFF39745D),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GiftWala Corp — Mumbai Office',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF604532),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      '302 Trade Centre, Bandra Kurla Complex,\n'
                      'Mumbai 400051, Maharashtra',
                      style: TextStyle(
                        fontSize: 6.5,
                        height: 1.3,
                        color: Color(0xFF967D67),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      '+91 98201 55432',
                      style: TextStyle(
                        fontSize: 6,
                        color: Color(0xFF967D67),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotal() {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Total amount',
            style: TextStyle(
              fontSize: 6.5,
              color: Color(0xFF967D67),
            ),
          ),
        ),

        const SizedBox(height: 2),

        Row(
          children: [
            const Text(
              '₹1,46,832',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B5E34),
              ),
            ),
            const Spacer(),
            const Text(
              'via ',
              style: TextStyle(
                fontSize: 6,
                color: Color(0xFF967D67),
              ),
            ),
            const Text(
              'Razorpay',
              style: TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3569A8),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        SizedBox(
          width: double.infinity,
          height: 45,
          child: ElevatedButton.icon(
            onPressed: () {
              // Later: Razorpay/backend payment integration
            },
            icon: const Icon(
              Icons.credit_card_outlined,
              size: 16,
            ),
            label: const Text(
              'Pay ₹1,46,832',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F8065),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          '🔒 Secured by KalaMitr · 256-bit SSL',
          style: TextStyle(
            fontSize: 5.8,
            color: Color(0xFF9A806A),
          ),
        ),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: const Color(0xFFE0CFB8),
        ),
      ),
      child: child,
    );
  }
}