import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_app/Api/DataSource/api_data_source.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/fill_profile/Model/update_profile_response.dart';

import '../../Login Screen/Controller/login_notifier.dart';

class ProfileState {
  final bool isLoading;
  final String? error;
  final UserProfileData? profile;

  const ProfileState({this.isLoading = false, this.error, this.profile});

  ProfileState copyWith({
    bool? isLoading,
    String? error,
    UserProfileData? profile,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      profile: profile ?? this.profile,
    );
  }

  factory ProfileState.initial() => const ProfileState();
}

class ProfileNotifier extends Notifier<ProfileState> {
  late final ApiDataSource api;

  @override
  ProfileState build() {
    api = ref.read(apiDataSourceProvider);
    return ProfileState.initial();
  }

  Future<UserProfileResponse?> fetchProfile({
    required String displayName,
    required String email,
    required String gender,
    required String dateOfBirth,
    File? ownerImageFile, // only used if type == service
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    String customerImageUrl = '';
    final uploadResult = await api.userProfileUpload(
      imageFile: ownerImageFile!,
    );
    customerImageUrl =
        uploadResult.fold<String?>(
          (failure) => null,
          (success) => success.message,
        ) ??
        '';
    try {
      final result = await api.updateProfile(
        email: email,
        displayName: displayName,
        gender: gender,
        dateOfBirth: dateOfBirth,
        avatarUrl: customerImageUrl,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(isLoading: false, error: failure.message);
          return null;
        },
        (response) {
          state = state.copyWith(isLoading: false, profile: response.data);

          _cacheProfile(response.data);
          return response;
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
    return null;
  }

  Future<void> _cacheProfile(UserProfileData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileName', data.displayName);
    await prefs.setString('profileAvatar', data.avatarUrl ?? '');
    await prefs.setString('profilePhone', data.user.phoneNumber);
  }

  Future<void> clearProfile() async {
    state = ProfileState.initial();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profileName');
    await prefs.remove('profileAvatar');
    await prefs.remove('profilePhone');
  }
}

final profileNotifierProvider = NotifierProvider<ProfileNotifier, ProfileState>(
  () {
    return ProfileNotifier();
  },
);
