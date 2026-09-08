import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/artisan_order_model.dart';
import '../data/orders_repository.dart';

final ordersRepositoryProvider = Provider<OrdersRepository>(
  (ref) => OrdersRepository(),
);

final artisanOrdersProvider =
    FutureProvider.family<List<ArtisanOrder>, String?>((ref, status) {
  return ref.watch(ordersRepositoryProvider).getArtisanOrders(status: status);
});

final orderDetailsProvider =
    FutureProvider.family<ArtisanOrderDetail, String>((ref, orderId) {
  return ref.watch(ordersRepositoryProvider).getOrder(orderId);
});