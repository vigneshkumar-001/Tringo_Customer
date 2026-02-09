class ProductDetailResponse {
  final bool status;
  final ProductDetailsData data;

  ProductDetailResponse({required this.status, required this.data});

  factory ProductDetailResponse.fromJson(Map<String, dynamic> json) {
    return ProductDetailResponse(
      status: json['status'] ?? false,
      data: ProductDetailsData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'data': data.toJson()};
  }
}

class ProductDetailsData {
  final Product product;
  final Shop shop;
  final PagedProducts similarProducts;
  final List<Shop> peopleAlsoViewed; // 👈 changed to Shop
  final Reviews reviews;

  ProductDetailsData({
    required this.product,
    required this.shop,
    required this.similarProducts,
    required this.peopleAlsoViewed,
    required this.reviews,
  });

  factory ProductDetailsData.fromJson(Map<String, dynamic> json) {
    return ProductDetailsData(
      product: Product.fromJson(json['product'] ?? {}),
      shop: Shop.fromJson(json['shop'] ?? {}),
      similarProducts: PagedProducts.fromJson(json['similarProducts'] ?? {}),
      peopleAlsoViewed: (json['peopleAlsoViewed'] as List? ?? [])
          .map((e) => Shop.fromJson(e ?? {}))
          .toList(),
      reviews: Reviews.fromJson(json['reviews'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'shop': shop.toJson(),
      'similarProducts': similarProducts.toJson(),
      'peopleAlsoViewed': peopleAlsoViewed.map((e) => e.toJson()).toList(),
      'reviews': reviews.toJson(),
    };
  }
}

class Product {
  final String kind; // 👈 NEW
  final String id;
  final String englishName;
  final String? tamilName;
  final String category;
  final String categoryLabel;
  final String subCategory;
  final String subCategoryLabel;
  final double price;
  final double offerPrice;
  final String imageUrl;
  final String? unitLabel;
  final int? stockCount;
  final bool isFeatured;
  final String? offerLabel;
  final String? offerValue;
  final String description;
  final List<String> keywords;
  final int? readyTimeMinutes;
  final bool doorDelivery;
  final String status;
  final int rating;
  final int ratingCount;
  final List<Feature> features;
  final bool hasVariants;
  final List<Media> media;
  final List<Feature> highlights;
  final List<Sku> skus;
  final int reviewCount;

  Product({
    required this.kind,
    required this.id,
    required this.englishName,
    this.tamilName,
    required this.category,
    required this.categoryLabel,
    required this.subCategory,
    required this.subCategoryLabel,
    required this.price,
    required this.offerPrice,
    required this.imageUrl,
    this.unitLabel,
    this.stockCount,
    required this.isFeatured,
    this.offerLabel,
    this.offerValue,
    required this.description,
    required this.keywords,
    this.readyTimeMinutes,
    required this.doorDelivery,
    required this.status,
    required this.rating,
    required this.ratingCount,
    required this.features,
    required this.hasVariants,
    required this.media,
    required this.highlights,
    required this.skus,
    required this.reviewCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      kind: json['kind'] ?? '',
      id: json['id'] ?? '',
      englishName: json['englishName'] ?? '',
      tamilName: json['tamilName'],
      category: json['category'] ?? '',
      categoryLabel: json['categoryLabel'] ?? '',
      subCategory: json['subCategory'] ?? '',
      subCategoryLabel: json['subCategoryLabel'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      offerPrice: (json['offerPrice'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] ?? '',
      unitLabel: json['unitLabel'],
      stockCount: json['stockCount'],
      isFeatured: json['isFeatured'] ?? false,
      offerLabel: json['offerLabel'],
      offerValue: json['offerValue'],
      description: json['description'] ?? '',
      keywords: (json['keywords'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      readyTimeMinutes: json['readyTimeMinutes'],
      doorDelivery: json['doorDelivery'] ?? false,
      status: json['status'] ?? '',
      rating: json['rating'] ?? 0,
      ratingCount: json['ratingCount'] ?? 0,
      features: (json['features'] as List? ?? [])
          .map((e) => Feature.fromJson(e ?? {}))
          .toList(),
      hasVariants: json['hasVariants'] ?? false,
      media: (json['media'] as List? ?? [])
          .map((e) => Media.fromJson(e ?? {}))
          .toList(),
      highlights: (json['highlights'] as List? ?? [])
          .map((e) => Feature.fromJson(e ?? {}))
          .toList(),
      skus: (json['skus'] as List? ?? [])
          .map((e) => Sku.fromJson(e ?? {}))
          .toList(),
      reviewCount: json['reviewCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kind': kind,
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
      'rating': rating,
      'ratingCount': ratingCount,
      'features': features.map((e) => e.toJson()).toList(),
      'hasVariants': hasVariants,
      'media': media.map((e) => e.toJson()).toList(),
      'highlights': highlights.map((e) => e.toJson()).toList(),
      'skus': skus.map((e) => e.toJson()).toList(),
      'reviewCount': reviewCount,
    };
  }
}

class Feature {
  final String id;
  final String label;
  final String value;
  final String? language;

  Feature({
    required this.id,
    required this.label,
    required this.value,
    this.language,
  });

  factory Feature.fromJson(Map<String, dynamic> json) {
    return Feature(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      value: json['value'] ?? '',
      language: json['language'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'label': label, 'value': value, 'language': language};
  }
}

class Media {
  final String id;
  final String url;
  final int displayOrder;

  Media({required this.id, required this.url, required this.displayOrder});

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      displayOrder: json['displayOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'url': url, 'displayOrder': displayOrder};
  }
}

class Sku {
  final String id;
  final double mrp;
  final double price;
  final int stockQty;
  final bool isPrimary;
  final String? variantLabel;
  final String? weightLabel;
  final String? barcode;
  final bool active;

  Sku({
    required this.id,
    required this.mrp,
    required this.price,
    required this.stockQty,
    required this.isPrimary,
    this.variantLabel,
    this.weightLabel,
    this.barcode,
    required this.active,
  });

  factory Sku.fromJson(Map<String, dynamic> json) {
    return Sku(
      id: json['id'] ?? '',
      mrp: (json['mrp'] as num?)?.toDouble() ?? 0.0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stockQty: json['stockQty'] ?? 0,
      isPrimary: json['isPrimary'] ?? false,
      variantLabel: json['variantLabel'],
      weightLabel: json['weightLabel'],
      barcode: json['barcode'],
      active: json['active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mrp': mrp,
      'price': price,
      'stockQty': stockQty,
      'isPrimary': isPrimary,
      'variantLabel': variantLabel,
      'weightLabel': weightLabel,
      'barcode': barcode,
      'active': active,
    };
  }
}

class Shop {
  final String id;
  final String englishName;
  final String? tamilName;
  final String category;
  final String subCategory;
  final String city;
  final String state;
  final String country;

  // extra fields from JSON
  final String? ownershipType;
  final double? gpsLatitude;
  final double? gpsLongitude;
  final List<dynamic> shopWeeklyHours;

  final int rating;
  final int ratingCount;
  final bool isTrusted;
  final bool doorDelivery;
  final String shopKind;
  final String primaryPhone;
  final double? distanceKm;
  final String? distanceLabel;
  final String? openLabel;
  final bool isOpen;
  final String primaryImageUrl;
  final String? closeTime;

  Shop({
    required this.id,
    required this.englishName,
    this.tamilName,
    required this.category,
    required this.subCategory,
    required this.city,
    required this.state,
    required this.country,
    this.ownershipType,
    this.gpsLatitude,
    this.gpsLongitude,
    this.shopWeeklyHours = const [],
    required this.rating,
    required this.ratingCount,
    required this.isTrusted,
    required this.doorDelivery,
    required this.shopKind,
    required this.primaryPhone,
    this.distanceKm,
    this.distanceLabel,
    this.openLabel,
    required this.isOpen,
    required this.primaryImageUrl,
    this.closeTime,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] ?? '',
      englishName: json['englishName'] ?? '',
      tamilName: json['tamilName'],
      category: json['category'] ?? '',
      subCategory: json['subCategory'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',

      ownershipType: json['ownershipType'],
      gpsLatitude: parseDoubleNullable(json['gpsLatitude']),
      gpsLongitude: parseDoubleNullable(json['gpsLongitude']),
      shopWeeklyHours: (json['shopWeeklyHours'] as List? ?? []),

      // ✅ FIX HERE
      rating: parseInt(json['rating']),
      ratingCount: parseInt(json['ratingCount']),

      isTrusted: json['isTrusted'] ?? false,
      doorDelivery: json['doorDelivery'] ?? false,
      shopKind: json['shopKind'] ?? '',
      primaryPhone: json['primaryPhone'] ?? '',
      distanceKm: parseDoubleNullable(json['distanceKm']),
      distanceLabel: json['distanceLabel'],
      openLabel: json['openLabel'],
      isOpen: json['isOpen'] ?? false,
      primaryImageUrl: json['primaryImageUrl'] ?? '',
      closeTime: json['closeTime'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'englishName': englishName,
      'tamilName': tamilName,
      'category': category,
      'subCategory': subCategory,
      'city': city,
      'state': state,
      'country': country,
      'ownershipType': ownershipType,
      'gpsLatitude': gpsLatitude,
      'gpsLongitude': gpsLongitude,
      'shopWeeklyHours': shopWeeklyHours,
      'rating': rating,
      'ratingCount': ratingCount,
      'isTrusted': isTrusted,
      'doorDelivery': doorDelivery,
      'shopKind': shopKind,
      'primaryPhone': primaryPhone,
      'distanceKm': distanceKm,
      'distanceLabel': distanceLabel,
      'openLabel': openLabel,
      'isOpen': isOpen,
      'primaryImageUrl': primaryImageUrl,
      'closeTime': closeTime,
    };
  }
}

class PagedProducts {
  final int total;
  final List<SimilarProduct> items;

  PagedProducts({required this.total, required this.items});

  factory PagedProducts.fromJson(Map<String, dynamic> json) {
    return PagedProducts(
      total: json['total'] ?? 0,
      items: (json['items'] as List? ?? [])
          .map((e) => SimilarProduct.fromJson(e ?? {}))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'total': total, 'items': items.map((e) => e.toJson()).toList()};
  }
}

class SimilarProduct {
  final String id;
  final String englishName;
  final String? tamilName;
  final String category;
  final String categoryLabel;
  final String subCategory;
  final String subCategoryLabel;
  final double price;
  final double offerPrice;
  final String imageUrl;
  final String? unitLabel;
  final int? stockCount;
  final bool isFeatured;
  final String? offerLabel;
  final String? offerValue;
  final String description;
  final List<String> keywords;
  final int? readyTimeMinutes;
  final bool doorDelivery;
  final String status;
  final int rating;
  final int ratingCount;
  final List<Feature> features;
  final bool hasVariants;
  final String? distanceLabel;
  final String? shopName;

  SimilarProduct({
    required this.id,
    required this.englishName,
    this.tamilName,
    required this.category,
    required this.categoryLabel,
    required this.subCategory,
    required this.subCategoryLabel,
    required this.price,
    required this.offerPrice,
    required this.imageUrl,
    this.unitLabel,
    this.stockCount,
    required this.isFeatured,
    this.offerLabel,
    this.offerValue,
    required this.description,
    required this.keywords,
    this.readyTimeMinutes,
    required this.doorDelivery,
    required this.status,
    required this.rating,
    required this.ratingCount,
    required this.features,
    required this.hasVariants,
    this.distanceLabel,
    this.shopName,
  });

  factory SimilarProduct.fromJson(Map<String, dynamic> json) {
    return SimilarProduct(
      id: json['id'] ?? '',
      englishName: json['englishName'] ?? '',
      tamilName: json['tamilName'],
      category: json['category'] ?? '',
      categoryLabel: json['categoryLabel'] ?? '',
      subCategory: json['subCategory'] ?? '',
      subCategoryLabel: json['subCategoryLabel'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      offerPrice: (json['offerPrice'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] ?? '',
      unitLabel: json['unitLabel'],
      stockCount: json['stockCount'],
      isFeatured: json['isFeatured'] ?? false,
      offerLabel: json['offerLabel'],
      offerValue: json['offerValue'],
      description: json['description'] ?? '',
      keywords: (json['keywords'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      readyTimeMinutes: json['readyTimeMinutes'],
      doorDelivery: json['doorDelivery'] ?? false,
      status: json['status'] ?? '',
      rating: json['rating'] ?? 0,
      ratingCount: json['ratingCount'] ?? 0,
      features: (json['features'] as List? ?? [])
          .map((e) => Feature.fromJson(e ?? {}))
          .toList(),
      hasVariants: json['hasVariants'] ?? false,
      distanceLabel: json['distanceLabel'],
      shopName: json['shopName'] ?? json['shop']?['englishName'],
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
      'rating': rating,
      'ratingCount': ratingCount,
      'features': features.map((e) => e.toJson()).toList(),
      'hasVariants': hasVariants,
      'distanceLabel': distanceLabel,
      'shopName': shopName
    };
  }
}

class Reviews {
  final ReviewSummary summary;
  final List<ReviewItem> items;

  Reviews({required this.summary, required this.items});

  factory Reviews.fromJson(Map<String, dynamic> json) {
    return Reviews(
      summary: ReviewSummary.fromJson(json['summary'] ?? {}),
      items: (json['items'] as List? ?? [])
          .map((e) => ReviewItem.fromJson(e ?? {}))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary.toJson(),
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class ReviewSummary {
  final double rating;
  final int count;

  ReviewSummary({required this.rating, required this.count});

  factory ReviewSummary.fromJson(Map<String, dynamic> json) {
    return ReviewSummary(
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'rating': rating, 'count': count};
  }
}
int parseInt(dynamic v, {int def = 0}) {
  if (v == null) return def;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? double.tryParse(v)?.toInt() ?? def;
  return def;
}

double? parseDoubleNullable(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

double parseDouble(dynamic v, {double def = 0.0}) {
  return parseDoubleNullable(v) ?? def;
}


/// If later API gives you review item fields, extend this.
class ReviewItem {
  // Placeholder – adjust based on real API
  ReviewItem();

  factory ReviewItem.fromJson(Map<String, dynamic> json) {
    return ReviewItem();
  }

  Map<String, dynamic> toJson() {
    return {};
  }
}

// class ProductDetailResponse {
//   final bool status;
//   final ProductDetailsData data;
//
//   ProductDetailResponse({required this.status, required this.data});
//
//   factory ProductDetailResponse.fromJson(Map<String, dynamic> json) {
//     return ProductDetailResponse(
//       status: json['status'] ?? false,
//       data: ProductDetailsData.fromJson(json['data'] ?? {}),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {'status': status, 'data': data.toJson()};
//   }
// }
//
// class ProductDetailsData {
//   final Product product;
//   final Shop shop;
//   final PagedProducts similarProducts;
//   final List<SimilarProduct> peopleAlsoViewed;
//   final Reviews reviews;
//
//   ProductDetailsData({
//     required this.product,
//     required this.shop,
//     required this.similarProducts,
//     required this.peopleAlsoViewed,
//     required this.reviews,
//   });
//
//   factory ProductDetailsData.fromJson(Map<String, dynamic> json) {
//     return ProductDetailsData(
//       product: Product.fromJson(json['product'] ?? {}),
//       shop: Shop.fromJson(json['shop'] ?? {}),
//       similarProducts: PagedProducts.fromJson(json['similarProducts'] ?? {}),
//       peopleAlsoViewed: (json['peopleAlsoViewed'] as List? ?? [])
//           .map((e) => SimilarProduct.fromJson(e ?? {}))
//           .toList(),
//       reviews: Reviews.fromJson(json['reviews'] ?? {}),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'product': product.toJson(),
//       'shop': shop.toJson(),
//       'similarProducts': similarProducts.toJson(),
//       'peopleAlsoViewed': peopleAlsoViewed.map((e) => e.toJson()).toList(),
//       'reviews': reviews.toJson(),
//     };
//   }
// }
//
// class Product {
//   final String id;
//   final String englishName;
//   final String? tamilName;
//   final String category;
//   final String categoryLabel;
//   final String subCategory;
//   final String subCategoryLabel;
//   final double price;
//   final double offerPrice;
//   final String imageUrl;
//   final String? unitLabel;
//   final int? stockCount;
//   final bool isFeatured;
//   final String? offerLabel;
//   final String? offerValue;
//   final String description;
//   final List<String> keywords;
//   final int? readyTimeMinutes;
//   final bool doorDelivery;
//   final String status;
//   final int rating;
//   final int ratingCount;
//   final List<Feature> features;
//   final bool hasVariants;
//   final List<Media> media;
//   final List<Feature> highlights;
//   final List<Sku> skus;
//   final int reviewCount;
//
//   Product({
//     required this.id,
//     required this.englishName,
//     this.tamilName,
//     required this.category,
//     required this.categoryLabel,
//     required this.subCategory,
//     required this.subCategoryLabel,
//     required this.price,
//     required this.offerPrice,
//     required this.imageUrl,
//     this.unitLabel,
//     this.stockCount,
//     required this.isFeatured,
//     this.offerLabel,
//     this.offerValue,
//     required this.description,
//     required this.keywords,
//     this.readyTimeMinutes,
//     required this.doorDelivery,
//     required this.status,
//     required this.rating,
//     required this.ratingCount,
//     required this.features,
//     required this.hasVariants,
//     required this.media,
//     required this.highlights,
//     required this.skus,
//     required this.reviewCount,
//   });
//
//   factory Product.fromJson(Map<String, dynamic> json) {
//     return Product(
//       id: json['id'] ?? '',
//       englishName: json['englishName'] ?? '',
//       tamilName: json['tamilName'],
//       category: json['category'] ?? '',
//       categoryLabel: json['categoryLabel'] ?? '',
//       subCategory: json['subCategory'] ?? '',
//       subCategoryLabel: json['subCategoryLabel'] ?? '',
//       price: (json['price'] ?? 0).toDouble(),
//       offerPrice: (json['offerPrice'] ?? 0).toDouble(),
//       imageUrl: json['imageUrl'] ?? '',
//       unitLabel: json['unitLabel'],
//       stockCount: json['stockCount'],
//       isFeatured: json['isFeatured'] ?? false,
//       offerLabel: json['offerLabel'],
//       offerValue: json['offerValue'],
//       description: json['description'] ?? '',
//       keywords: (json['keywords'] as List? ?? [])
//           .map((e) => e.toString())
//           .toList(),
//       readyTimeMinutes: json['readyTimeMinutes'],
//       doorDelivery: json['doorDelivery'] ?? false,
//       status: json['status'] ?? '',
//       rating: json['rating'] ?? 0,
//       ratingCount: json['ratingCount'] ?? 0,
//       features: (json['features'] as List? ?? [])
//           .map((e) => Feature.fromJson(e ?? {}))
//           .toList(),
//       hasVariants: json['hasVariants'] ?? false,
//       media: (json['media'] as List? ?? [])
//           .map((e) => Media.fromJson(e ?? {}))
//           .toList(),
//       highlights: (json['highlights'] as List? ?? [])
//           .map((e) => Feature.fromJson(e ?? {}))
//           .toList(),
//       skus: (json['skus'] as List? ?? [])
//           .map((e) => Sku.fromJson(e ?? {}))
//           .toList(),
//       reviewCount: json['reviewCount'] ?? 0,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'englishName': englishName,
//       'tamilName': tamilName,
//       'category': category,
//       'categoryLabel': categoryLabel,
//       'subCategory': subCategory,
//       'subCategoryLabel': subCategoryLabel,
//       'price': price,
//       'offerPrice': offerPrice,
//       'imageUrl': imageUrl,
//       'unitLabel': unitLabel,
//       'stockCount': stockCount,
//       'isFeatured': isFeatured,
//       'offerLabel': offerLabel,
//       'offerValue': offerValue,
//       'description': description,
//       'keywords': keywords,
//       'readyTimeMinutes': readyTimeMinutes,
//       'doorDelivery': doorDelivery,
//       'status': status,
//       'rating': rating,
//       'ratingCount': ratingCount,
//       'features': features.map((e) => e.toJson()).toList(),
//       'hasVariants': hasVariants,
//       'media': media.map((e) => e.toJson()).toList(),
//       'highlights': highlights.map((e) => e.toJson()).toList(),
//       'skus': skus.map((e) => e.toJson()).toList(),
//       'reviewCount': reviewCount,
//     };
//   }
// }
//
// class Feature {
//   final String id;
//   final String label;
//   final String value;
//   final String? language;
//
//   Feature({
//     required this.id,
//     required this.label,
//     required this.value,
//     this.language,
//   });
//
//   factory Feature.fromJson(Map<String, dynamic> json) {
//     return Feature(
//       id: json['id'] ?? '',
//       label: json['label'] ?? '',
//       value: json['value'] ?? '',
//       language: json['language'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {'id': id, 'label': label, 'value': value, 'language': language};
//   }
// }
//
// class Media {
//   final String id;
//   final String url;
//   final int displayOrder;
//
//   Media({required this.id, required this.url, required this.displayOrder});
//
//   factory Media.fromJson(Map<String, dynamic> json) {
//     return Media(
//       id: json['id'] ?? '',
//       url: json['url'] ?? '',
//       displayOrder: json['displayOrder'] ?? 0,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {'id': id, 'url': url, 'displayOrder': displayOrder};
//   }
// }
//
// class Sku {
//   final String id;
//   final double mrp;
//   final double price;
//   final int stockQty;
//   final bool isPrimary;
//   final String? variantLabel;
//   final String? weightLabel;
//   final String? barcode;
//   final bool active;
//
//   Sku({
//     required this.id,
//     required this.mrp,
//     required this.price,
//     required this.stockQty,
//     required this.isPrimary,
//     this.variantLabel,
//     this.weightLabel,
//     this.barcode,
//     required this.active,
//   });
//
//   factory Sku.fromJson(Map<String, dynamic> json) {
//     return Sku(
//       id: json['id'] ?? '',
//       mrp: (json['mrp'] ?? 0).toDouble(),
//       price: (json['price'] ?? 0).toDouble(),
//       stockQty: json['stockQty'] ?? 0,
//       isPrimary: json['isPrimary'] ?? false,
//       variantLabel: json['variantLabel'],
//       weightLabel: json['weightLabel'],
//       barcode: json['barcode'],
//       active: json['active'] ?? false,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'mrp': mrp,
//       'price': price,
//       'stockQty': stockQty,
//       'isPrimary': isPrimary,
//       'variantLabel': variantLabel,
//       'weightLabel': weightLabel,
//       'barcode': barcode,
//       'active': active,
//     };
//   }
// }
//
// class Shop {
//   final String id;
//   final String englishName;
//   final String? tamilName;
//   final String category;
//   final String subCategory;
//   final String city;
//   final String state;
//   final String country;
//   final int rating;
//   final int ratingCount;
//   final bool isTrusted;
//   final bool doorDelivery;
//   final String shopKind;
//   final String primaryPhone;
//   final double? distanceKm;
//   final String? distanceLabel;
//   final String? openLabel;
//   final bool isOpen;
//   final String primaryImageUrl;
//
//   Shop({
//     required this.id,
//     required this.englishName,
//     this.tamilName,
//     required this.category,
//     required this.subCategory,
//     required this.city,
//     required this.state,
//     required this.country,
//     required this.rating,
//     required this.ratingCount,
//     required this.isTrusted,
//     required this.doorDelivery,
//     required this.shopKind,
//     required this.primaryPhone,
//     this.distanceKm,
//     this.distanceLabel,
//     this.openLabel,
//     required this.isOpen,
//     required this.primaryImageUrl,
//   });
//
//   factory Shop.fromJson(Map<String, dynamic> json) {
//     return Shop(
//       id: json['id'] ?? '',
//       englishName: json['englishName'] ?? '',
//       tamilName: json['tamilName'],
//       category: json['category'] ?? '',
//       subCategory: json['subCategory'] ?? '',
//       city: json['city'] ?? '',
//       state: json['state'] ?? '',
//       country: json['country'] ?? '',
//       rating: json['rating'] ?? 0,
//       ratingCount: json['ratingCount'] ?? 0,
//       isTrusted: json['isTrusted'] ?? false,
//       doorDelivery: json['doorDelivery'] ?? false,
//       shopKind: json['shopKind'] ?? '',
//       primaryPhone: json['primaryPhone'] ?? '',
//       distanceKm: (json['distanceKm'] != null)
//           ? (json['distanceKm'] as num).toDouble()
//           : null,
//       distanceLabel: json['distanceLabel'],
//       openLabel: json['openLabel'],
//       isOpen: json['isOpen'] ?? false,
//       primaryImageUrl: json['primaryImageUrl'] ?? '',
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'englishName': englishName,
//       'tamilName': tamilName,
//       'category': category,
//       'subCategory': subCategory,
//       'city': city,
//       'state': state,
//       'country': country,
//       'rating': rating,
//       'ratingCount': ratingCount,
//       'isTrusted': isTrusted,
//       'doorDelivery': doorDelivery,
//       'shopKind': shopKind,
//       'primaryPhone': primaryPhone,
//       'distanceKm': distanceKm,
//       'distanceLabel': distanceLabel,
//       'openLabel': openLabel,
//       'isOpen': isOpen,
//       'primaryImageUrl': primaryImageUrl,
//     };
//   }
// }
//
// class PagedProducts {
//   final int total;
//   final List<SimilarProduct> items;
//
//   PagedProducts({required this.total, required this.items});
//
//   factory PagedProducts.fromJson(Map<String, dynamic> json) {
//     return PagedProducts(
//       total: json['total'] ?? 0,
//       items: (json['items'] as List? ?? [])
//           .map((e) => SimilarProduct.fromJson(e ?? {}))
//           .toList(),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {'total': total, 'items': items.map((e) => e.toJson()).toList()};
//   }
// }
//
// class SimilarProduct {
//   final String id;
//   final String englishName;
//   final String? tamilName;
//   final String category;
//   final String categoryLabel;
//   final String subCategory;
//   final String subCategoryLabel;
//   final double price;
//   final double offerPrice;
//   final String imageUrl;
//   final String? unitLabel;
//   final int? stockCount;
//   final bool isFeatured;
//   final String? offerLabel;
//   final String? offerValue;
//   final String description;
//   final List<String> keywords;
//   final int? readyTimeMinutes;
//   final bool doorDelivery;
//   final String status;
//   final int rating;
//   final int ratingCount;
//   final List<Feature> features;
//   final bool hasVariants;
//
//   SimilarProduct({
//     required this.id,
//     required this.englishName,
//     this.tamilName,
//     required this.category,
//     required this.categoryLabel,
//     required this.subCategory,
//     required this.subCategoryLabel,
//     required this.price,
//     required this.offerPrice,
//     required this.imageUrl,
//     this.unitLabel,
//     this.stockCount,
//     required this.isFeatured,
//     this.offerLabel,
//     this.offerValue,
//     required this.description,
//     required this.keywords,
//     this.readyTimeMinutes,
//     required this.doorDelivery,
//     required this.status,
//     required this.rating,
//     required this.ratingCount,
//     required this.features,
//     required this.hasVariants,
//   });
//
//   factory SimilarProduct.fromJson(Map<String, dynamic> json) {
//     return SimilarProduct(
//       id: json['id'] ?? '',
//       englishName: json['englishName'] ?? '',
//       tamilName: json['tamilName'],
//       category: json['category'] ?? '',
//       categoryLabel: json['categoryLabel'] ?? '',
//       subCategory: json['subCategory'] ?? '',
//       subCategoryLabel: json['subCategoryLabel'] ?? '',
//       price: (json['price'] ?? 0).toDouble(),
//       offerPrice: (json['offerPrice'] ?? 0).toDouble(),
//       imageUrl: json['imageUrl'] ?? '',
//       unitLabel: json['unitLabel'],
//       stockCount: json['stockCount'],
//       isFeatured: json['isFeatured'] ?? false,
//       offerLabel: json['offerLabel'],
//       offerValue: json['offerValue'],
//       description: json['description'] ?? '',
//       keywords: (json['keywords'] as List? ?? [])
//           .map((e) => e.toString())
//           .toList(),
//       readyTimeMinutes: json['readyTimeMinutes'],
//       doorDelivery: json['doorDelivery'] ?? false,
//       status: json['status'] ?? '',
//       rating: json['rating'] ?? 0,
//       ratingCount: json['ratingCount'] ?? 0,
//       features: (json['features'] as List? ?? [])
//           .map((e) => Feature.fromJson(e ?? {}))
//           .toList(),
//       hasVariants: json['hasVariants'] ?? false,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'englishName': englishName,
//       'tamilName': tamilName,
//       'category': category,
//       'categoryLabel': categoryLabel,
//       'subCategory': subCategory,
//       'subCategoryLabel': subCategoryLabel,
//       'price': price,
//       'offerPrice': offerPrice,
//       'imageUrl': imageUrl,
//       'unitLabel': unitLabel,
//       'stockCount': stockCount,
//       'isFeatured': isFeatured,
//       'offerLabel': offerLabel,
//       'offerValue': offerValue,
//       'description': description,
//       'keywords': keywords,
//       'readyTimeMinutes': readyTimeMinutes,
//       'doorDelivery': doorDelivery,
//       'status': status,
//       'rating': rating,
//       'ratingCount': ratingCount,
//       'features': features.map((e) => e.toJson()).toList(),
//       'hasVariants': hasVariants,
//     };
//   }
// }
//
// class Reviews {
//   final ReviewSummary summary;
//   final List<ReviewItem> items;
//
//   Reviews({required this.summary, required this.items});
//
//   factory Reviews.fromJson(Map<String, dynamic> json) {
//     return Reviews(
//       summary: ReviewSummary.fromJson(json['summary'] ?? {}),
//       items: (json['items'] as List? ?? [])
//           .map((e) => ReviewItem.fromJson(e ?? {}))
//           .toList(),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'summary': summary.toJson(),
//       'items': items.map((e) => e.toJson()).toList(),
//     };
//   }
// }
//
// class ReviewSummary {
//   final double rating;
//   final int count;
//
//   ReviewSummary({required this.rating, required this.count});
//
//   factory ReviewSummary.fromJson(Map<String, dynamic> json) {
//     return ReviewSummary(
//       rating: (json['rating'] ?? 0).toDouble(),
//       count: json['count'] ?? 0,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {'rating': rating, 'count': count};
//   }
// }
//
// /// If later API gives you review item fields, extend this.
// class ReviewItem {
//   // Placeholder – adjust based on real API
//   ReviewItem();
//
//   factory ReviewItem.fromJson(Map<String, dynamic> json) {
//     return ReviewItem();
//   }
//
//   Map<String, dynamic> toJson() {
//     return {};
//   }
// }
