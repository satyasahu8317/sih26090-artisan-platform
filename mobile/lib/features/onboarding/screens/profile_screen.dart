import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController =
      TextEditingController();

  String? selectedCraft;
  String selectedLanguage = 'हिंदी';

  final List<String> crafts = [
    'Pottery',
    'Textiles',
    'Jewellery',
    'Woodcraft',
    'Painting',
    'Weaving',
  ];

  final List<String> languages = [
    'हिंदी',
    'मराठी',
    'தமிழ்',
    'తెలుగు',
    'English',
  ];

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _saveAndContinue() {
    FocusScope.of(context).unfocus();

    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name'),
        ),
      );
      return;
    }

    if (selectedCraft == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select what you make'),
        ),
      );
      return;
    }

    context.go('/artisan-address');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E7),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 390,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // ---------------- TOP ROW ----------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE0CC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          color: Color(0xFF8B5E34),
                          size: 21,
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE0CC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Step 1 of 2',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8B5E34),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ---------------- HEADING ----------------
                  const Text(
                    "Let's set up\nyour profile",
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 29,
                      height: 1.05,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF604532),
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'This helps buyers trust you.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8B6B52),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ---------------- FORM ----------------
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Name',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF604532),
                            ),
                          ),

                          const SizedBox(height: 7),

                          TextField(
                            controller: nameController,
                            decoration: _inputDecoration(
                              hintText: 'e.g. Sita Devi',
                            ),
                          ),

                          const SizedBox(height: 14),

                          // WHAT DO YOU MAKE
                          const Text(
                            'What do you make?',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF604532),
                            ),
                          ),

                          const SizedBox(height: 8),

                          GridView.builder(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            itemCount: crafts.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 7,
                              mainAxisSpacing: 7,
                              childAspectRatio: 2.15,
                            ),
                            itemBuilder: (context, index) {
                              final craft = crafts[index];
                              final isSelected =
                                  selectedCraft == craft;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedCraft = craft;
                                  });
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF8B5E34)
                                        : Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(9),
                                    border: Border.all(
                                      color: const Color(0xFFD2B48C),
                                    ),
                                  ),
                                  child: Text(
                                    craft,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF604532),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 18),

                          // PREFERRED LANGUAGE
                          const Text(
                            'Preferred Language',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF604532),
                            ),
                          ),

                          const SizedBox(height: 7),

                          DropdownButtonFormField<String>(
                            initialValue: selectedLanguage,
                            decoration: _inputDecoration(),
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              size: 18,
                              color: Color(0xFF8B5E34),
                            ),
                            dropdownColor: Colors.white,
                            items: languages.map((language) {
                              return DropdownMenuItem<String>(
                                value: language,
                                child: Text(
                                  language,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF604532),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedLanguage = value;
                                });
                              }
                            },
                          ),

                          const SizedBox(height: 14),

                          // DESCRIPTION
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Describe yourself',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF604532),
                                ),
                              ),
                              Text(
                                '(Optional)',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF9B806B),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 7),

                          TextField(
                            controller: descriptionController,
                            maxLines: 3,
                            decoration: _inputDecoration(
                              hintText:
                                  'eg. Making handmade pottery for 12 years · 3rd generation craftsperson from Jaipur',
                            ),
                          ),

                          const SizedBox(height: 12),

                          // PRIVACY BOX
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F3EE),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: const Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '🔒',
                                  style: TextStyle(fontSize: 12),
                                ),
                                SizedBox(width: 7),
                                Expanded(
                                  child: Text(
                                    'Your details are safe and only shared with buyers who enquire.',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      height: 1.3,
                                      color: Color(0xFF468267),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ---------------- CONTINUE ----------------
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _saveAndContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5E34),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Save & Continue →',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    String? hintText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontSize: 11,
        color: Color(0xFFB49B88),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFD2B48C),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFD2B48C),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF8B5E34),
          width: 1.4,
        ),
      ),
    );
  }
}