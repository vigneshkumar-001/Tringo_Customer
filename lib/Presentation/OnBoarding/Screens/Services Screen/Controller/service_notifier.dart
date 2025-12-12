import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tringo_app/Api/DataSource/api_data_source.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Services%20Screen/Models/service_details_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Services%20Screen/Models/service_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Services%20Screen/Models/services_list_response.dart';

// These seem unused here but if other screens use them you can keep
import 'package:tringo_app/Presentation/OnBoarding/Screens/Shop%20Screen/Model/product_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Shop%20Screen/Model/shop_details_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Shop%20Screen/Model/shops_model.dart';

import '../../Login Screen/Controller/login_notifier.dart';

class ServiceState {
  final bool isLoading;
  final String? error;
  final ServiceResponse? serviceResponse;
  final ServiceDetailsResponse? serviceDetailsResponse;
  final ServicesListResponse? servicesListResponse;

  const ServiceState({
    this.isLoading = false,
    this.error,
    this.serviceResponse,
    this.serviceDetailsResponse,
    this.servicesListResponse,
  });

  factory ServiceState.initial() => const ServiceState();

  ServiceState copyWith({
    bool? isLoading,
    String? error,
    ServiceResponse? serviceResponse,
    ServiceDetailsResponse? serviceDetailsResponse,
    ServicesListResponse? servicesListResponse,
  }) {
    return ServiceState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      serviceResponse: serviceResponse ?? this.serviceResponse,
      servicesListResponse: servicesListResponse ?? this.servicesListResponse,
      serviceDetailsResponse:
      serviceDetailsResponse ?? this.serviceDetailsResponse,
    );
  }
}

class ServiceNotifier extends Notifier<ServiceState> {
  late final ApiDataSource api;

  @override
  ServiceState build() {
    api = ref.read(apiDataSourceProvider);
    return ServiceState.initial();
  }

  Future<void> fetchServiceDetails({bool force = false,required String highlightId}) async {
    if (!force && state.serviceResponse != null) return;

    state = state.copyWith(isLoading: true);

    final result = await api.getServiceDetails(highlightId: highlightId);

    result.fold(
          (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
          (response) {
        state = state.copyWith(isLoading: false, serviceResponse: response);
      },
    );
  }

  Future<void> showSpecificServiceDetails({
    required String shopId,
    bool force = false,
  }) async {
    state = state.copyWith(isLoading: true, serviceDetailsResponse: null);

    final result = await api.getServiceSpecificDetails(shopId: shopId);

    result.fold(
          (failure) {
        state = state.copyWith(isLoading: false, serviceDetailsResponse: null);
      },
          (response) {
        state = state.copyWith(
          isLoading: false,
          serviceDetailsResponse: response,
        );
      },
    );
  }

  // You can keep this for other screens if they use it
  Future<void> viewAllServices({
    required String shopId,
    bool force = false,
  }) async {
    state = ServiceState(isLoading: true, servicesListResponse: null);

    final result = await api.viewAllServices(shopId: shopId);

    result.fold(
          (failure) {
        state = ServiceState(isLoading: false, servicesListResponse: null);
      },
          (response) {
        state = ServiceState(isLoading: false, servicesListResponse: response);
      },
    );
  }
}

// 🔹 Old-style global Notifier (can still be used by other screens)
final serviceNotifierProvider = NotifierProvider<ServiceNotifier, ServiceState>(
  ServiceNotifier.new,
);

/// 🔥 NEW: Per-shop FutureProvider used by ServiceSingleCompanyList
final shopServicesProvider =
FutureProvider.family<ServicesListResponse, String>((ref, String shopId) async {
  final api = ref.watch(apiDataSourceProvider);

  final result = await api.viewAllServices(shopId: shopId);

  return result.fold(
        (failure) => throw Exception(failure.message),
        (response) => response,
  );
});




// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import 'package:tringo_app/Api/DataSource/api_data_source.dart';
// import 'package:tringo_app/Presentation/OnBoarding/Screens/Services%20Screen/Models/service_details_response.dart';
// import 'package:tringo_app/Presentation/OnBoarding/Screens/Services%20Screen/Models/service_response.dart';
// import 'package:tringo_app/Presentation/OnBoarding/Screens/Services%20Screen/Models/services_list_response.dart';
// import 'package:tringo_app/Presentation/OnBoarding/Screens/Shop%20Screen/Model/product_detail_response.dart';
// import 'package:tringo_app/Presentation/OnBoarding/Screens/Shop%20Screen/Model/shop_details_response.dart';
//
// import 'package:tringo_app/Presentation/OnBoarding/Screens/Shop%20Screen/Model/shops_model.dart';
//
// import '../../Login Screen/Controller/login_notifier.dart';
//
// class ServiceState {
//   final bool isLoading;
//   final String? error;
//   final ServiceResponse? serviceResponse;
//   final ServiceDetailsResponse? serviceDetailsResponse;
//   final ServicesListResponse? servicesListResponse;
//
//   const ServiceState({
//     this.isLoading = false,
//     this.error,
//     this.serviceResponse,
//     this.serviceDetailsResponse,
//     this.servicesListResponse,
//   });
//
//   factory ServiceState.initial() => const ServiceState();
//
//   ServiceState copyWith({
//     bool? isLoading,
//     String? error,
//     ServiceResponse? serviceResponse,
//     ServiceDetailsResponse? serviceDetailsResponse,
//     ServicesListResponse? servicesListResponse,
//   }) {
//     return ServiceState(
//       isLoading: isLoading ?? this.isLoading,
//       error: error,
//       serviceResponse: serviceResponse ?? this.serviceResponse,
//       servicesListResponse: servicesListResponse ?? this.servicesListResponse,
//       serviceDetailsResponse:
//           serviceDetailsResponse ?? this.serviceDetailsResponse,
//     );
//   }
// }
//
// class ServiceNotifier extends Notifier<ServiceState> {
//   late final ApiDataSource api;
//
//   @override
//   ServiceState build() {
//     api = ref.read(apiDataSourceProvider);
//     return ServiceState.initial();
//   }
//
//   Future<void> fetchServiceDetails({bool force = false}) async {
//     if (!force && state.serviceResponse != null) return;
//
//     state = state.copyWith(isLoading: true);
//
//     final result = await api.getServiceDetails();
//
//     result.fold(
//       (failure) {
//         state = state.copyWith(isLoading: false, error: failure.message);
//       },
//       (response) {
//         state = state.copyWith(isLoading: false, serviceResponse: response);
//       },
//     );
//   }
//
//   Future<void> showSpecificServiceDetails({
//     required String shopId,
//     bool force = false,
//   }) async {
//     state = state.copyWith(isLoading: true, serviceDetailsResponse: null);
//
//     final result = await api.getServiceSpecificDetails(shopId: shopId);
//
//     result.fold(
//       (failure) {
//         state = state.copyWith(isLoading: false, serviceDetailsResponse: null);
//       },
//       (response) {
//         state = state.copyWith(
//           isLoading: false,
//           serviceDetailsResponse: response,
//         );
//       },
//     );
//   }
//
//   Future<void> viewAllServices({
//     required String shopId,
//     bool force = false,
//   }) async {
//     state = ServiceState(isLoading: true, servicesListResponse: null);
//
//     final result = await api.viewAllServices(shopId: shopId);
//
//     result.fold(
//       (failure) {
//         state = ServiceState(isLoading: false, servicesListResponse: null);
//       },
//       (response) {
//         state = ServiceState(isLoading: false, servicesListResponse: response);
//       },
//     );
//   }
// }
//
// final serviceNotifierProvider = NotifierProvider<ServiceNotifier, ServiceState>(
//   ServiceNotifier.new,
// );
