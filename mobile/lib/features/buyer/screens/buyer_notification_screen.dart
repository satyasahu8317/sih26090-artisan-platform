import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BuyerNotificationsScreen extends StatefulWidget {
  const BuyerNotificationsScreen({super.key});

  @override
  State<BuyerNotificationsScreen> createState() =>
      _BuyerNotificationsScreenState();
}

class _BuyerNotificationsScreenState
    extends State<BuyerNotificationsScreen> {
  String selectedFilter = 'All';

  final List<String> filters = [
    'All',
    'Orders',
    'Payments',
    'Enquiries',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildFilters(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildActionRequired(),
                    const SizedBox(height: 12),

                    const Text(
                      'TODAY',
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                        letterSpacing: .7,
                        color: Color(0xFF9A806A),
                      ),
                    ),
                    const SizedBox(height: 7),

                    _buildApprovalNotification(),
                    const SizedBox(height: 8),

                    _buildPaymentNotification(),
                    const SizedBox(height: 8),

                    _buildShippingNotification(),
                    const SizedBox(height: 8),

                    _buildEnquiryNotification(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  // ================= HEADER =================

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF8B5E34),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 9),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  '4 new notifications',
                  style: TextStyle(
                    fontSize: 7,
                    color: Color(0xFFEADCC9),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 5,
              ),
              backgroundColor: Colors.white.withValues(alpha: .16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Mark all read',
              style: TextStyle(
                fontSize: 6.5,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= FILTERS =================

  Widget _buildFilters() {
    return Container(
      height: 43,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final selected = selectedFilter == filter;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedFilter = filter;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF8B5E34)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF8B5E34)
                      : const Color(0xFFD2B48C),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    filter,
                    style: TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? Colors.white
                          : const Color(0xFF765944),
                    ),
                  ),
                  if (filter == 'All')
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFFEAC7A5)
                              : const Color(0xFFB65B3A),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  if (filter == 'Orders') _countBadge('2', selected),
                  if (filter == 'Payments') _countBadge('1', selected),
                  if (filter == 'Enquiries') _countBadge('1', selected),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _countBadge(String value, bool selected) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFFB68A5D)
            : const Color(0xFFF0D9C0),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 5.5,
          color: selected
              ? Colors.white
              : const Color(0xFF8B5E34),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ================= ACTION REQUIRED =================

  Widget _buildActionRequired() {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: const Color(0xFFDCEEE5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFAED2BF),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 27,
            height: 27,
            decoration: const BoxDecoration(
              color: Color(0xFFC6E2D4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.access_time,
              size: 14,
              color: Color(0xFF39745D),
            ),
          ),
          const SizedBox(width: 7),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Action Required',
                  style: TextStyle(
                    fontSize: 7.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF315D4D),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Artisan approved your order — complete payment to confirm.',
                  style: TextStyle(
                    fontSize: 6.5,
                    color: Color(0xFF4B7565),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF39745D),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              'Pay Now',
              style: TextStyle(
                fontSize: 6.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= NOTIFICATIONS =================

  Widget _buildApprovalNotification() {
    return _notificationCard(
      icon: Icons.check_circle,
      iconBackground: const Color(0xFFDCEFE3),
      iconColor: const Color(0xFF3E8767),
      title: 'Artisan Approved Your Request!',
      message:
          'Sita Devi (Blue Pottery, Jaipur) has confirmed your order for 280 Gift Box Sets. Proceed to payment to lock in the deal.',
      time: 'Just now',
      tag: 'Orders',
      buttonText: 'Go to Payment →',
      buttonColor: const Color(0xFFDCEFE3),
      buttonTextColor: const Color(0xFF39745D),
      onPressed: () {},
    );
  }

  Widget _buildPaymentNotification() {
    return _notificationCard(
      icon: Icons.credit_card,
      iconBackground: const Color(0xFFE2EDF7),
      iconColor: const Color(0xFF4D789D),
      title: 'Payment Successful — ₹1,45,600',
      message:
          'Your payment for ORD-1041 (GiftWala Corporate Order) has been processed. Artisan has started production.',
      time: '1 hr ago',
      tag: 'Payments',
      buttonText: 'Track Order →',
      buttonColor: const Color(0xFFE1EDF7),
      buttonTextColor: const Color(0xFF4D789D),
      onPressed: () {
        context.push('/buyer-orders');
      },
    );
  }

  Widget _buildShippingNotification() {
    return _notificationCard(
      icon: Icons.inventory_2_outlined,
      iconBackground: const Color(0xFFECE2D5),
      iconColor: const Color(0xFF8B5E34),
      title: 'Order Shipped — ORD-1038',
      message:
          'Your Madhubani Wall Art set is on the way! Estimated delivery: Feb 27. Courier: BlueDart · Tracking: BD9292847101.',
      time: '2 hrs ago',
      tag: 'Orders',
      buttonText: 'Track Delivery →',
      buttonColor: const Color(0xFFF0E2CD),
      buttonTextColor: const Color(0xFF8B5E34),
      onPressed: () {},
    );
  }

  Widget _buildEnquiryNotification() {
    return _notificationCard(
      icon: Icons.chat_bubble_outline,
      iconBackground: const Color(0xFFF6E5DC),
      iconColor: const Color(0xFFB65B3A),
      title: 'Artisan Replied to Your Enquiry',
      message:
          'Ramesh Kumar responded: “Yes, I can make 40 custom Terracotta pieces with your logo in 12 days. Sharing samples tomorrow.”',
      time: '3 hrs ago',
      tag: 'Enquiries',
      buttonText: 'Open Chat →',
      buttonColor: const Color(0xFFF9E3D8),
      buttonTextColor: const Color(0xFFB65B3A),
      onPressed: () {
        context.push('/chat-seller');
      },
    );
  }

  Widget _notificationCard({
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    required String title,
    required String message,
    required String time,
    required String tag,
    required String buttonText,
    required Color buttonColor,
    required Color buttonTextColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: const Color(0xFFE0CFB8),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 29,
            height: 29,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(
              icon,
              size: 15,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 7.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF604532),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 6.5,
                    height: 1.35,
                    color: Color(0xFF806F60),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 5.8,
                        color: Color(0xFFAA927E),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1E7D9),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 5.5,
                          color: Color(0xFF8B5E34),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onPressed,
                    style: TextButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: buttonTextColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 6,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= BOTTOM NAV =================

  Widget _buildBottomNavigation(BuildContext context) {
    final items = [
      (Icons.home_rounded, 'Home'),
      (Icons.search_rounded, 'Search'),
      (Icons.grid_view_rounded, 'Categories'),
      (Icons.shopping_bag_rounded, 'Orders'),
      (Icons.person_rounded, 'Profile'),
    ];

    return Container(
      height: 62,
      decoration: const BoxDecoration(
        color: Color(0xFFF6F1E7),
        border: Border(
          top: BorderSide(
            color: Color(0xFFD2B48C),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          items.length,
          (index) {
            return GestureDetector(
              onTap: () {
                if (index == 0) {
                  context.go('/buyer-home');
                } else if (index == 1) {
                  context.push('/buyer-search');
                } else if (index == 3) {
                  context.push('/buyer-orders');
                } else if (index == 4) {
                  context.push('/buyer-profile');
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    items[index].$1,
                    size: 17,
                    color: const Color(0xFF9A6C43),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    items[index].$2,
                    style: const TextStyle(
                      fontSize: 6.5,
                      color: Color(0xFF9A806A),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}