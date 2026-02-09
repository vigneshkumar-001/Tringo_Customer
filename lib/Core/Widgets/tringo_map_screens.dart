import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../Presentation/OnBoarding/Screens/Home Screen/Controller/nearby_shop_map_notifier.dart';
import '../../Presentation/OnBoarding/Screens/Home Screen/Model/nearby_map_response.dart';
import '../../Presentation/OnBoarding/Screens/Shop Screen/Screens/shops_details.dart';
import '../Utility/map_urls.dart';

class TringoMapScreen extends ConsumerStatefulWidget {
  final String shopId; // ✅ required (base shop id for nearby API)
  final LatLng? initialLocation;
  final Function(NearbyShopItem shop)? onShopSelected;

  const TringoMapScreen({
    super.key,
    required this.shopId,
    this.initialLocation,
    this.onShopSelected,
  });

  @override
  ConsumerState<TringoMapScreen> createState() => _TringoMapScreenState();
}

class _TringoMapScreenState extends ConsumerState<TringoMapScreen>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  late AnimationController _pulseController;
  late AnimationController _slideController;

  LatLng? selectedLocation;
  Set<Marker> _shopMarkers = {};
  bool _movedToMyLocation = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _initLocationAndLoad();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initLocationAndLoad() async {
    // If initial location is passed from previous screen
    if (widget.initialLocation != null) {
      selectedLocation = widget.initialLocation!;
      await _loadShopsOnMap();
      await _tryMoveCameraToSelected();
      _slideController.forward();
      return;
    }

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // fallback
        selectedLocation = const LatLng(13.0827, 80.2707);
        await _loadShopsOnMap();
        await _tryMoveCameraToSelected();
        _slideController.forward();
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      selectedLocation = LatLng(pos.latitude, pos.longitude);
      await _loadShopsOnMap();
      await _tryMoveCameraToSelected();
    } catch (_) {
      selectedLocation = const LatLng(13.0827, 80.2707);
      await _loadShopsOnMap();
      await _tryMoveCameraToSelected();
    }

    _slideController.forward();
  }

  Future<void> _tryMoveCameraToSelected() async {
    if (selectedLocation == null || _mapController == null) return;

    if (!_movedToMyLocation) {
      _movedToMyLocation = true;
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(selectedLocation!, 15),
      );
    }
  }

  Future<void> _loadShopsOnMap() async {
    if (selectedLocation == null) return;

    // ✅ CALL API (Riverpod Notifier)
    await ref
        .read(nearbyNotifierProvider.notifier)
        .fetchNearbyShops(
          shopId: widget.shopId,
          lat: selectedLocation!.latitude,
          lng: selectedLocation!.longitude,
        );

    final nearby = ref.read(nearbyNotifierProvider);
    final items = nearby.nearbyResponse?.data?.items ?? [];

    _buildMarkersFromApi(items);

    // Fit bounds around selected location
    await Future.delayed(const Duration(milliseconds: 250));
    if (_mapController != null && selectedLocation != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              selectedLocation!.latitude - 0.015,
              selectedLocation!.longitude - 0.015,
            ),
            northeast: LatLng(
              selectedLocation!.latitude + 0.015,
              selectedLocation!.longitude + 0.015,
            ),
          ),
          80,
        ),
      );
    }

    if (mounted) setState(() {});
  }

  void _buildMarkersFromApi(List<NearbyShopItem> items) {
    _shopMarkers.clear();

    for (final shop in items) {
      _shopMarkers.add(
        Marker(
          markerId: MarkerId(shop.id),
          position: LatLng(shop.lat, shop.lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
          infoWindow: InfoWindow(
            title: shop.name,
            snippet: '${shop.categoryLabel} • ${shop.distanceLabel}',
          ),
          onTap: () => _showShopDetails(shop),
        ),
      );
    }

    if (selectedLocation != null) {
      _shopMarkers.add(
        Marker(
          markerId: const MarkerId('selected'),
          position: selectedLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }
  }

  void _showShopDetails(NearbyShopItem shop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildShopDetailsSheet(shop),
    );
  }

  Widget _buildShopDetailsSheet(NearbyShopItem shop) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.orange.shade50.withOpacity(0.3)],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),

              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade400,
                      Colors.deepOrange.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.store_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shop.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  shop.distanceLabel,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Category / City card (API doesn't have address, so we show city + category)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange.shade300,
                                Colors.orange.shade500,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.category_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            '${shop.categoryLabel} • ${shop.city}',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade800,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildActionButton(
                      label: 'Call Shop',
                      icon: Icons.phone_rounded,
                      gradient: LinearGradient(
                        colors: [Colors.green.shade500, Colors.green.shade700],
                      ),
                      onPressed: () async {
                        await MapUrls.openDialer(
                          context,
                          shop. phone ,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      label: 'Details',
                      icon: Icons.info_outline_rounded,
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade500, Colors.blue.shade700],
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ShopsDetails(
                              shopId: shop.id,
                              page: 'map',
                              heroTag: 'shop_${shop.id}',
                              image: shop.imageUrl,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nearby = ref.watch(nearbyNotifierProvider);
    final items = nearby.nearbyResponse?.data?.items ?? [];
    final isLoading = nearby.isLoading;
    final error = nearby.error;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: Colors.white.withOpacity(0.85),
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.orange.shade700,
                    size: 18,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Column(
                children: [
                  const Text(
                    'Nearby Shops',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (items.isNotEmpty)
                    Text(
                      '${items.length} locations found',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: selectedLocation ?? const LatLng(13.0827, 80.2707),
              zoom: 14,
            ),
            onMapCreated: (controller) async {
              _mapController = controller;
              await _tryMoveCameraToSelected();
            },
            onTap: (point) async {
              setState(() {
                selectedLocation = point;
                _movedToMyLocation = true;
              });
              await _loadShopsOnMap();
            },
            markers: _shopMarkers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            compassEnabled: true,
            mapToolbarEnabled: false,
            zoomControlsEnabled: false,
          ),

          // Error toast/card
          if (error != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 160,
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    error,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),

          // Loading overlay
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(
                          Colors.orange.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Finding shops near you...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Shop Counter Badge
          if (items.isNotEmpty)
            Positioned(
              top: 100,
              right: 16,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_pulseController.value * 0.1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.shade500,
                            Colors.deepOrange.shade600,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.5),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.store_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${items.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          // Custom Location Button
          Positioned(
            bottom: 90,
            right: 16,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(2, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _slideController,
                      curve: Curves.elasticOut,
                    ),
                  ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade500,
                      Colors.deepOrange.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      _movedToMyLocation = false;
                      await _initLocationAndLoad();
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: const Icon(
                        Icons.my_location_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
