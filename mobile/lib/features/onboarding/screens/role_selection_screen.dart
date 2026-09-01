import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? selectedRole;

  static const Color backgroundColor = Color(0xFFF6F1E7);
  static const Color brown = Color(0xFF8B5E34);
  static const Color green = Color(0xFF2E7058);
  static const Color darkBrown = Color(0xFF5C4033);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 28),

              // Logo
              Image.asset(
                'assets/images/mitr_logo.png',
                height: 95,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 18),

              // Heading
              const Text(
                'How will you use\nKalamitr ?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 27,
                  height: 1.05,
                  fontWeight: FontWeight.w700,
                  color: darkBrown,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              const Text(
                'Choose what you want to do and we’ll personalize your experience.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.2,
                  color: Color(0xFF7D6B5C),
                ),
              ),

              const SizedBox(height: 24),

              // Role cards
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _RoleCard(
                        imagePath: 'assets/images/auth/artist_side.png',
                        icon: Icons.shopping_basket_outlined,
                        title: 'Seller / Artisan',
                        description: 'Sell your handmade\nproducts',
                        feature: 'Reach more buyers\nCreate listing with AI',
                        buttonText: 'Continue as Seller',
                        color: brown,
                        isSelected: selectedRole == 'seller',
                        onTap: () {
                          setState(() {
                            selectedRole = 'seller';
                          });
                        },
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: _RoleCard(
                        imagePath: 'assets/images/auth/buyer_side.png',
                        icon: Icons.shopping_bag_outlined,
                        title: 'Buyer',
                        description: 'Discover handmade\nproducts',
                        feature: 'Explore artisans\nbuy authentic crafts',
                        buttonText: 'Continue as Buyer',
                        color: green,
                        isSelected: selectedRole == 'buyer',
                        onTap: () {
                          setState(() {
                            selectedRole = 'buyer';
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Bottom Continue button
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: selectedRole == null
                      ? null
                      : () {
                          // Navigation will be added next.
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brown,
                    disabledBackgroundColor: brown.withOpacity(0.45),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Continue  →',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}


/// Individual Seller / Buyer card
class _RoleCard extends StatelessWidget {
  final String imagePath;
  final IconData icon;
  final String title;
  final String description;
  final String feature;
  final String buttonText;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.imagePath,
    required this.icon,
    required this.title,
    required this.description,
    required this.feature,
    required this.buttonText,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 317,
        decoration: BoxDecoration(
          color: const Color(0xFFF6F1E7),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: isSelected ? color : Colors.black54,
            width: isSelected ? 2 : 0.7,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Image
            SizedBox(
              height: 115,
              width: double.infinity,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),

            // Card content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // Circular icon
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD8C9AA),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 27,
                        color: color,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.15,
                        color: Colors.black,
                      ),
                    ),

                    const Spacer(),

                    // Feature box
                    Container(
                      width: double.infinity,
                      height: 45,
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 23,
                            height: 23,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 15,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              feature,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                fontSize: 9.5,
                                height: 1.1,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Card button
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              buttonText,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.chevron_right,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}