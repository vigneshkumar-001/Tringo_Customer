// lib/Core/Routing/app_go_routes.dart
import 'package:go_router/go_router.dart';

import '../Presentation/OnBoarding/Screens/Home Screen/Screens/home_screen.dart';
import '../Presentation/OnBoarding/Screens/Privacy Policy/privacy_policy.dart';
import '../Presentation/OnBoarding/Screens/Splash_screen.dart';
import '../Presentation/OnBoarding/Screens/Login Screen/login_mobile_number.dart';
import '../Presentation/OnBoarding/Screens/Login Screen/mobile_number_verify.dart';
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

  static const String splashScreenPath = '/splashScreen';
  static const String loginPath = '/login';
  static const String mobileNumberVerifyPath = '/mobileNumberVerify';
  static const String otpPath = '/otp';
  static const String homePath = '/home';
  static const String fillProfilePath = '/fillProfile';
  static const String privacyPolicyPath = '/privacyPolicy';
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
      builder: (context, state) => const LoginMobileNumber(),
    ),
    GoRoute(
      path: AppRoutes.mobileNumberVerifyPath,
      name: AppRoutes.mobileNumberVerify,
      builder: (context, state) {
        final phone = state.extra as String?;
        return MobileNumberVerify(loginNumber: phone ?? '');
      },
    ),
    GoRoute(
      path: AppRoutes.otpPath,
      name: AppRoutes.otp,
      builder: (context, state) {
        final phone = state.extra as String?;
        return OtpScreen( phoneNumber : phone ?? '');
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
  ],
);
