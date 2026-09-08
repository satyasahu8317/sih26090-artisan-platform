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
    final responseData = response.data as Map<String, dynamic>;
    return ArtisanProfile.fromJson(
      responseData['data']['artisanProfile'] as Map<String, dynamic>,
    );
  }
}