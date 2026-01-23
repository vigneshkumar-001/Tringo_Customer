import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_app/Api/DataSource/api_data_source.dart';
import '../../../../../Core/Utility/app_snackbar.dart';
import '../../Login Screen/Controller/login_notifier.dart';
import '../Model/wallet_history_response.dart';

class WalletState {
  final bool isLoading;
  final bool isMsgSendingLoading;
  final WalletHistoryResponse? walletHistoryResponse;

  final String? error;

  const WalletState({
    this.isLoading = true,
    this.isMsgSendingLoading = true,
    this.error,
    this.walletHistoryResponse,
  });

  factory WalletState.initial() => const WalletState();

  WalletState copyWith({
    bool? isLoading,
    bool? isMsgSendingLoading,
    String? error,
    WalletHistoryResponse? walletHistoryResponse,
  }) {
    return WalletState(
      isLoading: isLoading ?? this.isLoading,
      isMsgSendingLoading: isMsgSendingLoading ?? this.isMsgSendingLoading,
      walletHistoryResponse:
          walletHistoryResponse ?? this.walletHistoryResponse,
      error: error,
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
}

final walletNotifier = NotifierProvider<WalletNotifier, WalletState>(
  WalletNotifier.new,
);
