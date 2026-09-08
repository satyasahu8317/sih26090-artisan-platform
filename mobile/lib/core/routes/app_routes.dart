import 'package:go_router/go_router.dart';

// ================= BUYER =================
import 'package:sih26090_mobile/features/buyer/screens/buyer_home_screen.dart';
import 'package:sih26090_mobile/features/buyer/screens/buyer_interests_screen.dart';
import 'package:sih26090_mobile/features/buyer/screens/buyer_language_screen.dart';
import 'package:sih26090_mobile/features/buyer/screens/buyer_notification_screen.dart';
import 'package:sih26090_mobile/features/buyer/screens/buyer_order_details_screen.dart';
import 'package:sih26090_mobile/features/buyer/screens/buyer_orders_screen.dart';
import 'package:sih26090_mobile/features/buyer/screens/buyer_payment_screen.dart';
import 'package:sih26090_mobile/features/buyer/screens/buyer_product_detail_screen.dart';
import 'package:sih26090_mobile/features/buyer/screens/buyer_profile_screen.dart';
import 'package:sih26090_mobile/features/buyer/screens/chat_with_seller_screen.dart';
import 'package:sih26090_mobile/features/buyer/screens/search_screen.dart';
import 'package:sih26090_mobile/features/buyer/screens/wishlist_screen.dart';
import 'package:sih26090_mobile/features/buyer/screens/buyer_onboarding_profile_screen.dart';

// ================= AUTH =================
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_screen.dart';

// ================= ONBOARDING =================
import '../../features/onboarding/screens/artisan_address_screen.dart';
import '../../features/onboarding/screens/artisan_profile_screen.dart';
import '../../features/onboarding/screens/language_screen.dart';
import '../../features/onboarding/screens/profile_screen.dart';
import '../../features/onboarding/screens/role_selection_screen.dart';
import '../../features/onboarding/screens/splash_screen.dart';

// ================= ARTISAN / PRODUCTS =================
import '../../features/enquiries/screens/artisan_enquiries_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/products/screens/add_product_screen.dart';
import '../../features/products/screens/buyer_opportunities_screen.dart';
import '../../features/products/screens/my_catalog_screen.dart';
import '../../features/products/screens/my_orders_screen.dart';
import '../../features/products/screens/notifications_screen.dart';
import '../../features/products/screens/order_track_screen.dart';
import '../../features/products/screens/requirement_detail_screen.dart';
import '../../features/products/screens/review_edit_listing_screen.dart';
import '../../features/products/screens/submit_quote_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',

  routes: [
    // ============================================================
    // SPLASH
    // ============================================================

    GoRoute(
      path: '/splash',
      builder: (context, state) =>
          const SplashScreen(),
    ),

    // ============================================================
    // LANGUAGE
    // ============================================================

    GoRoute(
      path: '/language',
      builder: (context, state) =>
          const LanguageScreen(),
    ),

    // ============================================================
    // ROLE
    // ============================================================

    GoRoute(
      path: '/role',
      builder: (context, state) =>
          const RoleSelectionScreen(),
    ),

    // ============================================================
    // AUTH
    // ============================================================

    GoRoute(
      path: '/login',
      builder: (context, state) =>
          const LoginScreen(),
    ),

    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final extra = state.extra;

        final data = extra is Map
            ? extra
            : const <String, dynamic>{};

        return OtpScreen(
          phone:
              (data['phone'] as String?) ?? '',
          reqId:
              (data['reqId'] as String?) ?? '',
        );
      },
    ),

    // ============================================================
    // ARTISAN HOME
    // ============================================================

    GoRoute(
      path: '/home',
      builder: (context, state) =>
          const HomeScreen(),
    ),

    // ============================================================
    // BUYER HOME
    // ============================================================

    GoRoute(
      path: '/buyer-home',
      builder: (context, state) =>
          const BuyerHomeScreen(),
    ),

    // ============================================================
    // ONBOARDING PROFILE
    // ============================================================

    GoRoute(
      path: '/profile',
      builder: (context, state) =>
          const ProfileScreen(),
    ),

    GoRoute(
      path: '/artisan-address',
      builder: (context, state) =>
          const ArtisanAddressScreen(),
    ),

    // ============================================================
    // ARTISAN PRODUCTS
    // ============================================================

    GoRoute(
      path: '/add-product',
      builder: (context, state) =>
          const AddProductScreen(),
    ),

    GoRoute(
      path: '/my-catalog',
      builder: (context, state) =>
          const MyCatalogScreen(),
    ),

    GoRoute(
      path: '/review-edit-listing',
      builder: (context, state) {
        final imagePath =
            state.extra as String?;

        return ReviewEditListingScreen(
          imagePath: imagePath,
        );
      },
    ),

    // ============================================================
    // ARTISAN OPPORTUNITIES
    // ============================================================

    GoRoute(
      path: '/buyer-opportunities',
      builder: (context, state) =>
          const BuyerOpportunitiesScreen(),
    ),

    GoRoute(
      path: '/requirement-detail',
      builder: (context, state) =>
          const RequirementDetailScreen(),
    ),

    GoRoute(
      path: '/submit-quote',
      builder: (context, state) =>
          const SubmitQuoteScreen(),
    ),

    // ============================================================
    // ARTISAN PROFILE
    // ============================================================

    GoRoute(
      path: '/artisan-profile',
      builder: (context, state) =>
          const ArtisanProfileScreen(),
    ),

    // ============================================================
    // ARTISAN ORDERS
    // ============================================================

    GoRoute(
      path: '/my-orders',
      builder: (context, state) =>
          const MyOrdersScreen(),
    ),

    // ============================================================
    // ARTISAN ENQUIRIES
    // ============================================================

    GoRoute(
      path: '/artisan-enquiries',
      builder: (context, state) =>
          const ArtisanEnquiriesScreen(),
    ),

    // ============================================================
    // ARTISAN NOTIFICATIONS
    // ============================================================

    GoRoute(
      path: '/notifications',
      builder: (context, state) =>
          const NotificationsScreen(),
    ),

    // ============================================================
    // ORDER TRACK
    // ============================================================

    GoRoute(
      path: '/order-track',
      builder: (context, state) {
        final extra = state.extra;

        final data = extra is Map
            ? extra
            : const <String, dynamic>{};

        return OrderTrackScreen(
          orderId:
              data['orderId'] as String?,
          initialStatus:
              data['status'] as String?,
          requestedQty:
              data['requestedQty'] as int?,
        );
      },
    ),

    // ============================================================
    // BUYER ONBOARDING PROFILE
    // ============================================================

    GoRoute(
      path: '/buyer-onboarding-profile',
      builder: (context, state) =>
          const BuyerOnboardingProfileScreen(),
    ),

    GoRoute(
      path: '/buyer-languages',
      builder: (context, state) =>
          const BuyerLanguagesScreen(),
    ),

    GoRoute(
      path: '/buyer-interests',
      builder: (context, state) =>
          const BuyerInterestsScreen(),
    ),

    // ============================================================
    // BUYER PROFILE
    // ============================================================

    GoRoute(
      path: '/buyer-profile',
      builder: (context, state) =>
          const BuyerProfileScreen(),
    ),

    // ============================================================
    // BUYER PRODUCT DETAIL
    // ============================================================

    GoRoute(
      path: '/buyer-product-detail',
      builder: (context, state) {
        final productId =
            state.extra as String;

        return BuyerProductDetailScreen(
          productId: productId,
        );
      },
    ),

    // ============================================================
    // BUYER SEARCH
    // ============================================================

    GoRoute(
      path: '/buyer-search',
      builder: (context, state) =>
          const SearchScreen(),
    ),

    // ============================================================
    // BUYER ORDERS
    // ============================================================

    GoRoute(
      path: '/buyer-orders',
      builder: (context, state) =>
          const BuyerOrdersScreen(),
    ),

    // ============================================================
    // BUYER ORDER DETAILS
    // ============================================================

    GoRoute(
      path: '/buyer-order-details',
      builder: (context, state) {
        final orderId =
            state.extra as String;

        return BuyerOrderDetailsScreen(
          orderId: orderId,
        );
      },
    ),

    // ============================================================
    // BUYER NOTIFICATIONS
    // ============================================================

    GoRoute(
      path: '/buyer-notifications',
      builder: (context, state) =>
          const BuyerNotificationsScreen(),
    ),

    // ============================================================
    // BUYER CHAT
    // ============================================================

    GoRoute(
      path: '/chat-seller',
      builder: (context, state) {
        final enquiryId =
            state.extra as String;

        return ChatWithSellerScreen(
          enquiryId: enquiryId,
        );
      },
    ),

    // ============================================================
    // BUYER WISHLIST
    // ============================================================

    GoRoute(
      path: '/wishlist',
      builder: (context, state) =>
          const WishlistScreen(),
    ),

    // ============================================================
    // BUYER PAYMENT
    // ============================================================

    GoRoute(
      path: '/buyer-payment',
      builder: (context, state) =>
          const BuyerPaymentScreen(),
    ),
  ],
);