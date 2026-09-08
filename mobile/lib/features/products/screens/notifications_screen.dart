import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../notifications/data/notification_model.dart';
import '../../notifications/providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  static const Color background = Color(0xFFF6F1E7);
  static const Color brown = Color(0xFF8B5E34);
  static const Color darkBrown = Color(0xFF604532);
  static const Color green = Color(0xFF2E7058);
  static const Color border = Color(0xFFD2B48C);
  String? readingId;
  bool markingAll = false;

  Future<void> _markRead(String notificationId) async {
    if (readingId != null) return;

    setState(() {
      readingId = notificationId;
    });

    try {
      await ref.read(notificationsRepositoryProvider).markRead(notificationId);
      ref.invalidate(artisanNotificationsProvider);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not mark the notification as read.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          readingId = null;
        });
      }
    }
  }

  Future<void> _markAllRead() async {
    if (markingAll) return;

    setState(() {
      markingAll = true;
    });

    try {
      await ref.read(notificationsRepositoryProvider).markAllRead();
      ref.invalidate(artisanNotificationsProvider);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not mark all notifications as read.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          markingAll = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(artisanNotificationsProvider);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),

            _tabs(notifications.valueOrNull?.length ?? 0),

            Expanded(
              child: notifications.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: brown),
                ),
                error: (error, stackTrace) => _ErrorState(
                  onRetry: () => ref.invalidate(artisanNotificationsProvider),
                ),
                data: (items) => items.isEmpty
                    ? const Center(
                        child: Text(
                          'No notifications yet',
                          style: TextStyle(color: Color(0xFF8B6B52)),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final notification = items[index];
                          final presentation =
                              _presentation(notification.type);
                          return _notificationCard(
                            notification: notification,
                            icon: presentation.$1,
                            iconBackground: presentation.$2,
                            tag: presentation.$3,
                            tagColor: presentation.$4,
                            actionText: notification.isRead
                                ? 'Read'
                                : 'Mark as read',
                            onAction: () => _markRead(notification.id),
                          );
                        },
                      ),
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
          GestureDetector(
            onTap: markingAll ? null : _markAllRead,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(15),
              ),
              child: markingAll
                  ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Mark all as read',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── TABS ─────────────────

  Widget _tabs(int count) {
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
          _tab('All $count', true),
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

  (IconData, Color, String, Color) _presentation(String type) {
    switch (type) {
      case 'ORDER':
        return (
          Icons.check_circle_outline,
          const Color(0xFFE1F0E7),
          'Orders',
          green,
        );
      case 'ENQUIRY':
        return (
          Icons.chat_bubble_outline,
          const Color(0xFFF3E2D2),
          'Enquiries',
          brown,
        );
      case 'SYSTEM':
        return (
          Icons.campaign_outlined,
          const Color(0xFFF1E3D5),
          'System',
          brown,
        );
      default:
        return (
          Icons.info_outline,
          const Color(0xFFE4ECF4),
          'Updates',
          const Color(0xFF4C6B88),
        );
    }
  }

  // ───────────────── NOTIFICATION CARD ─────────────────

  Widget _notificationCard({
    required ArtisanNotification notification,
    required IconData icon,
    required Color iconBackground,
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
                      notification.title,
                      style: const TextStyle(
                        color: darkBrown,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
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
                _formatTime(notification.createdAt),
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

  String _formatTime(DateTime value) {
    final elapsed = DateTime.now().difference(value.toLocal());
    if (elapsed.inMinutes < 60) {
      return '${elapsed.inMinutes.clamp(1, 59)} min ago';
    }
    if (elapsed.inHours < 24) {
      return '${elapsed.inHours} hr ago';
    }
    if (elapsed.inDays == 1) return 'Yesterday';
    return '${value.toLocal().day}/${value.toLocal().month}/${value.toLocal().year}';
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
            'Unable to load notifications',
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