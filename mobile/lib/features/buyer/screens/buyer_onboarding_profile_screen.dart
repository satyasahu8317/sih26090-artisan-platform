import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/buyer_provider.dart';

class BuyerOnboardingProfileScreen extends ConsumerStatefulWidget {
  const BuyerOnboardingProfileScreen({super.key});

  @override
  ConsumerState<BuyerOnboardingProfileScreen> createState() =>
      _BuyerProfileScreenState();
}

class _BuyerProfileScreenState
    extends ConsumerState<BuyerOnboardingProfileScreen> {
  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController organizationController =
      TextEditingController();

  String? selectedPurpose;

  bool _isSaving = false;

  final List<Map<String, String>> purposes = [
    {
      'title': 'Retail Shop',
      'subtitle': 'Physical store selling crafts',
      'icon': '🏪',
    },
    {
      'title': 'Boutique',
      'subtitle': 'Curated lifestyle brand',
      'icon': '👗',
    },
    {
      'title': 'Corporate Gifting',
      'subtitle': 'Bulk orders for events',
      'icon': '🎁',
    },
    {
      'title': 'Reseller',
      'subtitle': 'Online marketplace / export',
      'icon': '🔄',
    },
    {
      'title': 'Personal Buyer',
      'subtitle': 'Buying for myself / gifts',
      'icon': '🛍️',
    },
    {
      'title': 'NGO / Trust',
      'subtitle': 'Supporting artisan welfare',
      'icon': '💛',
    },
  ];

  bool get canContinue =>
      nameController.text.trim().isNotEmpty &&
      selectedPurpose != null &&
      !_isSaving;

  @override
  void dispose() {
    nameController.dispose();
    organizationController.dispose();
    super.dispose();
  }

  // ============================================================
  // SAVE PROFILE
  // ============================================================

  Future<void> _continue() async {
    if (!canContinue) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await ref
          .read(buyerProfileRepositoryProvider)
          .updateProfile(
            name: nameController.text.trim(),
            businessName:
                organizationController.text.trim().isEmpty
                    ? null
                    : organizationController.text.trim(),
            businessType: selectedPurpose,
          );

      // Refresh profile data after successful update.
      ref.invalidate(buyerProfileProvider);

      if (!mounted) return;

      context.go('/buyer-languages');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to save profile. Please try again.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

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
            child: Column(
              children: [
                // ==================================================
                // TOP HEADER
                // ==================================================

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
                        top: 18,
                        left: 18,
                        child: Text(
                          'STEP 1 OF 3',
                          style: TextStyle(
                            fontSize: 9,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(
                              alpha: 0.65,
                            ),
                          ),
                        ),
                      ),

                      const Positioned(
                        left: 18,
                        top: 43,
                        child: Text(
                          'Who are you?',
                          style: TextStyle(
                            fontFamily: 'Playfair Display',
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const Positioned(
                        left: 18,
                        top: 78,
                        child: Text(
                          'Tell us your name and buying\npurpose',
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.35,
                            color: Color(0xFFDCC8B5),
                          ),
                        ),
                      ),

                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: SizedBox(
                          width: 135,
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

                // ==================================================
                // FORM
                // ==================================================

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      16,
                      18,
                      10,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _buildLabel(
                          'YOUR FULL NAME',
                          required: true,
                        ),

                        const SizedBox(height: 6),

                        _buildTextField(
                          controller: nameController,
                          hintText: 'e.g. Priya Sharma',
                          icon: Icons.person_outline,
                        ),

                        const SizedBox(height: 13),

                        _buildLabel(
                          'BUSINESS / ORGANISATION NAME',
                          optional: true,
                        ),

                        const SizedBox(height: 6),

                        _buildTextField(
                          controller:
                              organizationController,
                          hintText: 'e.g. GiftWala Corp',
                          icon: Icons.business_outlined,
                        ),

                        const SizedBox(height: 15),

                        _buildLabel(
                          'I AM BUYING AS...',
                          required: true,
                        ),

                        const SizedBox(height: 8),

                        GridView.builder(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          itemCount: purposes.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 7,
                            mainAxisSpacing: 7,
                            childAspectRatio: 1.75,
                          ),
                          itemBuilder: (
                            context,
                            index,
                          ) {
                            final purpose =
                                purposes[index];

                            final title =
                                purpose['title']!;

                            final isSelected =
                                selectedPurpose ==
                                    title;

                            return GestureDetector(
                              onTap: _isSaving
                                  ? null
                                  : () {
                                      setState(() {
                                        selectedPurpose =
                                            title;
                                      });
                                    },
                              child: Container(
                                padding:
                                    const EdgeInsets.all(
                                  9,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color: isSelected
                                      ? const Color(
                                          0xFFEDE0CC,
                                        )
                                      : Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(
                                    11,
                                  ),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(
                                            0xFF8B5E34,
                                          )
                                        : const Color(
                                            0xFFD2B48C,
                                          ),
                                    width: isSelected
                                        ? 1.5
                                        : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      purpose['icon']!,
                                      style:
                                          const TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 7,
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Text(
                                            title,
                                            style:
                                                const TextStyle(
                                              fontSize: 10,
                                              fontWeight:
                                                  FontWeight
                                                      .w700,
                                              color: Color(
                                                0xFF604532,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 2,
                                          ),
                                          Text(
                                            purpose[
                                                'subtitle']!,
                                            maxLines: 2,
                                            overflow:
                                                TextOverflow
                                                    .ellipsis,
                                            style:
                                                const TextStyle(
                                              fontSize: 7.5,
                                              height: 1.1,
                                              color: Color(
                                                0xFF9B806B,
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
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // ==================================================
                // PAGE INDICATOR
                // ==================================================

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    _dot(true),
                    const SizedBox(width: 6),
                    _dot(false),
                    const SizedBox(width: 6),
                    _dot(false),
                  ],
                ),

                const SizedBox(height: 10),

                // ==================================================
                // CONTINUE BUTTON
                // ==================================================

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed:
                          canContinue ? _continue : null,
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF8B5E34),
                        disabledBackgroundColor:
                            const Color(0xFFD9BE98),
                        foregroundColor: Colors.white,
                        disabledForegroundColor:
                            const Color(0xFFB99C76),
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(13),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 19,
                              height: 19,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Continue →',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight:
                                    FontWeight.w700,
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

  // ============================================================
  // LABEL
  // ============================================================

  Widget _buildLabel(
    String text, {
    bool required = false,
    bool optional = false,
  }) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 8,
            letterSpacing: 0.7,
            fontWeight: FontWeight.w700,
            color: Color(0xFF9B806B),
          ),
        ),
        if (required)
          const Text(
            ' *',
            style: TextStyle(
              fontSize: 8,
              color: Color(0xFFB65B3A),
            ),
          ),
        if (optional)
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              '(optional)',
              style: TextStyle(
                fontSize: 7,
                color: Color(0xFFB49B88),
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return Container(
      height: 43,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFD2B48C),
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: (_) {
          setState(() {});
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(
            icon,
            size: 17,
            color: const Color(0xFF9B806B),
          ),
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 9,
            color: Color(0xFFB49B88),
          ),
          contentPadding:
              const EdgeInsets.symmetric(
            vertical: 13,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DOT
  // ============================================================

  Widget _dot(bool active) {
    return Container(
      width: active ? 18 : 5,
      height: 5,
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF8B5E34)
            : const Color(0xFFD2B48C),
        borderRadius:
            BorderRadius.circular(5),
      ),
    );
  }
}