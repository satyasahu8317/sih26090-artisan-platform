import 'package:flutter/material.dart';
import 'camera_screen.dart';
class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  // Colors
  static const Color backgroundColor = Color(0xFFF6F1E7);
  static const Color brownColor = Color(0xFF8B5E34);
  static const Color darkBrown = Color(0xFF604532);
  static const Color lightBrown = Color(0xFFEDE0CC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

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

                  // ─────────────────────────────
                  // TOP BAR
                  // ─────────────────────────────

                  const SizedBox(height: 16),

                  Row(
                    children: [

                      // Back button
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },

                        child: Container(
                          width: 44,
                          height: 44,

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: brownColor.withValues(alpha: .35),
                            ),
                          ),

                          child: const Icon(
                            Icons.arrow_back,
                            size: 20,
                            color: darkBrown,
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Title
                      const Text(
                        'Add New Product',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: darkBrown,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ─────────────────────────────
                  // SUBTITLE
                  // ─────────────────────────────

                  const Text(
                    'Add a photo and tell us about your product.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF806F60),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ─────────────────────────────
                  // TAKE PHOTO
                  // ─────────────────────────────

                  GestureDetector(
                 
onTap: () async {
  final photoPath = await Navigator.push<String>(
    context,
    MaterialPageRoute(
      builder: (context) => const CameraScreen(),
    ),
  );

  if (photoPath != null) {
    debugPrint('Selected photo: $photoPath');
  }
},
                    child: Container(
                      width: double.infinity,
                      height: 138,

                      decoration: BoxDecoration(
                        color: brownColor,
                        borderRadius: BorderRadius.circular(24),
                      ),

                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          // Camera icon circle
                          Container(
                            width: 66,
                            height: 66,

                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha:0.18),
                              shape: BoxShape.circle,
                            ),

                            child: const Icon(
                              Icons.camera_alt,
                              size: 34,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            'Take Photo',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ─────────────────────────────
                  // RECORD VOICE
                  // ─────────────────────────────

                  GestureDetector(
                    onTap: () {
                      // Voice recording will be connected later
                    },

                    child: Container(
                      width: double.infinity,
                      height: 142,

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),

                        border: Border.all(
                          color: brownColor,
                          width: 1.5,
                        ),
                      ),

                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          Container(
                            width: 52,
                            height: 52,

                            decoration: const BoxDecoration(
                              color: Color(0xFFFBE9E3),
                              shape: BoxShape.circle,
                            ),

                            child: const Icon(
                              Icons.mic,
                              size: 28,
                              color: brownColor,
                            ),
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            'Record Voice',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: darkBrown,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // ─────────────────────────────
                  // INFO BOX
                  // ─────────────────────────────

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),

                    decoration: BoxDecoration(
                      color: lightBrown,
                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: const Row(
                      children: [

                        Text(
                          '💡',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),

                        SizedBox(width: 8),

                        Expanded(
                          child: Text(
                            'You can do both for better results.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF604532),
                            ),
                          ),
                        ),
                      ],
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
}