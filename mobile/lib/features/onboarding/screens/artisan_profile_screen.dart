import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../artisan/providers/artisan_provider.dart';
import '../../../l10n/generated/app_localizations.dart';

class ArtisanProfileScreen extends ConsumerWidget {
  const ArtisanProfileScreen({super.key});

  static const bg = Color(0xFFF6F1E7);
  static const brown = Color(0xFF8B5E34);
  static const darkBrown = Color(0xFF604532);
  static const lightBrown = Color(0xFFEDE0CC);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(artisanProfileProvider).valueOrNull;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Column(
              children: [
                // TOP BAR
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      _topButton(
                        Icons.arrow_back,
                        () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.artisanProfile,
                          style: TextStyle(
                            fontFamily: 'Playfair Display',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: darkBrown,
                          ),
                        ),
                      ),
                      _topButton(
                        Icons.more_horiz,
                        () {},
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    child: Column(
                      children: [
                        // PROFILE HEADER
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFFE0C8A8),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 62,
                                height: 62,
                                decoration: const BoxDecoration(
                                  color: lightBrown,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person,
                                  size: 34,
                                  color: darkBrown,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          profile?.name ?? 'Artisan',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: darkBrown,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        _badge(
                                          l10n.verified,
                                          const Color(0xFFE5F4EC),
                                          const Color(0xFF287A59),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        _badge(
                                          l10n.masterArtisan,
                                          const Color(0xFFFFE8A8),
                                          const Color(0xFF8B5E34),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '📍 ${profile?.district ?? 'District'}, '
                                      '${profile?.state ?? 'State'}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF806F60),
                                      ),
                                    ),
                                    Text(
                                      '🌐 ${profile?.preferredLanguage ?? 'Language'}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF806F60),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // BIO
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBE9E3),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text('🏺'),
                              SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  'Making handmade pottery for 12 years · '
                                  '3rd generation craftsperson from Jaipur',
                                  style: TextStyle(
                                    fontSize: 11,
                                    height: 1.35,
                                    color: darkBrown,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // STATS
                        Row(
                          children: [
                            _stat('24', 'Products'),
                            const SizedBox(width: 8),
                            _stat('4.8 ★', 'Rating'),
                            const SizedBox(width: 8),
                            _stat('156', 'Orders'),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // TABS
                        Container(
                          height: 42,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: lightBrown,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    l10n.about,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: darkBrown,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    l10n.products,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // CRAFT SPECIALTIES
                        _sectionTitle(l10n.craftSpecialties),

                        const SizedBox(height: 7),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _chip('Blue Pottery'),
                              _chip('Hand Painting'),
                              _chip('Ceramics'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // DETAILS
                        _sectionTitle(l10n.details),

                        const SizedBox(height: 7),

                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFE0C8A8),
                            ),
                          ),
                          child: Column(
                            children: [
                              _detail(
                                Icons.location_on_outlined,
                                'Jaipur, Rajasthan',
                                'Workshop open Mon–Sat',
                              ),
                              const Divider(
                                height: 1,
                                indent: 48,
                              ),
                              _detail(
                                Icons.language,
                                l10n.languages,
                                'Hindi · English · Rajasthani',
                              ),
                              const Divider(
                                height: 1,
                                indent: 48,
                              ),
                              _detail(
                                Icons.shopping_bag_outlined,
                                l10n.acceptsCustomOrders,
                                'Min. qty: 5 units · Lead time: 15 days',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // BOTTOM NAV
                Container(
                  height: 68,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: Color(0xFFE2D4C1),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceAround,
                    children: [
                      _nav(Icons.home_outlined, 'Home'),
                      _nav(Icons.inventory_2_outlined, 'Catalog'),

                      Container(
                        width: 46,
                        height: 46,
                        decoration: const BoxDecoration(
                          color: Color(0xFF8B250E),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),

                      _nav(
                        Icons.shopping_bag_outlined,
                        'Orders',
                      ),
                      _nav(
                        Icons.person,
                        'Profile',
                        selected: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _topButton(
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: const Color(0xFFD9B98F),
          ),
        ),
        child: Icon(
          icon,
          size: 19,
          color: darkBrown,
        ),
      ),
    );
  }

  static Widget _badge(
    String text,
    Color background,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  static Widget _stat(
    String value,
    String label,
  ) {
    return Expanded(
      child: Container(
        height: 66,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: const Color(0xFFE0C8A8),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: darkBrown,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFF8B6B52),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: .6,
          color: Color(0xFF8B6B52),
        ),
      ),
    );
  }

  static Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFBE9E3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          color: brown,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static Widget _detail(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 10,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 19,
            color: brown,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: darkBrown,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF8B6B52),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _nav(
    IconData icon,
    String label, {
    bool selected = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 19,
          color: selected ? brown : const Color(0xFF806F60),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 8,
            color: selected ? brown : const Color(0xFF806F60),
          ),
        ),
      ],
    );
  }
}