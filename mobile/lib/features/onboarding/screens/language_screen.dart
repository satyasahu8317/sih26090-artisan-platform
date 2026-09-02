import 'package:flutter/material.dart';
import 'role_selection_screen.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String selectedLanguage = 'हिंदी';

  final List<String> languages = [
    'हिंदी',
    'मराठी',
    'বাংলা',
    'ગુજરાતી',
    'தமிழ்',
    'తెలుగు',
    'English',
  ];

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
                  const SizedBox(height: 55),

                  const Text(
                    'Choose your\nlanguage',
                    style: TextStyle(
                      fontSize: 30,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF604532),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'अपनी भाषा चुनें',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF8B5E34),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Language grid
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.zero,

                      // IMPORTANT:
                      // Scroll is enabled now.
                      itemCount: languages.length,

                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2.3,
                      ),

                      itemBuilder: (context, index) {
                        final language = languages[index];

                        return _LanguageButton(
                          language: language,
                          isSelected: language == selectedLanguage,
                          onTap: () {
                            setState(() {
                              selectedLanguage = language;
                            });
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    height: 60,

                    child:ElevatedButton(
  onPressed: () {
    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const RoleSelectionScreen(),
  ),
);
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
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(width: 8),

                          Icon(
                            Icons.arrow_forward,
                            size: 20,
                          ),
                        ],
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
}

class _LanguageButton extends StatelessWidget {
  final String language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,

      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF8B5E34)
              : Colors.white,

          borderRadius: BorderRadius.circular(16),

          border: Border.all(
            color: isSelected
                ? const Color(0xFF8B5E34)
                : const Color(0xFFD2B48C),

            width: isSelected ? 1.6 : 1,
          ),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              language,

              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,

                color: isSelected
                    ? Colors.white
                    : const Color(0xFF604532),
              ),
            ),

            if (isSelected) ...[
              const SizedBox(width: 8),

              Container(
                width: 20,
                height: 20,

                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.check,
                  size: 14,
                  color: Color(0xFF8B5E34),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}