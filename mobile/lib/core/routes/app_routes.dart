import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/onboarding/screens/language_screen.dart';
import '../../features/onboarding/screens/profile_screen.dart';
import '../../features/onboarding/screens/role_selection_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',

  routes: [
    // Login
    GoRoute(
      path: '/login',
      builder: (context, state) {
        return const LoginScreen();
      },
    ),

    // OTP
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final data = state.extra as Map<String, String>?;
        return OtpScreen(
          phone: data?['phone'] ?? '',
          reqId: data?['reqId'] ?? '',
        );
      },
    ),

    // Language
    GoRoute(
      path: '/language',
      builder: (context, state) {
        return const LanguageScreen();
      },
    ),

    // Role Selection
    GoRoute(
      path: '/role',
      builder: (context, state) {
        return const RoleSelectionScreen();
      },
    ),
    GoRoute(
      path: '/buyer/register',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/artisan/register',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/buyer/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/artisan/home',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);