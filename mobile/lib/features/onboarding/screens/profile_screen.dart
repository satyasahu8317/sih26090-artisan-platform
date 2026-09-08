import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController otherCraftController = TextEditingController();

  int currentStep = 0;

  String? selectedCraft;
  String selectedLanguage = 'हिंदी';

  final List<String> crafts = [
    'Pottery',
    'Textiles',
    'Jewellery',
    'Woodcraft',
    'Painting',
    'Other',
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
    otherCraftController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    FocusScope.of(context).unfocus();

    // STEP 1 - Name
    if (currentStep == 0) {
      if (nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your name'),
          ),
        );
        return;
      }

      setState(() {
        currentStep = 1;
      });
      return;
    }

    // STEP 2 - Craft
    if (currentStep == 1) {
      if (selectedCraft == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select what you make'),
          ),
        );
        return;
      }

      if (selectedCraft == 'Other' &&
          otherCraftController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your craft'),
          ),
        );
        return;
      }

      setState(() {
        currentStep = 2;
      });
      return;
    }

    // STEP 3 - Language
    if (currentStep == 2) {
      final name = nameController.text.trim().isNotEmpty
          ? nameController.text.trim()
          : 'Artisan';
      final craft = (selectedCraft == 'Other'
              ? otherCraftController.text.trim()
              : selectedCraft) ??
          'Handicrafts';
      final lang = selectedLanguage;

      // Persist to Neon PostgreSQL via PATCH /api/v1/artisans/me
      await ref.read(authProvider.notifier).saveArtisanProfile({
        'name': name,
        'craftType': craft,
        'preferredLanguage': lang,
      });

      if (mounted) {
        context.go('/artisan/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

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
                  if (authState.isGuest) ...[
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDEFD6),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFD2B48C)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: Color(0xFF8B5E34)),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Demo Guest Mode (Artisan)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF8B5E34),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              ref.read(authProvider.notifier).exitGuestMode();
                              context.go('/role');
                            },
                            child: const Text(
                              'Exit',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Profile icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE0CC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFF8B5E34),
                      size: 22,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Heading
                  const Text(
                    "Let's set up\nyour profile",
                    style: TextStyle(
                      fontSize: 30,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF604532),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'This helps buyers trust you.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF8B6B52),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Current step content
                  Expanded(
                    child: _buildStepContent(),
                  ),

                  // Progress indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _progressDot(currentStep == 0),
                      const SizedBox(width: 10),
                      _progressDot(currentStep == 1),
                      const SizedBox(width: 10),
                      _progressDot(currentStep == 2),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Privacy message
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF4EE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🔒',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your details are safe and only shared with buyers who enquire.',
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.4,
                              color: Color(0xFF468267),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _continue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5E34),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Save & Continue →',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // STEP CONTENT
  // --------------------------------------------------

  Widget _buildStepContent() {
    if (currentStep == 0) {
      return _buildNameStep();
    }

    if (currentStep == 1) {
      return _buildCraftStep();
    }

    return _buildLanguageStep();
  }

  // --------------------------------------------------
  // STEP 1 - NAME
  // --------------------------------------------------

  Widget _buildNameStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 16,
                color: Color(0xFF8B5E34),
              ),
              SizedBox(width: 5),
              Text(
                'Your Name',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF604532),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          TextField(
            controller: nameController,
            decoration: _inputDecoration(
              hintText: 'Enter your name',
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // STEP 2 - CRAFT
  // --------------------------------------------------

  Widget _buildCraftStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                '🎨',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(width: 5),
              Text(
                'What do you make?',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF604532),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Craft buttons
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: crafts.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.25,
            ),
            itemBuilder: (context, index) {
              final craft = crafts[index];
              final isSelected = selectedCraft == craft;

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
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFD2B48C),
                    ),
                  ),
                  child: Text(
                    craft,
                    style: TextStyle(
                      fontSize: 12,
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

          const SizedBox(height: 16),

          // Other craft field
          TextField(
            controller: otherCraftController,
            decoration: _inputDecoration(
              hintText: 'if other...',
              suffixIcon: const Icon(
                Icons.edit,
                size: 17,
                color: Color(0xFF8B5E34),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // STEP 3 - LANGUAGE
  // --------------------------------------------------

  Widget _buildLanguageStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                '🌐',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(width: 5),
              Text(
                'Preferred Language',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF604532),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            initialValue: selectedLanguage,
            decoration: _inputDecoration(),
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF8B5E34),
            ),
            dropdownColor: Colors.white,
            items: languages.map((language) {
              return DropdownMenuItem<String>(
                value: language,
                child: Text(
                  language,
                  style: const TextStyle(
                    color: Color(0xFF604532),
                    fontSize: 14,
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
        ],
      ),
    );
  }

  // --------------------------------------------------
  // INPUT DECORATION
  // --------------------------------------------------

  InputDecoration _inputDecoration({
    String? hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF9B806B),
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFD2B48C),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFD2B48C),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFF8B5E34),
          width: 1.5,
        ),
      ),
    );
  }

  // --------------------------------------------------
  // PROGRESS DOT
  // --------------------------------------------------

  Widget _progressDot(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: active ? 14 : 7,
      height: 7,
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF8B5E34)
            : const Color(0xFFD2D2D2),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}