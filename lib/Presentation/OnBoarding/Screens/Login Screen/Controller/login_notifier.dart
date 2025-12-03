import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_app/Api/Repository/failure.dart';
import 'package:tringo_app/Core/Const/app_logger.dart';

import '../../../../../Api/DataSource/api_data_source.dart';

import '../Model/login_response.dart';
import '../Model/otp_response.dart';
import '../Model/whatsapp_response.dart';

/// --- STATE ---
class LoginState {
  final bool isLoading;
  final LoginResponse? loginResponse;
  final OtpResponse? otpResponse;
  final String? error;
  final WhatsappResponse? whatsappResponse;

  const LoginState({
    this.isLoading = false,
    this.loginResponse,
    this.otpResponse,
    this.error,
    this.whatsappResponse,
  });

  factory LoginState.initial() => const LoginState();

  LoginState copyWith({
    bool? isLoading,
    LoginResponse? loginResponse,
    OtpResponse? otpResponse,
    String? error,
    WhatsappResponse? whatsappResponse,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      loginResponse: loginResponse ?? this.loginResponse,
      otpResponse: otpResponse ?? this.otpResponse,
      error: error,
      whatsappResponse: whatsappResponse ?? this.whatsappResponse,
    );
  }
}

class LoginNotifier extends Notifier<LoginState> {
  late final ApiDataSource api;

  // guard to prevent multiple OTP requests
  bool _isRequestingOtp = false;

  @override
  LoginState build() {
    api = ref.read(apiDataSourceProvider);
    return LoginState.initial();
  }

  void resetState() {
    _isRequestingOtp = false;
    state = LoginState.initial();
  }

  Future<void> loginUser({
    required String phoneNumber,
    String? simToken,
    String? page,
  }) async {
    state = const LoginState(isLoading: true);

    final result = await api.mobileNumberLogin(
      phoneNumber,
      simToken!,
      page: page ?? '',
    );

    result.fold(
      (failure) {
        state = LoginState(isLoading: false, error: failure.message);
      },
      (response) {
        state = LoginState(isLoading: false, loginResponse: response);
      },
    );
  }

  Future<void> verifyOtp({required String contact, required String otp}) async {
    state = const LoginState(isLoading: true);

    final result = await api.otp(contact: contact, otp: otp);

    await result.fold<Future<void>>(
      (Failure failure) async {
        state = LoginState(isLoading: false, error: failure.message);
      },
      (OtpResponse response) async {
        final data = response.data;

        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('token', data?.accessToken ?? '');
        await prefs.setString('refreshToken', data?.refreshToken ?? '');
        await prefs.setString('sessionToken', data?.sessionToken ?? '');
        await prefs.setString('role', data?.role ?? '');

        final accessToken = prefs.getString('token');
        final refreshToken = prefs.getString('refreshToken');
        final sessionToken = prefs.getString('sessionToken');
        final role = prefs.getString('role');

        AppLogger.log.i(' SharedPreferences stored successfully:');
        AppLogger.log.i('token → $accessToken');
        AppLogger.log.i('refreshToken → $refreshToken');
        AppLogger.log.i('sessionToken → $sessionToken');
        AppLogger.log.i('role → $role');

        state = LoginState(isLoading: false, otpResponse: response);
      },
    );
  }

  Future<void> verifyWhatsappNumber({
    required String contact,
    required String purpose,
  }) async {
    state = LoginState(isLoading: true); // start loader

    try {
      final result = await api.whatsAppNumberVerify(
        contact: contact,
        purpose: purpose,
      );

      result.fold(
            (failure) {
          // API failed
          state = LoginState(isLoading: false, error: failure.message);
        },
            (response) {
          // API success
          state = LoginState(isLoading: false, whatsappResponse: response);
        },
      );
    } catch (e) {
      state = LoginState(isLoading: false, error: e.toString());
    }
  }
}

/// --- PROVIDERS ---
final apiDataSourceProvider = Provider<ApiDataSource>((ref) {
  return ApiDataSource();
});

final loginNotifierProvider =
    NotifierProvider.autoDispose<LoginNotifier, LoginState>(LoginNotifier.new);

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:tringo_app/Api/DataSource/api_data_source.dart';
// import 'package:tringo_app/Api/Repository/failure.dart';
// import 'package:tringo_app/Core/Const/app_logger.dart';
//
// // ✅ IMPORTANT: use the SAME model files as ApiDataSource
// import 'package:tringo_app/Presentation/OnBoarding/Screens/Login Screen/Model/login_response.dart';
// import 'package:tringo_app/Presentation/OnBoarding/Screens/Login Screen/Model/otp_response.dart';
// import 'package:tringo_app/Presentation/OnBoarding/Screens/Login Screen/Model/whatsapp_response.dart';
//
// class LoginState {
//   final bool isLoading;
//   final LoginResponse? loginResponse;
//   final OtpResponse? otpResponse;
//   final WhatsappResponse? whatsappResponse;
//   final String? error;
//
//   const LoginState({
//     this.isLoading = false,
//     this.loginResponse,
//     this.otpResponse,
//     this.whatsappResponse,
//     this.error,
//   });
//
//   factory LoginState.initial() => const LoginState();
//
//   LoginState copyWith({
//     bool? isLoading,
//     LoginResponse? loginResponse,
//     OtpResponse? otpResponse,
//     WhatsappResponse? whatsappResponse,
//     String? error,
//   }) {
//     return LoginState(
//       isLoading: isLoading ?? this.isLoading,
//       loginResponse: loginResponse ?? this.loginResponse,
//       otpResponse: otpResponse ?? this.otpResponse,
//       whatsappResponse: whatsappResponse ?? this.whatsappResponse,
//       error: error,
//     );
//   }
// }
//
// /// --- LOGIN NOTIFIER ---
// class LoginNotifier extends Notifier<LoginState> {
//   @override
//   LoginState build() => LoginState.initial();
//
//   ApiDataSource get api => ref.read(apiDataSourceProvider);
//
//   void resetState() => state = LoginState.initial();
//
//   Future<void> loginUser({required String phoneNumber, String? page}) async {
//     state = state.copyWith(isLoading: true, error: null);
//
//     final result = await api.mobileNumberLogin(phoneNumber, page ?? '');
//
//     result.fold(
//       (Failure failure) {
//         state = state.copyWith(isLoading: false, error: failure.message);
//       },
//       (LoginResponse response) {
//         state = state.copyWith(
//           isLoading: false,
//           loginResponse: response,
//           error: null,
//         );
//       },
//     );
//   }
//
//   Future<void> verifyOtp({required String contact, required String otp}) async {
//     state = state.copyWith(isLoading: true, error: null);
//
//     final result = await api.otp(contact: contact, otp: otp);
//
//     result.fold(
//       (Failure failure) {
//         state = state.copyWith(isLoading: false, error: failure.message);
//       },
//       (OtpResponse response) async {
//         final data = response.data;
//
//         if (data != null) {
//           final prefs = await SharedPreferences.getInstance();
//
//           await prefs.setString('token', data.accessToken);
//           await prefs.setString('refreshToken', data.refreshToken);
//           await prefs.setString('sessionToken', data.sessionToken);
//           await prefs.setString('role', data.role);
//
//           AppLogger.log.i(
//             'SharedPreferences stored successfully: token → ${data.accessToken}',
//           );
//         } else {
//           AppLogger.log.e('OtpResponse.data is null, nothing to store');
//         }
//
//         state = state.copyWith(
//           isLoading: false,
//           otpResponse: response,
//           error: null,
//         );
//       },
//     );
//   }
//
//   Future<void> verifyWhatsappNumber({
//     required String contact,
//     required String purpose,
//   }) async {
//     state = LoginState(isLoading: true); // start loader
//
//     try {
//       final result = await api.whatsAppNumberVerify(
//         contact: contact,
//         purpose: purpose,
//       );
//
//       result.fold(
//             (failure) {
//           // API failed
//           state = LoginState(isLoading: false, error: failure.message);
//         },
//             (response) {
//           // API success
//           state = LoginState(isLoading: false, whatsappResponse: response);
//         },
//       );
//     } catch (e) {
//       state = LoginState(isLoading: false, error: e.toString());
//     }
//   }
// }
//
//
// /// --- PROVIDERS ---
// final apiDataSourceProvider = Provider<ApiDataSource>((ref) => ApiDataSource());
//
// final loginNotifierProvider =
//     NotifierProvider.autoDispose<LoginNotifier, LoginState>(LoginNotifier.new);
