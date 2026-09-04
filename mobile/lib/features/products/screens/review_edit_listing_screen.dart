import 'package:flutter/material.dart';

class ReviewEditListingScreen extends StatefulWidget {
  const ReviewEditListingScreen({super.key});

  @override
  State<ReviewEditListingScreen> createState() =>
      _ReviewEditListingScreenState();
}

class _ReviewEditListingScreenState
    extends State<ReviewEditListingScreen> {
  final TextEditingController productNameController =
      TextEditingController(text: 'Blue Pottery Vase');

  final TextEditingController descriptionController =
      TextEditingController(
    text:
        'Handcrafted blue pottery vase made using traditional techniques by skilled artisans of Jaipur, Rajasthan.',
  );

  @override
  void dispose() {
    productNameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9EF),
      body: SafeArea(
        child: Column(
          children: [
            // =========================================================
            // MAIN CONTENT
            // =========================================================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =================================================
                    // HEADER
                    // =================================================
                    Row(
                      children: [
                        _backButton(),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Text(
                            'Review & Edit Listing',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF5C4033),
                              fontFamily: 'Playfair Display',
                            ),
                          ),
                        ),

                        const Text(
                          '✏️',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // =================================================
                    // PRODUCT IMAGE
                    // =================================================
                    _productImageCard(),

                    const SizedBox(height: 12),

                    // =================================================
                    // AI ENHANCEMENT
                    // =================================================
                    _aiEnhancementCard(),

                    const SizedBox(height: 16),

                    // =================================================
                    // PRODUCT NAME
                    // =================================================
                    _productNameCard(),

                    const SizedBox(height: 16),

                    // =================================================
                    // DESCRIPTION
                    // =================================================
                    _descriptionCard(),

                    const SizedBox(height: 16),

                    // =================================================
                    // OPTIONAL PRICE SECTION
                    // =================================================
                    _priceCard(),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // =========================================================
            // BOTTOM BUTTONS
            // =========================================================
            _bottomButtons(),
          ],
        ),
      ),
    );
  }

  // =================================================================
  // BACK BUTTON
  // =================================================================

  Widget _backButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFCF6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFD2B48C),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.arrow_back,
          size: 19,
          color: Color(0xFF5C4033),
        ),
      ),
    );
  }

  // =================================================================
  // PRODUCT IMAGE
  // =================================================================

  Widget _productImageCard() {
    return Container(
      width: double.infinity,
      height: 208,
      decoration: BoxDecoration(
        color: const Color(0xFFC77B4A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // AI Enhanced badge
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5E34),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '✨ AI Enhanced',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Placeholder product image
          Center(
            child: Container(
              width: 80,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFFD8945E),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Center(
                child: Text(
                  '🏺',
                  style: TextStyle(fontSize: 48),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =================================================================
  // AI ENHANCEMENT CARD
  // =================================================================

  Widget _aiEnhancementCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        12,
        12,
        12,
        12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD2B48C),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI Enhancement',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8B5E34),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _enhancementItem(
                  '✨',
                  'Background\ncleaned',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _enhancementItem(
                  '✨',
                  'Lighting\nimproved',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _enhancementItem(
                  '✨',
                  'Product\ncentered',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _enhancementItem(
    String icon,
    String text,
  ) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F3EF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          '$icon $text',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            height: 1.2,
            color: Color(0xFF387D69),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // =================================================================
  // PRODUCT NAME CARD
  // =================================================================

  Widget _productNameCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD2B48C),
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PRODUCT NAME',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9A8979),
                  ),
                ),

                const SizedBox(height: 6),

                TextField(
                  controller: productNameController,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF5C4033),
                    fontFamily: 'Playfair Display',
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),

                const SizedBox(height: 6),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '✨ AI Generated',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF5485C4),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Edit button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF0E2CC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                '✏️',
                style: TextStyle(fontSize: 17),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =================================================================
  // DESCRIPTION CARD
  // =================================================================

  Widget _descriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD2B48C),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description heading + language buttons
          Row(
            children: [
              const Expanded(
                child: Text(
                  'DESCRIPTION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9A8979),
                  ),
                ),
              ),

              // English
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5E34),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  'English',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(width: 6),

              // Hindi
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0E2CC),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  'हिंदी',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF5C4033),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          TextField(
            controller: descriptionController,
            maxLines: 5,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF6B5143),
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  // =================================================================
  // PRICE CARD
  // =================================================================

  Widget _priceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD2B48C),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PRICE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9A8979),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '₹800 – ₹1,200',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF8B5E34),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF0E2CC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Edit',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8B5E34),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =================================================================
  // BOTTOM BUTTONS
  // =================================================================

  Widget _bottomButtons() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        24,
        12,
        24,
        16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9EF),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFD2B48C),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // SAVE DRAFT
          Expanded(
            child: SizedBox(
              height: 63,
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Draft saved'),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: Color(0xFF8B5E34),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: const Color(0xFFFFF9EF),
                ),
                child: const Text(
                  'Save Draft',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8B5E34),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // PUBLISH
          Expanded(
            child: SizedBox(
              height: 63,
              child: ElevatedButton(
                onPressed: () {
                  _publishProduct();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5E34),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Publish',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '🚀',
                      style: TextStyle(fontSize: 19),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =================================================================
  // PUBLISH ACTION
  // =================================================================

  void _publishProduct() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product published successfully!'),
      ),
    );
  }
}