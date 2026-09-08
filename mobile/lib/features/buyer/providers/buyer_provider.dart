import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/buyer_order_model.dart';
import '../data/buyer_order_repository.dart';
import '../../../core/network/api_client.dart';
import '../data/buyer_product_model.dart';
import '../data/buyer_repository.dart';
import '../data/buyer_enquiry_model.dart';
import '../data/buyer_notification_model.dart';
import '../data/buyer_notification_repository.dart';
import '../data/buyer_profile_model.dart';
import '../data/buyer_profile_repository.dart';
import '../data/buyer_enquiry_repository.dart';


final buyerRepositoryProvider = Provider<BuyerRepository>((ref) {
  return BuyerRepository(ApiClient.dio);
});

final buyerSelectedCategoryProvider =
    StateProvider<String?>((ref) => null);

final buyerProductsProvider =
    FutureProvider.autoDispose<List<BuyerProduct>>((ref) {
  final category = ref.watch(buyerSelectedCategoryProvider);

  return ref.read(buyerRepositoryProvider).getProducts(
        page: 1,
        limit: 20,
        category: category,
      );
});

// ADD THIS
final buyerProductDetailProvider =
    FutureProvider.autoDispose.family<BuyerProduct, String>((ref, id) {
  return ref.read(buyerRepositoryProvider).getProductById(id);
});final buyerArtisanDetailProvider =
    FutureProvider.autoDispose.family<BuyerArtisan, String>(
  (ref, id) {
    return ref.read(buyerRepositoryProvider).getArtisanById(id);
  },
);final buyerEnquiryRepositoryProvider =
    Provider<BuyerEnquiryRepository>((ref) {
  return BuyerEnquiryRepository(ApiClient.dio);
});

final buyerMyEnquiriesProvider =
    FutureProvider.autoDispose<List<BuyerEnquiry>>((ref) {
  return ref
      .read(buyerEnquiryRepositoryProvider)
      .getMyEnquiries();
});final buyerOrderRepositoryProvider =
    Provider<BuyerOrderRepository>((ref) {
  return BuyerOrderRepository(ApiClient.dio);
});

final buyerMyOrdersProvider =
    FutureProvider.autoDispose<List<BuyerOrder>>((ref) {
  return ref
      .read(buyerOrderRepositoryProvider)
      .getMyOrders();
});

final buyerOrderDetailProvider =
    FutureProvider.autoDispose.family<BuyerOrder, String>(
  (ref, id) {
    return ref
        .read(buyerOrderRepositoryProvider)
        .getOrderById(id);
  },
);final buyerNotificationRepositoryProvider =
    Provider<BuyerNotificationRepository>((ref) {
  return BuyerNotificationRepository(ApiClient.dio);
});

final buyerNotificationsProvider =
    FutureProvider.autoDispose<List<BuyerNotification>>((ref) {
  return ref
      .read(buyerNotificationRepositoryProvider)
      .getNotifications();
});final buyerEnquiryMessagesProvider =
    FutureProvider.autoDispose.family<
        List<BuyerEnquiryMessage>,
        String>((ref, enquiryId) {
  return ref
      .read(buyerEnquiryRepositoryProvider)
      .getMessages(enquiryId);
});final buyerProfileRepositoryProvider =
    Provider<BuyerProfileRepository>((ref) {
  return BuyerProfileRepository(ApiClient.dio);
});

final buyerProfileProvider =
    FutureProvider.autoDispose<BuyerProfile>((ref) {
  return ref
      .read(buyerProfileRepositoryProvider)
      .getProfile();
});