import 'dart:convert';

/// ---------- TOP LEVEL ----------
class NearbyMapResponse {
  final bool status;
  final NearbyMapData? data;

  const NearbyMapResponse({
    required this.status,
    required this.data,
  });

  factory NearbyMapResponse.fromJson(Map<String, dynamic> json) {
    return NearbyMapResponse(
      status: json['status'] == true,
      data: json['data'] == null
          ? null
          : NearbyMapData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  static NearbyMapResponse fromRawJson(String raw) =>
      NearbyMapResponse.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}

/// ---------- DATA ----------
class NearbyMapData {
  final String shopId;
  final LatLngPoint center;
  final String city;
  final int total;
  final List<NearbyShopItem> items;

  const NearbyMapData({
    required this.shopId,
    required this.center,
    required this.city,
    required this.total,
    required this.items,
  });

  factory NearbyMapData.fromJson(Map<String, dynamic> json) {
    final itemsJson = (json['items'] as List?) ?? const [];
    return NearbyMapData(
      shopId: (json['shopId'] ?? '').toString(),
      center: LatLngPoint.fromJson((json['center'] as Map?)?.cast<String, dynamic>() ?? const {}),
      city: (json['city'] ?? '').toString(),
      total: _asInt(json['total']),
      items: itemsJson
          .whereType<Map>()
          .map((e) => NearbyShopItem.fromJson(e.cast<String, dynamic>()))
          .toList(),
    );
  }
}

/// ---------- CENTER / POINT ----------
class LatLngPoint {
  final double latitude;
  final double longitude;

  const LatLngPoint({
    required this.latitude,
    required this.longitude,
  });

  factory LatLngPoint.fromJson(Map<String, dynamic> json) {
    return LatLngPoint(
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
    );
  }
}

/// ---------- ITEM ----------
class NearbyShopItem {
  final String id;
  final String name;
  final String categoryLabel;
  final String city;
  final double lat;
  final double lng;
  final bool isTrusted;
  final double distanceKm;
  final String distanceLabel;
  final String? imageUrl;
  final String phone;
  final bool isOpen;
  final String openLabel;

  const NearbyShopItem({
    required this.id,
    required this.name,
    required this.categoryLabel,
    required this.city,
    required this.lat,
    required this.lng,
    required this.isTrusted,
    required this.distanceKm,
    required this.distanceLabel,
    required this.imageUrl,
    required this.phone,
    required this.isOpen,
    required this.openLabel,
  });

  factory NearbyShopItem.fromJson(Map<String, dynamic> json) {
    return NearbyShopItem(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      categoryLabel: (json['categoryLabel'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      lat: _asDouble(json['lat']),
      lng: _asDouble(json['lng']),
      isTrusted: json['isTrusted'] == true,
      distanceKm: _asDouble(json['distanceKm']),
      distanceLabel: (json['distanceLabel'] ?? '').toString(),
      imageUrl: (json['imageUrl'] == null || (json['imageUrl'].toString().trim().isEmpty))
          ? null
          : json['imageUrl'].toString(),
      phone: (json['phone'] ?? '').toString(),
      isOpen: json['isOpen'] == true,
      openLabel: (json['openLabel'] ?? '').toString(),
    );
  }
}

/// ---------- SAFE CAST HELPERS ----------
int _asInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

double _asDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}
