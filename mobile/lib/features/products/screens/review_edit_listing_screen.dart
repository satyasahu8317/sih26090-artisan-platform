
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/product_model.dart';
import '../providers/products_provider.dart';

class ReviewEditListingScreen extends ConsumerStatefulWidget {
  final String? imagePath;
  final String? productId;
  final CatalogueDraft? catalogue;
  final String? initialProductName;
  final String? initialDescription;

  const ReviewEditListingScreen({
    super.key,
    this.imagePath,
    this.productId,
    this.catalogue,
    this.initialProductName,
    this.initialDescription,
  });

  @override
  ConsumerState<ReviewEditListingScreen> createState() =>
      _ReviewEditListingScreenState();
}

class _ReviewEditListingScreenState
    extends ConsumerState<ReviewEditListingScreen> {
  static const background = Color(0xFFF6F1E7);
  static const brown = Color(0xFF8B5E34);
  static const darkBrown = Color(0xFF604532);
  static const borderBrown = Color(0xFFD2B48C);

  final productNameController =
      TextEditingController(text: 'Blue Pottery Vase');

  final descriptionController = TextEditingController(
    text:
        'Handcrafted blue pottery vase made using traditional techniques by skilled artisans of Jaipur, Rajasthan.',
  );

  final priceController = TextEditingController(text: '1000');

  String selectedColor = 'Blue';

  bool isSaving = false;
  bool isUpdatingStatus = false;

  String? savedProductId;
  String productStatus = 'DRAFT';

  @override
  void initState() {
    super.initState();

    final catalogue = widget.catalogue;

    if (catalogue != null) {
      productNameController.text =
          catalogue.englishProductName;

      descriptionController.text =
          catalogue.englishDescription;
    } else {
      if (widget.initialProductName != null) {
        productNameController.text =
            widget.initialProductName!;
      }

      if (widget.initialDescription != null) {
        descriptionController.text =
            widget.initialDescription!;
      }
    }
  }

  @override
  void dispose() {
    productNameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // SAVE DRAFT
  // ------------------------------------------------------------

  Future<void> _saveDraft() async {
    final productName =
        productNameController.text.trim();

    final description =
        descriptionController.text.trim();

    if (productName.isEmpty ||
        description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Product name and description are required.',
          ),
        ),
      );
      return;
    }

    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    try {
      final repository =
          ref.read(productsRepositoryProvider);

      late final Product product;

      if (widget.productId == null ||
          widget.productId!.isEmpty) {
        debugPrint(
          'CREATING NEW PRODUCT...',
        );

        product =
            await repository.createProduct(
          productName: productName,
          description: description,
          category: 'Pottery',
        );
      } else {
        debugPrint(
          'UPDATING PRODUCT: ${widget.productId}',
        );

        product =
            await repository.updateProduct(
          productId: widget.productId!,
          productName: productName,
          description: description,
        );
      }

      debugPrint(
        'PRODUCT SAVED SUCCESSFULLY',
      );

      debugPrint(
        'PRODUCT ID: ${product.id}',
      );

      debugPrint(
        'PRODUCT STATUS: ${product.status}',
      );

      if (!mounted) return;

      setState(() {
        savedProductId = product.id;
        productStatus = product.status;
        isSaving = false;
      });

      ref.invalidate(myProductsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '✅ Product saved to My Catalog!',
          ),
          duration: Duration(seconds: 3),
        ),
      );
    } on DioException catch (e) {
      debugPrint(
        '========================================',
      );

      debugPrint(
        'SAVE PRODUCT DIO ERROR',
      );

      debugPrint(
        'STATUS CODE: ${e.response?.statusCode}',
      );

      debugPrint(
        'RESPONSE DATA: ${e.response?.data}',
      );

      debugPrint(
        'MESSAGE: ${e.message}',
      );

      debugPrint(
        'REQUEST URL: ${e.requestOptions.uri}',
      );

      debugPrint(
        'REQUEST DATA: ${e.requestOptions.data}',
      );

      debugPrint(
        '========================================',
      );

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      String message =
          'Could not save the product.';

      final responseData =
          e.response?.data;

      if (responseData is Map) {
        final serverMessage =
            responseData['message'];

        if (serverMessage != null &&
            serverMessage
                .toString()
                .trim()
                .isNotEmpty) {
          message =
              serverMessage.toString();
        } else {
          final errorMessage =
              responseData['error'];

          if (errorMessage != null &&
              errorMessage
                  .toString()
                  .trim()
                  .isNotEmpty) {
            message =
                errorMessage.toString();
          }
        }
      }

      if (e.response?.statusCode != null) {
        message =
            '$message (${e.response?.statusCode})';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration:
              const Duration(seconds: 6),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        '========================================',
      );

      debugPrint(
        'SAVE PRODUCT ERROR',
      );

      debugPrint(
        'ERROR: $e',
      );

      debugPrint(
        'STACK TRACE: $stackTrace',
      );

      debugPrint(
        '========================================',
      );

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Save failed: $e',
          ),
          duration:
              const Duration(seconds: 6),
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // PUBLISH / UNPUBLISH
  // ------------------------------------------------------------

  Future<void> _togglePublish() async {
    final productId =
        savedProductId ?? widget.productId;

    if (productId == null ||
        productId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Save the draft before publishing it.',
          ),
        ),
      );
      return;
    }

    if (isUpdatingStatus) return;

    setState(() {
      isUpdatingStatus = true;
    });

    try {
      final repository =
          ref.read(productsRepositoryProvider);

      final product =
          productStatus == 'PUBLISHED'
              ? await repository
                  .unpublishProduct(productId)
              : await repository
                  .publishProduct(productId);

      debugPrint(
        'PRODUCT STATUS UPDATED: ${product.status}',
      );

      if (!mounted) return;

      setState(() {
        productStatus = product.status;
        isUpdatingStatus = false;
      });

      ref.invalidate(myProductsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            product.status == 'PUBLISHED'
                ? 'Product published successfully.'
                : 'Product unpublished successfully.',
          ),
        ),
      );
    } on DioException catch (e) {
      debugPrint(
        'PRODUCT STATUS ERROR: ${e.response?.statusCode}',
      );

      debugPrint(
        'RESPONSE: ${e.response?.data}',
      );

      if (!mounted) return;

      setState(() {
        isUpdatingStatus = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Publish failed: ${e.response?.data ?? e.message}',
          ),
          duration:
              const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      debugPrint(
        'PRODUCT STATUS ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        isUpdatingStatus = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not update product status: $e',
          ),
          duration:
              const Duration(seconds: 5),
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.fromLTRB(
                  24,
                  16,
                  24,
                  20,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _header(),

                    const SizedBox(height: 14),

                    _productImage(),

                    const SizedBox(height: 12),

                    _aiEnhancement(),

                    const SizedBox(height: 14),

                    _productName(),

                    const SizedBox(height: 14),

                    _description(),

                    const SizedBox(height: 14),

                    _colorOptions(),

                    const SizedBox(height: 14),

                    _suggestedPrice(),
                  ],
                ),
              ),
            ),

            _bottomButtons(),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget _header() {
    return Row(
      children: [
        GestureDetector(
          onTap: () =>
              Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(12),
              border: Border.all(
                color: borderBrown,
              ),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: darkBrown,
              size: 19,
            ),
          ),
        ),

        const SizedBox(width: 14),

        const Expanded(
          child: Text(
            'Review & Edit Listing',
            style: TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.w700,
              color: darkBrown,
            ),
          ),
        ),

        const Text(
          '✏️',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // PRODUCT IMAGE
  // ------------------------------------------------------------

  Widget _productImage() {
    return Container(
      width: double.infinity,
      height: 190,
      decoration: BoxDecoration(
        color: const Color(
          0xFFC77B4A,
        ),
        borderRadius:
            BorderRadius.circular(22),
      ),
      clipBehavior:
          Clip.antiAlias,
      child: Stack(
        children: [
          if (widget.imagePath != null &&
              widget.imagePath!.isNotEmpty)
            Positioned.fill(
              child: Image.file(
                File(widget.imagePath!),
                fit: BoxFit.cover,
              ),
            )
          else
            const Center(
              child: Text(
                '🏺',
                style: TextStyle(
                  fontSize: 60,
                ),
              ),
            ),

          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration:
                  BoxDecoration(
                color: brown,
                borderRadius:
                    BorderRadius.circular(
                  9,
                ),
              ),
              child: const Text(
                '✨ AI Enhanced',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // AI ENHANCEMENT
  // ------------------------------------------------------------

  Widget _aiEnhancement() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(12),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(15),
        border: Border.all(
          color: borderBrown,
          width: .8,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'AI Enhancement',
            style: TextStyle(
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
              color: brown,
            ),
          ),

          const SizedBox(height: 9),

          Row(
            children: [
              _enhancement(
                '✨',
                'Background\ncleaned',
              ),

              const SizedBox(width: 7),

              _enhancement(
                '✨',
                'Lighting\nimproved',
              ),

              const SizedBox(width: 7),

              _enhancement(
                '✨',
                'Product\ncentered',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _enhancement(
    String icon,
    String text,
  ) {
    return Expanded(
      child: Container(
        height: 58,
        decoration:
            BoxDecoration(
          color:
              const Color(0xFFE8F3EF),
          borderRadius:
              BorderRadius.circular(9),
        ),
        child: Center(
          child: Text(
            '$icon $text',
            textAlign:
                TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              height: 1.2,
              color:
                  Color(0xFF387D69),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // PRODUCT NAME
  // ------------------------------------------------------------

  Widget _productName() {
    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'PRODUCT NAME',
            style: TextStyle(
              fontSize: 10,
              fontWeight:
                  FontWeight.w600,
              color:
                  Color(0xFF9A8979),
            ),
          ),

          const SizedBox(height: 5),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller:
                      productNameController,
                  decoration:
                      const InputDecoration(
                    border:
                        InputBorder.none,
                    isDense: true,
                    contentPadding:
                        EdgeInsets.zero,
                  ),
                  style:
                      const TextStyle(
                    fontSize: 19,
                    fontWeight:
                        FontWeight.w700,
                    color: darkBrown,
                  ),
                ),
              ),

              Container(
                width: 36,
                height: 36,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFF0E2CC,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    9,
                  ),
                ),
                child:
                    const Icon(
                  Icons.edit,
                  size: 16,
                  color: brown,
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          _tag(
            '✨ AI Generated',
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // DESCRIPTION
  // ------------------------------------------------------------

  Widget _description() {
    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'DESCRIPTION',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w600,
                    color:
                        Color(0xFF9A8979),
                  ),
                ),
              ),

              _languageChip(
                'English',
                true,
              ),

              const SizedBox(width: 5),

              _languageChip(
                'हिंदी',
                false,
              ),
            ],
          ),

          const SizedBox(height: 8),

          TextField(
            controller:
                descriptionController,
            maxLines: 4,
            decoration:
                const InputDecoration(
              border:
                  InputBorder.none,
              isDense: true,
              contentPadding:
                  EdgeInsets.zero,
            ),
            style:
                const TextStyle(
              fontSize: 13,
              height: 1.45,
              color:
                  Color(0xFF6B5143),
            ),
          ),

          _tag(
            '✨ AI Suggested',
          ),
        ],
      ),
    );
  }

  Widget _languageChip(
    String text,
    bool selected,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 6,
      ),
      decoration:
          BoxDecoration(
        color: selected
            ? brown
            : const Color(
                0xFFF0E2CC,
              ),
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight:
              FontWeight.w600,
          color: selected
              ? Colors.white
              : darkBrown,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // COLOR OPTIONS
  // ------------------------------------------------------------

  Widget _colorOptions() {
    const colors = [
      'Black',
      'Blue',
      'Brown',
    ];

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Color options Available',
          style: TextStyle(
            fontSize: 12,
            fontWeight:
                FontWeight.w600,
            color: darkBrown,
          ),
        ),

        const SizedBox(height: 8),

        Row(
          children:
              colors.map((color) {
            final selected =
                selectedColor ==
                    color;

            return Padding(
              padding:
                  const EdgeInsets.only(
                right: 8,
              ),
              child:
                  GestureDetector(
                onTap: () {
                  setState(() {
                    selectedColor =
                        color;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 15,
                    vertical: 7,
                  ),
                  decoration:
                      BoxDecoration(
                    color: selected
                        ? const Color(
                            0xFFF0E2CC,
                          )
                        : Colors.white,
                    borderRadius:
                        BorderRadius
                            .circular(
                      8,
                    ),
                    border:
                        Border.all(
                      color: selected
                          ? brown
                          : borderBrown,
                    ),
                  ),
                  child: Text(
                    color,
                    style:
                        TextStyle(
                      fontSize: 11,
                      fontWeight:
                          FontWeight
                              .w600,
                      color: selected
                          ? brown
                          : darkBrown,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // SUGGESTED PRICE
  // ------------------------------------------------------------

  Widget _suggestedPrice() {
    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'SUGGESTED PRICE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w600,
                    color:
                        Color(0xFF9A8979),
                  ),
                ),
              ),

              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFE8F3EF,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    8,
                  ),
                ),
                child: const Text(
                  'AI Confidence: High',
                  style: TextStyle(
                    fontSize: 9,
                    color:
                        Color(0xFF387D69),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          Container(
            height: 45,
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 12,
            ),
            decoration:
                BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(
                10,
              ),
              border: Border.all(
                color: borderBrown,
              ),
            ),
            child: Row(
              children: [
                const Text(
                  '₹',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight:
                        FontWeight.w700,
                    color: darkBrown,
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: TextField(
                    controller:
                        priceController,
                    keyboardType:
                        TextInputType
                            .number,
                    decoration:
                        const InputDecoration(
                      border:
                          InputBorder.none,
                      isDense: true,
                      contentPadding:
                          EdgeInsets.zero,
                    ),
                    style:
                        const TextStyle(
                      fontSize: 16,
                      color:
                          darkBrown,
                    ),
                  ),
                ),

                const Icon(
                  Icons.edit,
                  size: 16,
                  color: brown,
                ),
              ],
            ),
          ),

          const SizedBox(height: 7),

          Container(
            height: 38,
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 12,
            ),
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFF0E2CC,
              ),
              borderRadius:
                  BorderRadius.circular(
                9,
              ),
            ),
            child: const Row(
              children: [
                Text(
                  '₹ 1200',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w600,
                    color: brown,
                  ),
                ),

                Spacer(),

                Text(
                  'Recommended',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight:
                        FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // COMMON CARD
  // ------------------------------------------------------------

  Widget _card({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(15),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(15),
        border: Border.all(
          color: borderBrown,
          width: .8,
        ),
      ),
      child: child,
    );
  }

  Widget _tag(String text) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(0xFFEAF2FF),
        borderRadius:
            BorderRadius.circular(9),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          color:
              Color(0xFF5485C4),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BOTTOM BUTTONS
  // ------------------------------------------------------------

  Widget _bottomButtons() {
    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        24,
        10,
        24,
        16,
      ),
      decoration:
          const BoxDecoration(
        color: background,
        border: Border(
          top: BorderSide(
            color: borderBrown,
            width: .5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 54,
              child: OutlinedButton(
                onPressed:
                    isSaving ||
                            isUpdatingStatus
                        ? null
                        : _saveDraft,
                style:
                    OutlinedButton.styleFrom(
                  side:
                      const BorderSide(
                    color: brown,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: brown,
                        ),
                      )
                    : const Text(
                        'Save Draft',
                        style:
                            TextStyle(
                          color: brown,
                          fontWeight:
                              FontWeight
                                  .w600,
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed:
                    isSaving ||
                            isUpdatingStatus
                        ? null
                        : _togglePublish,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      brown,
                  elevation: 0,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                  ),
                ),
                child: isUpdatingStatus
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color:
                              Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          Text(
                            productStatus ==
                                    'PUBLISHED'
                                ? 'Unpublish'
                                : 'Publish',
                            style:
                                const TextStyle(
                              color:
                                  Colors.white,
                              fontWeight:
                                  FontWeight
                                      .w600,
                            ),
                          ),
                          const SizedBox(
                            width: 7,
                          ),
                          Text(
                            productStatus ==
                                    'PUBLISHED'
                                ? '↩'
                                : '🚀',
                            style:
                                const TextStyle(
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
