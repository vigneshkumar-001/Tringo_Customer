import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_app/Api/Repository/failure.dart';
import 'package:tringo_app/Core/Const/app_logger.dart';
import 'package:tringo_app/Core/Utility/app_prefs.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Login%20Screen/Model/login_new_response.dart';

import '../../../../../Api/DataSource/api_data_source.dart';

import '../../../../../Core/contacts/contacts_service.dart';
import '../Model/contact_response.dart';
import '../Model/login_response.dart';
import '../Model/otp_response.dart';
import '../Model/whatsapp_response.dart';

/// --- STATE ---
class LoginState {
  final bool isLoading;
  final LoginResponse? loginResponse;
  final OtpLoginResponse? otpLoginResponse;
  final OtpResponse? otpResponse;
  final String? error;
  final WhatsappResponse? whatsappResponse;
  final ContactResponse? contactResponse;

  const LoginState({
    this.isLoading = false,
    this.loginResponse,
    this.otpResponse,
    this.error,
    this.whatsappResponse,
    this.contactResponse,
    this.otpLoginResponse,
  });

  factory LoginState.initial() => const LoginState();

  LoginState copyWith({
    bool? isLoading,
    LoginResponse? loginResponse,
    OtpResponse? otpResponse,
    String? error,
    WhatsappResponse? whatsappResponse,
    ContactResponse? contactResponse,
    OtpLoginResponse? otpLoginResponse,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      loginResponse: loginResponse ?? this.loginResponse,
      otpResponse: otpResponse ?? this.otpResponse,
      error: error,
      whatsappResponse: whatsappResponse ?? this.whatsappResponse,
      contactResponse: contactResponse ?? this.contactResponse,
      otpLoginResponse: otpLoginResponse ?? this.otpLoginResponse,
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
          error: failure.message,
          loginResponse: null,
        );
      },
      (response) {
        state = state.copyWith(
          isLoading: false,
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

        //  HERE: contacts sync for SIM-direct login
        final alreadySynced = prefs.getBool('contacts_synced') ?? false;

        // Optional: only sync when SIM verified true
        final simVerified = response.data?.simVerified == true;

        if (!alreadySynced && simVerified) {
          try {
            AppLogger.log.i("✅ Contact sync started (SIM login)");

            final contacts = await ContactsService.getAllContacts();
            AppLogger.log.i("📞 contacts fetched = ${contacts.length}");

            if (contacts.isEmpty) {
              AppLogger.log.w(
                "⚠️ Contacts empty / permission denied. Will retry later.",
              );
              return;
            }

            final limited = contacts.take(500).toList();

            final items = limited
                .map((c) => {"name": c.name, "phone": "+91${c.phone}"})
                .toList();

            // ✅ chunk to reduce payload size (recommended)
            const chunkSize = 200;
            for (var i = 0; i < items.length; i += chunkSize) {
              final chunk = items.sublist(
                i,
                (i + chunkSize > items.length) ? items.length : i + chunkSize,
              );

              final res = await api.syncContacts(items: chunk);

              res.fold(
                (l) => AppLogger.log.e("❌ batch sync fail: ${l.message}"),
                (r) => AppLogger.log.i(
                  "✅ batch ok total=${r.data.total} inserted=${r.data.inserted} touched=${r.data.touched} skipped=${r.data.skipped}",
                ),
              );
            }

            await prefs.setBool('contacts_synced', true);
            AppLogger.log.i("✅ Contacts synced (SIM login): ${limited.length}");
          } catch (e) {
            AppLogger.log.e("❌ Contact sync failed (SIM login): $e");
          }
        }
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

        final alreadySynced = prefs.getBool('contacts_synced') ?? false;
        if (alreadySynced) return;

        try {
          AppLogger.log.i("✅ Contact sync started");

          final contacts = await ContactsService.getAllContacts();
          AppLogger.log.i("📞 contacts fetched = ${contacts.length}");

          if (contacts.isEmpty) {
            AppLogger.log.w(
              "⚠️ Contacts empty OR permission denied. Not marking synced.",
            );
            return;
          }

          // ✅ Build items array (backend expects items[])
          final limited = contacts.take(500).toList(); // increase if you want
          final items = limited
              .map(
                (c) => {
                  "name": c.name,
                  "phone": "+91${c.phone}", // or use dialCode dynamic
                },
              )
              .toList();

          // ✅ Chunk to avoid huge payload (recommended)
          const chunkSize = 200;
          for (var i = 0; i < items.length; i += chunkSize) {
            final chunk = items.sublist(
              i,
              (i + chunkSize > items.length) ? items.length : i + chunkSize,
            );

            final res = await api.syncContacts(items: chunk);

            res.fold(
              (l) => AppLogger.log.e("❌ batch sync fail: ${l.message}"),
              (r) => AppLogger.log.i(
                "✅ batch ok total=${r.data.total} inserted=${r.data.inserted} touched=${r.data.touched} skipped=${r.data.skipped}",
              ),
            );
          }

          await prefs.setBool('contacts_synced', true);
          AppLogger.log.i("✅ Contacts synced done: ${limited.length}");
        } catch (e) {
          AppLogger.log.e("❌ Contact sync failed: $e");
        }
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

final apiDataSourceProvider = Provider<ApiDataSource>((ref) {
  return ApiDataSource();
});

// final loginNotifierProvider =
//     NotifierProvider.autoDispose<LoginNotifier, LoginState>(LoginNotifier.new);
final loginNotifierProvider = NotifierProvider<LoginNotifier, LoginState>(
  LoginNotifier.new,
);
