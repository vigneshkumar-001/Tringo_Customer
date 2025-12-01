import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tringo_app/Api/DataSource/api_data_source.dart';

import '../../Login Screen/Controller/login_notifier.dart';
import '../Models/service_data_response.dart';
import '../Models/service_details_response.dart';

class ServiceDataSate {
  final bool isLoading;
  final String? error;
  final ServiceDataResponse?  serviceDataResponse;

  const ServiceDataSate({
    this.isLoading = false,
    this.error,
    this.serviceDataResponse,
  });

  factory ServiceDataSate.initial() => const ServiceDataSate();

  ServiceDataSate copyWith({
    bool? isLoading,
    String? error,
    ServiceDataResponse? serviceDataResponse,
  }) {
    return ServiceDataSate(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      serviceDataResponse:
      serviceDataResponse ?? this.serviceDataResponse,
    );
  }
}

class ServiceDataNotifier extends Notifier<ServiceDataSate> {
  late final ApiDataSource api;

  @override
  ServiceDataSate build() {
    api = ref.read(apiDataSourceProvider);
    return ServiceDataSate.initial();
  }

  Future<void> viewDetailServices({
    required String serviceId,
    bool force = false,
  }) async {
    state = state.copyWith(isLoading: true, serviceDataResponse: null);

    final result = await api.viewDetailServices(serviceId: serviceId);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, serviceDataResponse: null);
      },
      (response) {
        state = state.copyWith(
          isLoading: false,
          serviceDataResponse: response,
        );
      },
    );
  }
}

final serviceDataNotifierProvider =
    NotifierProvider<ServiceDataNotifier, ServiceDataSate>(
      ServiceDataNotifier.new,
    );
