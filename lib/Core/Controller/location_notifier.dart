import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationState {
  final bool isLoading;
  final String? address;

  const LocationState({this.isLoading = true, this.address});

  LocationState copyWith({bool? isLoading, String? address}) {
    return LocationState(
      isLoading: isLoading ?? this.isLoading,
      address: address ?? this.address,
    );
  }
}

// App-wide location cache: fetched once (GPS + reverse geocode) and shared
// by every screen via ref.watch, instead of each CurrentLocationWidget
// instance re-running the whole flow on its own initState.
class LocationNotifier extends Notifier<LocationState> {
  StreamSubscription<ServiceStatus>? _serviceSub;
  bool _hasFetchedOnce = false;

  @override
  LocationState build() {
    ref.onDispose(() => _serviceSub?.cancel());
    _serviceSub = Geolocator.getServiceStatusStream().listen((status) {
      if (status == ServiceStatus.enabled) {
        fetchCurrentLocation(force: true);
      }
    });
    // Deferred to a microtask: fetchCurrentLocation writes to `state` on its
    // very first synchronous line (before any await), and Riverpod hasn't
    // finished registering this provider's initial value while build() is
    // still executing - writing state synchronously from here throws "Tried
    // to read the state of an uninitialized provider". Scheduling it lets
    // build() return first, so the write lands after the provider is live.
    Future.microtask(() => fetchCurrentLocation());
    return const LocationState();
  }

  Future<void> fetchCurrentLocation({bool force = false}) async {
    if (_hasFetchedOnce && !force) return;
    state = state.copyWith(isLoading: true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = LocationState(isLoading: false, address: 'Location services disabled');
        return;
      }

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied) {
        state = LocationState(isLoading: false, address: 'Permission denied');
        return;
      }
      if (perm == LocationPermission.deniedForever) {
        state = LocationState(isLoading: false, address: 'Permission permanently denied');
        return;
      }

      // No GPS fix (weak signal / emulator / indoors) must never hang this
      // forever - time out and fall back to the last known fix instead of
      // leaving the UI stuck on "Fetching location..." permanently.
      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
      } catch (_) {
        pos = await Geolocator.getLastKnownPosition();
      }

      if (pos == null) {
        state = const LocationState(isLoading: false, address: 'Unable to fetch location');
        return;
      }

      final marks = await placemarkFromCoordinates(pos.latitude, pos.longitude);

      String address;
      if (marks.isNotEmpty) {
        final p = marks.first;
        final parts = <String>[
          if ((p.street ?? '').trim().isNotEmpty) p.street!.trim(),
          if ((p.locality ?? '').trim().isNotEmpty) p.locality!.trim(),
          if ((p.administrativeArea ?? '').trim().isNotEmpty) p.administrativeArea!.trim(),
        ];
        address = parts.join(', ');
      } else {
        address = 'Unknown location';
      }

      _hasFetchedOnce = true;
      state = LocationState(isLoading: false, address: address);
    } catch (e) {
      state = LocationState(isLoading: false, address: 'Unable to fetch location');
    }
  }
}

final locationNotifierProvider = NotifierProvider<LocationNotifier, LocationState>(
  LocationNotifier.new,
);
