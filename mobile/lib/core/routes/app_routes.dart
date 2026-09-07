import 'package:go_router/go_router.dart';

import 'package:sih26090_mobile/features/onboarding/screens/artisan_profile_screen.dart';
import 'package:sih26090_mobile/features/products/screens/notifications_screen.dart';
import 'package:sih26090_mobile/features/products/screens/order_track_screen.dart';

import '../../features/products/screens/buyer_opportunities_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/onboarding/screens/language_screen.dart';
import '../../features/onboarding/screens/role_selection_screen.dart';
import '../../features/onboarding/screens/profile_screen.dart';
import '../../features/onboarding/screens/artisan_address_screen.dart';

import '../../features/home/home_screen.dart';
import '../../features/buyer/screens/buyer_home_screen.dart';

import '../../features/products/screens/add_product_screen.dart';
import '../../features/products/screens/my_catalog_screen.dart';
import '../../features/products/screens/review_edit_listing_screen.dart';
import '../../features/products/screens/submit_quote_screen.dart';
import '../../features/products/screens/my_orders_screen.dart';
import '../../features/products/screens/requirement_detail_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',

  routes: [
    // Splash
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // Language
    GoRoute(
      path: '/language',
      builder: (context, state) => const LanguageScreen(),
    ),

    // Role Selection
    GoRoute(
      path: '/role',
      builder: (context, state) => const RoleSelectionScreen(),
    ),

    // Login
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    // OTP
    GoRoute(
      path: '/otp',
      builder: (context, state) => const OtpScreen(),
    ),

    // Seller Home
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),

    // Buyer Home
    GoRoute(
      path: '/buyer-home',
      builder: (context, state) => const BuyerHomeScreen(),
    ),

    // Onboarding Profile
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),

    // Artisan Address
    GoRoute(
      path: '/artisan-address',
      builder: (context, state) => const ArtisanAddressScreen(),
    ),

    // Add Product
    GoRoute(
      path: '/add-product',
      builder: (context, state) => const AddProductScreen(),
    ),

    // My Catalog
    GoRoute(
      path: '/my-catalog',
      builder: (context, state) => const MyCatalogScreen(),
    ),

    // Review & Edit Listing
    GoRoute(
      path: '/review-edit-listing',
      builder: (context, state) {
        final imagePath = state.extra as String?;

        return ReviewEditListingScreen(
          imagePath: imagePath,
        );
      },
    ),

    // Buyer Opportunities
    GoRoute(
      path: '/buyer-opportunities',
      builder: (context, state) => const BuyerOpportunitiesScreen(),
    ),

    // Requirement Detail
    GoRoute(
      path: '/requirement-detail',
      builder: (context, state) => const RequirementDetailScreen(),
    ),

    // Submit Quote
    GoRoute(
      path: '/submit-quote',
      builder: (context, state) => const SubmitQuoteScreen(),
    ),

    // Artisan Profile
    GoRoute(
      path: '/artisan-profile',
      builder: (context, state) => const ArtisanProfileScreen(),
    ),

    // My Orders
    GoRoute(
      path: '/my-orders',
      builder: (context, state) => const MyOrdersScreen(),
    ),

    // Notifications
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),

    // Order Track
    GoRoute(
      path: '/order-track',
      builder: (context, state) => const OrderTrackScreen(),
    ),
  ],
);