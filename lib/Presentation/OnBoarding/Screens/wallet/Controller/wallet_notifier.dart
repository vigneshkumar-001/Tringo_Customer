import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_app/Api/DataSource/api_data_source.dart';
import '../../../../../Core/Utility/app_snackbar.dart';
import '../../Login Screen/Controller/login_notifier.dart';
import '../Model/referral_history_response.dart';
import '../Model/review_create_response.dart';
import '../Model/review_history_response.dart';
import '../Model/send_tcoin_response.dart';
import '../Model/uid_name_response.dart';
import '../Model/wallet_history_response.dart';
import '../Model/withdraw_request_response.dart';

class WalletState {
  final bool isLoading;
  final bool isMsgSendingLoading;
  final WalletHistoryResponse? walletHistoryResponse;
  final UidNameResponse? uidNameResponse;
  final SendTcoinData? sendTcoinData;
  final WithdrawRequestResponse? withdrawRequestResponse;
  final ReferralHistoryResponse? referralHistoryResponse;
  final ReviewHistoryResponse? reviewHistoryResponse;
  final ReviewCreateResponse? reviewCreateResponse;

  final String? error;

  const WalletState({
    this.isLoading = false,
    this.isMsgSendingLoading = false,
    this.error,
    this.walletHistoryResponse,
    this.uidNameResponse,
    this.sendTcoinData,
    this.withdrawRequestResponse,
    this.referralHistoryResponse,
    this.reviewHistoryResponse,
    this.reviewCreateResponse,
  });

  factory WalletState.initial() => const WalletState();

  WalletState copyWith({
    bool? isLoading,
    bool? isMsgSendingLoading,
    String? error,
    WalletHistoryResponse? walletHistoryResponse,
    UidNameResponse? uidNameResponse,
    SendTcoinData? sendTcoinData,
    WithdrawRequestResponse? withdrawRequestResponse,
    ReferralHistoryResponse? referralHistoryResponse,
    ReviewHistoryResponse? reviewHistoryResponse,
    ReviewCreateResponse? reviewCreateResponse,
  }) {
    return WalletState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isMsgSendingLoading: isMsgSendingLoading ?? this.isMsgSendingLoading,
      walletHistoryResponse:
          walletHistoryResponse ?? this.walletHistoryResponse,
      uidNameResponse: uidNameResponse ?? this.uidNameResponse,
      sendTcoinData: sendTcoinData ?? this.sendTcoinData,
      withdrawRequestResponse:
          withdrawRequestResponse ?? this.withdrawRequestResponse,
      referralHistoryResponse:
          referralHistoryResponse ?? this.referralHistoryResponse,
      reviewHistoryResponse:
          reviewHistoryResponse ?? this.reviewHistoryResponse,
      reviewCreateResponse: reviewCreateResponse ?? this.reviewCreateResponse,
    );
  }
}

class WalletNotifier extends Notifier<WalletState> {
  late final ApiDataSource api;

  @override
  WalletState build() {
    api = ref.read(apiDataSourceProvider);
    return WalletState.initial();
  }

  Future<void> walletHistory({String type = "ALL"}) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.walletHistory(type: type);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (response) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          walletHistoryResponse: response,
        );
      },
    );
  }

  Future<void> fetchUidPersonName(String uid ,{bool load = true}) async {
    state = state.copyWith(isLoading: load, error: null);

    final result = await api.uIDPersonName(uid: uid);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (response) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          uidNameResponse: response,
        );
      },
    );
  }

  Future<void> uIDSendApi({
    required String toUid,
    required String tcoin,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.uIDSendApi( tCoin : tcoin, toUid: toUid);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (resp) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          sendTcoinData: resp.data, // ✅ store only inner data
        );
      },
    );
  }

  Future<void> uIDWithRawApi({
    required String upiId,
    required String tcoin,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.uIDWithRawApi(tcoin: tcoin, upiId: upiId);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (resp) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          withdrawRequestResponse: resp, // ✅ WithdrawRequestData
        );
      },
    );
  }

  Future<void> referralHistory() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.referralHistory();

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (response) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          referralHistoryResponse: response,
        );
      },
    );
  }

  Future<void> reviewHistory() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.reviewHistory();

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (response) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          reviewHistoryResponse: response,
        );
      },
    );
  }

  Future<void> reviewCreate({
    required String shopId,
    required int rating,
    required String heading,
    required String comment,
  }) async {
    state = state.copyWith(isMsgSendingLoading: true, error: null);

    final result = await api.reviewCreate(
      shopId: shopId,
      rating: rating,
      heading: heading,
      comment: comment,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isMsgSendingLoading: false,
          error: failure.message,
        );
      },
      (response) {
        state = state.copyWith(
          isMsgSendingLoading: false,
          error: null,
          reviewCreateResponse: response,
        );
      },
    );
  }
}

final walletNotifier = NotifierProvider<WalletNotifier, WalletState>(
  WalletNotifier.new,
);
