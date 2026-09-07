import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatWithSellerScreen extends StatefulWidget {
  const ChatWithSellerScreen({super.key});

  @override
  State<ChatWithSellerScreen> createState() =>
      _ChatWithSellerScreenState();
}

class _ChatWithSellerScreenState extends State<ChatWithSellerScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Can you make 20 pieces for bulk order?',
      time: '10:32 AM',
      isBuyer: true,
    ),
    ChatMessage(
      text: 'Yes, I can. For 20 pieces it will take about 15 days.',
      time: '10:35 AM',
      isBuyer: false,
    ),
    ChatMessage(
      text: 'What will be the price for bulk?',
      time: '10:36 AM',
      isBuyer: true,
    ),
    ChatMessage(
      text: 'For 20 pieces, I can offer ₹900 each.\nTotal ₹18,000.',
      time: '10:38 AM',
      isBuyer: false,
    ),
  ];

  final List<String> _quickReplies = [
    'Ask about price',
    'Ask about bulk',
    'Ask about delivery',
  ];

  void _sendMessage() {
    final text = _messageController.text.trim();

    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          time: _currentTime(),
          isBuyer: true,
        ),
      );
    });

    _messageController.clear();

    _scrollToBottom();
  }

  void _sendQuickReply(String text) {
    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          time: _currentTime(),
          isBuyer: true,
        ),
      );
    });

    _scrollToBottom();
  }

  String _currentTime() {
    final now = TimeOfDay.now();
    return now.format(context);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E7),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProductCard(),
            Expanded(
              child: _buildMessages(),
            ),
            _buildQuickReplies(),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget _buildHeader() {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 10),
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
              child: Text(
                '👩',
                style: TextStyle(fontSize: 19),
              ),
            ),
          ),

          const SizedBox(width: 8),

          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sita Devi',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF604532),
                  ),
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 6,
                      color: Color(0xFF3D765F),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Online · Jaipur',
                      style: TextStyle(
                        fontSize: 7,
                        color: Color(0xFF668A7B),
                      ),
                    ),
                  ],
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

  // ------------------------------------------------------------
  // PRODUCT CARD
  // ------------------------------------------------------------

  Widget _buildProductCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 8, 10, 5),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: const Color(0xFFD2B48C),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Image.network(
              'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?w=200',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return Container(
                  width: 40,
                  height: 40,
                  color: const Color(0xFFE8D8C0),
                  child: const Icon(
                    Icons.image_outlined,
                    size: 18,
                    color: Color(0xFF9B7653),
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 8),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Blue Pottery Vase',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF604532),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  '₹800 – ₹1,200',
                  style: TextStyle(
                    fontSize: 7,
                    color: Color(0xFF8B5E34),
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.chevron_right,
            size: 18,
            color: Color(0xFFAA927E),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // MESSAGES
  // ------------------------------------------------------------

  Widget _buildMessages() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];

        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isBuyer
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
          color: message.isBuyer
              ? const Color(0xFF986237)
              : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(11),
            topRight: const Radius.circular(11),
            bottomLeft: Radius.circular(
              message.isBuyer ? 11 : 3,
            ),
            bottomRight: Radius.circular(
              message.isBuyer ? 3 : 11,
            ),
          ),
          border: message.isBuyer
              ? null
              : Border.all(
                  color: const Color(0xFFD2B48C),
                ),
        ),
        child: Column(
          crossAxisAlignment: message.isBuyer
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                fontSize: 8.5,
                height: 1.35,
                color: message.isBuyer
                    ? Colors.white
                    : const Color(0xFF604532),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              message.time,
              style: TextStyle(
                fontSize: 6,
                color: message.isBuyer
                    ? const Color(0xFFE8D7C7)
                    : const Color(0xFFAA927E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // QUICK REPLIES
  // ------------------------------------------------------------

  Widget _buildQuickReplies() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        scrollDirection: Axis.horizontal,
        itemCount: _quickReplies.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _sendQuickReply(_quickReplies[index]);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF0E4D1),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: const Color(0xFFD2B48C),
                ),
              ),
              child: Text(
                _quickReplies[index],
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

  // ------------------------------------------------------------
  // MESSAGE INPUT
  // ------------------------------------------------------------

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 9),
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
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 40,
                maxHeight: 100,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: const Color(0xFFD2B48C),
                ),
              ),
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    fontSize: 8,
                    color: Color(0xFFB49B88),
                  ),
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
            onTap: _sendMessage,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5E34),
                borderRadius: BorderRadius.circular(11),
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
}

class ChatMessage {
  final String text;
  final String time;
  final bool isBuyer;

  ChatMessage({
    required this.text,
    required this.time,
    required this.isBuyer,
  });
}