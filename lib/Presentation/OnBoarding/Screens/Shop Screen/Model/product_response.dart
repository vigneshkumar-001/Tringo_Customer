class ProductResponse {
  final bool status;
  final ProductData? data;

  ProductResponse({required this.status, this.data});

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      status: json['status'] ?? false,
      data: json['data'] != null ? ProductData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data?.toJson(),
    };
  }
}

class ProductData {
  final int total;
  final List<Category> categories;
  final List<ProductItem> items;

  ProductData({
    required this.total,
    required this.categories,
    required this.items,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(
      total: json['total'] ?? 0,
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList(),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => ProductItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'categories': categories.map((e) => e.toJson()).toList(),
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class Category {
  final String slug;
  final String label;
  final int count;

  Category({required this.slug, required this.label, required this.count});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      slug: json['slug'] ?? '',
      label: json['label'] ?? '',
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': slug,
      'label': label,
      'count': count,
    };
  }
}

class ProductItem {
  final String id;
  final String? englishName;
  final String? tamilName;
  final String? category;
  final String? categoryLabel;
  final String? subCategory;
  final String? subCategoryLabel;
  final double? price;
  final double? offerPrice;
  final String? imageUrl;
  final String? unitLabel;
  final int? stockCount;
  final bool isFeatured;
  final String? offerLabel;
  final String? offerValue;
  final String? description;
  final List<String> keywords;
  final int? readyTimeMinutes;
  final bool doorDelivery;
  final String status;
  final List<ProductFeature> features;
  final bool hasVariants;

  /// 🔹 Added from JSON
  final int rating;
  final int ratingCount;

  ProductItem({
    required this.id,
    this.englishName,
    this.tamilName,
    this.category,
    this.categoryLabel,
    this.subCategory,
    this.subCategoryLabel,
    this.price,
    this.offerPrice,
    this.imageUrl,
    this.unitLabel,
    this.stockCount,
    required this.isFeatured,
    this.offerLabel,
    this.offerValue,
    this.description,
    required this.keywords,
    this.readyTimeMinutes,
    required this.doorDelivery,
    required this.status,
    required this.features,
    required this.hasVariants,
    required this.rating,
    required this.ratingCount,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      id: json['id'] ?? '',
      englishName: json['englishName'],
      tamilName: json['tamilName'],
      category: json['category'],
      categoryLabel: json['categoryLabel'],
      subCategory: json['subCategory'],
      subCategoryLabel: json['subCategoryLabel'],

      // 🔹 safe num → double conversion
      price: (json['price'] as num?)?.toDouble(),
      offerPrice: (json['offerPrice'] as num?)?.toDouble(),

      imageUrl: json['imageUrl'],
      unitLabel: json['unitLabel'],
      stockCount: json['stockCount'],
      isFeatured: json['isFeatured'] ?? false,
      offerLabel: json['offerLabel'],
      offerValue: json['offerValue'],
      description: json['description'],
      keywords: (json['keywords'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      readyTimeMinutes: json['readyTimeMinutes'],
      doorDelivery: json['doorDelivery'] ?? false,
      status: json['status'] ?? '',
      features: (json['features'] as List<dynamic>? ?? [])
          .map((e) => ProductFeature.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasVariants: json['hasVariants'] ?? false,

      // 🔹 new fields
      rating: json['rating'] ?? 0,
      ratingCount: json['ratingCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'englishName': englishName,
      'tamilName': tamilName,
      'category': category,
      'categoryLabel': categoryLabel,
      'subCategory': subCategory,
      'subCategoryLabel': subCategoryLabel,
      'price': price,
      'offerPrice': offerPrice,
      'imageUrl': imageUrl,
      'unitLabel': unitLabel,
      'stockCount': stockCount,
      'isFeatured': isFeatured,
      'offerLabel': offerLabel,
      'offerValue': offerValue,
      'description': description,
      'keywords': keywords,
      'readyTimeMinutes': readyTimeMinutes,
      'doorDelivery': doorDelivery,
      'status': status,
      'features': features.map((e) => e.toJson()).toList(),
      'hasVariants': hasVariants,
      'rating': rating,
      'ratingCount': ratingCount,
    };
  }
}

class ProductFeature {
  final String id;
  final String label;
  final String value;
  final String? language;

  ProductFeature({
    required this.id,
    required this.label,
    required this.value,
    this.language,
  });

  factory ProductFeature.fromJson(Map<String, dynamic> json) {
    return ProductFeature(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      value: json['value'] ?? '',
      language: json['language'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'value': value,
      'language': language,
    };
  }
}


// class ProductResponse {
//   final bool status;
//   final ProductData? data;
//
//   ProductResponse({required this.status, this.data});
//
//   factory ProductResponse.fromJson(Map<String, dynamic> json) {
//     return ProductResponse(
//       status: json['status'] ?? false,
//       data: json['data'] != null ? ProductData.fromJson(json['data']) : null,
//     );
//   }
// }
//
// class ProductData {
//   final int total;
//   final List<Category> categories;
//   final List<ProductItem> items;
//
//   ProductData({
//     required this.total,
//     required this.categories,
//     required this.items,
//   });
//
//   factory ProductData.fromJson(Map<String, dynamic> json) {
//     return ProductData(
//       total: json['total'] ?? 0,
//       categories: (json['categories'] as List<dynamic>? ?? [])
//           .map((e) => Category.fromJson(e))
//           .toList(),
//       items: (json['items'] as List<dynamic>? ?? [])
//           .map((e) => ProductItem.fromJson(e))
//           .toList(),
//     );
//   }
// }
//
// class Category {
//   final String slug;
//   final String label;
//   final int count;
//
//   Category({required this.slug, required this.label, required this.count});
//
//   factory Category.fromJson(Map<String, dynamic> json) {
//     return Category(
//       slug: json['slug'] ?? '',
//       label: json['label'] ?? '',
//       count: json['count'] ?? 0,
//     );
//   }
// }
//
// class ProductItem {
//   final String id;
//   final String? englishName;
//   final String? tamilName;
//   final String? category;
//   final String? categoryLabel;
//   final String? subCategory;
//   final String? subCategoryLabel;
//   final double? price;
//   final double? offerPrice;
//   final String? imageUrl;
//   final String? unitLabel;
//   final int? stockCount;
//   final bool isFeatured;
//   final String? offerLabel;
//   final String? offerValue;
//   final String? description;
//   final List<String> keywords;
//   final int? readyTimeMinutes;
//   final bool doorDelivery;
//   final String status;
//   final List<ProductFeature> features;
//   final bool hasVariants;
//
//   ProductItem({
//     required this.id,
//     this.englishName,
//     this.tamilName,
//     this.category,
//     this.categoryLabel,
//     this.subCategory,
//     this.subCategoryLabel,
//     this.price,
//     this.offerPrice,
//     this.imageUrl,
//     this.unitLabel,
//     this.stockCount,
//     required this.isFeatured,
//     this.offerLabel,
//     this.offerValue,
//     this.description,
//     required this.keywords,
//     this.readyTimeMinutes,
//     required this.doorDelivery,
//     required this.status,
//     required this.features,
//     required this.hasVariants,
//   });
//
//   factory ProductItem.fromJson(Map<String, dynamic> json) {
//     return ProductItem(
//       id: json['id'] ?? '',
//       englishName: json['englishName'],
//       tamilName: json['tamilName'],
//       category: json['category'],
//       categoryLabel: json['categoryLabel'],
//       subCategory: json['subCategory'],
//       subCategoryLabel: json['subCategoryLabel'],
//       price: (json['price'] is int)
//           ? (json['price'] as int).toDouble()
//           : json['price'],
//       offerPrice: (json['offerPrice'] is int)
//           ? (json['offerPrice'] as int).toDouble()
//           : json['offerPrice'],
//       imageUrl: json['imageUrl'],
//       unitLabel: json['unitLabel'],
//       stockCount: json['stockCount'],
//       isFeatured: json['isFeatured'] ?? false,
//       offerLabel: json['offerLabel'],
//       offerValue: json['offerValue'],
//       description: json['description'],
//       keywords: (json['keywords'] as List<dynamic>? ?? [])
//           .map((e) => e.toString())
//           .toList(),
//       readyTimeMinutes: json['readyTimeMinutes'],
//       doorDelivery: json['doorDelivery'] ?? false,
//       status: json['status'] ?? '',
//       features: (json['features'] as List<dynamic>? ?? [])
//           .map((e) => ProductFeature.fromJson(e))
//           .toList(),
//       hasVariants: json['hasVariants'] ?? false,
//     );
//   }
// }
//
// class ProductFeature {
//   final String id;
//   final String label;
//   final String value;
//   final String? language;
//
//   ProductFeature({
//     required this.id,
//     required this.label,
//     required this.value,
//     this.language,
//   });
//
//   factory ProductFeature.fromJson(Map<String, dynamic> json) {
//     return ProductFeature(
//       id: json['id'] ?? '',
//       label: json['label'] ?? '',
//       value: json['value'] ?? '',
//       language: json['language'],
//     );
//   }
// }
