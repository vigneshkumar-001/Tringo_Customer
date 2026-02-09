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

  /// ✅ ONLY for HOME API error
  final String? error;

  /// ✅ enquiry error only
  final String? enquiryError;

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
    this.enquiryError,
    this.homeResponse,
    this.enquiryResponse,
    this.activeEnquiryId,
    this.advertisementResponse,
  });

  factory homeState.initial() => const homeState();

  homeState copyWith({
    bool? isLoading,
    bool? isAdsLoading,
    bool? isEnquiryLoading,
    String? activeEnquiryId,

    MarkEnquiry? markEnquiry,

    /// keep same behavior: pass error explicitly when needed
    String? error,
    String? enquiryError,

    HomeResponse? homeResponse,
    EnquiryResponse? enquiryResponse,
    AdvertisementResponse? advertisementResponse,
  }) {
    return homeState(
      isLoading: isLoading ?? this.isLoading,
      isEnquiryLoading: isEnquiryLoading ?? this.isEnquiryLoading,
      isAdsLoading: isAdsLoading ?? this.isAdsLoading,

      markEnquiry: markEnquiry ?? this.markEnquiry,

      error: error,
      enquiryError: enquiryError,

      homeResponse: homeResponse ?? this.homeResponse,
      enquiryResponse: enquiryResponse ?? this.enquiryResponse,
      advertisementResponse:
          advertisementResponse ?? this.advertisementResponse,

      activeEnquiryId: activeEnquiryId ?? this.activeEnquiryId,
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

  /// ✅ HOME API ONLY controls `error`
  Future<void> fetchHomeDetails({
    required double lng,
    required double lat,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await api.getHomeDetails(lng: lng, lat: lat);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message, // ✅ home error only
        );
      },
      (response) async {
        final bool profileCompleteFromApi =
            response.data.user.profileComplete ?? false;

        await AppPrefs.setIsProfileCompleted(profileCompleteFromApi);

        state = state.copyWith(
          isLoading: false,
          error: null,
          homeResponse: response,
        );
      },
    );
  }

  Future<bool> putEnquiry({
    required String serviceId,
    required String productId,
    required String message,
    required String shopId,
    required BuildContext context,
  }) async {
    state = state.copyWith(
      isEnquiryLoading: true,
      enquiryError: null,
      activeEnquiryId: shopId,
      error: state.error, // keep home error unchanged
    );

    final result = await api.putEnquiry(
      serviceId: serviceId,
      productId: productId,
      message: message,
      shopId: shopId,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isEnquiryLoading: false,
          activeEnquiryId: null,
          enquiryError: failure.message, // ✅ API failure message
          error: state.error,
        );
        AppSnackBar.error(context, failure.message); // ✅ API msg only
        return false; // ✅ do NOT disable
      },
      (response) {
        state = state.copyWith(
          isEnquiryLoading: false,
          enquiryError: null,
          activeEnquiryId: null,
          enquiryResponse: response,
          error: state.error,
        );

        // ✅ success msg from API
        AppSnackBar.success(context, response.data.message);
        return true; // ✅ success -> disable
      },
    );
  }

  /// ✅ Ads must NOT set `error` (because it triggers NoData logic)
  Future<void> advertisements({
    required String placement,
    required double lat,
    required double lang,
  }) async {
    state = state.copyWith(isAdsLoading: true, error: state.error);

    final result = await api.advertisements(
      placement: placement,
      lat: lat,
      lang: lang,
    );

    result.fold(
      (failure) {
        // ❌ do not set state.error
        state = state.copyWith(
          isAdsLoading: false,
          advertisementResponse: null,
          error: state.error,
        );
      },
      (response) {
        state = state.copyWith(
          isAdsLoading: false,
          advertisementResponse: response,
          error: state.error,
        );
      },
    );
  }

  /// ✅ Mark call/map must NOT set `error` OR isLoading (avoid whole screen logic)
  Future<void> markCallOrLocation({
    required String type,
    required String shopId,
  }) async {
    final result = await api.markCallOrMapEnquiry(type: type, shopId: shopId);

    result.fold(
      (failure) {
        // keep silent or log only
        AppLogger.log.e(failure.message);
      },
      (response) {
        state = state.copyWith(markEnquiry: response, error: state.error);
      },
    );
  }
}

final homeNotifierProvider = NotifierProvider<HomeNotifier, homeState>(
  HomeNotifier.new,
);

//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import 'package:tringo_app/Api/DataSource/api_data_source.dart';
// import 'package:tringo_app/Core/Const/app_logger.dart';
// import 'package:tringo_app/Core/Utility/app_prefs.dart';
// import 'package:tringo_app/Core/Utility/app_snackbar.dart';
// import 'package:tringo_app/Presentation/OnBoarding/Screens/Home%20Screen/Model/advertisement_response.dart';
// import 'package:tringo_app/Presentation/OnBoarding/Screens/Home%20Screen/Model/enquiry_response.dart';
// import 'package:tringo_app/Presentation/OnBoarding/Screens/Home%20Screen/Model/home_response.dart';
// import 'package:tringo_app/Presentation/OnBoarding/Screens/Home%20Screen/Model/mark_enquiry.dart';
//
// import '../../Login Screen/Controller/login_notifier.dart';
//
// class homeState {
//   final bool isLoading;
//   final bool isEnquiryLoading;
//   final bool isAdsLoading;
//   final String? error;
//   final String? enquiryError;
//   final String? activeEnquiryId;
//   final MarkEnquiry? markEnquiry;
//   final HomeResponse? homeResponse;
//   final EnquiryResponse? enquiryResponse;
//   final AdvertisementResponse? advertisementResponse;
//
//   const homeState({
//     this.isLoading = true,
//     this.isEnquiryLoading = false,
//     this.isAdsLoading = false,
//     this.markEnquiry,
//     this.error,
//     this.enquiryError,
//     this.homeResponse,
//     this.enquiryResponse,
//     this.activeEnquiryId,
//     this.advertisementResponse,
//   });
//
//   factory homeState.initial() => const homeState();
//
//   homeState copyWith({
//     bool? isLoading,
//     bool? isAdsLoading,
//     String? activeEnquiryId,
//     MarkEnquiry? markEnquiry,
//     bool? isEnquiryLoading,
//     String? error,
//     String? enquiryError,
//     HomeResponse? homeResponse,
//     AdvertisementResponse? advertisementResponse,
//     EnquiryResponse? enquiryResponse,
//   }) {
//     return homeState(
//       isLoading: isLoading ?? this.isLoading,
//       isEnquiryLoading: isEnquiryLoading ?? this.isEnquiryLoading,
//       isAdsLoading: isAdsLoading ?? this.isAdsLoading,
//       markEnquiry: markEnquiry ?? this.markEnquiry,
//       // when we call copyWith we usually want to override error explicitly
//       error: error,
//       enquiryError: enquiryError,
//       // keep existing homeResponse unless explicitly replaced
//       homeResponse: homeResponse ?? this.homeResponse,
//       // keep existing enquiryResponse unless explicitly replaced
//       enquiryResponse: enquiryResponse ?? this.enquiryResponse,
//       advertisementResponse:
//           advertisementResponse ?? this.advertisementResponse,
//       activeEnquiryId: activeEnquiryId ?? this.activeEnquiryId,
//       // activeEnquiryId: activeEnquiryId,
//     );
//   }
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
//   Future<void> fetchHomeDetails({
//     required double lng,
//     required double lat,
//   }) async {
//     // keep old enquiryResponse if any, just show loading and clear error
//     state = state.copyWith(isLoading: true, error: null);
//
//     final result = await api.getHomeDetails(lng: lng, lat: lat);
//
//     result.fold(
//       (failure) {
//         state = state.copyWith(
//           isLoading: false,
//           error: failure.message,
//           // homeResponse stays as it was (probably null on first load)
//         );
//       },
//       (response) async {
//         final bool profileCompleteFromApi =
//             response.data.user.profileComplete ?? false;
//
//         // Update SharedPreferences – this is the whole point
//         await AppPrefs.setIsProfileCompleted(profileCompleteFromApi);
//         final profile = await AppPrefs.getIsProfileComplete();
//         AppLogger.log.i(profile);
//         state = state.copyWith(
//           isLoading: false,
//           error: null,
//           homeResponse: response,
//         );
//       },
//     );
//   }
//
//   Future<void> putEnquiry({
//     required String serviceId,
//     required String productId,
//     required String message,
//     required String shopId,
//     required BuildContext context,
//   }) async {
//     // 🔹 IMPORTANT: do NOT drop homeResponse
//     state = state.copyWith(
//       isEnquiryLoading: true,
//       enquiryError: null,
//       activeEnquiryId: shopId,
//     );
//
//     final result = await api.putEnquiry(
//       serviceId: serviceId,
//       productId: productId,
//       message: message,
//       shopId: shopId,
//     );
//
//     result.fold(
//       (failure) {
//         state = state.copyWith(
//           isEnquiryLoading: false,
//           activeEnquiryId: null,
//           enquiryError: failure.message,
//           // homeResponse is preserved
//         );
//         AppSnackBar.error(context, failure.message);
//       },
//       (response) {
//         state = state.copyWith(
//           isEnquiryLoading: false,
//           enquiryError: null,
//           activeEnquiryId: null,
//           enquiryResponse: response,
//           // homeResponse still preserved
//         );
//         AppSnackBar.success(context, response.data.message);
//       },
//     );
//   }
//
//   Future<void> advertisements({
//     required String placement,
//     required double lat,
//     required double lang,
//   }) async {
//     state = state.copyWith(isAdsLoading: true, error: null);
//
//     final result = await api.advertisements(
//       placement: placement,
//       lat: lat,
//       lang: lang,
//     );
//
//     result.fold(
//       (failure) => state = state.copyWith(
//         isAdsLoading: false,
//         error: failure.message,
//         advertisementResponse: null,
//       ),
//       (response) => state = state.copyWith(
//         isAdsLoading: false,
//         error: null,
//         advertisementResponse: response,
//       ),
//     );
//   }
//
//   Future<void> markCallOrLocation({
//     required String type,
//     required String shopId,
//   }) async {
//     state = state.copyWith(isLoading: true, error: null);
//
//     final result = await api.markCallOrMapEnquiry(type: type, shopId: shopId);
//
//     result.fold(
//       (failure) => state = state.copyWith(
//         isLoading: false,
//         error: failure.message,
//         markEnquiry: null,
//       ),
//       (response) => state = state.copyWith(
//         isLoading: false,
//         error: null,
//         markEnquiry: response,
//       ),
//     );
//   }
// }
//
// final homeNotifierProvider = NotifierProvider<HomeNotifier, homeState>(
//   HomeNotifier.new,
// );
