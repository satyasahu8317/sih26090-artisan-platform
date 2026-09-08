import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import 'product_model.dart';

class ProductsRepository {
  final Dio _client;

  ProductsRepository({Dio? client}) : _client = client ?? ApiClient.dio;

  Future<List<Product>> getMyProducts() async {
    final response = await _client.get('/api/v1/products/my');
    final responseData = response.data as Map<String, dynamic>;
    final products = responseData['data'] as List<dynamic>;

    return products
        .map((product) => Product.fromJson(product as Map<String, dynamic>))
        .toList();
  }

  Future<Product> getProduct(String productId) async {
    final response = await _client.get('/api/v1/products/$productId');
    final responseData = response.data as Map<String, dynamic>;

    return Product.fromJson(
      responseData['data'] as Map<String, dynamic>,
    );
  }

  Future<CatalogueDraft> generateCatalogue(String text) async {
    final response = await _client.post(
      '/api/v1/ai/catalogue/generate',
      data: {'text': text},
    );

    return CatalogueDraft.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<CatalogueDraft> generateCatalogueFromAudio(String audioPath) async {
    final formData = FormData.fromMap({
      'audio': await MultipartFile.fromFile(audioPath),
    });
    final response = await _client.post(
      '/api/v1/ai/catalogue/generate-from-audio',
      data: formData,
    );
    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;

    return CatalogueDraft.fromJson(
      data['catalogue'] as Map<String, dynamic>,
    );
  }

  Future<Product> createProduct({
    required String productName,
    required String description,
    required String category,
    String? material,
    List<String> tags = const [],
  }) async {
    final response = await _client.post(
      '/api/v1/products',
      data: {
        'productName': {
          'en': productName,
          'hi': productName,
        },
        'category': category,
        'material': material,
        'description': {
          'en': description,
          'hi': description,
        },
        'tags': tags,
      },
    );

    final responseData = response.data as Map<String, dynamic>;
    return Product.fromJson(
      responseData['data'] as Map<String, dynamic>,
    );
  }

  Future<Product> updateProduct({
    required String productId,
    String? productName,
    String? description,
  }) async {
    final data = <String, dynamic>{};
    if (productName != null) {
      data['productName'] = {
        'en': productName,
        'hi': productName,
      };
    }
    if (description != null) {
      data['description'] = {
        'en': description,
        'hi': description,
      };
    }

    final response = await _client.put(
      '/api/v1/products/$productId',
      data: data,
    );
    final responseData = response.data as Map<String, dynamic>;

    return Product.fromJson(
      responseData['data'] as Map<String, dynamic>,
    );
  }

  Future<Product> publishProduct(String productId) {
    return _updateProductStatus(productId, 'publish');
  }

  Future<Product> unpublishProduct(String productId) {
    return _updateProductStatus(productId, 'unpublish');
  }

  Future<void> deleteProduct(String productId) async {
    await _client.delete('/api/v1/products/$productId');
  }

  Future<Product> _updateProductStatus(
    String productId,
    String action,
  ) async {
    final response = await _client.patch('/api/v1/products/$productId/$action');
    final responseData = response.data as Map<String, dynamic>;

    return Product.fromJson(
      responseData['data'] as Map<String, dynamic>,
    );
  }
}