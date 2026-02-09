import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tringo_app/Api/DataSource/api_data_source.dart';
import 'package:tringo_app/Core/Const/app_logger.dart';
import 'package:tringo_app/Core/Utility/app_prefs.dart';
import 'package:tringo_app/Core/Utility/app_snackbar.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Home%20Screen/Model/advertisement_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Home%20Screen/Model/enquiry_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Home%20Screen/Model/home_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Home%20Screen/Model/mark_enquiry.dart';

import '../../Login Screen/Controller/login_notifier.dart';

class homeState {
  final bool isLoading;
  final bool isEnquiryLoading;
  final bool isAdsLoading;
  final String? error;
  final String? activeEnquiryId;
  final MarkEnquiry? markEnquiry;
  final HomeResponse? homeResponse;
  final EnquiryResponse? enquiryResponse;
  final AdvertisementResponse? advertisementResponse;

  const homeState({
    this.isLoading = true,
    this.isEnquiryLoading = false,
    this.isAdsLoading = false,
    this.markEnquiry,
    this.error,
    this.homeResponse,
    this.enquiryResponse,
    this.activeEnquiryId,
    this.advertisementResponse,
  });

  factory homeState.initial() => const homeState();

  homeState copyWith({
    bool? isLoading,
    bool? isAdsLoading,
    String? activeEnquiryId,
    MarkEnquiry? markEnquiry,
    bool? isEnquiryLoading,
    String? error,
    HomeResponse? homeResponse,
    AdvertisementResponse? advertisementResponse,
    EnquiryResponse? enquiryResponse,
  }) {
    return homeState(
      isLoading: isLoading ?? this.isLoading,
      isEnquiryLoading: isEnquiryLoading ?? this.isEnquiryLoading,
      isAdsLoading: isAdsLoading ?? this.isAdsLoading,
      markEnquiry: markEnquiry ?? this.markEnquiry,
      // when we call copyWith we usually want to override error explicitly
      error: error,
      // keep existing homeResponse unless explicitly replaced
      homeResponse: homeResponse ?? this.homeResponse,
      // keep existing enquiryResponse unless explicitly replaced
      enquiryResponse: enquiryResponse ?? this.enquiryResponse,
      advertisementResponse:
          advertisementResponse ?? this.advertisementResponse,
      activeEnquiryId: activeEnquiryId ?? this.activeEnquiryId,
      // activeEnquiryId: activeEnquiryId,
    );
  }
}

class HomeNotifier extends Notifier<homeState> {
  late final ApiDataSource api;

  @override
  homeState build() {
    api = ref.read(apiDataSourceProvider);
    return homeState.initial();
  }

  Future<void> fetchHomeDetails({
    required double lng,
    required double lat,
  }) async {
    // keep old enquiryResponse if any, just show loading and clear error
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.getHomeDetails(lng: lng, lat: lat);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          // homeResponse stays as it was (probably null on first load)
        );
      },
      (response) async {
        final bool profileCompleteFromApi =
            response.data.user.profileComplete ?? false;

        // Update SharedPreferences – this is the whole point
        await AppPrefs.setIsProfileCompleted(profileCompleteFromApi);
        final profile = await AppPrefs.getIsProfileComplete();
        AppLogger.log.i(profile);
        state = state.copyWith(
          isLoading: false,
          error: null,
          homeResponse: response,
        );
      },
    );
  }

  Future<void> putEnquiry({
    required String serviceId,
    required String productId,
    required String message,
    required String shopId,
    required BuildContext context,
  }) async {
    // 🔹 IMPORTANT: do NOT drop homeResponse
    state = state.copyWith(
      isEnquiryLoading: true,
      error: null,
      activeEnquiryId: shopId,
    );

    final result = await api.putEnquiry(
      serviceId: serviceId,
      productId: productId,
      message: message,
      shopId: shopId,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isEnquiryLoading: false,
          activeEnquiryId: null,
          error: failure.message,
          // homeResponse is preserved
        );
        AppSnackBar.error(context, failure.message);
      },
      (response) {
        state = state.copyWith(
          isEnquiryLoading: false,
          error: null,
          activeEnquiryId: null,
          enquiryResponse: response,
          // homeResponse still preserved
        );
        AppSnackBar.success(context, response.data.message);
      },
    );
  }

  Future<void> advertisements({
    required String placement,
    required double lat,
    required double lang,
  }) async {
    state = state.copyWith(isAdsLoading: true, error: null);

    final result = await api.advertisements(
      placement: placement,
      lat: lat,
      lang: lang,
    );

    result.fold(
      (failure) => state = state.copyWith(
        isAdsLoading: false,
        error: failure.message,
        advertisementResponse: null,
      ),
      (response) => state = state.copyWith(
        isAdsLoading: false,
        error: null,
        advertisementResponse: response,
      ),
    );
  }

  Future<void> markCallOrLocation({
    required String type,
    required String shopId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.markCallOrMapEnquiry(type: type, shopId: shopId);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
        markEnquiry: null,
      ),
      (response) => state = state.copyWith(
        isLoading: false,
        error: null,
        markEnquiry: response,
      ),
    );
  }
}

final homeNotifierProvider = NotifierProvider<HomeNotifier, homeState>(
  HomeNotifier.new,
);

// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import 'package:tringo_app/Api/DataSource/api_data_source.dart';
// import 'package:tringo_app/Presentation/OnBoarding/Screens/Home%20Screen/Model/enquiry_response.dart';
// import 'package:tringo_app/Presentation/OnBoarding/Screens/Home%20Screen/Model/home_response.dart';
//
// import '../../Login Screen/Controller/login_notifier.dart';
//
// class homeState {
//   final bool isLoading;
//   final bool isEnquiryLoading;
//   final String? error;
//   final HomeResponse? homeResponse;
//   final EnquiryResponse? enquiryResponse;
//
//   const homeState({
//     this.isLoading = false,
//     this.error,
//     this.homeResponse,
//     this. enquiryResponse ,
//     this.isEnquiryLoading = false,
//   });
//
//   factory homeState.initial() => const homeState();
// }
//
// class HomeNotifier extends Notifier<homeState> {
//   late final ApiDataSource api;
//
//   @override
//   homeState build() {
//     api = ref.read(apiDataSourceProvider);
//     return homeState.initial();
//   }
//
//   Future<void> fetchHomeDetails() async {
//     state = const homeState(isLoading: true);
//
//     final result = await api.getHomeDetails();
//
//     result.fold(
//       (failure) => state = homeState(isLoading: false, error: failure.message),
//       (response) => state = homeState(isLoading: false, homeResponse: response),
//     );
//   }
//
//   Future<void> putEnquiry({
//     required String serviceId,
//     required String productId,
//     required String message,
//     required String shopId,
//   }) async {
//     state = const homeState(isEnquiryLoading: true);
//
//     final result = await api.putEnquiry(
//       serviceId: serviceId,
//       productId: productId,
//       message: message,
//       shopId: shopId,
//     );
//
//     result.fold(
//       (failure) =>
//           state = homeState(isEnquiryLoading: false, error: failure.message),
//       (response) =>
//           state = homeState(isEnquiryLoading: false, enquiryResponse: response),
//     );
//   }
// }
//
// final homeNotifierProvider = NotifierProvider<HomeNotifier, homeState>(
//   HomeNotifier.new,
// );
