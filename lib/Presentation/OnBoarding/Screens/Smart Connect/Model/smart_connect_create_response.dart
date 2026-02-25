import 'dart:convert';

class SmartConnectCreateResponse {
  final bool status;
  final SmartConnectCreatedData data;

  const SmartConnectCreateResponse({
    required this.status,
    required this.data,
  });

  /// ✅ Quick access (as you asked)
  String get id => data.id;
  String get productName => data.productName;

  factory SmartConnectCreateResponse.fromJson(Map<String, dynamic> json) {
    return SmartConnectCreateResponse(
      status: json['status'] == true,
      data: SmartConnectCreatedData.fromJson(
        (json['data'] ?? {}) as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data.toJson(),
  };

  static SmartConnectCreateResponse fromRawJson(String source) =>
      SmartConnectCreateResponse.fromJson(jsonDecode(source) as Map<String, dynamic>);

  String toRawJson() => jsonEncode(toJson());
}

class SmartConnectCreatedData {
  final String id;
  final String productName;

  // optional fields (keep for future use)
  final String? categoryTrail;
  final String? description;
  final String? city;
  final String? targetShopId;
  final String? targetListingId;
  final String? targetListingType;
  final String? status;
  final DateTime? createdAt;
  final String? createdTimeLabel;
  final String? createdLabel;
  final int replyCount;
  final String? shopsReachedText;
  final DateTime? lastReplyAt;

  const SmartConnectCreatedData({
    required this.id,
    required this.productName,
    this.categoryTrail,
    this.description,
    this.city,
    this.targetShopId,
    this.targetListingId,
    this.targetListingType,
    this.status,
    this.createdAt,
    this.createdTimeLabel,
    this.createdLabel,
    this.replyCount = 0,
    this.shopsReachedText,
    this.lastReplyAt,
  });

  factory SmartConnectCreatedData.fromJson(Map<String, dynamic> json) {
    return SmartConnectCreatedData(
      id: (json['id'] ?? '').toString(),
      productName: (json['productName'] ?? '').toString(),
      categoryTrail: json['categoryTrail']?.toString(),
      description: json['description']?.toString(),
      city: json['city']?.toString(),
      targetShopId: json['targetShopId']?.toString(),
      targetListingId: json['targetListingId']?.toString(),
      targetListingType: json['targetListingType']?.toString(),
      status: json['status']?.toString(),
      createdAt: _toDate(json['createdAt']),
      createdTimeLabel: json['createdTimeLabel']?.toString(),
      createdLabel: json['createdLabel']?.toString(),
      replyCount: _toInt(json['replyCount']),
      shopsReachedText: json['shopsReachedText']?.toString(),
      lastReplyAt: _toDate(json['lastReplyAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "productName": productName,
    if (categoryTrail != null) "categoryTrail": categoryTrail,
    if (description != null) "description": description,
    if (city != null) "city": city,
    if (targetShopId != null) "targetShopId": targetShopId,
    if (targetListingId != null) "targetListingId": targetListingId,
    if (targetListingType != null) "targetListingType": targetListingType,
    if (status != null) "status": status,
    if (createdAt != null) "createdAt": createdAt!.toIso8601String(),
    if (createdTimeLabel != null) "createdTimeLabel": createdTimeLabel,
    if (createdLabel != null) "createdLabel": createdLabel,
    "replyCount": replyCount,
    if (shopsReachedText != null) "shopsReachedText": shopsReachedText,
    "lastReplyAt": lastReplyAt?.toIso8601String(),
  };

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    if (s.isEmpty || s == 'null') return null;
    return DateTime.tryParse(s);
  }
}