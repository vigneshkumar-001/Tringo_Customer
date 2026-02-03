class SearchSuggestionResponse {
  final bool status;
  final SearchSuggestionData? data;

  SearchSuggestionResponse({required this.status, this.data});

  factory SearchSuggestionResponse.fromJson(Map<String, dynamic> json) {
    return SearchSuggestionResponse(
      status: json['status'] == true,
      data: json['data'] != null
          ? SearchSuggestionData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {'status': status, 'data': data?.toJson()};
}

class SearchSuggestionData {
  final String query;
  final List<SearchItem> items;

  SearchSuggestionData({required this.query, required this.items});

  factory SearchSuggestionData.fromJson(Map<String, dynamic> json) {
    return SearchSuggestionData(
      query: (json['query'] ?? '').toString(),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => SearchItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'query': query,
    'items': items.map((e) => e.toJson()).toList(),
  };
}

class SearchItem {
  /// Example: "CUSTOMER"
  final String type;
  final String id;
  final String label;
  final String inLabel;
  final SearchTarget target;
  final SearchMeta? meta;

  SearchItem({
    required this.type,
    required this.id,
    required this.label,
    required this.inLabel,
    required this.target,
    this.meta,
  });

  factory SearchItem.fromJson(Map<String, dynamic> json) {
    return SearchItem(
      type: (json['type'] ?? '').toString(),
      id: (json['id'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      inLabel: (json['inLabel'] ?? '').toString(),
      target: SearchTarget.fromJson(
        (json['target'] ?? {}) as Map<String, dynamic>,
      ),
      meta: json['meta'] != null
          ? SearchMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'label': label,
    'inLabel': inLabel,
    'target': target.toJson(),
    'meta': meta?.toJson(),
  };

  /// Helpers (update as per your backend values)
  bool get isOwnerShop => type == 'OWNER_SHOP';
  bool get isShop => type == 'SHOP' || isOwnerShop;
  bool get isPerson => type == 'PERSON';
  bool get isCustomer => type == 'CUSTOMER';
}

class SearchTarget {
  /// Example: "MOBILENO_USER_DETAIL"
  final String kind;
  final String q;

  final String? shopId;
  final String? phone;

  /// new (because response has: target.contactId)
  final String? contactId;

  /// keep for future
  final String? productId;
  final String? serviceId;

  SearchTarget({
    required this.kind,
    required this.q,
    this.shopId,
    this.phone,
    this.contactId,
    this.productId,
    this.serviceId,
  });

  factory SearchTarget.fromJson(Map<String, dynamic> json) {
    return SearchTarget(
      kind: (json['kind'] ?? '').toString(),
      q: (json['q'] ?? '').toString(),
      shopId: json['shopId']?.toString(),
      phone: json['phone']?.toString(),
      contactId: json['contactId']?.toString(),
      productId: json['productId']?.toString(),
      serviceId: json['serviceId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'kind': kind,
    'q': q,
    'shopId': shopId,
    'phone': phone,
    'contactId': contactId,
    'productId': productId,
    'serviceId': serviceId,
  };

  bool get isShopDetail => kind == 'SHOP_DETAIL';
  bool get isProductDetail => kind == 'PRODUCT_DETAIL';
  bool get isServiceDetail => kind == 'SERVICE_DETAIL';

  /// new helper
  bool get isMobileNoUserDetail => kind == 'MOBILENO_USER_DETAIL';
}

class SearchMeta {
  final String? name; // ✅ ADD THIS

  final String? phone;
  final String? category;
  final String? categoryLabel;
  final String? imageUrl;
  final String? city;
  final num? rating;
  final String? subtitle;

  SearchMeta({
    this.name, // ✅ ADD THIS
    this.phone,
    this.category,
    this.categoryLabel,
    this.imageUrl,
    this.city,
    this.rating,
    this.subtitle,
  });

  factory SearchMeta.fromJson(Map<String, dynamic> json) {
    return SearchMeta(
      name: json['name']?.toString(), // ✅ ADD THIS
      phone: json['phone']?.toString(),
      category: json['category']?.toString(),
      categoryLabel: json['categoryLabel']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      city: json['city']?.toString(),
      rating: json['rating'] as num?,
      subtitle: json['subtitle']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name, // ✅ ADD THIS
    'phone': phone,
    'category': category,
    'categoryLabel': categoryLabel,
    'imageUrl': imageUrl,
    'city': city,
    'rating': rating,
    'subtitle': subtitle,
  };
}
