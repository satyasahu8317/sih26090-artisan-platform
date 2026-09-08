import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/product_model.dart';
import 'review_edit_listing_screen.dart';
import '../providers/products_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  bool isUpdatingStatus = false;
  bool isDeleting = false;
  String? statusOverride;
  late Product loadedProduct;

  String get productName => loadedProduct.displayName;
  String get price => loadedProduct.material ?? loadedProduct.category;
  String get imageUrl => loadedProduct.imageUrl ?? '';
  String get description =>
    (loadedProduct.description['en'] ?? loadedProduct.description['hi'])
      ?.toString() ??
    '';
  bool get isPublished =>
    (statusOverride ?? loadedProduct.status) == 'PUBLISHED';

  Future<void> _unpublish() async {
    setState(() {
      isUpdatingStatus = true;
    });

    try {
      final product = await ref
          .read(productsRepositoryProvider)
          .unpublishProduct(widget.productId);
      ref.invalidate(myProductsProvider);

      if (!mounted) return;
      setState(() {
        statusOverride = product.status;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product unpublished successfully.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not unpublish the product. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isUpdatingStatus = false;
        });
      }
    }
  }

  Future<void> _deleteProduct() async {
    setState(() {
      isDeleting = true;
    });

    try {
      await ref.read(productsRepositoryProvider).deleteProduct(widget.productId);
      ref.invalidate(myProductsProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product deleted successfully.'),
        ),
      );
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete the product. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailsProvider(widget.productId));

    return productAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFFF6F1E7),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF8B5E34)),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        backgroundColor: const Color(0xFFF6F1E7),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Unable to load this product',
                style: TextStyle(
                  color: Color(0xFF604532),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => ref.invalidate(
                  productDetailsProvider(widget.productId),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (product) {
        loadedProduct = product;
        return _buildLoadedProduct();
      },
    );
  }

  Widget _buildLoadedProduct() {
    const backgroundColor = Color(0xFFF6F1E7);
    const brown = Color(0xFF6B4735);
    const primaryBrown = Color(0xFF8B5E34);
    const borderColor = Color(0xFFD2B48C);
    const green = Color(0xFF287B65);
    const orange = Color(0xFFB85C38);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --------------------------------------------------
                    // PRODUCT IMAGE
                    // --------------------------------------------------
                    Stack(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 250,
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) {
                                    return Container(
                                      color: const Color(0xFFD07B4D),
                                      child: const Icon(
                                        Icons.image_outlined,
                                        size: 60,
                                        color: Colors.white70,
                                      ),
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }

                                    return Container(
                                      color: const Color(0xFFD07B4D),
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: const Color(0xFFD07B4D),
                                  child: const Icon(
                                    Icons.image_outlined,
                                    size: 60,
                                    color: Colors.white70,
                                  ),
                                ),
                        ),

                        // Back button
                        Positioned(
                          top: 14,
                          left: 16,
                          child: _circleButton(
                            icon: Icons.arrow_back,
                            onTap: () => Navigator.pop(context),
                          ),
                        ),

                        // Edit image button
                        Positioned(
                          top: 14,
                          right: 16,
                          child: _circleButton(
                            icon: Icons.edit,
                            onTap: () async {
                              await Navigator.push<Product>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ReviewEditListingScreen(
                                    productId: widget.productId,
                                    initialProductName: productName,
                                    initialDescription: description,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Published badge
                        Positioned(
                          left: 16,
                          bottom: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isPublished ? 'Published' : 'Draft',
                              style: TextStyle(
                                color: green,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // --------------------------------------------------
                    // MAIN CONTENT
                    // --------------------------------------------------
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product name
                          Text(
                            productName,
                            style: const TextStyle(
                              color: brown,
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'serif',
                            ),
                          ),

                          const SizedBox(height: 5),

                          // Price
                          Text(
                            price,
                            style: const TextStyle(
                              color: primaryBrown,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'serif',
                            ),
                          ),

                          const SizedBox(height: 18),

                          // --------------------------------------------------
                          // STATS
                          // --------------------------------------------------
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  icon: '🏷️',
                                  value: loadedProduct.category,
                                  label: 'Category',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  icon: '🧵',
                                  value: loadedProduct.material ?? 'Not specified',
                                  label: 'Material',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  icon: '🔖',
                                  value: '${loadedProduct.tags.length}',
                                  label: 'Tags',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // --------------------------------------------------
                          // ABOUT PRODUCT
                          // --------------------------------------------------
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: borderColor,
                                width: 0.8,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'ABOUT THIS PRODUCT',
                                  style: TextStyle(
                                    color: Color(0xFF9A8A78),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  description,
                                  style: const TextStyle(
                                    color: brown,
                                    fontSize: 15,
                                    height: 1.55,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // --------------------------------------------------
                          // PRODUCT DETAILS
                          // --------------------------------------------------
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: borderColor,
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF1E4CF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '👩',
                                      style: TextStyle(fontSize: 27),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 13),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        loadedProduct.category,
                                        style: const TextStyle(
                                          color: brown,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Text(
                                            '📍',
                                            style: TextStyle(fontSize: 13),
                                          ),
                                          const SizedBox(width: 3),
                                          Expanded(
                                            child: Text(
                                                loadedProduct.material ??
                                                  'Material not specified',
                                              style: const TextStyle(
                                                color: Color(0xFF9A8A78),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                if (loadedProduct.tags.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 11,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE5F2ED),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Tags: ${loadedProduct.tags.join(', ')}',
                                      style: const TextStyle(
                                        color: green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --------------------------------------------------
            // BOTTOM ACTIONS
            // --------------------------------------------------
            Container(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
              decoration: const BoxDecoration(
                color: backgroundColor,
                border: Border(
                  top: BorderSide(
                    color: borderColor,
                    width: 0.8,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 64,
                      child: OutlinedButton(
                        onPressed: () {
                          // Edit action later
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryBrown,
                          side: const BorderSide(
                            color: primaryBrown,
                            width: 1.6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          '✏️ Edit',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: SizedBox(
                      height: 64,
                      child: OutlinedButton(
                        onPressed: isUpdatingStatus || isDeleting || !isPublished
                            ? null
                            : () {
                          _showUnpublishDialog(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: orange,
                          side: const BorderSide(
                            color: orange,
                            width: 1.6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isUpdatingStatus
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: orange,
                                ),
                              )
                            : const Text(
                          'Unpublish',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: SizedBox(
                      height: 64,
                      child: OutlinedButton(
                        onPressed: isUpdatingStatus || isDeleting
                            ? null
                            : () => _showDeleteDialog(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFB23B32),
                          side: const BorderSide(
                            color: Color(0xFFB23B32),
                            width: 1.6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isDeleting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFFB23B32),
                                ),
                              )
                            : const Text(
                                'Delete',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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
  }

  // --------------------------------------------------
  // HELPERS
  // --------------------------------------------------

  static Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withValues(alpha: .9),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            size: 19,
            color: const Color(0xFF6B4735),
          ),
        ),
      ),
    );
  }

  void _showUnpublishDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF6F1E7),
          title: const Text(
            'Unpublish product?',
            style: TextStyle(
              color: Color(0xFF6B4735),
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'This product will no longer be visible to buyers.',
            style: TextStyle(
              color: Color(0xFF6B4735),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _unpublish();
              },
              child: const Text(
                'Unpublish',
                style: TextStyle(
                  color: Color(0xFFB85C38),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF6F1E7),
          title: const Text(
            'Delete product?',
            style: TextStyle(
              color: Color(0xFF6B4735),
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'This product will be permanently removed from your catalog.',
            style: TextStyle(
              color: Color(0xFF6B4735),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _deleteProduct();
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Color(0xFFB23B32),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD2B48C),
          width: 0.8,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF6B4735),
              fontSize: 17,
              fontWeight: FontWeight.w700,
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9A8A78),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}