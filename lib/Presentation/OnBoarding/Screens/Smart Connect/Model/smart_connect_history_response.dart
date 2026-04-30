import 'dart:convert';

class SmartConnectHistoryResponse {
  final bool status;
  final SmartConnectHistoryData data;

  const SmartConnectHistoryResponse({required this.status, required this.data});

  factory SmartConnectHistoryResponse.fromJson(Map<String, dynamic> json) {
    return SmartConnectHistoryResponse(
      status: json['status'] == true,
      data: SmartConnectHistoryData.fromJson(
        (json['data'] ?? {}) as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() => {"status": status, "data": data.toJson()};

  static SmartConnectHistoryResponse fromRawJson(String source) =>
      SmartConnectHistoryResponse.fromJson(
        jsonDecode(source) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());
}

class SmartConnectHistoryData {
  final int page;
  final int limit;
  final int total;
  final int totalItems;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;
  final List<SmartConnectHistorySection> sections;

  const SmartConnectHistoryData({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalItems,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
    required this.sections,
  });

  factory SmartConnectHistoryData.fromJson(Map<String, dynamic> json) {
    return SmartConnectHistoryData(
      page: _toInt(json['page']),
      limit: _toInt(json['limit']),
      total: _toInt(json['total']),
      totalItems: _toInt(json['totalItems']),
      totalPages: _toInt(json['totalPages']),
      hasNext: json['hasNext'] == true,
      hasPrev: json['hasPrev'] == true,
      sections: (json['sections'] as List<dynamic>? ?? [])
          .map(
            (e) => SmartConnectHistorySection.fromJson(
              (e ?? {}) as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    "page": page,
    "limit": limit,
    "total": total,
    "totalItems": totalItems,
    "totalPages": totalPages,
    "hasNext": hasNext,
    "hasPrev": hasPrev,
    "sections": sections.map((e) => e.toJson()).toList(),
  };
}

class SmartConnectHistorySection {
  final String key; // "today"
  final String label; // "Today"
  final int count;
  final List<SmartConnectHistoryItem> items;

  const SmartConnectHistorySection({
    required this.key,
    required this.label,
    required this.count,
    required this.items,
  });

  factory SmartConnectHistorySection.fromJson(Map<String, dynamic> json) {
    return SmartConnectHistorySection(
      key: (json['key'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      count: _toInt(json['count']),
      items: (json['items'] as List<dynamic>? ?? [])
          .map(
            (e) => SmartConnectHistoryItem.fromJson(
              (e ?? {}) as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    "key": key,
    "label": label,
    "count": count,
    "items": items.map((e) => e.toJson()).toList(),
  };
}

class SmartConnectHistoryItem {
  final String id;
  final String productName;
  final String categoryTrail;
  final String description;
  final String city;

  final String targetShopId;
  final String targetListingId;
  final String targetListingType; // "PRODUCT"

  final String status; // "OPEN"
  final DateTime? createdAt;

  final String createdTimeLabel; // "8:51AM"
  final String createdLabel; // "Created on 8:51AM"

  final int replyCount;
  final String shopsReachedText;
  final DateTime? lastReplyAt;

  const SmartConnectHistoryItem({
    required this.id,
    required this.productName,
    required this.categoryTrail,
    required this.description,
    required this.city,
    required this.targetShopId,
    required this.targetListingId,
    required this.targetListingType,
    required this.status,
    required this.createdAt,
    required this.createdTimeLabel,
    required this.createdLabel,
    required this.replyCount,
    required this.shopsReachedText,
    required this.lastReplyAt,
  });

  factory SmartConnectHistoryItem.fromJson(Map<String, dynamic> json) {
    return SmartConnectHistoryItem(
      id: (json['id'] ?? '').toString(),
      productName: (json['productName'] ?? '').toString(),
      categoryTrail: (json['categoryTrail'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      targetShopId: (json['targetShopId'] ?? '').toString(),
      targetListingId: (json['targetListingId'] ?? '').toString(),
      targetListingType: (json['targetListingType'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      createdAt: _toDate(json['createdAt']),
      createdTimeLabel: (json['createdTimeLabel'] ?? '').toString(),
      createdLabel: (json['createdLabel'] ?? '').toString(),
      replyCount: _toInt(json['replyCount']),
      shopsReachedText: (json['shopsReachedText'] ?? '').toString(),
      lastReplyAt: _toDate(json['lastReplyAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "productName": productName,
    "categoryTrail": categoryTrail,
    "description": description,
    "city": city,
    "targetShopId": targetShopId,
    "targetListingId": targetListingId,
    "targetListingType": targetListingType,
    "status": status,
    "createdAt": createdAt?.toIso8601String(),
    "createdTimeLabel": createdTimeLabel,
    "createdLabel": createdLabel,
    "replyCount": replyCount,
    "shopsReachedText": shopsReachedText,
    "lastReplyAt": lastReplyAt?.toIso8601String(),
  };
}

// -------- helpers --------
int _toInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? 0;
}

DateTime? _toDate(dynamic v) {
  if (v == null) return null;
  final s = v.toString();
  if (s.isEmpty || s == 'null') return null;
  return DateTime.tryParse(s);
}
