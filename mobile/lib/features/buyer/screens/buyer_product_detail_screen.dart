import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/buyer_product_model.dart';
import '../providers/buyer_provider.dart';

class BuyerProductDetailScreen extends ConsumerWidget {
  final String productId;

  const BuyerProductDetailScreen({
    super.key,
    required this.productId,
  });

  String _localizedText(Map<String, dynamic>? value) {
    if (value == null || value.isEmpty) return '';

    if (value['en'] != null) {
      return value['en'].toString();
    }

    if (value['hi'] != null) {
      return value['hi'].toString();
    }

    return value.values.first.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync =
        ref.watch(buyerProductDetailProvider(productId));

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E7),
      body: productAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 45,
                  color: Color(0xFFB65B3A),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Unable to load product',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF604532),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(
                      buyerProductDetailProvider(productId),
                    );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (product) => _buildProduct(
          context,
          ref,
          product,
        ),
      ),
    );
  }

  Widget _buildProduct(
    BuildContext context,
    WidgetRef ref,
    BuyerProduct product,
  ) {
    final name = _localizedText(product.productName);
    final description = _localizedText(product.description);

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageHeader(
                    context,
                    product.imageUrl,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      14,
                      16,
                      100,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.isEmpty ? 'Product' : name,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF5C4033),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildArtisanCard(
                          context,
                          product,
                        ),
                        const SizedBox(height: 13),
                        _buildAboutProduct(description),
                        const SizedBox(height: 13),
                        _buildProductDetails(product),
                        if (product.tags != null &&
                            product.tags!.isNotEmpty) ...[
                          const SizedBox(height: 13),
                          _buildTags(product.tags!),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomActions(
            context,
            ref,
            product,
          ),
        ],
      ),
    );
  }

  Widget _buildImageHeader(
    BuildContext context,
    String? imageUrl,
  ) {
    return SizedBox(
      height: 260,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: imageUrl != null &&
                    imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        _imagePlaceholder(),
                  )
                : _imagePlaceholder(),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: _roundButton(
              icon: Icons.arrow_back,
              onTap: () => context.pop(),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: _roundButton(
              icon: Icons.share_outlined,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFE5D5BF),
      child: const Icon(
        Icons.image_outlined,
        size: 50,
        color: Color(0xFF9B7653),
      ),
    );
  }

  Widget _buildArtisanCard(
    BuildContext context,
    BuyerProduct product,
  ) {
    final artisan = product.artisan;

    if (artisan == null) {
      return const SizedBox.shrink();
    }

    final location = [
      artisan.district,
      artisan.state,
    ].where((e) => e != null && e.isNotEmpty).join(', ');

    return GestureDetector(
      onTap: () {
        context.push(
          '/buyer-artisan-detail',
          extra: artisan.id,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFD2B48C),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFEDE0CC),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                color: Color(0xFF8B5E34),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    artisan.name ?? 'Artisan',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF604532),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    [
                      if (location.isNotEmpty)
                        '📍 $location',
                      if (artisan.craftType != null)
                        artisan.craftType!,
                    ].join(' · '),
                    style: const TextStyle(
                      fontSize: 8,
                      color: Color(0xFF9A806A),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: Color(0xFF9A806A),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutProduct(String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD2B48C),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'ABOUT THIS PRODUCT',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: Color(0xFF9B806B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description.isEmpty
                ? 'No description available.'
                : description,
            style: const TextStyle(
              fontSize: 9,
              height: 1.5,
              color: Color(0xFF604532),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails(BuyerProduct product) {
    final origin = [
      product.artisan?.district,
      product.artisan?.state,
    ].where((e) => e != null && e.isNotEmpty).join(', ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD2B48C),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'PRODUCT DETAILS',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: Color(0xFF9B806B),
            ),
          ),
          const SizedBox(height: 10),
          _DetailRow(
            label: 'Category',
            value: product.category ?? '-',
          ),
          _DetailRow(
            label: 'Material',
            value: product.material ?? '-',
          ),
          _DetailRow(
            label: 'Status',
            value: product.status ?? '-',
          ),
          _DetailRow(
            label: 'Origin',
            value: origin,
          ),
        ],
      ),
    );
  }

  Widget _buildTags(List<dynamic> tags) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE0CC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            tag.toString(),
            style: const TextStyle(
              fontSize: 8,
              color: Color(0xFF604532),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomActions(
    BuildContext context,
    WidgetRef ref,
    BuyerProduct product,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        14,
        9,
        14,
        12,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF6F1E7),
        border: Border(
          top: BorderSide(
            color: Color(0xFFD2B48C),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                if (product.artisan == null) {
                  return;
                }

                final controller =
                    TextEditingController();

                final message =
                    await showDialog<String>(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      title:
                          const Text('Send Enquiry'),
                      content: TextField(
                        controller: controller,
                        maxLines: 4,
                        decoration:
                            const InputDecoration(
                          hintText:
                              'Write your enquiry...',
                          border:
                              OutlineInputBorder(),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(
                              dialogContext,
                            );
                          },
                          child:
                              const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            final text =
                                controller.text
                                    .trim();

                            if (text.isNotEmpty) {
                              Navigator.pop(
                                dialogContext,
                                text,
                              );
                            }
                          },
                          child:
                              const Text('Send'),
                        ),
                      ],
                    );
                  },
                );

                controller.dispose();

                if (message == null ||
                    message.isEmpty) {
                  return;
                }

                try {
             final enquiry = await ref
    .read(buyerEnquiryRepositoryProvider)
    .createEnquiry(
      artisanId: product.artisan!.id,
      productId: product.id,
      message: message,
    );

if (context.mounted) {
  context.push(
    '/chat-seller',
    extra: enquiry.id,
  );
}
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Enquiry sent successfully',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Failed to send enquiry',
                        ),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(
                Icons.chat_bubble_outline,
                size: 15,
              ),
              label: const Text('Enquire'),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    const Color(0xFF8B5E34),
                side: const BorderSide(
                  color: Color(0xFF8B5E34),
                ),
                minimumSize:
                    const Size(double.infinity, 46),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(11),
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: ElevatedButton.icon(
            onPressed: () async {
  if (product.artisan == null) return;

  final quantityController =
      TextEditingController(text: '1');

  final quantity = await showDialog<int>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Place Order'),
        content: TextField(
          controller: quantityController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Quantity',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value =
                  int.tryParse(quantityController.text.trim());

              if (value != null && value > 0) {
                Navigator.pop(dialogContext, value);
              }
            },
            child: const Text('Place Order'),
          ),
        ],
      );
    },
  );

  quantityController.dispose();

  if (quantity == null) return;

  try {
    final order = await ref
        .read(buyerOrderRepositoryProvider)
        .createOrder(
          artisanId: product.artisan!.id,
          productId: product.id,
          requestedQty: quantity,
          unitPrice: 0,
        );

    if (context.mounted) {
      context.push(
        '/buyer-order-details',
        extra: order.id,
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to place order'),
        ),
      );
    }
  }
},
              icon: const Icon(
                Icons.shopping_bag_outlined,
                size: 15,
              ),
              label: const Text('Add to Cart'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF3D765F),
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize:
                    const Size(double.infinity, 46),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(11),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 19,
          color: const Color(0xFF604532),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 8,
                color: Color(0xFF9A806A),
              ),
            ),
          ),
          Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: Color(0xFF604532),
            ),
          ),
        ],
      ),
    );
  }
}