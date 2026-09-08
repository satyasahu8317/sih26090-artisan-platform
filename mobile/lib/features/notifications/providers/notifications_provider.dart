import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/notification_model.dart';
import '../data/notifications_repository.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => NotificationsRepository(),
);

final artisanNotificationsProvider =
    FutureProvider<List<ArtisanNotification>>((ref) {
  return ref.watch(notificationsRepositoryProvider).getNotifications();
});