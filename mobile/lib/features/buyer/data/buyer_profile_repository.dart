import 'package:dio/dio.dart';

import 'buyer_profile_model.dart';

class BuyerProfileRepository {
  final Dio _client;

  BuyerProfileRepository(this._client);

  // GET /api/auth/me
  Future<BuyerProfile> getProfile() async {
    final response = await _client.get(
      '/api/auth/me',
    );

    final responseData =
        Map<String, dynamic>.from(
      response.data,
    );

    final user = Map<String, dynamic>.from(
      responseData['user'],
    );

    final buyerProfile = user['buyerProfile'];

    if (buyerProfile == null) {
      return BuyerProfile(
        id: user['id']?.toString(),
        name: user['name']?.toString(),
      );
    }

    return BuyerProfile.fromJson(
      Map<String, dynamic>.from(
        buyerProfile,
      ),
    );
  }

  // PATCH /api/v1/buyers/me
  Future<BuyerProfile> updateProfile({
    String? name,
    String? businessName,
    String? businessType,
    String? state,
    String? district,
  }) async {
    final response = await _client.patch(
      '/api/v1/buyers/me',
      data: {
        if (name != null && name.trim().isNotEmpty)
          'name': name.trim(),
        if (businessName != null &&
            businessName.trim().isNotEmpty)
          'businessName': businessName.trim(),
        if (businessType != null &&
            businessType.trim().isNotEmpty)
          'businessType': businessType.trim(),
        if (state != null && state.trim().isNotEmpty)
          'state': state.trim(),
        if (district != null &&
            district.trim().isNotEmpty)
          'district': district.trim(),
      },
    );

    final responseData =
        Map<String, dynamic>.from(
      response.data,
    );

    return BuyerProfile.fromJson(
      Map<String, dynamic>.from(
        responseData['data'],
      ),
    );
  }
}