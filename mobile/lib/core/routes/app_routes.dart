import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/home/buyer_home_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/onboarding/screens/buyer_registration_screen.dart';
import '../../features/onboarding/screens/language_screen.dart';
import '../../features/onboarding/screens/profile_screen.dart';
import '../../features/onboarding/screens/role_selection_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/role',

  routes: [
    // Role Selection ("How will you use Kalamitr?")
    GoRoute(
      path: '/role',
      builder: (context, state) {
        return const RoleSelectionScreen();
      },
    ),

    // Login
    GoRoute(
      path: '/login',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final role = extra?['role']?.toString();
        return LoginScreen(role: role);
      },
    ),

    // OTP
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return OtpScreen(
          phoneNumber: extra?['phoneNumber']?.toString() ?? '',
          reqId: extra?['reqId']?.toString() ?? '',
          role: extra?['role']?.toString() ?? 'BUYER',
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

    // Artisan Registration / Profile Setup
    GoRoute(
      path: '/artisan/register',
      builder: (context, state) {
        return const ProfileScreen();
      },
    ),

    // Artisan Home / Dashboard
    GoRoute(
      path: '/artisan/home',
      builder: (context, state) {
        return const HomeScreen();
      },
    ),

    // Buyer Registration
    GoRoute(
      path: '/buyer/register',
      builder: (context, state) {
        return const BuyerRegistrationScreen();
      },
    ),

    // Buyer Home / Marketplace
    GoRoute(
      path: '/buyer/home',
      builder: (context, state) {
        return const BuyerHomeScreen();
      },
    ),
  ],
);