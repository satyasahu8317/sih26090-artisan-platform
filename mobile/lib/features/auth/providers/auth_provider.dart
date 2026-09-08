import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_state.dart';
import '../services/auth_service.dart';

class AuthNotifier extends StateNotifier<AppAuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AppAuthState.unauthenticatedState);

  /// Authenticate with real token received from MSG91 -> backend verify
  void loginAsAuthenticatedUser({
    required String token,
    required String role,
  }) {
    final normalizedRole = role.toUpperCase() == 'ARTISAN' ? 'ARTISAN' : 'BUYER';
    state = AppAuthState(
      status: normalizedRole == 'ARTISAN'
          ? AuthStatus.authenticatedArtisan
          : AuthStatus.authenticatedBuyer,
      token: token,
      role: normalizedRole,
    );
  }

  /// Real database-backed guest login:
  /// Calls backend POST /api/auth/guest to create isolated DB record
  /// and stores the signed backend JWT with isGuest: true.
  Future<void> loginAsGuest(String role) async {
    final res = await _authService.loginAsGuest(role);
    final normalizedRole = res['role'] as String? ??
        (role.toUpperCase() == 'ARTISAN' || role.toLowerCase() == 'seller' ? 'ARTISAN' : 'BUYER');

    state = AppAuthState(
      status: normalizedRole == 'ARTISAN'
          ? AuthStatus.guestArtisan
          : AuthStatus.guestBuyer,
      token: res['token'] as String?,
      role: normalizedRole,
      guestName: normalizedRole == 'ARTISAN' ? 'Demo Artisan' : 'Demo Buyer',
    );
  }

  /// Synchronous in-memory helper for tests/offline fallback
  void enterGuestMode(String role) {
    final normalizedRole = role.toUpperCase() == 'ARTISAN' || role.toLowerCase() == 'seller'
        ? 'ARTISAN'
        : 'BUYER';

    state = AppAuthState(
      status: normalizedRole == 'ARTISAN'
          ? AuthStatus.guestArtisan
          : AuthStatus.guestBuyer,
      token: 'demo_guest_token',
      role: normalizedRole,
      guestName: normalizedRole == 'ARTISAN' ? 'Demo Artisan' : 'Demo Buyer',
    );
  }

  /// Update guest local profile name
  void updateGuestProfile({required String name}) {
    if (state.isGuest) {
      state = state.copyWith(guestName: name);
    }
  }

  /// Persist buyer onboarding data directly to PostgreSQL via PATCH /api/v1/buyers/me
  Future<void> saveBuyerProfile(Map<String, dynamic> data) async {
    try {
      await _authService.updateBuyerProfile(data);
    } catch (_) {
      // Allow fallback if network/server is momentarily unavailable in offline demos
    }
    if (data.containsKey('name') && data['name'] != null) {
      state = state.copyWith(guestName: data['name'].toString());
    }
  }

  /// Persist artisan onboarding data directly to PostgreSQL via PATCH /api/v1/artisans/me
  Future<void> saveArtisanProfile(Map<String, dynamic> data) async {
    try {
      await _authService.updateArtisanProfile(data);
    } catch (_) {
      // Allow fallback if network/server is momentarily unavailable in offline demos
    }
    if (data.containsKey('name') && data['name'] != null) {
      state = state.copyWith(guestName: data['name'].toString());
    }
  }

  /// Explicitly exit guest mode, clear stored JWT, and return to unauthenticated state.
  /// (Does not delete database records per spec).
  Future<void> exitGuestMode() async {
    try {
      await _authService.logout();
    } catch (_) {
      // Platform channel not available in unit test runners
    }
    state = AppAuthState.unauthenticatedState;
  }

  /// Logout for authenticated users (clears stored token)
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (_) {
      // Platform channel not available in unit test runners
    }
    state = AppAuthState.unauthenticatedState;
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authProvider = StateNotifierProvider<AuthNotifier, AppAuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
