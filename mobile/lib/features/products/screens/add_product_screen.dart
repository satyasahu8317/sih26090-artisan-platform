import 'dart:io';

import 'package:flutter/material.dart';
import 'describe_product_screen.dart';
import 'camera_screen.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  static const Color backgroundColor = Color(0xFFF6F1E7);
  static const Color brownColor = Color(0xFF8B5E34);
  static const Color darkBrown = Color(0xFF604532);
  static const Color lightBrown = Color(0xFFEDE0CC);

  String? selectedPhotoPath;

  Future<void> _takePhoto() async {
    final photoPath = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraScreen(),
      ),
    );

    if (photoPath != null && mounted) {
      setState(() {
        selectedPhotoPath = photoPath;
      });
    }
  }
void _openProductDescription() {
  if (selectedPhotoPath == null) {
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => DescribeProductScreen(
        imagePath: selectedPhotoPath!,
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final bool hasPhoto = selectedPhotoPath != null;

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
                  const SizedBox(height: 16),

                  // ---------------- HEADER ----------------

                  Row(
                    children: [
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
                              color: brownColor.withValues(alpha: 0.35),
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

                  const Text(
                    'Add a photo and tell us about your product.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF806F60),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ---------------- TAKE PHOTO ----------------

                  GestureDetector(
                    onTap: _takePhoto,
                    child: Container(
                      width: double.infinity,
                      height: 138,
                      decoration: BoxDecoration(
                        color: brownColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: hasPhoto
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.file(
                                    File(selectedPhotoPath!),
                                    fit: BoxFit.cover,
                                  ),

                                  Container(
                                    color: Colors.black.withValues(
                                      alpha: 0.25,
                                    ),
                                  ),

                                  const Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.camera_alt,
                                          size: 30,
                                          color: Colors.white,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Change Photo',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 66,
                                  height: 66,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(
                                      alpha: 0.18,
                                    ),
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

                  // ---------------- PRODUCT DESCRIPTION ----------------

                  GestureDetector(
                    onTap: hasPhoto ? _openProductDescription : null,
                    child: Opacity(
                      opacity: hasPhoto ? 1.0 : 0.55,
                      child: Container(
                        width: double.infinity,
                        height: 142,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: brownColor.withValues(alpha: 0.45),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.subject,
                              size: 32,
                              color: hasPhoto
                                  ? brownColor
                                  : const Color(0xFF9B8B7A),
                            ),

                            const SizedBox(height: 12),

                            Text(
                              'Product Description',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: hasPhoto
                                    ? darkBrown
                                    : const Color(0xFF9B8B7A),
                              ),
                            ),

                            if (!hasPhoto) ...[
                              const SizedBox(height: 5),
                              const Text(
                                'Add a photo first',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFFB49B88),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // ---------------- INFO BOX ----------------

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
                              color: darkBrown,
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