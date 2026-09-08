/// Maps the locally selected role ('seller' / 'buyer' from
/// `selectedRoleProvider`) to the backend's role enum ('ARTISAN' / 'BUYER').
///
/// This is ONLY meaningful for NEW users - the backend uses it to decide
/// what kind of account to create. For existing users the backend ignores
/// it and is the source of truth instead (see [resolvePostAuthRoute]).
String mapSelectedRoleToBackendRole(String? selectedRole) {
  switch (selectedRole) {
    case 'seller':
      return 'ARTISAN';
    case 'buyer':
      return 'BUYER';
    default:
      // Shouldn't normally happen (role selection screen forces a choice
      // before /login is reachable), but fall back to a safe default
      // rather than sending an invalid role to the backend.
      return 'BUYER';
  }
}

/// Decides which EXISTING go_router path to navigate to after a successful
/// MSG91 -> backend verification.
///
/// - For NEW users we trust [selectedRole]: it's exactly what we told the
///   backend to create the account as, so we route to the matching
///   onboarding screen ('/profile' for artisan, '/buyer-profile' for buyer).
/// - For EXISTING users the backend is the source of truth. We map its
///   `redirect` string (e.g. '/artisan/home') onto the actual route paths
///   already defined in app_routes.dart, rather than trusting the locally
///   selected role.
String resolvePostAuthRoute({
  required bool isNewUser,
  required String? selectedRole,
  required String? backendRedirect,
}) {
  if (isNewUser) {
    return selectedRole == 'buyer' ? '/buyer-profile' : '/profile';
  }

  final normalized = backendRedirect?.toLowerCase().trim() ?? '';

  final looksLikeBuyer = normalized.contains('buyer');
  final looksLikeArtisan =
      normalized.contains('artisan') || normalized.contains('seller');
  final looksLikeHome = normalized.contains('home');
  final looksLikeProfile =
      normalized.contains('profile') || normalized.contains('onboarding');

  if (looksLikeBuyer && looksLikeHome) return '/buyer-home';
  if (looksLikeArtisan && looksLikeHome) return '/home';
  if (looksLikeBuyer && looksLikeProfile) return '/buyer-profile';
  if (looksLikeArtisan && looksLikeProfile) return '/profile';

  // We couldn't confidently map the backend's redirect onto one of our
  // existing routes. Fall back to the role-appropriate home screen instead
  // of inventing a new route.
  return selectedRole == 'buyer' ? '/buyer-home' : '/home';
}
