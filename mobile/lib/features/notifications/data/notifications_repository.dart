import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import 'notification_model.dart';

class NotificationsRepository {
  final Dio _client;

  NotificationsRepository({Dio? client}) : _client = client ?? ApiClient.dio;

  Future<List<ArtisanNotification>> getNotifications() async {
    final response = await _client.get('/api/v1/notifications');
    final responseData = response.data as Map<String, dynamic>;
    final notifications = responseData['data'] as List<dynamic>;

    return notifications
        .map(
          (notification) => ArtisanNotification.fromJson(
            notification as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> markRead(String notificationId) async {
    await _client.patch('/api/v1/notifications/$notificationId/read');
  }

  Future<void> markAllRead() async {
    await _client.patch('/api/v1/notifications/read-all');
  }
}