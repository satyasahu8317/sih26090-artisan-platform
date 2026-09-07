import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const Color background = Color(0xFFF6F1E7);
  static const Color brown = Color(0xFF8B5E34);
  static const Color darkBrown = Color(0xFF604532);
  static const Color green = Color(0xFF2E7058);
  static const Color red = Color(0xFF9E260F);
  static const Color border = Color(0xFFD2B48C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),

            _tabs(),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                children: [
                  _notificationCard(
                    icon: Icons.auto_awesome,
                    iconBackground: const Color(0xFFF3E2D2),
                    title: 'New Opportunity — 94% Match',
                    message:
                        'GiftWala Corp needs 300 corporate gift boxes by Feb 18. Your Blue Pottery Gift Box Set is a strong match.',
                    time: '1 hour ago',
                    tag: 'Opportunities',
                    tagColor: brown,
                    actionText: 'View Opportunity',
                    onAction: () {
                      context.push('/buyer-opportunities');
                    },
                  ),

                  const SizedBox(height: 10),

                  _notificationCard(
                    icon: Icons.check_circle_outline,
                    iconBackground: const Color(0xFFE1F0E7),
                    title: 'Order Confirmed — ORD-1041',
                    message:
                        'GiftWala Corp confirmed your quote for 280 Blue Pottery Gift Box Sets.',
                    time: '3 hrs ago',
                    tag: 'Orders',
                    tagColor: green,
                    actionText: 'View Order',
                    onAction: () {
                      context.push('/order-track');
                    },
                  ),

                  const SizedBox(height: 10),

                  _notificationCard(
                    icon: Icons.account_balance_wallet_outlined,
                    iconBackground: const Color(0xFFE4ECF4),
                    title: 'Payment Released — ₹1,28,800',
                    message:
                        'Payment for ORD-1029 has been released. Amount credited to your registered account.',
                    time: '5 hrs ago',
                    tag: 'Payments',
                    tagColor: const Color(0xFF4C6B88),
                    actionText: 'View Earnings',
                    onAction: () {},
                  ),

                  const SizedBox(height: 10),

                  _notificationCard(
                    icon: Icons.campaign_outlined,
                    iconBackground: const Color(0xFFF1E3D5),
                    title: '3 New Leads in Your Area',
                    message:
                        'Buyers near Jaipur are looking for pottery and handmade craft products.',
                    time: 'Yesterday',
                    tag: 'Opportunities',
                    tagColor: brown,
                    actionText: 'View Leads',
                    onAction: () {
                      context.push('/buyer-opportunities');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────── HEADER ─────────────────

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      color: brown,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UPDATES',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Text(
              'Mark all as read',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── TABS ─────────────────

  Widget _tabs() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFE8DED0),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          _tab('All 4', true),
          _tab('Opportunities', false),
          _tab('Orders', false),
        ],
      ),
    );
  }

  Widget _tab(String title, bool selected) {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected ? darkBrown : const Color(0xFF9A8575),
            fontSize: 8.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ───────────────── NOTIFICATION CARD ─────────────────

  Widget _notificationCard({
    required IconData icon,
    required Color iconBackground,
    required String title,
    required String message,
    required String time,
    required String tag,
    required Color tagColor,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  color: tagColor,
                  size: 19,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: darkBrown,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: const TextStyle(
                        color: Color(0xFF806F60),
                        fontSize: 8.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: tagColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: tagColor,
                    fontSize: 7,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(width: 7),

              Text(
                time,
                style: const TextStyle(
                  color: Color(0xFFA18F80),
                  fontSize: 7.5,
                ),
              ),

              const Spacer(),

              GestureDetector(
                onTap: onAction,
                child: Text(
                  actionText,
                  style: const TextStyle(
                    color: brown,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}