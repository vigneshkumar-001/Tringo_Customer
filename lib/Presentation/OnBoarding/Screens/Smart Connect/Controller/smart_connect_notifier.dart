import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tringo_app/Api/DataSource/api_data_source.dart';

import 'package:tringo_app/Core/Utility/app_prefs.dart';

import 'package:tringo_app/Presentation/OnBoarding/Screens/Home%20Screen/Model/mark_enquiry.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Smart%20Connect/Model/smart_connect_create_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Smart%20Connect/Model/smart_connect_details_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Smart%20Connect/Model/smart_connect_history_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Smart%20Connect/Model/smart_connect_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Smart%20Connect/Model/smart_connect_search_response.dart';

import '../../Login Screen/Controller/login_notifier.dart';

class SmartConnectState {
  final bool isLoading;
  final bool isSearchLoading;

  final String? error;

  final SmartConnectResponse? smartConnectResponse;
  final SmartConnectSearchResponse? smartConnectSearchResponse;
  final SmartConnectCreateResponse? smartConnectCreateResponse;
  final SmartConnectHistoryResponse? smartConnectHistoryResponse;
  final SmartConnectDetailsResponse? smartConnectDetailsResponse;

  const SmartConnectState({
    this.isLoading = false,
    this.isSearchLoading = false,

    this.smartConnectResponse,
    this.smartConnectSearchResponse,
    this.smartConnectCreateResponse,
    this.smartConnectHistoryResponse,
    this.smartConnectDetailsResponse,
    this.error,
  });

  factory SmartConnectState.initial() => const SmartConnectState();

  SmartConnectState copyWith({
    bool? isLoading,
    bool? isSearchLoading,

    SmartConnectResponse? smartConnectResponse,
    SmartConnectSearchResponse? smartConnectSearchResponse,
    SmartConnectCreateResponse? smartConnectCreateResponse,
    SmartConnectHistoryResponse? smartConnectHistoryResponse,
    SmartConnectDetailsResponse? smartConnectDetailsResponse,

    /// keep same behavior: pass error explicitly when needed
    String? error,
  }) {
    return SmartConnectState(
      isLoading: isLoading ?? this.isLoading,
      isSearchLoading: isSearchLoading ?? this.isSearchLoading,
      smartConnectDetailsResponse:
          smartConnectDetailsResponse ?? this.smartConnectDetailsResponse,
      smartConnectCreateResponse:
          smartConnectCreateResponse ?? this.smartConnectCreateResponse,

      smartConnectResponse: smartConnectResponse ?? this.smartConnectResponse,
      smartConnectHistoryResponse:
          smartConnectHistoryResponse ?? this.smartConnectHistoryResponse,
      smartConnectSearchResponse:
          smartConnectSearchResponse ?? this.smartConnectSearchResponse,

      error: error,
    );
  }
}

class SmartConnectNotifier extends Notifier<SmartConnectState> {
  late final ApiDataSource api;

  @override
  SmartConnectState build() {
    api = ref.read(apiDataSourceProvider);
    return SmartConnectState.initial();
  }

  Future<void> fetchSmartConnectGuide() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.getSmartConnectGuide();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message, // ✅ home error only
        );
      },
      (response) async {
        state = state.copyWith(
          isLoading: false,
          error: null,
          smartConnectResponse: response,
        );
      },
    );
  }

  Future<void> fetchSmartConnectHistory({
    required int page,
    required int limit,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.getSmartConnectHistory(page: page, limit: limit);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message, // ✅ home error only
        );
      },
      (response) async {
        state = state.copyWith(
          isLoading: false,
          error: null,
          smartConnectHistoryResponse: response,
        );
      },
    );
  }


  Future<void> fetchSmartConnectDetails({
    required String requestId,

  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.getSmartConnectDetails( requestId: requestId );

    result.fold(
          (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message, // ✅ home error only
        );
      },
          (response) async {
        state = state.copyWith(
          isLoading: false,
          error: null,
           smartConnectDetailsResponse : response,
        );
      },
    );
  }

  Future<String?> createSmartConnect({
    required String listingId,
    required String listingType,
    required String shopId,
    required String description,
    required List<Map<String, String>> attachments,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.createSmartConnect(
      listingId: listingId,
      listingType: listingType,
      shopId: shopId,
      description: description,
      attachments: attachments,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return failure.message;
      },
      (response) async {
        state = state.copyWith(
          isLoading: false,
          error: null,
          smartConnectCreateResponse: response,
        );
        return null;
      },
    );
  }

  Future<void> fetchSmartConnectSearch({required String search}) async {
    state = state.copyWith(isSearchLoading: true, error: null);

    final result = await api.getSmartConnectSearch(search: search);

    result.fold(
      (failure) {
        state = state.copyWith(isSearchLoading: false, error: failure.message);
      },
      (response) async {
        state = state.copyWith(
          isSearchLoading: false,
          error: null,
          smartConnectSearchResponse: response,
        );
      },
    );
  }
}

final smartConnectNotifierProvider =
    NotifierProvider<SmartConnectNotifier, SmartConnectState>(
      SmartConnectNotifier.new,
    );
