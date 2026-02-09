import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_app/Api/DataSource/api_data_source.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Home%20Screen/Model/nearby_map_response.dart';

import '../../Login Screen/Controller/login_notifier.dart';

class NearbyShopMapState {
  final bool isLoading;
  final String? error;
  final NearbyMapResponse? nearbyResponse;

  const NearbyShopMapState({
    this.isLoading = false,
    this.error,
    this.nearbyResponse,
  });

  factory NearbyShopMapState.initial() =>
      const NearbyShopMapState(isLoading: false);

  NearbyShopMapState copyWith({
    bool? isLoading,
    String? error, // set null to clear
    NearbyMapResponse? nearbyResponse,
  }) {
    return NearbyShopMapState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      nearbyResponse: nearbyResponse ?? this.nearbyResponse,
    );
  }
}

class NearbyShopMapNotifier extends Notifier<NearbyShopMapState> {
  late final ApiDataSource api;

  @override
  NearbyShopMapState build() {
    api = ref.read(apiDataSourceProvider);
    return NearbyShopMapState.initial();
  }

  /// GET:
  /// {{base_url}}/api/v1/public/shops/{{shopId}}/nearby?lat=0.0&lng=0.0
  Future<void> fetchNearbyShops({
    required String shopId,
    required double lat,
    required double lng,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.getNearbyShops(shopId: shopId, lat: lat, lng: lng);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          // keep old nearbyResponse unless you want to clear it:
          // nearbyResponse: null,
        );
      },
      (response) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          nearbyResponse: response,
        );
      },
    );
  }

  void clearNearby() {
    state = state.copyWith(error: null, nearbyResponse: null, isLoading: false);
  }
}

/// Provider
final nearbyNotifierProvider =
    NotifierProvider<NearbyShopMapNotifier, NearbyShopMapState>(
      NearbyShopMapNotifier.new,
    );
