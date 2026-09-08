import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import 'enquiry_model.dart';

class EnquiriesRepository {
  final Dio _client;

  EnquiriesRepository({Dio? client}) : _client = client ?? ApiClient.dio;

  Future<List<ArtisanEnquiry>> getArtisanEnquiries() async {
    final response = await _client.get('/api/v1/artisans/enquiries');
    final responseData = response.data as Map<String, dynamic>;
    final enquiries = responseData['data'] as List<dynamic>;

    return enquiries
        .map(
          (enquiry) => ArtisanEnquiry.fromJson(
            enquiry as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<EnquiryDetails> getEnquiry(String enquiryId) async {
    final response = await _client.get('/api/v1/enquiries/$enquiryId');
    final responseData = response.data as Map<String, dynamic>;

    return EnquiryDetails.fromJson(
      responseData['data'] as Map<String, dynamic>,
    );
  }

  Future<List<EnquiryMessage>> getMessages(String enquiryId) async {
    final response = await _client.get('/api/v1/enquiries/$enquiryId/messages');
    final responseData = response.data as Map<String, dynamic>;
    final messages = responseData['data'] as List<dynamic>;

    return messages
        .map(
          (message) => EnquiryMessage.fromJson(
            message as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> sendMessage(String enquiryId, String message) async {
    await _client.post(
      '/api/v1/enquiries/$enquiryId/messages',
      data: {'message': message},
    );
  }
}