// lib/Core/Routing/app_go_routes.dart
import 'package:go_router/go_router.dart';
import 'package:tringo_app/Core/Widgets/Common%20Bottom%20Navigation%20bar/service_and_shops_details.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Edit%20Profile/Screens/edit_profile.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Login%20Screen/Screens/referral_screens.dart';

import '../Presentation/OnBoarding/Screens/Home Screen/Screens/home_screen.dart';
import '../Presentation/OnBoarding/Screens/Mobile Nomber Verify/Screen/mobile_number_verify.dart'
    hide LoginMobileNumber;
import '../Presentation/OnBoarding/Screens/Privacy Policy/screens/privacy_policy.dart';
import '../Presentation/OnBoarding/Screens/Splash_screen.dart';
import '../Presentation/OnBoarding/Screens/Login Screen/Screens/login_mobile_number.dart';
import '../Presentation/OnBoarding/Screens/Login Screen/Screens/mobile_number_verify.dart';
import '../Presentation/OnBoarding/Screens/OTP Screen/otp_screen.dart';
import '../Presentation/OnBoarding/Screens/fill_profile/Screens/fill_profile.dart';

class AppRoutes {
  static const String splashScreen = 'splashScreen';
  static const String login = 'login';
  static const String mobileNumberVerify = 'mobileNumberVerify';
  static const String otp = 'otp';
  static const String home = 'home';
  static const String fillProfile = 'fillProfile';
  static const String privacyPolicy = 'privacyPolicy';
  static const String referralScreen = 'referralScreen';
  static const String editProfile = 'editProfile';

  static const String splashScreenPath = '/splashScreen';
  static const String loginPath = '/login';
  static const String mobileNumberVerifyPath = '/mobileNumberVerify';
  static const String otpPath = '/otp';
  static const String homePath = '/home';
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
      path: '/shop/details',
      builder: (context, state) {
        final shopId = state.uri.queryParameters['shopId'] ?? '';
        final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;

        return ServiceAndShopsDetails(
          shopId: shopId,
          initialIndex: 4,
        );
      },
    ),


    GoRoute(
      path: AppRoutes.homePath,
      name: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
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
