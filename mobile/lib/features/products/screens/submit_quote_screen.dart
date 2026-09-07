import 'package:flutter/material.dart';

class SubmitQuoteScreen extends StatefulWidget {
  const SubmitQuoteScreen({super.key});

  @override
  State<SubmitQuoteScreen> createState() => _SubmitQuoteScreenState();
}

class _SubmitQuoteScreenState extends State<SubmitQuoteScreen> {
  static const Color background = Color(0xFFF6F1E7);
  static const Color brown = Color(0xFF8B5E34);
  static const Color darkBrown = Color(0xFF604532);
  static const Color green = Color(0xFF2E7058);
  static const Color border = Color(0xFFD2B48C);
  static const Color lightBrown = Color(0xFFEDE0CC);

  int quantity = 280;
  final double pricePerUnit = 460;

  final TextEditingController noteController = TextEditingController();

  double get subtotal => quantity * pricePerUnit;

  double get gst => subtotal * 0.12;

  double get totalOrderValue => subtotal + gst;

  double get platformFee => totalOrderValue * 0.04;

  double get youEarn => totalOrderValue - platformFee;

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  String money(double value) {
    return '₹${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            // ───────────────── HEADER ─────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              decoration: const BoxDecoration(
                color: brown,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 21,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FULFILL ORDER',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Submit Your Quote',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '94% Match',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ───────────────── CONTENT ─────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  children: [
                    _orderSummary(),

                    const SizedBox(height: 14),

                    _productCard(),

                    const SizedBox(height: 14),

                    _quantityCard(),

                    const SizedBox(height: 14),

                    _shippingCard(),

                    const SizedBox(height: 14),

                    _noteCard(),

                    const SizedBox(height: 14),

                    _billBreakdown(),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ───────────────── SUBMIT ─────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
              decoration: BoxDecoration(
                color: background,
                border: Border(
                  top: BorderSide(
                    color: border.withValues(alpha: 0.7),
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Quote submitted successfully'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check, size: 20),
                  label: const Text(
                    'Submit Quote to Buyer',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════ ORDER SUMMARY ═════════════════

  Widget _orderSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: brown,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Text(
            '📦',
            style: TextStyle(fontSize: 22),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Corporate Gift Boxes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'GiftWala Corp · 300 units · ₹400–₹500/pc',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '15 days',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'deadline',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═════════════════ PRODUCT ═════════════════

  Widget _productCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon: '🏺',
            title: 'Product You Are Making',
          ),

          const SizedBox(height: 14),

          _infoRow(
            'Product Name',
            'Blue Pottery Gift Box Set',
          ),

          _infoRow(
            'Craft Type',
            'Blue Pottery — Jaipur GI Certified',
          ),

          _infoRow(
            'Specification',
            'With logo engraving (buyer design)',
          ),

          _infoRow(
            'Material',
            'Mineral clay, cobalt-blue glaze',
          ),

          _infoRow(
            'Price Per Unit',
            '₹460',
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ═════════════════ QUANTITY ═════════════════

  Widget _quantityCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '📦  Quantity You Can Make',
                  style: TextStyle(
                    color: darkBrown,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: lightBrown,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Min 250',
                  style: TextStyle(
                    color: brown,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _quantityButton(
                icon: Icons.remove,
                onTap: () {
                  if (quantity > 250) {
                    setState(() {
                      quantity -= 10;
                    });
                  }
                },
              ),

              const SizedBox(width: 28),

              Column(
                children: [
                  Text(
                    '$quantity',
                    style: const TextStyle(
                      color: darkBrown,
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text(
                    'units',
                    style: TextStyle(
                      color: Color(0xFF9A8575),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 28),

              _quantityButton(
                icon: Icons.add,
                onTap: () {
                  if (quantity < 500) {
                    setState(() {
                      quantity += 10;
                    });
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '250',
                style: TextStyle(
                  fontSize: 9,
                  color: Color(0xFF9A8575),
                ),
              ),
              Text(
                '500',
                style: TextStyle(
                  fontSize: 9,
                  color: Color(0xFF9A8575),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          LinearProgressIndicator(
            value: (quantity - 250) / 250,
            minHeight: 5,
            backgroundColor: const Color(0xFFE5DED2),
            valueColor: const AlwaysStoppedAnimation<Color>(brown),
          ),

          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2EB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '✓ $quantity units — within your capacity (320 units/month)',
              style: const TextStyle(
                color: green,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: icon == Icons.add ? brown : lightBrown,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: icon == Icons.add ? Colors.white : brown,
          size: 20,
        ),
      ),
    );
  }

  // ═════════════════ SHIPPING ═════════════════

  Widget _shippingCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon: '📅',
            title: 'Expected Shipping Date',
          ),

          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: lightBrown,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Text(
                  '📅',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '18 February 2025',
                      style: TextStyle(
                        color: darkBrown,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '1 day from today',
                      style: TextStyle(
                        color: Color(0xFF9A8575),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: brown,
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            '✓ Within buyer\'s 15-day deadline.',
            style: TextStyle(
              color: green,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════ NOTE ═════════════════

  Widget _noteCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Expanded(
                child: Text(
                  '✍️  Note to Buyer',
                  style: TextStyle(
                    color: darkBrown,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                'Optional',
                style: TextStyle(
                  color: Color(0xFF9A8575),
                  fontSize: 9,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          TextField(
            controller: noteController,
            maxLines: 4,
            maxLength: 200,
            decoration: InputDecoration(
              hintText:
                  'Add any special notes — past work,\ncustomisation capability, delivery assurance...',
              hintStyle: const TextStyle(
                color: Color(0xFFB5A292),
                fontSize: 11,
              ),
              filled: true,
              fillColor: const Color(0xFFF8F3EA),
              counterStyle: const TextStyle(
                fontSize: 9,
                color: Color(0xFF9A8575),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: border,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: border,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════ BILL ═════════════════

  Widget _billBreakdown() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon: '💰',
            title: 'Total Bill Breakdown',
          ),

          const SizedBox(height: 14),

          _billRow(
            '$quantity units × ₹${pricePerUnit.toStringAsFixed(0)}',
            money(subtotal),
          ),

          const SizedBox(height: 8),

          _billRow(
            'GST (12%)',
            '+ ${money(gst)}',
          ),

          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF8F250F),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Order Value',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 9,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        '₹1,44,256',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'After 4% platform fee',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 8,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      money(youEarn),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Text(
                      'You earn',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'You will earn',
                  style: TextStyle(
                    color: Color(0xFF8B6B52),
                    fontSize: 10,
                  ),
                ),
              ),
              Text(
                money(youEarn),
                style: const TextStyle(
                  color: green,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _billRow(String title, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF806F60),
              fontSize: 10,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: darkBrown,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ═════════════════ HELPERS ═════════════════

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: child,
    );
  }

  Widget _sectionTitle({
    required String icon,
    required String title,
  }) {
    return Row(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 15),
        ),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            color: darkBrown,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _infoRow(
    String title,
    String value, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: isLast ? 0 : 11,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF9A8575),
                fontSize: 9.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: darkBrown,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}