import 'package:dio/dio.dart';

import 'buyer_enquiry_model.dart';

class BuyerEnquiryRepository {
  final Dio _client;

  BuyerEnquiryRepository(this._client);

  Future<BuyerEnquiry> createEnquiry({
    required String artisanId,
    required String productId,
    required String message,
  }) async {
    final response = await _client.post(
      '/api/v1/enquiries',
      data: {
        'artisanId': artisanId,
        'productId': productId,
        'message': message,
      },
    );

    final responseData =
        response.data as Map<String, dynamic>;

    return BuyerEnquiry.fromJson(
      Map<String, dynamic>.from(
        responseData['data'],
      ),
    );
  }

  Future<List<BuyerEnquiry>> getMyEnquiries() async {
    final response = await _client.get(
      '/api/v1/enquiries/my',
    );

    final responseData =
        response.data as Map<String, dynamic>;

    final enquiriesData =
        responseData['data'] as List<dynamic>;

    return enquiriesData
        .map(
          (item) => BuyerEnquiry.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<List<BuyerEnquiryMessage>> getMessages(
    String enquiryId,
  ) async {
    final response = await _client.get(
      '/api/v1/enquiries/$enquiryId/messages',
    );

    final responseData =
        response.data as Map<String, dynamic>;

    final messagesData =
        responseData['data'] as List<dynamic>;

    return messagesData
        .map(
          (item) => BuyerEnquiryMessage.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<BuyerEnquiryMessage> sendMessage({
    required String enquiryId,
    required String message,
  }) async {
    final response = await _client.post(
      '/api/v1/enquiries/$enquiryId/messages',
      data: {
        'message': message,
      },
    );

    final responseData =
        response.data as Map<String, dynamic>;

    return BuyerEnquiryMessage.fromJson(
      Map<String, dynamic>.from(
        responseData['data'],
      ),
    );
  }
}