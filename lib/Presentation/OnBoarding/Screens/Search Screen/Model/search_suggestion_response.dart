class SearchSuggestionResponse {
  final bool status;
  final SearchSuggestionData? data;

  SearchSuggestionResponse({
    required this.status,
    this.data,
  });

  factory SearchSuggestionResponse.fromJson(Map<String, dynamic> json) {
    return SearchSuggestionResponse(
      status: json['status'] ?? false,
      data: json['data'] != null
          ? SearchSuggestionData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data?.toJson(),
    };
  }
}

class SearchSuggestionData {
  final String query;
  final List<SearchItem> items;

  SearchSuggestionData({
    required this.query,
    required this.items,
  });

  factory SearchSuggestionData.fromJson(Map<String, dynamic> json) {
    return SearchSuggestionData(
      query: json['query'] ?? '',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => SearchItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class SearchItem {
  /// "SHOP", "PRODUCT", "SERVICE"
  final String type;
  final String id;
  final String label;
  final String inLabel;
  final SearchTarget target;

  SearchItem({
    required this.type,
    required this.id,
    required this.label,
    required this.inLabel,
    required this.target,
  });

  factory SearchItem.fromJson(Map<String, dynamic> json) {
    return SearchItem(
      type: json['type'] ?? '',
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      inLabel: json['inLabel'] ?? '',
      target: SearchTarget.fromJson(json['target'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': id,
      'label': label,
      'inLabel': inLabel,
      'target': target.toJson(),
    };
  }

  /// Convenience helper for UI: quick type checks
  bool get isShop => type == 'SHOP';
  bool get isProduct => type == 'PRODUCT';
  bool get isService => type == 'SERVICE';
}

class SearchTarget {
  /// "SHOP_LIST", "PRODUCT_LIST", "SERVICE_LIST"
  final String kind;
  final String q;
  final String? shopId;
  final String? productId;
  final String? serviceId;

  SearchTarget({
    required this.kind,
    required this.q,
    this.shopId,
    this.productId,
    this.serviceId,
  });

  factory SearchTarget.fromJson(Map<String, dynamic> json) {
    return SearchTarget(
      kind: json['kind'] ?? '',
      q: json['q'] ?? '',
      shopId: json['shopId'],
      productId: json['productId'],
      serviceId: json['serviceId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kind': kind,
      'q': q,
      'shopId': shopId,
      'productId': productId,
      'serviceId': serviceId,
    };
  }

  bool get isShopList => kind == 'SHOP_LIST';
  bool get isProductList => kind == 'PRODUCT_LIST';
  bool get isServiceList => kind == 'SERVICE_LIST';
}
