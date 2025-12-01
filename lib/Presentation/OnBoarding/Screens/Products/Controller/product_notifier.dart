import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tringo_app/Api/DataSource/api_data_source.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Products/Model/product_detail_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Shop%20Screen/Model/product_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Shop%20Screen/Model/shop_details_response.dart';

import 'package:tringo_app/Presentation/OnBoarding/Screens/Shop%20Screen/Model/shops_model.dart';

import '../../Login Screen/Controller/login_notifier.dart';

// class ProductState {
//   final bool isLoading;
//   final String? error;
//   final ShopsResponse? shopsResponse;
//   final ShopDetailsResponse? shopDetailsResponse;
//
//   const ProductState({
//     this.isLoading = false,
//     this.error,
//     this.shopsResponse,
//     this.shopDetailsResponse,
//   });
//
//   factory ProductState.initial() => const ProductState();
// }
class ProductState {
  final bool isLoading;
  final String? error;
  final ProductDetailResponse? productDetailsResponse;

  const ProductState({
    this.isLoading = false,
    this.error,
    this.productDetailsResponse,
  });

  factory ProductState.initial() => const ProductState();

  ProductState copyWith({
    bool? isLoading,
    String? error,
    ProductDetailResponse? productDetailsResponse,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      productDetailsResponse:
          productDetailsResponse ?? this.productDetailsResponse,
    );
  }
}

class ProductNotifier extends Notifier<ProductState> {
  late final ApiDataSource api;

  @override
  ProductState build() {
    api = ref.read(apiDataSourceProvider);
    return ProductState.initial();
  }

  Future<void> viewAllProducts({
    required String productId,
    bool force = false,
  }) async {
    state = state.copyWith(isLoading: true, productDetailsResponse: null);

    final result = await api.viewDetailProducts(productId: productId);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, productDetailsResponse: null);
      },
      (response) {
        state = state.copyWith(
          isLoading: false,
          productDetailsResponse: response,
        );
      },
    );
  }
}

final productNotifierProvider = NotifierProvider<ProductNotifier, ProductState>(
  ProductNotifier.new,
);
