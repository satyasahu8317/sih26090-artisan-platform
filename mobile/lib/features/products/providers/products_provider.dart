import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/product_model.dart';
import '../data/products_repository.dart';

final productsRepositoryProvider = Provider<ProductsRepository>(
  (ref) => ProductsRepository(),
);

final myProductsProvider = FutureProvider<List<Product>>((ref) {
  return ref.watch(productsRepositoryProvider).getMyProducts();
});

final productDetailsProvider = FutureProvider.family<Product, String>(
  (ref, productId) {
    return ref.watch(productsRepositoryProvider).getProduct(productId);
  },
);