import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tringo_app/Api/DataSource/api_data_source.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Shop%20Screen/Model/product_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Shop%20Screen/Model/shop_details_response.dart';

import 'package:tringo_app/Presentation/OnBoarding/Screens/Shop%20Screen/Model/shops_model.dart';

import '../../Login Screen/Controller/login_notifier.dart';

// class ShopsState {
//   final bool isLoading;
//   final String? error;
//   final ShopsResponse? shopsResponse;
//   final ShopDetailsResponse? shopDetailsResponse;
//
//   const ShopsState({
//     this.isLoading = false,
//     this.error,
//     this.shopsResponse,
//     this.shopDetailsResponse,
//   });
//
//   factory ShopsState.initial() => const ShopsState();
// }
class ShopsState {
  final bool isLoading;
  final String? error;
  final ShopsResponse? shopsResponse;
  final ShopDetailsResponse? shopDetailsResponse;
  final ProductResponse? productResponse;

  const ShopsState({
    this.isLoading = false,
    this.error,
    this.shopsResponse,
    this.productResponse,
    this.shopDetailsResponse,
  });

  factory ShopsState.initial() => const ShopsState();

  ShopsState copyWith({
    bool? isLoading,
    String? error,
    ShopsResponse? shopsResponse,
    ShopDetailsResponse? shopDetailsResponse,
    ProductResponse? productResponse,
  }) {
    return ShopsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      shopsResponse: shopsResponse ?? this.shopsResponse,
      shopDetailsResponse: shopDetailsResponse ?? this.shopDetailsResponse,
      productResponse: productResponse ?? this.productResponse,
    );
  }
}

class ShopsNotifier extends Notifier<ShopsState> {
  late final ApiDataSource api;

  @override
  ShopsState build() {
    api = ref.read(apiDataSourceProvider);
    return ShopsState.initial();
  }

  Future<void> fetchShopsDetails({bool force = false}) async {
    if (!force && state.shopsResponse != null) return;

    state = state.copyWith(isLoading: true);

    final result = await api.getShopDetails();

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (response) {
        state = state.copyWith(isLoading: false, shopsResponse: response);
      },
    );
  }

  Future<void> showSpecificShopDetails({
    required String shopId,
    bool force = false,
  }) async {
    state = state.copyWith(isLoading: true, shopDetailsResponse: null);

    final result = await api.getSpecificDetails(shopId: shopId);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, shopDetailsResponse: null);
      },
      (response) {
        state = state.copyWith(isLoading: false, shopDetailsResponse: response);
      },
    );
  }

  Future<void> viewAllProducts({
    required String shopId,
    bool force = false,
  }) async {
    state = state.copyWith(isLoading: true, productResponse: null);

    final result = await api.viewAllProducts(shopId: shopId);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, productResponse: null);
      },
      (response) {
        state = state.copyWith(isLoading: false, productResponse: response);
      },
    );
  }
}

final shopsNotifierProvider = NotifierProvider<ShopsNotifier, ShopsState>(
  ShopsNotifier.new,
);

/// 🔥 NEW: Per-shop FutureProvider used by ServiceSingleCompanyList
final shopProductsProvider =
FutureProvider.family<ProductResponse, String>((ref, String shopId) async {
  final api = ref.watch(apiDataSourceProvider);

  final result = await api.viewAllProducts(shopId: shopId);

  return result.fold(
        (failure) => throw Exception(failure.message),
        (response) => response,
  );
});





