import 'package:dio/dio.dart';

import 'buyer_product_model.dart';

class BuyerRepository {
  final Dio _client;

  BuyerRepository(this._client);

  Future<List<BuyerProduct>> getProducts({
    int page = 1,
    int limit = 20,
    String? query,
    String? category,
  }) async {
    final response = await _client.get(
      '/api/v1/products',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (query != null && query.trim().isNotEmpty)
          'q': query.trim(),
        if (category != null && category.trim().isNotEmpty)
          'category': category.trim(),
      },
    );

    final responseData =
        response.data as Map<String, dynamic>;

    final productsData =
        responseData['data'] as List<dynamic>;

    return productsData
        .map(
          (item) => BuyerProduct.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<BuyerProduct> getProductById(String id) async {
    final response = await _client.get(
      '/api/v1/products/$id',
    );

    final responseData =
        response.data as Map<String, dynamic>;

    return BuyerProduct.fromJson(
      Map<String, dynamic>.from(
        responseData['data'],
      ),
    );
  }Future<BuyerArtisan> getArtisanById(String id) async {
  final response = await _client.get(
    '/api/v1/artisans/$id',
  );

  final responseData =
      response.data as Map<String, dynamic>;

  return BuyerArtisan.fromJson(
    Map<String, dynamic>.from(
      responseData['data'],
    ),
  );
}
}