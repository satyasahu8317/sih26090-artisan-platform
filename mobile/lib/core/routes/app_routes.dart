import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/onboarding/screens/language_screen.dart';
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
        return const OtpScreen();
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
  ],
);