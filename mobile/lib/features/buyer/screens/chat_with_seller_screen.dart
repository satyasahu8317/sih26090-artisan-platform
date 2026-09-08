import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/buyer_enquiry_model.dart';
import '../providers/buyer_provider.dart';

class ChatWithSellerScreen extends ConsumerStatefulWidget {
  final String enquiryId;

  const ChatWithSellerScreen({
    super.key,
    required this.enquiryId,
  });

  @override
  ConsumerState<ChatWithSellerScreen> createState() =>
      _ChatWithSellerScreenState();
}

class _ChatWithSellerScreenState
    extends ConsumerState<ChatWithSellerScreen> {
  final TextEditingController _messageController =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();

    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) {
        if (mounted) {
          ref.invalidate(
            buyerEnquiryMessagesProvider(widget.enquiryId),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();

    if (text.isEmpty) return;

    _messageController.clear();

    try {
      await ref
          .read(buyerEnquiryRepositoryProvider)
          .sendMessage(
            enquiryId: widget.enquiryId,
            message: text,
          );

      ref.invalidate(
        buyerEnquiryMessagesProvider(widget.enquiryId),
      );

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      _messageController.text = text;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send message'),
        ),
      );
    }
  }

  void _sendQuickReply(String text) {
    _messageController.text = text;
    _sendMessage();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final local = dateTime.toLocal();

    final hour = local.hour % 12 == 0
        ? 12
        : local.hour % 12;

    final minute =
        local.minute.toString().padLeft(2, '0');

    final period = local.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync =
        ref.watch(
          buyerEnquiryMessagesProvider(
            widget.enquiryId,
          ),
        );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E7),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: messagesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) =>
                    _buildError(),
                data: (messages) {
                  if (messages.isEmpty) {
                    return const Center(
                      child: Text(
                        'No messages yet',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF806F60),
                        ),
                      ),
                    );
                  }

                  WidgetsBinding.instance
                      .addPostFrameCallback(
                    (_) => _scrollToBottom(),
                  );

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      12,
                      12,
                      12,
                      8,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];

                      final isBuyer =
                          message.senderRole
                                  ?.toUpperCase() ==
                              'BUYER';

                      return _buildMessageBubble(
                        message,
                        isBuyer,
                      );
                    },
                  );
                },
              ),
            ),

            _buildQuickReplies(),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF6F1E7),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFD2B48C),
            width: 0.7,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
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

          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFEDE0CC),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.person,
                size: 20,
                color: Color(0xFF8B5E34),
              ),
            ),
          ),

          const SizedBox(width: 8),

          const Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Artisan',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF604532),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Enquiry conversation',
                  style: TextStyle(
                    fontSize: 7,
                    color: Color(0xFF668A7B),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 7,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE5F1EC),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Text(
              '✓ Verified',
              style: TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3D765F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MESSAGES
  // ============================================================

  Widget _buildMessageBubble(
    BuyerEnquiryMessage message,
    bool isBuyer,
  ) {
    return Align(
      alignment: isBuyer
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 255,
        ),
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.fromLTRB(
          10,
          8,
          10,
          6,
        ),
        decoration: BoxDecoration(
          color: isBuyer
              ? const Color(0xFF986237)
              : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(11),
            topRight: const Radius.circular(11),
            bottomLeft: Radius.circular(
              isBuyer ? 11 : 3,
            ),
            bottomRight: Radius.circular(
              isBuyer ? 3 : 11,
            ),
          ),
          border: isBuyer
              ? null
              : Border.all(
                  color: const Color(0xFFD2B48C),
                ),
        ),
        child: Column(
          crossAxisAlignment: isBuyer
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: TextStyle(
                fontSize: 8.5,
                height: 1.35,
                color: isBuyer
                    ? Colors.white
                    : const Color(0xFF604532),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              _formatTime(message.createdAt),
              style: TextStyle(
                fontSize: 6,
                color: isBuyer
                    ? const Color(0xFFE8D7C7)
                    : const Color(0xFFAA927E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // QUICK REPLIES
  // ============================================================

  Widget _buildQuickReplies() {
    const replies = [
      'Ask about price',
      'Ask about bulk',
      'Ask about delivery',
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: replies.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 6),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _sendQuickReply(replies[index]);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF0E4D1),
                borderRadius:
                    BorderRadius.circular(9),
                border: Border.all(
                  color: const Color(0xFFD2B48C),
                ),
              ),
              child: Text(
                replies[index],
                style: const TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8B5E34),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // INPUT
  // ============================================================

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        10,
        7,
        10,
        9,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF6F1E7),
        border: Border(
          top: BorderSide(
            color: Color(0xFFD2B48C),
            width: 0.7,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 40,
                maxHeight: 100,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(11),
                border: Border.all(
                  color: const Color(0xFFD2B48C),
                ),
              ),
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 4,
                textInputAction:
                    TextInputAction.newline,
                decoration:
                    const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    fontSize: 8,
                    color: Color(0xFFB49B88),
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 11,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 7),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5E34),
                borderRadius:
                    BorderRadius.circular(11),
              ),
              child: const Icon(
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

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: 40,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 10),
          const Text(
            'Unable to load messages',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(
                buyerEnquiryMessagesProvider(
                  widget.enquiryId,
                ),
              );
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}