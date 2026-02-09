import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tringo_app/Api/DataSource/api_data_source.dart';

import 'package:tringo_app/Presentation/OnBoarding/Screens/Surprise_Screens/Model/surprise_offer_response.dart';

import '../../Login Screen/Controller/login_notifier.dart';

const _unset = Object();

class SurpriseState {
  final bool isLoading;
  final String? error;
  final SurpriseStatusResponse? surpriseStatusResponse;

  const SurpriseState({
    this.isLoading = false,
    this.error,
    this.surpriseStatusResponse,
  });

  factory SurpriseState.initial() => const SurpriseState(isLoading: false);

  SurpriseState copyWith({
    bool? isLoading,
    Object? error = _unset,
    SurpriseStatusResponse? surpriseStatusResponse,
  }) {
    return SurpriseState(
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _unset) ? this.error : error as String?,
      surpriseStatusResponse:
          surpriseStatusResponse ?? this.surpriseStatusResponse,
    );
  }
}

class SurpriseNotifier extends Notifier<SurpriseState> {
  late final ApiDataSource api;

  @override
  SurpriseState build() {
    api = ref.read(apiDataSourceProvider);
    return SurpriseState.initial();
  }

  Future<void> surpriseStatusCheck({
    required double lng,
    required double lat,
    required String shopId,
    String? offerId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.surpriseStatusCheck(
      lng: lng,
      lat: lat,
      shopId: shopId,
      offerId: offerId,
    );

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (response) async {
        state = state.copyWith(
          isLoading: false,
          error: null,
          surpriseStatusResponse: response,
        );
      },
    );
  }

  Future<SurpriseStatusResponse?> surpriseClaimed({
    required double lng,
    required double lat,
    required String shopId,
    required String offerId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.surpriseClaimed(
      lng: lng,
      lat: lat,
      shopId: shopId,
      offerId: offerId,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return null;
      },
      (response) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          surpriseStatusResponse: response,
        );
        return response;
      },
    );
  }
}

final surpriseNotifierProvider =
    NotifierProvider<SurpriseNotifier, SurpriseState>(SurpriseNotifier.new);
