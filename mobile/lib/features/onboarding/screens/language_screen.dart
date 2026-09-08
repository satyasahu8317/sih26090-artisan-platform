import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/locale_provider.dart';
import '../../../l10n/generated/app_localizations.dart';

class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key});

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  String selectedLanguage = 'English';

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
    final l10n = AppLocalizations.of(context)!;
    final activeLanguage = _languageName(ref.watch(localeProvider).languageCode);

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

                  Text(
                    l10n.chooseLanguage,
                    style: TextStyle(
                      fontSize: 30,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF604532),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    l10n.chooseLanguageNative,
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
                          isSelected: language == activeLanguage,
                          onTap: () {
                            setState(() {
                              selectedLanguage = language;
                            });
                            ref.read(localeProvider.notifier).setLanguage(
                                  _languageCode(language),
                                );
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
  context.go('/role');
},

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5E34),
                        foregroundColor: Colors.white,
                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.continueLabel,
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

  String _languageCode(String language) {
    switch (language) {
      case 'हिंदी':
        return 'hi';
      case 'मराठी':
        return 'mr';
      case 'বাংলা':
        return 'bn';
      case 'ગુજરાતી':
        return 'gu';
      case 'தமிழ்':
        return 'ta';
      case 'తెలుగు':
        return 'te';
      default:
        return 'en';
    }
  }

  String _languageName(String languageCode) {
    switch (languageCode) {
      case 'hi':
        return 'हिंदी';
      case 'mr':
        return 'मराठी';
      case 'bn':
        return 'বাংলা';
      case 'gu':
        return 'ગુજરાતી';
      case 'ta':
        return 'தமிழ்';
      case 'te':
        return 'తెలుగు';
      default:
        return 'English';
    }
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