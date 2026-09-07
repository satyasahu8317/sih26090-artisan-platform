import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BuyerLanguagesScreen extends StatefulWidget {
  const BuyerLanguagesScreen({super.key});

  @override
  State<BuyerLanguagesScreen> createState() =>
      _BuyerLanguagesScreenState();
}

class _BuyerLanguagesScreenState extends State<BuyerLanguagesScreen> {
  final Set<String> selectedLanguages = {'English'};

  final List<Map<String, String>> languages = [
    {'name': 'Hindi', 'native': 'हिंदी', 'icon': 'हि'},
    {'name': 'English', 'native': 'English', 'icon': 'En'},
    {'name': 'Marathi', 'native': 'मराठी', 'icon': 'म'},
    {'name': 'Tamil', 'native': 'தமிழ்', 'icon': 'த'},
    {'name': 'Telugu', 'native': 'తెలుగు', 'icon': 'తె'},
    {'name': 'Kannada', 'native': 'ಕನ್ನಡ', 'icon': 'ಕ'},
    {'name': 'Bengali', 'native': 'বাংলা', 'icon': 'ব'},
    {'name': 'Gujarati', 'native': 'ગુજરાતી', 'icon': 'ગુ'},
    {'name': 'Punjabi', 'native': 'ਪੰਜਾਬੀ', 'icon': 'ਪ'},
    {'name': 'Urdu', 'native': 'اردو', 'icon': 'ا'},
  ];

  void _toggleLanguage(String language) {
    setState(() {
      if (selectedLanguages.contains(language)) {
        // Keep at least one language selected.
        if (selectedLanguages.length > 1) {
          selectedLanguages.remove(language);
        }
      } else {
        selectedLanguages.add(language);
      }
    });
  }

  void _continue() {
    if (selectedLanguages.isEmpty) return;

    context.go('/buyer-interests');
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
                          'STEP 2 OF 3',
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
                          'Your Languages',
                          style: TextStyle(
                            fontFamily: 'Playfair Display',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const Positioned(
                        left: 18,
                        top: 124,
                        child: Text(
                          "We'll show content in your\nlanguage",
                          style: TextStyle(
                            fontSize: 10,
                            height: 1.3,
                            color: Color(0xFFDCC8B5),
                          ),
                        ),
                      ),

                      // Handbag asset
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
                      16,
                      12,
                      16,
                      8,
                    ),
                    child: Column(
                      children: [
                        // Selected language
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5F1EC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFC5DED4),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                'Selected:',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF5C776B),
                                ),
                              ),
                              const SizedBox(width: 6),
                              ...selectedLanguages.map(
                                (language) => Container(
                                  margin: const EdgeInsets.only(right: 5),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3D765F),
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    language,
                                    style: const TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Language grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          itemCount: languages.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 7,
                            mainAxisSpacing: 7,
                            childAspectRatio: 2.65,
                          ),
                          itemBuilder: (context, index) {
                            final language = languages[index];
                            final name = language['name']!;
                            final isSelected =
                                selectedLanguages.contains(name);

                            return GestureDetector(
                              onTap: () => _toggleLanguage(name),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFF0E5D5)
                                      : Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(11),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF8B5E34)
                                        : const Color(0xFFD2B48C),
                                    width: isSelected ? 1.4 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 29,
                                      height: 29,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFF8B5E34)
                                            : const Color(0xFFEDE0CC),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        language['icon']!,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight:
                                              FontWeight.w700,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(
                                                  0xFF604532,
                                                ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 7),

                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(
                                              fontSize: 9,
                                              fontWeight:
                                                  FontWeight.w700,
                                              color:
                                                  Color(0xFF604532),
                                            ),
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            language['native']!,
                                            style: const TextStyle(
                                              fontSize: 7,
                                              color:
                                                  Color(0xFF9B806B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    if (isSelected)
                                      const Icon(
                                        Icons.check,
                                        size: 14,
                                        color: Color(0xFF3D765F),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // ---------------- PAGE DOTS ----------------

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _dot(false),
                    const SizedBox(width: 6),
                    _dot(true),
                    const SizedBox(width: 6),
                    _dot(false),
                  ],
                ),

                const SizedBox(height: 9),

                // ---------------- CONTINUE ----------------

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: selectedLanguages.isNotEmpty
                          ? _continue
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
                        'Continue →',
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