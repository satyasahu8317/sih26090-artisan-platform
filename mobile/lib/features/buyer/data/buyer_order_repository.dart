import 'package:dio/dio.dart';

import 'buyer_order_model.dart';

class BuyerOrderRepository {
  final Dio _client;

  BuyerOrderRepository(this._client);

  // Create order
  Future<BuyerOrder> createOrder({
    required String artisanId,
    required String productId,
    required int requestedQty,
    required double unitPrice,
  }) async {
    final response = await _client.post(
      '/api/v1/orders',
      data: {
        'artisanId': artisanId,
        'productId': productId,
        'requestedQty': requestedQty,
        'unitPrice': unitPrice,
      },
    );

    final responseData =
        response.data as Map<String, dynamic>;

    return BuyerOrder.fromJson(
      Map<String, dynamic>.from(
        responseData['data'],
      ),
    );
  }

  // My orders
  Future<List<BuyerOrder>> getMyOrders({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _client.get(
      '/api/v1/orders/my',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    final responseData =
        response.data as Map<String, dynamic>;

    final ordersData =
        responseData['data'] as List<dynamic>;

    return ordersData
        .map(
          (item) => BuyerOrder.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  // Order detail
  Future<BuyerOrder> getOrderById(String id) async {
    final response = await _client.get(
      '/api/v1/orders/$id',
    );

    final responseData =
        response.data as Map<String, dynamic>;

    return BuyerOrder.fromJson(
      Map<String, dynamic>.from(
        responseData['data'],
      ),
    );
  }
}