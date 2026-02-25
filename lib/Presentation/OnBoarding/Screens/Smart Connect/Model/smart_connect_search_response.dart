import 'dart:convert';

class SmartConnectSearchResponse {
  final bool status;
  final SmartConnectSearchData data;

  const SmartConnectSearchResponse({
    required this.status,
    required this.data,
  });

  factory SmartConnectSearchResponse.fromJson(Map<String, dynamic> json) {
    return SmartConnectSearchResponse(
      status: json['status'] == true,
      data: SmartConnectSearchData.fromJson(
        (json['data'] ?? {}) as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data.toJson(),
  };

  static SmartConnectSearchResponse fromRawJson(String source) =>
      SmartConnectSearchResponse.fromJson(jsonDecode(source) as Map<String, dynamic>);

  String toRawJson() => jsonEncode(toJson());
}

class SmartConnectSearchData {
  final String term;
  final int total;
  final List<SmartConnectSearchItem> items;

  const SmartConnectSearchData({
    required this.term,
    required this.total,
    required this.items,
  });

  factory SmartConnectSearchData.fromJson(Map<String, dynamic> json) {
    return SmartConnectSearchData(
      term: (json['term'] ?? '').toString(),
      total: _toInt(json['total']),
      items: _toItemList(json['items']),
    );
  }

  Map<String, dynamic> toJson() => {
    "term": term,
    "total": total,
    "items": items.map((e) => e.toJson()).toList(),
  };

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static List<SmartConnectSearchItem> _toItemList(dynamic v) {
    if (v is List) {
      return v
          .whereType<Map>()
          .map((m) => SmartConnectSearchItem.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    }
    return const <SmartConnectSearchItem>[];
  }
}

class SmartConnectSearchItem {
  final String listingId;
  final String listingType; // PRODUCT, SHOP, etc.
  final String shopId;
  final String primaryText;   // LG
  final String secondaryText; // in Televisions

  const SmartConnectSearchItem({
    required this.listingId,
    required this.listingType,
    required this.shopId,
    required this.primaryText,
    required this.secondaryText,
  });

  factory SmartConnectSearchItem.fromJson(Map<String, dynamic> json) {
    return SmartConnectSearchItem(
      listingId: (json['listingId'] ?? '').toString(),
      listingType: (json['listingType'] ?? '').toString(),
      shopId: (json['shopId'] ?? '').toString(),
      primaryText: (json['primaryText'] ?? '').toString(),
      secondaryText: (json['secondaryText'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "listingId": listingId,
    "listingType": listingType,
    "shopId": shopId,
    "primaryText": primaryText,
    "secondaryText": secondaryText,
  };
}