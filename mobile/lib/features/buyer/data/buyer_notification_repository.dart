import 'package:dio/dio.dart';

import 'buyer_notification_model.dart';

class BuyerNotificationRepository {
  final Dio _client;

  BuyerNotificationRepository(this._client);

  Future<List<BuyerNotification>> getNotifications() async {
    final response = await _client.get(
      '/api/v1/notifications',
    );

    final responseData =
        response.data as Map<String, dynamic>;

    final data = responseData['data'] as List<dynamic>;

    return data
        .map(
          (item) => BuyerNotification.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<void> markAsRead(String id) async {
    await _client.patch(
      '/api/v1/notifications/$id/read',
    );
  }

  Future<void> markAllAsRead() async {
    await _client.patch(
      '/api/v1/notifications/read-all',
    );
  }
}