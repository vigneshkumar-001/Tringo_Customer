import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../Api/DataSource/api_data_source.dart';
import '../../../../../Core/Utility/app_prefs.dart';
import '../Model/edit_number_otp_response.dart';
import '../Model/edit_number_verify_response.dart';
import '../Model/edit_profile_response.dart';

class EditProfileState {
  final bool isLoading;
  final bool isSendingOtp;
  final bool isVerifyingOtp;
  final String? imageUrl;
  final String? error;
  final EditNumberVerifyResponse? editNumberVerifyResponse;
  final EditNumberOtpResponse? editNumberOtpResponse;
  final EditProfileResponse? editProfileResponse;

  const EditProfileState({
    this.isLoading = false,
    this.isSendingOtp = false,
    this.isVerifyingOtp = false,
    this.imageUrl,
    this.error,
    this.editNumberVerifyResponse,
    this.editNumberOtpResponse,
    this.editProfileResponse,
  });

  factory EditProfileState.initial() => const EditProfileState();

  EditProfileState copyWith({
    bool? isLoading,
    bool? isSendingOtp,
    bool? isVerifyingOtp,
    String? error,
    EditNumberVerifyResponse? editNumberVerifyResponse,
    EditNumberOtpResponse? editNumberOtpResponse,
    EditProfileResponse? editProfileResponse,
    bool clearError = false,
  }) {
    return EditProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSendingOtp: isSendingOtp ?? this.isSendingOtp,
      isVerifyingOtp: isVerifyingOtp ?? this.isVerifyingOtp,
      error: clearError ? null : (error ?? this.error),
      editNumberVerifyResponse:
          editNumberVerifyResponse ?? this.editNumberVerifyResponse,
      editNumberOtpResponse:
          editNumberOtpResponse ?? this.editNumberOtpResponse,
      editProfileResponse: editProfileResponse ?? this.editProfileResponse,
    );
  }
}

class ShopNotifier extends Notifier<EditProfileState> {
  final ApiDataSource apiDataSource = ApiDataSource();

  String _onlyIndian10(String input) {
    var p = input.trim();
    p = p.replaceAll(RegExp(r'[^0-9]'), '');
    if (p.startsWith('91') && p.length == 12) p = p.substring(2);
    if (p.length > 10) p = p.substring(p.length - 10);
    return p;
  }

  @override
  EditProfileState build() => EditProfileState.initial();

  Future<String?> changeNumberRequest({
    required String phoneNumber,
    required String type,
  }) async {
    if (state.isSendingOtp) return "OTP_ALREADY_SENDING";
    final phone10 = _onlyIndian10(phoneNumber);

    state = state.copyWith(isSendingOtp: true, clearError: true);

    final result = await apiDataSource.changeNumberRequest(
      phone: phone10,
      type: type,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isSendingOtp: false, error: failure.message);
        return failure.message;
      },
      (response) {
        state = state.copyWith(
          isSendingOtp: false,
          editNumberVerifyResponse: response,
        );
        return null; // ✅ success
      },
    );
  }

  Future<bool> changeOtpRequest({
    required String phoneNumber,
    required String type,
    required String code,
  }) async {
    if (state.isVerifyingOtp) return false;

    final phone10 = _onlyIndian10(phoneNumber);

    state = state.copyWith(isVerifyingOtp: true, clearError: true);

    final result = await apiDataSource.changeOtpRequest(
      phone: phone10,
      type: type,
      code: code,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isVerifyingOtp: false, error: failure.message);
        return false;
      },
      (response) async {
        final token = response.data?.verificationToken ?? '';
        if (token.isNotEmpty) {
          await AppPrefs.setVerificationToken(token);
        }

        state = state.copyWith(
          isVerifyingOtp: false,
          editNumberOtpResponse: response,
        );
        return response.data?.verified == true; // ✅ verified true/false
      },
    );
  }

  Future<bool> editProfile({
    required String displayName,
    required String email,
    required String gender,
    required String dateOfBirth,
    required String avatarUrl,
    required String phoneNumber,
    required String phoneVerificationToken,
  }) async {
    if (state.isVerifyingOtp) return false;

    state = state.copyWith(isVerifyingOtp: true, clearError: true);

    final result = await apiDataSource.editProfile(
      avatarUrl: avatarUrl,
      phoneNumber: phoneNumber,
      dateOfBirth: dateOfBirth,
      displayName: displayName,
      email: email,
      gender: gender,
      phoneVerificationToken: phoneVerificationToken,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isVerifyingOtp: false, error: failure.message);
        return false;
      },
      (response) async {
        final token = response.data?.verificationToken ?? '';
        if (token.isNotEmpty) {
          await AppPrefs.setVerificationToken(token);
        }

        state = state.copyWith(
          isVerifyingOtp: false,
          editProfileResponse: response,
        );

        return response.data?.verified == true;
      },
    );
  }

  void resetState() {
    state = EditProfileState.initial();
  }
}

final shopCategoryNotifierProvider =
    NotifierProvider.autoDispose<ShopNotifier, EditProfileState>(
      ShopNotifier.new,
    );
