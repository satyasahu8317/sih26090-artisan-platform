import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';

class BuyerRegistrationScreen extends ConsumerStatefulWidget {
  const BuyerRegistrationScreen({super.key});

  @override
  ConsumerState<BuyerRegistrationScreen> createState() =>
      _BuyerRegistrationScreenState();
}

class _BuyerRegistrationScreenState
    extends ConsumerState<BuyerRegistrationScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController organizationController = TextEditingController();

  int currentStep = 0;
  String selectedBuyerType = 'Individual Collector';
  final Set<String> selectedCategories = {'Textiles', 'Pottery'};

  final List<String> buyerTypes = [
    'Individual Collector',
    'Boutique / Retailer',
    'Interior Designer',
    'Corporate Gifting',
  ];

  final List<String> categories = [
    'Pottery',
    'Textiles',
    'Jewellery',
    'Woodcraft',
    'Painting',
    'Metalcraft',
  ];

  @override
  void dispose() {
    nameController.dispose();
    organizationController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    FocusScope.of(context).unfocus();

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

    if (currentStep == 1) {
      setState(() {
        currentStep = 2;
      });
      return;
    }

    if (currentStep == 2) {
      final name = nameController.text.trim().isNotEmpty
          ? nameController.text.trim()
          : 'Demo Buyer';
      final org = organizationController.text.trim().isNotEmpty
          ? organizationController.text.trim()
          : 'Craft Collections';

      // Persist to Neon PostgreSQL via PATCH /api/v1/buyers/me
      await ref.read(authProvider.notifier).saveBuyerProfile({
        'name': name,
        'businessName': org,
        'businessType': selectedBuyerType,
      });

      if (mounted) {
        context.go('/buyer/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    const primaryColor = Color(0xFF2E7058);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E7),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (authState.isGuest) ...[
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F3EE),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFCFE4D9)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              size: 16, color: primaryColor),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Demo Guest Mode (Buyer)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
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

                  // Buyer profile icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F3EE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: primaryColor,
                      size: 24,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Buyer Profile\nSetup",
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 28,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E4035),
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Personalize your authentic craft discovery.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7D72),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Step content
                  Expanded(
                    child: _buildStepContent(),
                  ),

                  // Progress dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _progressDot(currentStep == 0),
                      const SizedBox(width: 8),
                      _progressDot(currentStep == 1),
                      const SizedBox(width: 8),
                      _progressDot(currentStep == 2),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _continue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        currentStep == 2 ? 'Explore Marketplace →' : 'Continue →',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    if (currentStep == 0) return _buildNameStep();
    if (currentStep == 1) return _buildBuyerTypeStep();
    return _buildCategoriesStep();
  }

  Widget _buildNameStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Name *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E4035),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            decoration: _inputDecoration(hintText: 'e.g. Rahul Sharma'),
          ),
          const SizedBox(height: 20),
          const Text(
            'Organization / Store (Optional)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E4035),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: organizationController,
            decoration: _inputDecoration(hintText: 'e.g. Heritage Studio'),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyerTypeStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What describes your buying interest?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E4035),
            ),
          ),
          const SizedBox(height: 14),
          ...buyerTypes.map((type) {
            final isSelected = selectedBuyerType == type;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedBuyerType = type;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE8F3EE) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2E7058)
                        : const Color(0xFFD2B48C),
                    width: isSelected ? 1.8 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: isSelected
                          ? const Color(0xFF2E7058)
                          : const Color(0xFF9B806B),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      type,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF2E7058)
                            : const Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoriesStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select crafts you are interested in:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E4035),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: categories.map((category) {
              final isSelected = selectedCategories.contains(category);
              return FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedCategories.add(category);
                    } else {
                      selectedCategories.remove(category);
                    }
                  });
                },
                selectedColor: const Color(0xFF2E7058),
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF2E4035),
                  fontWeight: FontWeight.w600,
                ),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF2E7058)
                        : const Color(0xFFCFE4D9),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF9B806B)),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD2B48C)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD2B48C)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Color(0xFF2E7058), width: 1.6),
      ),
    );
  }

  Widget _progressDot(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: active ? 16 : 7,
      height: 7,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF2E7058) : const Color(0xFFD2D2D2),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
