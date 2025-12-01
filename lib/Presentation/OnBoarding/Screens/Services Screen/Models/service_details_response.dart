class    ServiceDetailsResponse    {
  final bool status;
  final ServiceData? data;

  ServiceDetailsResponse({required this.status, this.data});

  factory ServiceDetailsResponse.fromJson(Map<String, dynamic> json) => ServiceDetailsResponse(
    status: json['status'] ?? false,
    data: json['data'] != null ? ServiceData.fromJson(json['data']) : null,
  );

  Map<String, dynamic> toJson() => {
    'status': status,
    'data': data?.toJson(),
  };
}

class ServiceData {
  final String? id;
  final String? createdAt;
  final String? updatedAt;
  final String? category;
  final String? subCategory;
  final String? shopKind;
  final String? englishName;
  final String? tamilName;
  final String? descriptionEn;
  final String? descriptionTa;
  final String? addressEn;
  final String? addressTa;
  final String? gpsLatitude;
  final String? gpsLongitude;
  final String? primaryPhone;
  final String? alternatePhone;
  final String? contactEmail;
  final String? ownerImageUrl;
  final bool? doorDelivery;
  final bool? isTrusted;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final List<String>? serviceTags;
  final Map<String, dynamic>? weeklyHours;
  final String? averageRating;
  final int? reviewCount;
  final String? status;
  final List<Media>? media;
  final List<Keyword>? keywords;
  final List<Product>? products; // Updated
  final List<Service>? services;
  final List<dynamic>? reviews;
  final List<dynamic>? offers;
  final ProductSummary? productSummary;
  final List<ProductCategory>? productCategories;
  final ServiceSummary? serviceSummary;
  final int? rating;

  ServiceData({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.category,
    this.subCategory,
    this.shopKind,
    this.englishName,
    this.tamilName,
    this.descriptionEn,
    this.descriptionTa,
    this.addressEn,
    this.addressTa,
    this.gpsLatitude,
    this.gpsLongitude,
    this.primaryPhone,
    this.alternatePhone,
    this.contactEmail,
    this.ownerImageUrl,
    this.doorDelivery,
    this.isTrusted,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.serviceTags,
    this.weeklyHours,
    this.averageRating,
    this.reviewCount,
    this.status,
    this.media,
    this.keywords,
    this.products,
    this.services,
    this.reviews,
    this.offers,
    this.productSummary,
    this.productCategories,
    this.serviceSummary,
    this.rating,
  });

  factory ServiceData.fromJson(Map<String, dynamic> json) => ServiceData(
    id: json['id'],
    createdAt: json['createdAt'],
    updatedAt: json['updatedAt'],
    category: json['category'],
    subCategory: json['subCategory'],
    shopKind: json['shopKind'],
    englishName: json['englishName'],
    tamilName: json['tamilName'],
    descriptionEn: json['descriptionEn'],
    descriptionTa: json['descriptionTa'],
    addressEn: json['addressEn'],
    addressTa: json['addressTa'],
    gpsLatitude: json['gpsLatitude'],
    gpsLongitude: json['gpsLongitude'],
    primaryPhone: json['primaryPhone'],
    alternatePhone: json['alternatePhone'],
    contactEmail: json['contactEmail'],
    ownerImageUrl: json['ownerImageUrl'],
    doorDelivery: json['doorDelivery'],
    isTrusted: json['isTrusted'],
    city: json['city'],
    state: json['state'],
    country: json['country'],
    postalCode: json['postalCode'],
    serviceTags: json['serviceTags'] != null
        ? List<String>.from(json['serviceTags'])
        : null,
    weeklyHours: json['weeklyHours'],
    averageRating: json['averageRating'],
    reviewCount: json['reviewCount'],
    status: json['status'],
    media: json['media'] != null
        ? List<Media>.from(json['media'].map((x) => Media.fromJson(x)))
        : null,
    keywords: json['keywords'] != null
        ? List<Keyword>.from(json['keywords'].map((x) => Keyword.fromJson(x)))
        : null,
    products: json['products'] != null
        ? List<Product>.from(json['products'].map((x) => Product.fromJson(x)))
        : null, // updated
    services: json['services'] != null
        ? List<Service>.from(json['services'].map((x) => Service.fromJson(x)))
        : null,
    reviews: json['reviews'] != null ? List<dynamic>.from(json['reviews']) : null,
    offers: json['offers'] != null ? List<dynamic>.from(json['offers']) : null,
    productSummary: json['productSummary'] != null
        ? ProductSummary.fromJson(json['productSummary'])
        : null,
    productCategories: json['productCategories'] != null
        ? List<ProductCategory>.from(
        json['productCategories'].map((x) => ProductCategory.fromJson(x)))
        : null,
    serviceSummary: json['serviceSummary'] != null
        ? ServiceSummary.fromJson(json['serviceSummary'])
        : null,
    rating: json['rating'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'category': category,
    'subCategory': subCategory,
    'shopKind': shopKind,
    'englishName': englishName,
    'tamilName': tamilName,
    'descriptionEn': descriptionEn,
    'descriptionTa': descriptionTa,
    'addressEn': addressEn,
    'addressTa': addressTa,
    'gpsLatitude': gpsLatitude,
    'gpsLongitude': gpsLongitude,
    'primaryPhone': primaryPhone,
    'alternatePhone': alternatePhone,
    'contactEmail': contactEmail,
    'ownerImageUrl': ownerImageUrl,
    'doorDelivery': doorDelivery,
    'isTrusted': isTrusted,
    'city': city,
    'state': state,
    'country': country,
    'postalCode': postalCode,
    'serviceTags': serviceTags,
    'weeklyHours': weeklyHours,
    'averageRating': averageRating,
    'reviewCount': reviewCount,
    'status': status,
    'media': media?.map((x) => x.toJson()).toList(),
    'keywords': keywords?.map((x) => x.toJson()).toList(),
    'products': products?.map((x) => x.toJson()).toList(), // updated
    'services': services?.map((x) => x.toJson()).toList(),
    'reviews': reviews,
    'offers': offers,
    'productSummary': productSummary?.toJson(),
    'productCategories': productCategories?.map((x) => x.toJson()).toList(),
    'serviceSummary': serviceSummary?.toJson(),
    'rating': rating,
  };
}

class Media {
  final String? id;
  final String? createdAt;
  final String? updatedAt;
  final String? type;
  final String? url;
  final int? displayOrder;

  Media({this.id, this.createdAt, this.updatedAt, this.type, this.url, this.displayOrder});

  factory Media.fromJson(Map<String, dynamic> json) => Media(
    id: json['id'],
    createdAt: json['createdAt'],
    updatedAt: json['updatedAt'],
    type: json['type'],
    url: json['url'],
    displayOrder: json['displayOrder'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'type': type,
    'url': url,
    'displayOrder': displayOrder,
  };
}

class Product {
  final String? id;
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
  final bool? isFeatured;
  final String? offerLabel;
  final String? offerValue;
  final String? description;
  final List<String>? keywords;
  final int? readyTimeMinutes;
  final bool? doorDelivery;
  final String? status;
  final List<ProductFeature>? features;
  final bool? hasVariants;

  Product({
    this.id,
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
    this.isFeatured,
    this.offerLabel,
    this.offerValue,
    this.description,
    this.keywords,
    this.readyTimeMinutes,
    this.doorDelivery,
    this.status,
    this.features,
    this.hasVariants,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    englishName: json['englishName'],
    tamilName: json['tamilName'],
    category: json['category'],
    categoryLabel: json['categoryLabel'],
    subCategory: json['subCategory'],
    subCategoryLabel: json['subCategoryLabel'],
    price: json['price'] != null ? (json['price'] as num).toDouble() : null,
    offerPrice: json['offerPrice'] != null ? (json['offerPrice'] as num).toDouble() : null,
    imageUrl: json['imageUrl'],
    unitLabel: json['unitLabel'],
    stockCount: json['stockCount'],
    isFeatured: json['isFeatured'],
    offerLabel: json['offerLabel'],
    offerValue: json['offerValue'],
    description: json['description'],
    keywords: json['keywords'] != null ? List<String>.from(json['keywords']) : null,
    readyTimeMinutes: json['readyTimeMinutes'],
    doorDelivery: json['doorDelivery'],
    status: json['status'],
    features: json['features'] != null
        ? List<ProductFeature>.from(json['features'].map((x) => ProductFeature.fromJson(x)))
        : null,
    hasVariants: json['hasVariants'],
  );

  Map<String, dynamic> toJson() => {
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
    'features': features?.map((x) => x.toJson()).toList(),
    'hasVariants': hasVariants,
  };
}

class ProductFeature {
  final String? id;
  final String? label;
  final String? value;
  final String? language;

  ProductFeature({this.id, this.label, this.value, this.language});

  factory ProductFeature.fromJson(Map<String, dynamic> json) => ProductFeature(
    id: json['id'],
    label: json['label'],
    value: json['value'],
    language: json['language'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'value': value,
    'language': language,
  };
}

class Keyword {
  final String? id;
  final String? createdAt;
  final String? updatedAt;
  final String? keyword;
  final String? category;

  Keyword({this.id, this.createdAt, this.updatedAt, this.keyword, this.category});

  factory Keyword.fromJson(Map<String, dynamic> json) => Keyword(
    id: json['id'],
    createdAt: json['createdAt'],
    updatedAt: json['updatedAt'],
    keyword: json['keyword'],
    category: json['category'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'keyword': keyword,
    'category': category,
  };
}

class Service {
  final String? id;
  final String? englishName;
  final String? tamilName;
  final double? startsAt;
  final double? offerPrice;
  final int? durationMinutes;
  final String? offerLabel;
  final String? offerValue;
  final String? description;
  final String? status;
  final String? primaryImageUrl;
  final String? category;
  final String? subCategory;

  Service({
    this.id,
    this.englishName,
    this.tamilName,
    this.startsAt,
    this.offerPrice,
    this.durationMinutes,
    this.offerLabel,
    this.offerValue,
    this.description,
    this.status,
    this.primaryImageUrl,
    this.category,
    this.subCategory,
  });

  factory Service.fromJson(Map<String, dynamic> json) => Service(
    id: json['id'],
    englishName: json['englishName'],
    tamilName: json['tamilName'],
    startsAt: (json['startsAt'] != null) ? json['startsAt'].toDouble() : null,
    offerPrice: (json['offerPrice'] != null) ? json['offerPrice'].toDouble() : null,
    durationMinutes: json['durationMinutes'],
    offerLabel: json['offerLabel'],
    offerValue: json['offerValue'],
    description: json['description'],
    status: json['status'],
    primaryImageUrl: json['primaryImageUrl'],
    category: json['category'],
    subCategory: json['subCategory'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'englishName': englishName,
    'tamilName': tamilName,
    'startsAt': startsAt,
    'offerPrice': offerPrice,
    'durationMinutes': durationMinutes,
    'offerLabel': offerLabel,
    'offerValue': offerValue,
    'description': description,
    'status': status,
    'primaryImageUrl': primaryImageUrl,
    'category': category,
    'subCategory': subCategory,
  };
}

class ProductSummary {
  final int? total;
  final List<dynamic>? featured;

  ProductSummary({this.total, this.featured});

  factory ProductSummary.fromJson(Map<String, dynamic> json) => ProductSummary(
    total: json['total'],
    featured: json['featured'] != null ? List<dynamic>.from(json['featured']) : null,
  );

  Map<String, dynamic> toJson() => {
    'total': total,
    'featured': featured,
  };
}

class ProductCategory {
  final String? slug;
  final String? label;
  final int? count;

  ProductCategory({this.slug, this.label, this.count});

  factory ProductCategory.fromJson(Map<String, dynamic> json) => ProductCategory(
    slug: json['slug'],
    label: json['label'],
    count: json['count'],
  );

  Map<String, dynamic> toJson() => {
    'slug': slug,
    'label': label,
    'count': count,
  };
}

class ServiceSummary {
  final int? total;
  final List<Service>? featured;

  ServiceSummary({this.total, this.featured});

  factory ServiceSummary.fromJson(Map<String, dynamic> json) => ServiceSummary(
    total: json['total'],
    featured: json['featured'] != null
        ? List<Service>.from(json['featured'].map((x) => Service.fromJson(x)))
        : null,
  );

  Map<String, dynamic> toJson() => {
    'total': total,
    'featured': featured?.map((x) => x.toJson()).toList(),
  };
}
