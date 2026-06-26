// lib/Core/Routing/app_go_routes.dart
import 'package:go_router/go_router.dart';
import 'package:tringo_app/Core/Widgets/Common%20Bottom%20Navigation%20bar/service_and_shops_details.dart';
import 'package:tringo_app/Core/Widgets/Common%20Bottom%20Navigation%20bar/search_screen_bottombar.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Edit%20Profile/Screens/edit_profile.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Login%20Screen/Screens/referral_screens.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Products/Screens/product_details.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Services%20Screen/Screens/search_service_data.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Smart%20Connect/Screens/smart_connect_details.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Surprise_Screens/Screens/surprise_offer_details_from_push.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/wallet/Screens/wallet_screens.dart';
import 'package:tringo_app/Presentation/OnBoarding/Shared/referral_deeplink_gate.dart';

import '../Presentation/OnBoarding/Screens/Home Screen/Screens/home_screen.dart';
import '../Presentation/OnBoarding/Screens/Privacy Policy/screens/privacy_policy.dart';
import '../Presentation/OnBoarding/Screens/Splash_screen.dart';
import '../Presentation/OnBoarding/Screens/Login Screen/Screens/login_mobile_number.dart';
import '../Presentation/OnBoarding/Screens/OTP Screen/otp_screen.dart';
import '../Presentation/OnBoarding/Screens/fill_profile/Screens/fill_profile.dart';
import '../Presentation/OnBoarding/Screens/Contacts Sync/contacts_consent_gate.dart';

class AppRoutes {
  static const String splashScreen = 'splashScreen';
  static const String login = 'login';
  static const String mobileNumberVerify = 'mobileNumberVerify';
  static const String otp = 'otp';
  static const String contactsConsentGate = 'contactsConsentGate';
  static const String home = 'home';
  static const String homeShell = 'homeShell';
  static const String fillProfile = 'fillProfile';
  static const String privacyPolicy = 'privacyPolicy';
  static const String referralScreen = 'referralScreen';
  static const String editProfile = 'editProfile';

  static const String splashScreenPath = '/splashScreen';
  static const String loginPath = '/login';
  static const String mobileNumberVerifyPath = '/mobileNumberVerify';
  static const String otpPath = '/otp';
  static const String contactsConsentGatePath = '/contactsConsentGate';
  static const String homePath = '/home';
  static const String homeShellPath = '/homeShell';
  static const String fillProfilePath = '/fillProfile';
  static const String privacyPolicyPath = '/privacyPolicy';
  static const String referralScreenPath = '/referralScreenPath';
  static const String editProfilePath = '/editProfile';
}

final goRouter = GoRouter(
  initialLocation: AppRoutes.splashScreenPath,
  routes: [
    GoRoute(
      path: AppRoutes.splashScreenPath,
      name: AppRoutes.splashScreen,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.loginPath,
      name: AppRoutes.login,
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>? ?? {};
        final phone = args['phone'] as String? ?? '';
        final simToken = args['simToken'] as String? ?? '';

        return LoginMobileNumber(loginNumber: phone, simToken: simToken);
      },
    ),
    // GoRoute(
    //   path: AppRoutes.mobileNumberVerifyPath,
    //   name: AppRoutes.mobileNumberVerify,
    //   builder: (context, state) {
    //     final args = state.extra as Map<String, dynamic>? ?? {};
    //     final phone = args['phone'] as String? ?? '';
    //     final simToken = args['simToken'] as String? ?? '';
    //
    //     return MobileNumberVerify(loginNumber: phone, simToken: simToken);
    //   },
    // ),
    GoRoute(
      path: AppRoutes.otpPath,
      name: AppRoutes.otp,
      builder: (context, state) {
        String phone = '';

        final extra = state.extra;

        if (extra is String) {
          phone = extra;
        } else if (extra is Map) {
          final dynamic maybePhone = extra['phone'];
          if (maybePhone is String) phone = maybePhone;
        }

        return OtpScreen(phoneNumber: phone);
      },
    ),
    GoRoute(
      path: AppRoutes.contactsConsentGatePath,
      name: AppRoutes.contactsConsentGate,
      builder: (context, state) {
        final args =
            ContactsConsentGateArgs.tryParse(state.extra) ??
            const ContactsConsentGateArgs(nextRouteName: AppRoutes.home);
        return ContactsConsentGate(args: args);
      },
    ),
    GoRoute(
      path: '/shop/details',
      builder: (context, state) {
        final shopId = state.uri.queryParameters['shopId'] ?? '';
        // Default to ShopsDetails tab when not provided (fixes share links that
        // only include `shopId`).
        final rawTab =
            int.tryParse(state.uri.queryParameters['tab'] ?? '4') ?? 4;
        final tab = (rawTab < 0 || rawTab > 4) ? 4 : rawTab;

        return ServiceAndShopsDetails(
          shopId: shopId,
          initialIndex: tab,
        );
      },
    ),

    GoRoute(
      path: '/smart-connect/details',
      builder: (context, state) {
        final requestId = state.uri.queryParameters['requestId'] ?? '';
        return SmartConnectDetails(requestedId: requestId);
      },
    ),

    GoRoute(
      path: '/product/details',
      builder: (context, state) {
        final productId = state.uri.queryParameters['productId'] ?? '';
        return ProductDetails(productId: productId);
      },
    ),

    GoRoute(
      path: '/service/details',
      builder: (context, state) {
        final serviceId = state.uri.queryParameters['serviceId'] ?? '';
        return SearchServiceData(serviceId: serviceId);
      },
    ),

    GoRoute(
      path: '/surprise/offer',
      builder: (context, state) {
        final shopId = state.uri.queryParameters['shopId'] ?? '';
        final offerId = state.uri.queryParameters['offerId'] ?? '';
        return SurpriseOfferDetailsFromPush(shopId: shopId, offerId: offerId);
      },
    ),

    // Support backend share links: https://bknd.tringobiz.com/surprise/details?shopId=...&offerId=...
    GoRoute(
      path: '/surprise/details',
      builder: (context, state) {
        final shopId = state.uri.queryParameters['shopId'] ?? '';
        final offerId = state.uri.queryParameters['offerId'] ?? '';
        return SurpriseOfferDetailsFromPush(shopId: shopId, offerId: offerId);
      },
    ),

    GoRoute(
      path: '/wallet',
      builder: (context, state) {
        final extra = state.extra;
        String? type;
        String? toast;
        if (extra is Map) {
          final t = extra['type'];
          if (t != null) type = t.toString();
          final msg = extra['toast'];
          if (msg != null) toast = msg.toString();
        }

        // also allow query params, but prefer extra
        type ??= state.uri.queryParameters['type'];
        toast ??= state.uri.queryParameters['toast'];

        return WalletScreens(initialType: type, initialToast: toast);
      },
    ),

    // Referral deep link: https://bknd.tringobiz.com/referral?code=565799
    GoRoute(
      path: '/referral',
      builder: (context, state) {
        final qp = state.uri.queryParameters;
        final code = (qp['code'] ?? qp['ref'] ?? '').trim();
        return ReferralDeeplinkGate(referralCode: code);
      },
    ),


    GoRoute(
      path: AppRoutes.homePath,
      name: AppRoutes.home,
      // Support "home" deep links that actually carry an entity id.
      // Example: https://bknd.tringobiz.com/home?shopId=... should open shop details.
      redirect: (context, state) {
        final qp = state.uri.queryParameters;

        String pick(List<String> keys) {
          for (final k in keys) {
            final v = (qp[k] ?? '').trim();
            if (v.isNotEmpty) return v;
          }
          return '';
        }

        final productId = pick(const ['productId', 'productID']);
        if (productId.isNotEmpty) {
          return Uri(
            path: '/product/details',
            queryParameters: {'productId': productId},
          ).toString();
        }

        final serviceId = pick(const ['serviceId', 'serviceID']);
        if (serviceId.isNotEmpty) {
          return Uri(
            path: '/service/details',
            queryParameters: {'serviceId': serviceId},
          ).toString();
        }

        final shopId = pick(const ['shopId', 'shopID']);
        final offerId = pick(const ['offerId', 'offerID']);
        if (shopId.isNotEmpty && offerId.isNotEmpty) {
          return Uri(
            path: '/surprise/details',
            queryParameters: {'shopId': shopId, 'offerId': offerId},
          ).toString();
        }

        if (shopId.isNotEmpty) {
          final tab =
              int.tryParse((qp['tab'] ?? '').trim()) ??
              4;
          return Uri(
            path: '/shop/details',
            queryParameters: {'shopId': shopId, 'tab': '$tab'},
          ).toString();
        }

        return null;
      },
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.homeShellPath,
      name: AppRoutes.homeShell,
      builder: (context, state) => const SearchScreenBottombar(initialIndex: 0),
    ),
    GoRoute(
      path: AppRoutes.fillProfilePath,
      name: AppRoutes.fillProfile,
      builder: (context, state) => const FillProfile(),
    ),
    GoRoute(
      path: AppRoutes.privacyPolicyPath,
      name: AppRoutes.privacyPolicy,
      builder: (context, state) => const PrivacyPolicy(),
    ),
    GoRoute(
      path: AppRoutes.referralScreenPath,
      name: AppRoutes.referralScreen,
      builder: (context, state) => const ReferralScreens(),
    ),
    GoRoute(
      path: AppRoutes.editProfilePath,
      name: AppRoutes.editProfile,
      builder: (context, state) => const EditProfile(),
    ),
  ],
);
