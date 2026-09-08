import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/buyer_notification_model.dart';
import '../providers/buyer_provider.dart';

class BuyerNotificationsScreen extends ConsumerStatefulWidget {
  const BuyerNotificationsScreen({super.key});

  @override
  ConsumerState<BuyerNotificationsScreen> createState() =>
      _BuyerNotificationsScreenState();
}

class _BuyerNotificationsScreenState
    extends ConsumerState<BuyerNotificationsScreen> {
  String selectedFilter = 'All';

  final List<String> filters = [
    'All',
    'Orders',
    'Payments',
    'Enquiries',
  ];

  @override
  Widget build(BuildContext context) {
    final notificationsAsync =
        ref.watch(buyerNotificationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E7),
      body: SafeArea(
        child: Column(
          children: [
            notificationsAsync.when(
              loading: () => _buildHeader(0),
              error: (_, __) => _buildHeader(0),
              data: (notifications) => _buildHeader(
                notifications.where((n) => !n.isRead).length,
              ),
            ),
            _buildFilters(),
            Expanded(
              child: notificationsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => _buildError(),
                data: (notifications) {
                  final filtered =
                      _filteredNotifications(notifications);

                  if (filtered.isEmpty) {
                    return _buildEmpty();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(
                        buyerNotificationsProvider,
                      );
                      await ref.read(
                        buyerNotificationsProvider.future,
                      );
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        10,
                        8,
                        10,
                        20,
                      ),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final notification = filtered[index];

                        return _buildNotificationCard(
                          notification,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          _buildBottomNavigation(context),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(int unreadCount) {
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
          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  unreadCount == 0
                      ? 'All notifications read'
                      : '$unreadCount unread notification${unreadCount == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontSize: 7,
                    color: Color(0xFFEADCC9),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: unreadCount == 0
                ? null
                : _markAllRead,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 5,
              ),
              backgroundColor:
                  Colors.white.withValues(alpha: .16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Mark all read',
              style: TextStyle(
                fontSize: 6.5,
                color: unreadCount == 0
                    ? Colors.white38
                    : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTERS
  // ============================================================

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
        separatorBuilder: (_, __) =>
            const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final selected =
              selectedFilter == filter;

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
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? Colors.white
                      : const Color(0xFF765944),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // FILTER LOGIC
  // ============================================================

  List<BuyerNotification> _filteredNotifications(
    List<BuyerNotification> notifications,
  ) {
    if (selectedFilter == 'All') {
      return notifications;
    }

    final targetType =
        selectedFilter == 'Orders'
            ? 'ORDER'
            : selectedFilter == 'Payments'
                ? 'PAYMENT'
                : 'ENQUIRY';

    return notifications
        .where(
          (notification) =>
              notification.type.toUpperCase() ==
              targetType,
        )
        .toList();
  }

  // ============================================================
  // NOTIFICATION CARD
  // ============================================================

  Widget _buildNotificationCard(
    BuyerNotification notification,
  ) {
    final type = notification.type.toUpperCase();

    final iconData = _iconForType(type);
    final iconColor = _iconColorForType(type);
    final iconBackground =
        _iconBackgroundForType(type);

    return GestureDetector(
      onTap: () => _markRead(notification),
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.white
              : const Color(0xFFFFFBF5),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: notification.isRead
                ? const Color(0xFFE0CFB8)
                : const Color(0xFFCBAE8D),
          ),
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 29,
              height: 29,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius:
                    BorderRadius.circular(7),
              ),
              child: Icon(
                iconData,
                size: 15,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 7.5,
                            fontWeight:
                                notification.isRead
                                    ? FontWeight.w600
                                    : FontWeight.bold,
                            color:
                                const Color(0xFF604532),
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 6,
                          height: 6,
                          margin:
                              const EdgeInsets.only(
                            left: 5,
                            top: 2,
                          ),
                          decoration:
                              const BoxDecoration(
                            color:
                                Color(0xFFB65B3A),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
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
                        _formatTime(
                          notification.createdAt,
                        ),
                        style: const TextStyle(
                          fontSize: 5.8,
                          color: Color(0xFFAA927E),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFF1E7D9),
                          borderRadius:
                              BorderRadius.circular(5),
                        ),
                        child: Text(
                          _displayType(type),
                          style: const TextStyle(
                            fontSize: 5.5,
                            color:
                                Color(0xFF8B5E34),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // READ ACTIONS
  // ============================================================

  Future<void> _markRead(
    BuyerNotification notification,
  ) async {
    if (notification.isRead) {
      return;
    }

    try {
      await ref
          .read(
            buyerNotificationRepositoryProvider,
          )
          .markAsRead(notification.id);

      ref.invalidate(
        buyerNotificationsProvider,
      );
    } catch (_) {
      // Keep UI stable if marking read fails.
    }
  }

  Future<void> _markAllRead() async {
    try {
      await ref
          .read(
            buyerNotificationRepositoryProvider,
          )
          .markAllAsRead();

      ref.invalidate(
        buyerNotificationsProvider,
      );
    } catch (_) {
      // Keep UI stable if request fails.
    }
  }

  // ============================================================
  // STATES
  // ============================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 42,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load notifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check your connection and try again.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(
                  buyerNotificationsProvider,
                );
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFF0E2D2),
              borderRadius: BorderRadius.circular(36),
            ),
            child: const Icon(
              Icons.notifications_none,
              size: 36,
              color: Color(0xFF8B5E34),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No notifications',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF604532),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'You are all caught up.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF806F60),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  IconData _iconForType(String type) {
    switch (type) {
      case 'ORDER':
        return Icons.inventory_2_outlined;
      case 'PAYMENT':
        return Icons.credit_card;
      case 'ENQUIRY':
        return Icons.chat_bubble_outline;
      default:
        return Icons.notifications_none;
    }
  }

  Color _iconColorForType(String type) {
    switch (type) {
      case 'ORDER':
        return const Color(0xFF8B5E34);
      case 'PAYMENT':
        return const Color(0xFF4D789D);
      case 'ENQUIRY':
        return const Color(0xFFB65B3A);
      default:
        return const Color(0xFF8B5E34);
    }
  }

  Color _iconBackgroundForType(String type) {
    switch (type) {
      case 'ORDER':
        return const Color(0xFFECE2D5);
      case 'PAYMENT':
        return const Color(0xFFE2EDF7);
      case 'ENQUIRY':
        return const Color(0xFFF6E5DC);
      default:
        return const Color(0xFFF1E7D9);
    }
  }

  String _displayType(String type) {
    switch (type) {
      case 'ORDER':
        return 'Orders';
      case 'PAYMENT':
        return 'Payments';
      case 'ENQUIRY':
        return 'Enquiries';
      default:
        return type;
    }
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '';
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    }

    if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    }

    if (difference.inDays < 1) {
      return '${difference.inHours} hr ago';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    }

    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  // ============================================================
  // BOTTOM NAV
  // ============================================================

  Widget _buildBottomNavigation(
    BuildContext context,
  ) {
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
        mainAxisAlignment:
            MainAxisAlignment.spaceAround,
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
                mainAxisAlignment:
                    MainAxisAlignment.center,
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