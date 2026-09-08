import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/artisan_model.dart';
import '../data/artisan_repository.dart';

final artisanRepositoryProvider = Provider<ArtisanRepository>(
  (ref) => ArtisanRepository(),
);

final artisanDashboardProvider = FutureProvider<ArtisanDashboard>((ref) {
  return ref.watch(artisanRepositoryProvider).getDashboard();
});

final artisanProfileProvider = FutureProvider<ArtisanProfile>((ref) {
  return ref.watch(artisanRepositoryProvider).getProfile();
});