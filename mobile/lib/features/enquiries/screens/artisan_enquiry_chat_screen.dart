import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/enquiry_model.dart';
import '../providers/enquiries_provider.dart';

class ArtisanEnquiryChatScreen extends ConsumerStatefulWidget {
  final String enquiryId;

  const ArtisanEnquiryChatScreen({
    super.key,
    required this.enquiryId,
  });

  @override
  ConsumerState<ArtisanEnquiryChatScreen> createState() =>
      _ArtisanEnquiryChatScreenState();
}

class _ArtisanEnquiryChatScreenState
    extends ConsumerState<ArtisanEnquiryChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _pollingTimer;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => ref.invalidate(
        enquiryMessagesProvider(widget.enquiryId),
      ),
    );
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      await ref.read(enquiriesRepositoryProvider).sendMessage(
            widget.enquiryId,
            message,
          );
      _messageController.clear();
      ref.invalidate(enquiryMessagesProvider(widget.enquiryId));
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not send the message. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final details = ref.watch(enquiryDetailsProvider(widget.enquiryId));

    return details.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFFF6F1E7),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF8B5E34)),
        ),
      ),
      error: (error, stackTrace) => _ErrorScaffold(
        onRetry: () => ref.invalidate(
          enquiryDetailsProvider(widget.enquiryId),
        ),
      ),
      data: (enquiry) => _buildChat(enquiry),
    );
  }

  Widget _buildChat(EnquiryDetails enquiry) {
    final messages = ref.watch(enquiryMessagesProvider(widget.enquiryId));

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E7),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(enquiry),
            _buildProductCard(enquiry.product),
            Expanded(
              child: messages.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF8B5E34),
                  ),
                ),
                error: (error, stackTrace) => Center(
                  child: TextButton(
                    onPressed: () => ref.invalidate(
                      enquiryMessagesProvider(widget.enquiryId),
                    ),
                    child: const Text('Unable to load messages. Retry'),
                  ),
                ),
                data: (items) => ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  itemCount: items.length,
                  itemBuilder: (context, index) =>
                      _buildMessage(items[index]),
                ),
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(EnquiryDetails enquiry) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF6F1E7),
        border: Border(
          bottom: BorderSide(color: Color(0xFFD2B48C), width: 0.7),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: context.pop,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFFEDE0CC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 16,
                color: Color(0xFF604532),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFEDE0CC),
            child: Text('👤', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  enquiry.buyer.businessName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF604532),
                  ),
                ),
                Text(
                  enquiry.buyer.name,
                  style: const TextStyle(
                    fontSize: 7,
                    color: Color(0xFF668A7B),
                  ),
                ),
              ],
            ),
          ),
          _statusLabel(enquiry.status),
        ],
      ),
    );
  }

  Widget _buildProductCard(EnquiryProduct? product) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 8, 10, 5),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFD2B48C)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE8D8C0),
              borderRadius: BorderRadius.circular(7),
            ),
            clipBehavior: Clip.antiAlias,
            child: product?.imageUrl == null
                ? const Icon(
                    Icons.image_outlined,
                    size: 18,
                    color: Color(0xFF9B7653),
                  )
                : Image.network(
                    product!.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.image_outlined,
                      size: 18,
                      color: Color(0xFF9B7653),
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              product?.displayName ?? 'Enquiry',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Color(0xFF604532),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusLabel(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE5F1EC),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontSize: 7,
          fontWeight: FontWeight.w700,
          color: Color(0xFF3D765F),
        ),
      ),
    );
  }

  Widget _buildMessage(EnquiryMessage message) {
    final isBuyer = message.senderRole == 'BUYER';
    return Align(
      alignment: isBuyer ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 255),
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
        decoration: BoxDecoration(
          color: isBuyer ? Colors.white : const Color(0xFF986237),
          borderRadius: BorderRadius.circular(11),
          border: isBuyer
              ? Border.all(color: const Color(0xFFD2B48C))
              : null,
        ),
        child: Column(
          crossAxisAlignment:
              isBuyer ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Text(
              message.message,
              style: TextStyle(
                fontSize: 8.5,
                height: 1.35,
                color: isBuyer ? const Color(0xFF604532) : Colors.white,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              _formatTime(message.createdAt),
              style: TextStyle(
                fontSize: 6,
                color: isBuyer
                    ? const Color(0xFFAA927E)
                    : const Color(0xFFE8D7C7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime value) {
    final date = value.toLocal();
    final hour = date.hour == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${date.hour >= 12 ? 'PM' : 'AM'}';
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 9),
      decoration: const BoxDecoration(
        color: Color(0xFFF6F1E7),
        border: Border(
          top: BorderSide(color: Color(0xFFD2B48C), width: 0.7),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 40, maxHeight: 100),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: const Color(0xFFD2B48C)),
              ),
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(fontSize: 8, color: Color(0xFFB49B88)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 11,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 7),
          GestureDetector(
            onTap: _isSending ? null : _sendMessage,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5E34),
                borderRadius: BorderRadius.circular(11),
              ),
              child: _isSending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      size: 17,
                      color: Colors.white,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorScaffold extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorScaffold({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E7),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Unable to load this enquiry',
              style: TextStyle(
                color: Color(0xFF604532),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
