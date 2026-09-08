import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/enquiries_repository.dart';
import '../data/enquiry_model.dart';

final enquiriesRepositoryProvider = Provider<EnquiriesRepository>(
  (ref) => EnquiriesRepository(),
);

final artisanEnquiriesProvider = FutureProvider<List<ArtisanEnquiry>>((ref) {
  return ref.watch(enquiriesRepositoryProvider).getArtisanEnquiries();
});

final enquiryDetailsProvider = FutureProvider.family<EnquiryDetails, String>(
  (ref, enquiryId) {
    return ref.watch(enquiriesRepositoryProvider).getEnquiry(enquiryId);
  },
);

final enquiryMessagesProvider =
    FutureProvider.family<List<EnquiryMessage>, String>((ref, enquiryId) {
  return ref.watch(enquiriesRepositoryProvider).getMessages(enquiryId);
});