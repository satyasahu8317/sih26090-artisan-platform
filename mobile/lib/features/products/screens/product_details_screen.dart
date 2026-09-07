import 'package:flutter/material.dart';
import 'dart:io';

class ProductDetailsScreen extends StatefulWidget {
  final String imagePath;

  const ProductDetailsScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState
    extends State<ProductDetailsScreen> {
  final TextEditingController descriptionController =
      TextEditingController();

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
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
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Back + title
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFD9B98F),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFF604532),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Text(
                        'Product Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF604532),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Photo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      File(widget.imagePath),
                      width: double.infinity,
                      height: 210,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Tell us about your product',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF604532),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'You can type or use your voice.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8B6B52),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Description
                  TextField(
                    controller: descriptionController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText:
                          'Describe your product...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF9B806B),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFFD2B48C),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFFD2B48C),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Continue
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () {
                        // AI processing will be connected later.
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF8B5E34),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Continue →',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
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
}