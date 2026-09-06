import 'package:go_router/go_router.dart';
import '../../features/products/screens/buyer_opportunities_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/onboarding/screens/language_screen.dart';
import '../../features/onboarding/screens/role_selection_screen.dart';
import '../../features/products/screens/requirement_detail_screen.dart';
final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',

  routes: [
    // Splash
    GoRoute(
      path: '/splash',
      builder: (context, state) {
        return const SplashScreen();
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
    // Buyer Opportunities
GoRoute(
  path: '/buyer-opportunities',
  builder: (context, state) {
    return const BuyerOpportunitiesScreen();
  },
),// Requirement Detail
GoRoute(
  path: '/requirement-detail',
  builder: (context, state) {
    return const RequirementDetailScreen();
  },
),
  ],
);