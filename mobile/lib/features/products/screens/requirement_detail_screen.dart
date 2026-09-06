import 'package:flutter/material.dart';

class RequirementDetailScreen extends StatelessWidget {
  const RequirementDetailScreen({super.key});

  static const Color background = Color(0xFFF6F1E7);
  static const Color brown = Color(0xFF8B5E34);
  static const Color green = Color(0xFF2E7058);
  static const Color border = Color(0xFFD2B48C);
  static const Color lightBrown = Color(0xFFEDE0CC);
  static const Color textBrown = Color(0xFF6B4A35);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      body: SafeArea(
        child: Column(
          children: [
            // ───────────────── HEADER ─────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: Row(
                children: [
                  // Back button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.arrow_back,
                        color: textBrown,
                        size: 22,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Title
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Requirement Detail',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: textBrown,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'GiftWala Corp · Mumbai',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9A8575),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Match %
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1F1EA),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '94% Match',
                      style: TextStyle(
                        color: green,
                        fontSize: 11,
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
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: Column(
                  children: [
                    _requirementCard(),

                    const SizedBox(height: 14),

                    _matchBreakdown(),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ───────────────── ACTIONS ─────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              decoration: BoxDecoration(
                color: background,
                border: Border(
                  top: BorderSide(
                    color: border.withValues(alpha: 0.7),
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Full fulfil
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: connect with backend
                      },
                      icon: const Icon(
                        Icons.check,
                        size: 20,
                      ),
                      label: const Text(
                        'I Can Fulfill This',
                        style: TextStyle(
                          fontSize: 16,
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

                  const SizedBox(height: 8),

                  // Partial fulfil
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: connect with backend
                      },
                      icon: const Text(
                        '↪',
                        style: TextStyle(
                          fontSize: 18,
                          color: brown,
                        ),
                      ),
                      label: const Text(
                        'I Can Partially Fulfill',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: brown,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(
                          color: brown,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: () {
                      // TODO: pass requirement
                    },
                    child: const Text(
                      'Pass on this requirement',
                      style: TextStyle(
                        color: Color(0xFFA28D7A),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════ REQUIREMENT CARD ═════════════════

  Widget _requirementCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Brown heading
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            color: brown,
            child: const Text(
              'Corporate Gift Boxes — Order Requirement',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _detailRow(
                  icon: '📦',
                  title: 'Quantity',
                  value: '300 units (min. 250)',
                ),

                _detailRow(
                  icon: '💰',
                  title: 'Budget Per Unit',
                  value: '₹400 – ₹500',
                ),

                _detailRow(
                  icon: '⏱',
                  title: 'Delivery Deadline',
                  value: '15 days from acceptance',
                ),

                _detailRow(
                  icon: '📍',
                  title: 'Delivery Location',
                  value: 'Mumbai, Maharashtra',
                ),

                _detailRow(
                  icon: '🎨',
                  title: 'Specifications',
                  value: 'Pottery — with logo engraving',
                ),

                _detailRow(
                  icon: '🏢',
                  title: 'Buyer',
                  value: 'GiftWala Corp (Verified B2B)',
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow({
    required String icon,
    required String title,
    required String value,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: isLast ? 0 : 14,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Text(
              icon,
              style: const TextStyle(fontSize: 17),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFA08C7B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: textBrown,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════ AI MATCH BREAKDOWN ═════════════════

  Widget _matchBreakdown() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                const Text(
                  '✨',
                  style: TextStyle(fontSize: 16),
                ),

                const SizedBox(width: 7),

                const Expanded(
                  child: Text(
                    'AI Match Breakdown',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textBrown,
                    ),
                  ),
                ),

                const Text(
                  '94%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            const Divider(
              height: 1,
              color: Color(0xFFE6D7C4),
            ),

            const SizedBox(height: 12),

            _matchItem(
              title: 'Product Type Match',
              subtitle: 'Pottery — exact match',
              percentage: '100%',
              weight: 'weight 30%',
              progress: 1.0,
            ),

            const SizedBox(height: 14),

            _matchItem(
              title: 'Production Capacity',
              subtitle: 'You can make 300+ units/month',
              percentage: '90%',
              weight: 'weight 25%',
              progress: 0.90,
            ),

            const SizedBox(height: 14),

            _matchItem(
              title: 'Price Range',
              subtitle: 'Your avg ₹450/pc fits ₹400–₹500',
              percentage: '95%',
              weight: 'weight 25%',
              progress: 0.95,
            ),

            const SizedBox(height: 14),

            _matchItem(
              title: 'Delivery Time',
              subtitle: 'Your avg 12 days vs 15 day deadline',
              percentage: '88%',
              weight: 'weight 20%',
              progress: 0.88,
            ),
          ],
        ),
      ),
    );
  }

  Widget _matchItem({
    required String title,
    required String subtitle,
    required String percentage,
    required String weight,
    required double progress,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textBrown,
                ),
              ),
            ),
            Text(
              percentage,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: green,
              ),
            ),
          ],
        ),

        const SizedBox(height: 3),

        Row(
          children: [
            Expanded(
              child: Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 9.5,
                  color: Color(0xFF9A8575),
                ),
              ),
            ),
            Text(
              weight,
              style: const TextStyle(
                fontSize: 9.5,
                color: Color(0xFF9A8575),
              ),
            ),
          ],
        ),

        const SizedBox(height: 5),

        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: const Color(0xFFE5E0D7),
            valueColor: const AlwaysStoppedAnimation<Color>(green),
          ),
        ),
      ],
    );
  }
}