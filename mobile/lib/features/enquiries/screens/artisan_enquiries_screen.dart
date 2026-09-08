import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/enquiry_model.dart';
import '../providers/enquiries_provider.dart';
import 'artisan_enquiry_chat_screen.dart';

class ArtisanEnquiriesScreen extends ConsumerWidget {
  const ArtisanEnquiriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enquiries = ref.watch(artisanEnquiriesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E7),
      body: SafeArea(
        child: Column(
          children: [
            _Header(onBack: context.pop),
            Expanded(
              child: enquiries.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF8B5E34),
                  ),
                ),
                error: (error, stackTrace) => _ErrorState(
                  onRetry: () => ref.invalidate(artisanEnquiriesProvider),
                ),
                data: (items) => items.isEmpty
                    ? const Center(
                        child: Text(
                          'No enquiries yet',
                          style: TextStyle(
                            color: Color(0xFF8B6B52),
                            fontSize: 15,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                        itemCount: items.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _EnquiryCard(enquiry: items[index]),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;

  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      color: const Color(0xFF8B5E34),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ENQUIRIES',
                style: TextStyle(color: Colors.white70, fontSize: 9),
              ),
              SizedBox(height: 2),
              Text(
                'Buyer Enquiries',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EnquiryCard extends StatelessWidget {
  final ArtisanEnquiry enquiry;

  const _EnquiryCard({required this.enquiry});

  @override
  Widget build(BuildContext context) {
    final product = enquiry.product;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ArtisanEnquiryChatScreen(
              enquiryId: enquiry.id,
            ),
          ),
        );
      },
      child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD2B48C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductImage(imageUrl: product?.imageUrl),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      enquiry.buyer.businessName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF604532),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      enquiry.buyer.name,
                      style: const TextStyle(
                        color: Color(0xFF9A8575),
                        fontSize: 11,
                      ),
                    ),
                    if (product != null) ...[
                      const SizedBox(height: 7),
                      Text(
                        product.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF8B5E34),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _StatusLabel(status: enquiry.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            enquiry.message,
            style: const TextStyle(
              color: Color(0xFF604532),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatDate(enquiry.createdAt),
            style: const TextStyle(
              color: Color(0xFF9A8575),
              fontSize: 10,
            ),
          ),
        ],
      ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();
    return '${localDate.day}/${localDate.month}/${localDate.year}';
  }
}

class _ProductImage extends StatelessWidget {
  final String? imageUrl;

  const _ProductImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFEDE0CC),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl == null
          ? const Icon(Icons.local_florist_outlined, color: Color(0xFF8B5E34))
          : Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.local_florist_outlined,
                color: Color(0xFF8B5E34),
              ),
            ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  final String status;

  const _StatusLabel({required this.status});

  @override
  Widget build(BuildContext context) {
    final isNew = status == 'NEW';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: isNew ? const Color(0xFFE5F2ED) : const Color(0xFFEDE0CC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isNew ? const Color(0xFF2E7058) : const Color(0xFF80664F),
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Unable to load enquiries',
            style: TextStyle(
              color: Color(0xFF604532),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}