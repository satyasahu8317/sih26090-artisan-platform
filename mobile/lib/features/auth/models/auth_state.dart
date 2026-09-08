enum AuthStatus {
  unauthenticated,
  authenticatedBuyer,
  authenticatedArtisan,
  guestBuyer,
  guestArtisan,
}

class AppAuthState {
  final AuthStatus status;
  final String? token;
  final String? role; // 'BUYER' or 'ARTISAN'
  final String? guestName;

  const AppAuthState({
    this.status = AuthStatus.unauthenticated,
    this.token,
    this.role,
    this.guestName,
  });

  bool get isGuest =>
      status == AuthStatus.guestBuyer || status == AuthStatus.guestArtisan;

  bool get isGuestBuyer => status == AuthStatus.guestBuyer;
  bool get isGuestArtisan => status == AuthStatus.guestArtisan;

  bool get isAuthenticated =>
      status == AuthStatus.authenticatedBuyer ||
      status == AuthStatus.authenticatedArtisan ||
      (isGuest && token != null && token!.isNotEmpty);

  bool get isBuyer =>
      status == AuthStatus.authenticatedBuyer ||
      status == AuthStatus.guestBuyer;

  bool get isArtisan =>
      status == AuthStatus.authenticatedArtisan ||
      status == AuthStatus.guestArtisan;

  AppAuthState copyWith({
    AuthStatus? status,
    String? token,
    String? role,
    String? guestName,
  }) {
    return AppAuthState(
      status: status ?? this.status,
      token: token ?? this.token,
      role: role ?? this.role,
      guestName: guestName ?? this.guestName,
    );
  }

  static const unauthenticatedState = AppAuthState(
    status: AuthStatus.unauthenticated,
  );
}
