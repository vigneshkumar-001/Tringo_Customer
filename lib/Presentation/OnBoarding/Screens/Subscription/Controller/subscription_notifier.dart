import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_app/Api/DataSource/api_data_source.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Subscription/Model/ccavenue_confirm_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Subscription/Model/ccavenue_init_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Subscription/Model/subscription_current_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Subscription/Model/subscription_plans_response.dart';

import 'package:tringo_app/Api/api_providers.dart';

class SubscriptionState {
  final bool isLoadingPlans;
  final bool isLoadingCurrent;
  final bool isProcessing;
  final String? error;

  final String role;
  final String businessProfileId;
  final String shopId;

  final SubscriptionPlansResponse? plans;
  final SubscriptionCurrentResponse? current;

  const SubscriptionState({
    this.isLoadingPlans = false,
    this.isLoadingCurrent = false,
    this.isProcessing = false,
    this.error,
    this.role = '',
    this.businessProfileId = '',
    this.shopId = '',
    this.plans,
    this.current,
  });

  factory SubscriptionState.initial() => const SubscriptionState();

  SubscriptionState copyWith({
    bool? isLoadingPlans,
    bool? isLoadingCurrent,
    bool? isProcessing,
    String? error,
    String? role,
    String? businessProfileId,
    String? shopId,
    SubscriptionPlansResponse? plans,
    SubscriptionCurrentResponse? current,
  }) {
    return SubscriptionState(
      isLoadingPlans: isLoadingPlans ?? this.isLoadingPlans,
      isLoadingCurrent: isLoadingCurrent ?? this.isLoadingCurrent,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      role: role ?? this.role,
      businessProfileId: businessProfileId ?? this.businessProfileId,
      shopId: shopId ?? this.shopId,
      plans: plans ?? this.plans,
      current: current ?? this.current,
    );
  }
}

class SubscriptionNotifier extends Notifier<SubscriptionState> {
  static const _kBusinessProfileId = 'subscriptionBusinessProfileId';
  static const _kShopId = 'subscriptionShopId';

  late final ApiDataSource api;

  @override
  SubscriptionState build() {
    api = ref.read(apiDataSourceProvider);
    return SubscriptionState.initial();
  }

  Future<void> loadLocalContext() async {
    final sp = await SharedPreferences.getInstance();
    final role = (sp.getString('role') ?? '').trim();
    final bp = (sp.getString(_kBusinessProfileId) ?? '').trim();
    final shop = (sp.getString(_kShopId) ?? '').trim();
    state = state.copyWith(role: role, businessProfileId: bp, shopId: shop);
  }

  Future<void> setBusinessProfileId(String value) async {
    final v = value.trim();
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kBusinessProfileId, v);
    state = state.copyWith(businessProfileId: v, error: null);
  }

  Future<void> setShopId(String value) async {
    final v = value.trim();
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kShopId, v);
    state = state.copyWith(shopId: v, error: null);
  }

  Future<void> fetchPlans() async {
    state = state.copyWith(isLoadingPlans: true, error: null);
    final result = await api.getSubscriptionPlans();
    result.fold(
      (failure) {
        state = state.copyWith(isLoadingPlans: false, error: failure.message);
      },
      (resp) {
        state = state.copyWith(isLoadingPlans: false, plans: resp, error: null);
      },
    );
  }

  Future<void> fetchCurrent() async {
    state = state.copyWith(isLoadingCurrent: true, error: null);
    final result = await api.getCurrentSubscription(
      businessProfileId: state.businessProfileId,
    );
    result.fold(
      (failure) {
        state = state.copyWith(isLoadingCurrent: false, error: failure.message);
      },
      (resp) {
        state =
            state.copyWith(isLoadingCurrent: false, current: resp, error: null);
      },
    );
  }

  bool get hasPaidSubscription {
    final d = state.current?.data;
    if (d == null) return false;
    return d.isFreemium == false && (d.subscriptionId ?? '').trim().isNotEmpty;
  }

  Future<CcavenueInitData?> startCheckout({
    required String planId,
  }) async {
    // Employee requires businessProfileId.
    if (state.role.trim().toUpperCase() == 'EMPLOYEE' &&
        state.businessProfileId.trim().isEmpty) {
      state = state.copyWith(
        error: 'Business Profile ID is required for employees',
      );
      return null;
    }

    state = state.copyWith(isProcessing: true, error: null);
    final result = await api.initCcavenueCheckout(
      planId: planId,
      businessProfileId: state.businessProfileId,
      shopId: state.shopId,
      extend: hasPaidSubscription,
    );

    return result.fold<CcavenueInitData?>(
      (failure) {
        state = state.copyWith(isProcessing: false, error: failure.message);
        return null;
      },
      (resp) {
        state = state.copyWith(isProcessing: false, error: null);
        return resp.data;
      },
    );
  }

  Future<CcavenueConfirmResponse?> confirmPayment(String encResp) async {
    final v = encResp.trim();
    if (v.isEmpty) return null;

    state = state.copyWith(isProcessing: true, error: null);
    final result = await api.confirmCcavenuePayment(encResp: v);
    return result.fold<CcavenueConfirmResponse?>(
      (failure) {
        state = state.copyWith(isProcessing: false, error: failure.message);
        return null;
      },
      (resp) {
        state = state.copyWith(isProcessing: false, error: null);
        return resp;
      },
    );
  }
}

final subscriptionNotifierProvider =
    NotifierProvider<SubscriptionNotifier, SubscriptionState>(
  SubscriptionNotifier.new,
);
