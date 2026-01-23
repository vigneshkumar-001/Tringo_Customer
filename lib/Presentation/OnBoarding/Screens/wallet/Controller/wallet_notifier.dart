import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_app/Api/DataSource/api_data_source.dart';
import '../../../../../Core/Utility/app_snackbar.dart';
import '../../Login Screen/Controller/login_notifier.dart';
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

  final String? error;

  const WalletState({
    this.isLoading = true,
    this.isMsgSendingLoading = true,
    this.error,
    this.walletHistoryResponse,
    this.uidNameResponse,
    this.sendTcoinData,
    this.withdrawRequestResponse,
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
  }) {
    return WalletState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isMsgSendingLoading: isMsgSendingLoading ?? this.isMsgSendingLoading,
      walletHistoryResponse:
          walletHistoryResponse ?? this.walletHistoryResponse,
      uidNameResponse: uidNameResponse ?? this.uidNameResponse,
      sendTcoinData: sendTcoinData ?? this.sendTcoinData,
      withdrawRequestResponse:
          withdrawRequestResponse ?? this.withdrawRequestResponse,
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

  Future<void> walletHistory({String counts = "ALL"}) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.walletHistory();

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

  Future<void> fetchUidPersonName(String uid) async {
    state = state.copyWith(isLoading: true, error: null);

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

    final result = await api.uIDSendApi(tcoin: tcoin, toUid: toUid);

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
}

final walletNotifier = NotifierProvider<WalletNotifier, WalletState>(
  WalletNotifier.new,
);
