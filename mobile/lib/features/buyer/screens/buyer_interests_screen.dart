import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BuyerInterestsScreen extends StatefulWidget {
  const BuyerInterestsScreen({super.key});

  @override
  State<BuyerInterestsScreen> createState() =>
      _BuyerInterestsScreenState();
}

class _BuyerInterestsScreenState extends State<BuyerInterestsScreen> {
  final Set<String> selectedCategories = {
    'Home Decor',
    'Paintings',
  };

  final List<Map<String, String>> categories = [
    {
      'name': 'Pottery',
      'subtitle': 'Vases, pots, ceramic art',
      'icon': '🏺',
    },
    {
      'name': 'Textiles',
      'subtitle': 'Sarees, stoles, weaves',
      'icon': '🧶',
    },
    {
      'name': 'Jewellery',
      'subtitle': 'Lac, silver, gold craft',
      'icon': '💍',
    },
    {
      'name': 'Woodcraft',
      'subtitle': 'Carved & turned wood',
      'icon': '🪵',
    },
    {
      'name': 'Home Decor',
      'subtitle': 'Lamps, rugs, wall art',
      'icon': '🏮',
    },
    {
      'name': 'Paintings',
      'subtitle': 'Madhubani, Warli, folk',
      'icon': '🎨',
    },
    {
      'name': 'Metalwork',
      'subtitle': 'Brass, copper, Dhokra',
      'icon': '🏆',
    },
    {
      'name': 'Leatherwork',
      'subtitle': 'Bags, footwear, belts',
      'icon': '👜',
    },
  ];

  void _toggleCategory(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (selectedCategories.length == categories.length) {
        selectedCategories.clear();
      } else {
        selectedCategories
          ..clear()
          ..addAll(
            categories.map((category) => category['name']!),
          );
      }
    });
  }

  void _startExploring() {
    if (selectedCategories.isEmpty) return;

    context.go('/buyer-home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E7),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Column(
              children: [
                // ---------------- HEADER ----------------

                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF54220F),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(26),
                      bottomRight: Radius.circular(26),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 16,
                        left: 16,
                        child: GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const Positioned(
                        left: 18,
                        top: 68,
                        child: Text(
                          'STEP 3 OF 3',
                          style: TextStyle(
                            fontSize: 8,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFCBAF96),
                          ),
                        ),
                      ),

                      const Positioned(
                        left: 18,
                        top: 91,
                        child: Text(
                          'What do you love?',
                          style: TextStyle(
                            fontFamily: 'Playfair Display',
                            fontSize: 23,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const Positioned(
                        left: 18,
                        top: 124,
                        child: Text(
                          'Pick the crafts you are most\ninterested in',
                          style: TextStyle(
                            fontSize: 10,
                            height: 1.3,
                            color: Color(0xFFDCC8B5),
                          ),
                        ),
                      ),

                      // Handbag
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: SizedBox(
                          width: 130,
                          height: 155,
                          child: Image.asset(
                            'assets/images/handbag.png',
                            fit: BoxFit.contain,
                            alignment: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ---------------- CONTENT ----------------

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      12,
                      11,
                      12,
                      6,
                    ),
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Choose one or more craft categories. Your feed and\n'
                            'recommendations will be personalised to these.',
                            style: TextStyle(
                              fontSize: 8,
                              height: 1.35,
                              color: Color(0xFF9B806B),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Selected count
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCE8DD),
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                              color: const Color(0xFFF1C9B6),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.favorite_border,
                                size: 11,
                                color: Color(0xFFB65B3A),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${selectedCategories.length} categories selected',
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFB65B3A),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Category grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          itemCount: categories.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 7,
                            mainAxisSpacing: 7,
                            childAspectRatio: 1.55,
                          ),
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final name = category['name']!;
                            final isSelected =
                                selectedCategories.contains(name);

                            return GestureDetector(
                              onTap: () => _toggleCategory(name),
                              child: Container(
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFB9794E)
                                      : const Color(0xFF806F60),
                                  borderRadius:
                                      BorderRadius.circular(13),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFE7C5A5)
                                        : const Color(0xFFD2B48C),
                                    width: 1,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment:
                                          Alignment.topRight,
                                      child: Text(
                                        category['icon']!,
                                        style: const TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),

                                    if (isSelected)
                                      Positioned(
                                        left: 0,
                                        top: 0,
                                        child: Container(
                                          width: 17,
                                          height: 17,
                                          decoration:
                                              const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            size: 11,
                                            color: Color(0xFF3D765F),
                                          ),
                                        ),
                                      ),

                                    Positioned(
                                      left: 0,
                                      bottom: 0,
                                      right: 0,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(
                                              fontFamily:
                                                  'Playfair Display',
                                              fontSize: 10,
                                              fontWeight:
                                                  FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            category['subtitle']!,
                                            maxLines: 1,
                                            overflow:
                                                TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 7,
                                              color:
                                                  Color(0xFFF1E5D9),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 8),

                        // Select all
                        GestureDetector(
                          onTap: _selectAll,
                          child: Container(
                            width: double.infinity,
                            height: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1E4D0),
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(
                                color: const Color(0xFFD8BD97),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.favorite_border,
                                  size: 10,
                                  color: Color(0xFF8B5E34),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  selectedCategories.length ==
                                          categories.length
                                      ? 'Deselect All Categories'
                                      : 'Select All Categories',
                                  style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF8B5E34),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ---------------- DOTS ----------------

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _dot(false),
                    const SizedBox(width: 6),
                    _dot(false),
                    const SizedBox(width: 6),
                    _dot(true),
                  ],
                ),

                const SizedBox(height: 8),

                // ---------------- START EXPLORING ----------------

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: selectedCategories.isNotEmpty
                          ? _startExploring
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5E34),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Start Exploring ✦',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dot(bool active) {
    return Container(
      width: active ? 18 : 5,
      height: 5,
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF8B5E34)
            : const Color(0xFFD2B48C),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}