import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import 'artisan_order_model.dart';

class OrdersRepository {
  final Dio _client;

  OrdersRepository({Dio? client}) : _client = client ?? ApiClient.dio;

  Future<List<ArtisanOrder>> getArtisanOrders({String? status}) async {
    final response = await _client.get(
      '/api/v1/artisans/orders',
      queryParameters: status == null ? null : {'status': status},
    );
    final responseData = response.data as Map<String, dynamic>;
    final orders = responseData['data'] as List<dynamic>;

    return orders
        .map(
          (order) => ArtisanOrder.fromJson(
            order as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<ArtisanOrderDetail> getOrder(String orderId) async {
    final response = await _client.get('/api/v1/orders/$orderId');
    return ArtisanOrderDetail.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<void> acceptOrder(String orderId) async {
    await _client.patch('/api/v1/orders/$orderId/accept');
  }

  Future<void> partiallyAcceptOrder(
    String orderId,
    int acceptedQty,
  ) async {
    await _client.patch(
      '/api/v1/orders/$orderId/partial',
      data: {'acceptedQty': acceptedQty},
    );
  }

  Future<void> rejectOrder(String orderId) async {
    await _client.patch('/api/v1/orders/$orderId/reject');
  }

  Future<void> markFulfilling(String orderId) async {
    await _client.patch('/api/v1/orders/$orderId/fulfilling');
  }

  Future<void> completeOrder(String orderId) async {
    await _client.patch('/api/v1/orders/$orderId/complete');
  }
}