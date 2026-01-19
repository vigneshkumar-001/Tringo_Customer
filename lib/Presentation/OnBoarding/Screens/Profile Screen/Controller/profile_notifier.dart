import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../Api/DataSource/api_data_source.dart';
import '../../Login Screen/Controller/login_notifier.dart';
import '../Model/delete_response.dart';

class ProfileState {
  final bool isLoading;
  final bool isInsertLoading;
  final String? error;
  final DeleteResponse? deleteResponse;

  const ProfileState({
    this.isLoading = false,
    this.isInsertLoading = false,
    this.error,

    this.deleteResponse,
  });

  factory ProfileState.initial() => const ProfileState();

  ProfileState copyWith({
    bool? isLoading,
    bool? isInsertLoading,
    String? error,

    DeleteResponse? deleteResponse,
    bool clearError = false,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isInsertLoading: isInsertLoading ?? this.isInsertLoading,
      error: clearError ? null : (error ?? this.error),

      deleteResponse: deleteResponse ?? this.deleteResponse,
    );
  }
}

class ProfileNotifier extends Notifier<ProfileState> {
  late final ApiDataSource api;

  @override
  ProfileState build() {
    api = ref.read(apiDataSourceProvider);
    return ProfileState.initial();
  }

  Future<bool> deleteAccount() async {
    state = state.copyWith(
      isInsertLoading: true,
      deleteResponse: null,
      error: null,
    );

    final result = await api.deleteAccount();

    return result.fold(
      (failure) {
        state = state.copyWith(isInsertLoading: false, error: failure.message);
        return false;
      },
      (response) {
        state = state.copyWith(
          isInsertLoading: false,
          deleteResponse: response,
        );
        return response.status == true && response.data.deleted == true;
      },
    );
  }

  void resetState() {
    state = ProfileState.initial();
  }
}

final profileNotifier = NotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);
