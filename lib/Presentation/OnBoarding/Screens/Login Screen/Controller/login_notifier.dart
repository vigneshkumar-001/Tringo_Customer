import 'dart:async';

export 'package:tringo_app/Api/api_providers.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_app/Api/Repository/failure.dart';
import 'package:tringo_app/Api/api_providers.dart';
import 'package:tringo_app/Core/Const/app_logger.dart';
import 'package:tringo_app/Core/Utility/app_prefs.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Login%20Screen/Model/login_new_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Login%20Screen/Model/referral_response.dart';

import '../../../../../Api/DataSource/api_data_source.dart';
import '../Model/contact_response.dart';
import '../Model/login_response.dart';
import '../Model/otp_response.dart';
import '../Model/whatsapp_response.dart';

/// --- STATE ---
class LoginState {
  final bool isLoading;
  final bool isReferralCodeLoading;
  final bool isResendingOtp;
  final bool isVerifyingOtp;
  final LoginResponse? loginResponse;
  final OtpLoginResponse? otpLoginResponse;
  final OtpResponse? otpResponse;
  final String? error;
  final WhatsappResponse? whatsappResponse;
  final ContactResponse? contactResponse;
  final ReferralResponse? referralResponse;

  const LoginState({
    this.isLoading = false,
    this.isResendingOtp = false,
    this.isReferralCodeLoading = false,
    this.isVerifyingOtp = false,
    this.loginResponse,
    this.otpResponse,
    this.error,
    this.whatsappResponse,
    this.contactResponse,
    this.otpLoginResponse,
    this.referralResponse,
  });

  factory LoginState.initial() => const LoginState();

  LoginState copyWith({
    bool? isLoading,
    bool? isResendingOtp,
    bool? isReferralCodeLoading,
    bool? isVerifyingOtp,
    LoginResponse? loginResponse,
    OtpResponse? otpResponse,
    String? error,
    WhatsappResponse? whatsappResponse,
    ContactResponse? contactResponse,
    OtpLoginResponse? otpLoginResponse,
    ReferralResponse? referralResponse,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isResendingOtp: isResendingOtp ?? this.isResendingOtp,
      isReferralCodeLoading:
          isReferralCodeLoading ?? this.isReferralCodeLoading,
      isVerifyingOtp: isVerifyingOtp ?? this.isVerifyingOtp,
      loginResponse: loginResponse ?? this.loginResponse,
      otpResponse: otpResponse ?? this.otpResponse,
      error: error,
      whatsappResponse: whatsappResponse ?? this.whatsappResponse,
      contactResponse: contactResponse ?? this.contactResponse,
      otpLoginResponse: otpLoginResponse ?? this.otpLoginResponse,
      referralResponse: referralResponse ?? this.referralResponse,
    );
  }
}

class LoginNotifier extends Notifier<LoginState> {
  late final ApiDataSource api;

  @override
  LoginState build() {
    api = ref.read(apiDataSourceProvider);
    return LoginState.initial();
  }

  // Future<void> loginUser({
  //   required String phoneNumber,
  //   String? simToken,
  //   String? page,
  // }) async {
  //   state = state.copyWith(isLoading: true, error: null);
  //
  //   final result = await api.mobileNumberLogin(
  //     phoneNumber,
  //     simToken ?? "",
  //     page: page ?? "",
  //   );
  //
  //   result.fold(
  //     (failure) {
  //       state = state.copyWith(
  //         isLoading: false,
  //         error: failure.message,
  //         loginResponse: null,
  //       );
  //     },
  //     (response) {
  //       state = state.copyWith(
  //         isLoading: false,
  //         loginResponse: response,
  //         error: null,
  //       );
  //     },
  //   );
  // }

  Future<void> loginUser({
    required String phoneNumber,
    String? simToken,
    String? page,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.mobileNumberLogin(
      phoneNumber,
      simToken ?? "",
      page: page ?? "",
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          isResendingOtp: page == 'resendOtp',
          error: failure.message,
          loginResponse: null,
        );
      },
      (response) {
        state = state.copyWith(
          isLoading: false,
          isResendingOtp: false,
          loginResponse: response,
          error: null,
        );
      },
    );
  }

  Future<void> loginNewUser({
    required String phoneNumber,
    String? simToken,
    String? page,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      otpLoginResponse: null,
    );

    final result = await api.mobileNewNumberLogin(
      phoneNumber,
      simToken ?? "",
      page: page ?? "",
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          otpLoginResponse: null,
        );
      },
      (response) async {
        state = state.copyWith(
          isLoading: false,
          otpLoginResponse: response,
          error: null,
        );

        final prefs = await SharedPreferences.getInstance();
        await AppPrefs.setToken(response.data?.accessToken ?? '');
        await AppPrefs.setRefreshToken(response.data?.refreshToken ?? '');
        await AppPrefs.setSessionToken(response.data?.sessionToken ?? '');
        await AppPrefs.setRole(response.data?.role ?? '');

        AppLogger.log.i('✅ SIM login token stored');
      },
    );
  }

  Future<void> verifyOtp({required String contact, required String otp}) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.otp(contact: contact, otp: otp);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (response) async {
        final prefs = await SharedPreferences.getInstance();

        final data = response.data;
        await prefs.setString('token', data?.accessToken ?? '');
        await prefs.setString('refreshToken', data?.refreshToken ?? '');
        await prefs.setString('sessionToken', data?.sessionToken ?? '');
        await prefs.setString('role', data?.role ?? '');

        // ✅ OTP success state first (UI can navigate)
        state = state.copyWith(isLoading: false, otpResponse: response);
      },
    );
  }

  Future<void> verifyWhatsappNumber({
    required String contact,
    required String purpose,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.whatsAppNumberVerify(
      contact: contact,
      purpose: purpose,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          whatsappResponse: null, // clear old success
        );
      },
      (response) {
        state = state.copyWith(
          isLoading: false,
          whatsappResponse: response,
          error: null, // clear old error
        );
      },
    );
  }

  Future<void> verifyReferralCode({required String referralCode}) async {
    state = state.copyWith(isReferralCodeLoading: true, error: null);

    final result = await api.verifyReferralCode(referralCode: referralCode);

    result.fold(
      (failure) {
        state = state.copyWith(
          isReferralCodeLoading: false,
          error: failure.message,
          referralResponse: null, // clear old success
        );
      },
      (response) {
        state = state.copyWith(
          isReferralCodeLoading: false,
          referralResponse: response,
          error: null, // clear old error
        );
      },
    );
  }

  Future<void> syncContact({
    required String name,
    required String phone,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final items = [
      {"name": name, "phone": "+91$phone"},
    ];

    final result = await api.syncContacts(items: items);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          contactResponse: null,
        );
      },
      (response) {
        state = state.copyWith(
          isLoading: false,
          contactResponse: response,
          error: null,
        );
      },
    );
  }

  void resetState() {
    state = LoginState.initial();
  }
}

// final loginNotifierProvider =
//     NotifierProvider.autoDispose<LoginNotifier, LoginState>(LoginNotifier.new);
final loginNotifierProvider = NotifierProvider<LoginNotifier, LoginState>(
  LoginNotifier.new,
);
