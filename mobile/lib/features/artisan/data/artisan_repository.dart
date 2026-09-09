import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import 'artisan_model.dart';

class ArtisanRepository {
  final Dio _client;

  ArtisanRepository({Dio? client}) : _client = client ?? ApiClient.dio;

  Future<ArtisanDashboard> getDashboard() async {
    final response = await _client.get('/api/v1/artisans/me/dashboard');
    final responseData = response.data as Map<String, dynamic>;
    return ArtisanDashboard.fromJson(
      responseData['data'] as Map<String, dynamic>,
    );
  }
Future<ArtisanProfile> getProfile() async {
  final response = await _client.get('/api/v1/artisans/me');

  final responseData = Map<String, dynamic>.from(
    response.data as Map,
  );

  final rawData = responseData['data'];

  if (rawData is! Map) {
    throw Exception('Artisan profile data not found');
  }

  final data = Map<String, dynamic>.from(rawData);

  // Backend response may be:
  // data: { artisanProfile: {...} }
  // OR
  // data: {...}
  final profileData = data['artisanProfile'];

  if (profileData is Map) {
    return ArtisanProfile.fromJson(
      Map<String, dynamic>.from(profileData),
    );
  }

  return ArtisanProfile.fromJson(data);
}
}