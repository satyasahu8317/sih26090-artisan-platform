import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sih26090_mobile/core/config/app_config.dart';
import 'package:sih26090_mobile/features/auth/models/auth_state.dart';
import 'package:sih26090_mobile/features/auth/providers/auth_provider.dart';
import 'package:sih26090_mobile/features/auth/screens/login_screen.dart';
import 'package:sih26090_mobile/features/auth/services/auth_service.dart';
import 'package:sih26090_mobile/features/onboarding/screens/role_selection_screen.dart';

void main() {
  group('Guest Mode Auth State & Role Isolation Tests', () {
    test('1. Default state is unauthenticated and not guest', () {
      const state = AppAuthState.unauthenticatedState;
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.isGuest, false);
      expect(state.isAuthenticated, false);
      expect(state.isBuyer, false);
      expect(state.isArtisan, false);
      expect(state.token, isNull);
    });

    test('2. Guest Buyer state has correct flags, token, and is isolated from Artisan', () {
      final notifier = AuthNotifier(AuthService());
      notifier.enterGuestMode('buyer');

      final state = notifier.state;
      expect(state.status, AuthStatus.guestBuyer);
      expect(state.isGuest, true);
      expect(state.isGuestBuyer, true);
      expect(state.isGuestArtisan, false);
      expect(state.isBuyer, true);
      expect(state.isArtisan, false); // Role isolation
      expect(state.role, 'BUYER');
      expect(state.token, isNotNull); // Holds database JWT in database-backed mode
      expect(state.isAuthenticated, true);
    });

    test('3. Guest Artisan state has correct flags, token, and is isolated from Buyer', () {
      final notifier = AuthNotifier(AuthService());
      notifier.enterGuestMode('artisan');

      final state = notifier.state;
      expect(state.status, AuthStatus.guestArtisan);
      expect(state.isGuest, true);
      expect(state.isGuestArtisan, true);
      expect(state.isGuestBuyer, false);
      expect(state.isArtisan, true);
      expect(state.isBuyer, false); // Role isolation
      expect(state.role, 'ARTISAN');
      expect(state.token, isNotNull); // Holds database JWT in database-backed mode
      expect(state.isAuthenticated, true);
    });

    test('4. Updating guest profile updates guestName locally', () {
      final notifier = AuthNotifier(AuthService());
      notifier.enterGuestMode('buyer');
      notifier.updateGuestProfile(name: 'Priya Sharma');

      expect(notifier.state.guestName, 'Priya Sharma');
      expect(notifier.state.isGuest, true);
    });

    test('5. Exit guest mode resets to unauthenticated state', () async {
      final notifier = AuthNotifier(AuthService());
      notifier.enterGuestMode('seller');
      expect(notifier.state.isGuest, true);

      await notifier.exitGuestMode();
      expect(notifier.state.status, AuthStatus.unauthenticated);
      expect(notifier.state.isGuest, false);
      expect(notifier.state.role, isNull);
      expect(notifier.state.token, isNull);
    });

    test('6. Authenticated user has JWT and is distinct from guest', () {
      final notifier = AuthNotifier(AuthService());
      notifier.loginAsAuthenticatedUser(
        token: 'valid.jwt.token',
        role: 'BUYER',
      );

      final state = notifier.state;
      expect(state.status, AuthStatus.authenticatedBuyer);
      expect(state.isAuthenticated, true);
      expect(state.isGuest, false);
      expect(state.token, 'valid.jwt.token');
      expect(state.role, 'BUYER');
    });
  });

  group('Guest Mode UI Tests', () {
    testWidgets('7. Role selection screen displays both Seller and Buyer choices',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RoleSelectionScreen(),
          ),
        ),
      );

      expect(find.textContaining('How will you use'), findsOneWidget);
      expect(find.text('Seller / Artisan'), findsOneWidget);
      expect(find.text('Buyer'), findsOneWidget);
      expect(find.text('Continue  →'), findsOneWidget);
    });

    testWidgets('8. Login screen shows both Send OTP and Continue as Guest button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(role: 'buyer'),
          ),
        ),
      );

      // Verify real OTP login remains available
      expect(find.text('Send OTP →'), findsOneWidget);
      expect(find.text('Mobile Number *'), findsOneWidget);

      // Verify guest button exists if enableGuestMode is true
      if (AppConfig.enableGuestMode) {
        expect(find.text('Continue as Guest (Demo) →'), findsOneWidget);
      }
    });
  });
}
