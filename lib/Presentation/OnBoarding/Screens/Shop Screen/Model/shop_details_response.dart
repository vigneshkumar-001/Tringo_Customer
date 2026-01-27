/// ================= ROOT RESPONSE =================
class ShopDetailsResponse {
  final bool status;
  final ShopData? data;

  ShopDetailsResponse({required this.status, this.data});

  factory ShopDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ShopDetailsResponse(
      status: json['status'] == true,
      data: json['data'] != null ? ShopData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {'status': status, 'data': data?.toJson()};
}

/// ================= SHOP DATA =================
class ShopData {
  final String id;
  final String createdAt;
  final String updatedAt;

  final String category;
  final String subCategory;
  final String shopKind;

  final String englishName;
  final String tamilName;

  final String descriptionEn;
  final String descriptionTa;

  final String addressEn;
  final String addressTa;

  final String gpsLatitude;
  final String gpsLongitude;

  final String primaryPhone;
  final String alternatePhone;

  final String contactEmail;
  final String ownerImageUrl;

  final bool doorDelivery;
  final bool isTrusted;

  final String city;
  final String state;
  final String country;
  final String postalCode;

  final List<String> serviceTags; // ✅ API: null, safe list

  final List<WeeklyHour> weeklyHours;
  final String closeTime;

  final String averageRating;
  final int reviewCount;
  final String status;

  final List<Media> media;
  final List<Product> products;
  final List<Service> services;
  final List<Review> reviews;

  final List<dynamic> offers; // (empty list in API)

  final double distanceKm;
  final String distanceLabel;

  final List<ProductCategory> productCategories;
  final List<ServiceCategory> serviceCategories;

  final ReviewUi? reviewUi;

  ShopData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    required this.subCategory,
    required this.shopKind,
    required this.englishName,
    required this.tamilName,
    required this.descriptionEn,
    required this.descriptionTa,
    required this.addressEn,
    required this.addressTa,
    required this.gpsLatitude,
    required this.gpsLongitude,
    required this.primaryPhone,
    required this.alternatePhone,
    required this.contactEmail,
    required this.ownerImageUrl,
    required this.doorDelivery,
    required this.isTrusted,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.serviceTags,
    required this.weeklyHours,
    required this.closeTime,
    required this.averageRating,
    required this.reviewCount,
    required this.status,
    required this.media,
    required this.products,
    required this.services,
    required this.reviews,
    required this.offers,
    required this.distanceKm,
    required this.distanceLabel,
    required this.productCategories,
    required this.serviceCategories,
    required this.reviewUi,
  });

  factory ShopData.fromJson(Map<String, dynamic> json) {
    return ShopData(
      id: (json['id'] ?? "").toString(),
      createdAt: (json['createdAt'] ?? "").toString(),
      updatedAt: (json['updatedAt'] ?? "").toString(),
      category: (json['category'] ?? "").toString(),
      subCategory: (json['subCategory'] ?? "").toString(),
      shopKind: (json['shopKind'] ?? "").toString(),
      englishName: (json['englishName'] ?? "").toString(),
      tamilName: (json['tamilName'] ?? "").toString(),
      descriptionEn: (json['descriptionEn'] ?? "").toString(),
      descriptionTa: (json['descriptionTa'] ?? "").toString(),
      addressEn: (json['addressEn'] ?? "").toString(),
      addressTa: (json['addressTa'] ?? "").toString(),
      gpsLatitude: (json['gpsLatitude'] ?? "").toString(),
      gpsLongitude: (json['gpsLongitude'] ?? "").toString(),
      primaryPhone: (json['primaryPhone'] ?? "").toString(),
      alternatePhone: (json['alternatePhone'] ?? "").toString(),
      contactEmail: (json['contactEmail'] ?? "").toString(),
      ownerImageUrl: (json['ownerImageUrl'] ?? "").toString(),
      doorDelivery: json['doorDelivery'] == true,
      isTrusted: json['isTrusted'] == true,
      city: (json['city'] ?? "").toString(),
      state: (json['state'] ?? "").toString(),
      country: (json['country'] ?? "").toString(),
      postalCode: (json['postalCode'] ?? "").toString(),
      closeTime: (json['closeTime'] ?? "").toString(),


      /// ✅ serviceTags comes as null in API → keep empty list
      serviceTags:
          (json['serviceTags'] as List?)
              ?.map((e) => (e ?? "").toString())
              .toList() ??
          const [],

      weeklyHours: ((json['weeklyHours'] as List?) ?? const [])
          .map(
            (e) => WeeklyHour.fromJson(
              (e as Map?)?.cast<String, dynamic>() ?? const {},
            ),
          )
          .toList(),

      averageRating: (json['averageRating'] ?? "").toString(),
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      status: (json['status'] ?? "").toString(),

      media: ((json['media'] as List?) ?? const [])
          .map(
            (e) => Media.fromJson(
              (e as Map?)?.cast<String, dynamic>() ?? const {},
            ),
          )
          .toList(),

      products: ((json['products'] as List?) ?? const [])
          .map(
            (e) => Product.fromJson(
              (e as Map?)?.cast<String, dynamic>() ?? const {},
            ),
          )
          .toList(),

      services: ((json['services'] as List?) ?? const [])
          .map(
            (e) => Service.fromJson(
              (e as Map?)?.cast<String, dynamic>() ?? const {},
            ),
          )
          .toList(),

      /// ✅ reviews are objects now
      reviews: ((json['reviews'] as List?) ?? const [])
          .map(
            (e) => Review.fromJson(
              (e as Map?)?.cast<String, dynamic>() ?? const {},
            ),
          )
          .toList(),

      offers: (json['offers'] as List?) ?? const [],

      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
      distanceLabel: (json['distanceLabel'] ?? "").toString(),

      productCategories: ((json['productCategories'] as List?) ?? const [])
          .map(
            (e) => ProductCategory.fromJson(
              (e as Map?)?.cast<String, dynamic>() ?? const {},
            ),
          )
          .toList(),

      serviceCategories: ((json['serviceCategories'] as List?) ?? const [])
          .map(
            (e) => ServiceCategory.fromJson(
              (e as Map?)?.cast<String, dynamic>() ?? const {},
            ),
          )
          .toList(),

      reviewUi: json['reviewUi'] != null
          ? ReviewUi.fromJson(
              (json['reviewUi'] as Map?)?.cast<String, dynamic>() ?? const {},
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "category": category,
    "subCategory": subCategory,
    "shopKind": shopKind,
    "englishName": englishName,
    "tamilName": tamilName,
    "descriptionEn": descriptionEn,
    "descriptionTa": descriptionTa,
    "addressEn": addressEn,
    "addressTa": addressTa,
    "gpsLatitude": gpsLatitude,
    "gpsLongitude": gpsLongitude,
    "primaryPhone": primaryPhone,
    "alternatePhone": alternatePhone,
    "contactEmail": contactEmail,
    "ownerImageUrl": ownerImageUrl,
    "doorDelivery": doorDelivery,
    "isTrusted": isTrusted,
    "city": city,
    "state": state,
    "country": country,
    "postalCode": postalCode,
    "closeTime": closeTime,
    "serviceTags": serviceTags,
    "weeklyHours": weeklyHours.map((e) => e.toJson()).toList(),
    "averageRating": averageRating,
    "reviewCount": reviewCount,
    "status": status,
    "media": media.map((e) => e.toJson()).toList(),
    "products": products.map((e) => e.toJson()).toList(),
    "services": services.map((e) => e.toJson()).toList(),
    "reviews": reviews.map((e) => e.toJson()).toList(),
    "offers": offers,
    "distanceKm": distanceKm,
    "distanceLabel": distanceLabel,
    "productCategories": productCategories.map((e) => e.toJson()).toList(),
    "serviceCategories": serviceCategories.map((e) => e.toJson()).toList(),
    "reviewUi": reviewUi?.toJson(),
  };
}

/// ================= WEEKLY HOURS =================
class WeeklyHour {
  final String day;
  final String opensAt;
  final String closesAt;
  final bool closed;

  WeeklyHour({
    required this.day,
    required this.opensAt,
    required this.closesAt,
    required this.closed,
  });

  factory WeeklyHour.fromJson(Map<String, dynamic> json) {
    return WeeklyHour(
      day: (json['day'] ?? "").toString(),
      opensAt: (json['opensAt'] ?? "").toString(),
      closesAt: (json['closesAt'] ?? "").toString(),
      closed: json['closed'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    "day": day,
    "opensAt": opensAt,
    "closesAt": closesAt,
    "closed": closed,
  };
}

/// ================= MEDIA =================
class Media {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String type;
  final String url;
  final int displayOrder;

  Media({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.type,
    required this.url,
    required this.displayOrder,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: (json['id'] ?? "").toString(),
      createdAt: (json['createdAt'] ?? "").toString(),
      updatedAt: (json['updatedAt'] ?? "").toString(),
      type: (json['type'] ?? "").toString(),
      url: (json['url'] ?? "").toString(),
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "type": type,
    "url": url,
    "displayOrder": displayOrder,
  };
}

/// ================= PRODUCT =================
class Product {
  final String id;
  final String englishName;
  final String tamilName;
  final String category;
  final String subCategory;

  final double price;
  final double offerPrice;
  final String offerLabel;
  final String offerValue;

  final String description;
  final String imageUrl;

  final bool doorDelivery;
  final int rating;
  final int ratingCount;

  Product({
    required this.id,
    required this.englishName,
    required this.tamilName,
    required this.category,
    required this.subCategory,
    required this.price,
    required this.offerPrice,
    required this.offerLabel,
    required this.offerValue,
    required this.description,
    required this.imageUrl,
    required this.doorDelivery,
    required this.rating,
    required this.ratingCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] ?? "").toString(),
      englishName: (json['englishName'] ?? "").toString(),
      tamilName: (json['tamilName'] ?? "").toString(),
      category: (json['category'] ?? "").toString(),
      subCategory: (json['subCategory'] ?? "").toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      offerPrice: (json['offerPrice'] as num?)?.toDouble() ?? 0,
      offerLabel: (json['offerLabel'] ?? "").toString(),
      offerValue: (json['offerValue'] ?? "").toString(),
      description: (json['description'] ?? "").toString(),
      imageUrl: (json['imageUrl'] ?? "").toString(),
      doorDelivery: json['doorDelivery'] == true,
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "englishName": englishName,
    "tamilName": tamilName,
    "category": category,
    "subCategory": subCategory,
    "price": price,
    "offerPrice": offerPrice,
    "offerLabel": offerLabel,
    "offerValue": offerValue,
    "description": description,
    "imageUrl": imageUrl,
    "doorDelivery": doorDelivery,
    "rating": rating,
    "ratingCount": ratingCount,
  };
}

/// ================= SERVICE =================
class Service {
  final String id;
  final String kind;
  final String englishName;
  final String tamilName;

  final double price;
  final double offerPrice;
  final String offerLabel;
  final String offerValue;

  final String description;
  final int durationMinutes;

  final bool doorDelivery;

  final int rating;
  final int ratingCount;

  final String imageUrl;
  final String category;
  final String subCategory;

  Service({
    required this.id,
    required this.kind,
    required this.englishName,
    required this.tamilName,
    required this.price,
    required this.offerPrice,
    required this.offerLabel,
    required this.offerValue,
    required this.description,
    required this.durationMinutes,
    required this.doorDelivery,
    required this.rating,
    required this.ratingCount,
    required this.imageUrl,
    required this.category,
    required this.subCategory,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: (json['id'] ?? "").toString(),
      kind: (json['kind'] ?? "").toString(),
      englishName: (json['englishName'] ?? "").toString(),
      tamilName: (json['tamilName'] ?? "").toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      offerPrice: (json['offerPrice'] as num?)?.toDouble() ?? 0,
      offerLabel: (json['offerLabel'] ?? "").toString(),
      offerValue: (json['offerValue'] ?? "").toString(),
      description: (json['description'] ?? "").toString(),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      doorDelivery: json['doorDelivery'] == true,
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
      imageUrl: (json['imageUrl'] ?? "").toString(),
      category: (json['category'] ?? "").toString(),
      subCategory: (json['subCategory'] ?? "").toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "kind": kind,
    "id": id,
    "englishName": englishName,
    "tamilName": tamilName,
    "price": price,
    "offerPrice": offerPrice,
    "offerLabel": offerLabel,
    "offerValue": offerValue,
    "description": description,
    "durationMinutes": durationMinutes,
    "doorDelivery": doorDelivery,
    "rating": rating,
    "ratingCount": ratingCount,
    "imageUrl": imageUrl,
    "category": category,
    "subCategory": subCategory,
  };
}

/// ================= REVIEW =================
class Review {
  final String id;
  final String shopId;
  final String authorUserId;
  final String authorName;
  final String heading;
  final int rating;
  final String comment;
  final String createdAt;
  final String createdAtRelative;

  Review({
    required this.id,
    required this.shopId,
    required this.authorUserId,
    required this.authorName,
    required this.heading,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.createdAtRelative,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: (json['id'] ?? "").toString(),
      shopId: (json['shopId'] ?? "").toString(),
      authorUserId: (json['authorUserId'] ?? "").toString(),
      authorName: (json['authorName'] ?? "").toString(),
      heading: (json['heading'] ?? "").toString(),
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: (json['comment'] ?? "").toString(),
      createdAt: (json['createdAt'] ?? "").toString(),
      createdAtRelative: (json['createdAtRelative'] ?? "").toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "shopId": shopId,
    "authorUserId": authorUserId,
    "authorName": authorName,
    "heading": heading,
    "rating": rating,
    "comment": comment,
    "createdAt": createdAt,
    "createdAtRelative": createdAtRelative,
  };
}

/// ================= PRODUCT CATEGORY =================
class ProductCategory {
  final String slug;
  final String label;
  final int count;

  ProductCategory({
    required this.slug,
    required this.label,
    required this.count,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      slug: (json['slug'] ?? "").toString(),
      label: (json['label'] ?? "").toString(),
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "slug": slug,
    "label": label,
    "count": count,
  };
}

/// ================= SERVICE CATEGORY =================
class ServiceCategory {
  final String slug;
  final String label;
  final int count;

  ServiceCategory({
    required this.slug,
    required this.label,
    required this.count,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      slug: (json['slug'] ?? "").toString(),
      label: (json['label'] ?? "").toString(),
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "slug": slug,
    "label": label,
    "count": count,
  };
}

/// ================= REVIEW UI =================
class ReviewUi {
  final bool hasReviews;
  final int averageRating;
  final int reviewCount;
  final String ratingLabel;
  final String countLabel;
  final String buttonText;

  ReviewUi({
    required this.hasReviews,
    required this.averageRating,
    required this.reviewCount,
    required this.ratingLabel,
    required this.countLabel,
    required this.buttonText,
  });

  factory ReviewUi.fromJson(Map<String, dynamic> json) {
    return ReviewUi(
      hasReviews: json['hasReviews'] == true,
      averageRating: (json['averageRating'] as num?)?.toInt() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      ratingLabel: (json['ratingLabel'] ?? "").toString(),
      countLabel: (json['countLabel'] ?? "").toString(),
      buttonText: (json['buttonText'] ?? "").toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "hasReviews": hasReviews,
    "averageRating": averageRating,
    "reviewCount": reviewCount,
    "ratingLabel": ratingLabel,
    "countLabel": countLabel,
    "buttonText": buttonText,
  };
}

// /// ROOT RESPONSE
// class ShopDetailsResponse {
//   final bool status;
//   final ShopData? data;
//
//   ShopDetailsResponse({required this.status, this.data});
//
//   factory ShopDetailsResponse.fromJson(Map<String, dynamic> json) {
//     return ShopDetailsResponse(
//       status: json['status'] ?? false,
//       data: json['data'] != null ? ShopData.fromJson(json['data']) : null,
//     );
//   }
//
//   Map<String, dynamic> toJson() => {'status': status, 'data': data?.toJson()};
// }
//
// /// SHOP DATA
// class ShopData {
//   final String? id;
//   final String? createdAt;
//   final String? updatedAt;
//   final String? category;
//   final String? subCategory;
//   final String? shopKind;
//   final String? englishName;
//   final String? tamilName;
//   final String? descriptionEn;
//   final String? descriptionTa;
//   final String? addressEn;
//   final String? addressTa;
//   final String? gpsLatitude;
//   final String? gpsLongitude;
//   final String? primaryPhone;
//   final String? alternatePhone;
//   final String? contactEmail;
//   final String? ownerImageUrl;
//   final bool? doorDelivery;
//   final bool? isTrusted;
//   final String? city;
//   final String? state;
//   final String? country;
//   final String? postalCode;
//
//   /// ✅ from JSON: "serviceCategories": [...]
//   final List<ServiceCategory>? serviceTags;
//
//   /// ✅ from JSON: "weeklyHours": [ { day, opensAt, closesAt, closed }, ... ]
//   final List<WeeklyHour>? weeklyHours;
//
//   final String? averageRating;
//   final int? reviewCount;
//   final String? status;
//   final List<Media>? media;
//   final List<Product>? products;
//   final List<Service>? services;
//   final List<dynamic>? reviews;
//   final List<dynamic>? offers;
//   final ProductSummary? productSummary;
//
//   /// ✅ from JSON: "productCategories": [...]
//   final List<ProductCategory>? productCategories;
//
//   final ServiceSummary? serviceSummary;
//   final int? rating;
//
//   /// ✅ from JSON: "distanceKm", "distanceLabel"
//   final double? distanceKm;
//   final String? distanceLabel;
//
//   ShopData({
//     this.id,
//     this.createdAt,
//     this.updatedAt,
//     this.category,
//     this.subCategory,
//     this.shopKind,
//     this.englishName,
//     this.tamilName,
//     this.descriptionEn,
//     this.descriptionTa,
//     this.addressEn,
//     this.addressTa,
//     this.gpsLatitude,
//     this.gpsLongitude,
//     this.primaryPhone,
//     this.alternatePhone,
//     this.contactEmail,
//     this.ownerImageUrl,
//     this.doorDelivery,
//     this.isTrusted,
//     this.city,
//     this.state,
//     this.country,
//     this.postalCode,
//     this.serviceTags,
//     this.weeklyHours,
//     this.averageRating,
//     this.reviewCount,
//     this.status,
//     this.media,
//
//     this.products,
//     this.services,
//     this.reviews,
//     this.offers,
//     this.productSummary,
//     this.productCategories,
//     this.serviceSummary,
//     this.rating,
//     this.distanceKm,
//     this.distanceLabel,
//   });
//
//   factory ShopData.fromJson(Map<String, dynamic> json) {
//     return ShopData(
//       id: json['id'],
//       createdAt: json['createdAt'],
//       updatedAt: json['updatedAt'],
//       category: json['category'],
//       subCategory: json['subCategory'],
//       shopKind: json['shopKind'],
//       englishName: json['englishName'],
//       tamilName: json['tamilName'],
//       descriptionEn: json['descriptionEn'],
//       descriptionTa: json['descriptionTa'],
//       addressEn: json['addressEn'],
//       addressTa: json['addressTa'],
//       gpsLatitude: json['gpsLatitude'],
//       gpsLongitude: json['gpsLongitude'],
//       primaryPhone: json['primaryPhone'],
//       alternatePhone: json['alternatePhone'],
//       contactEmail: json['contactEmail'],
//       ownerImageUrl: json['ownerImageUrl'],
//       doorDelivery: json['doorDelivery'],
//       isTrusted: json['isTrusted'],
//       city: json['city'],
//       state: json['state'],
//       country: json['country'],
//       postalCode: json['postalCode'],
//
//       /// serviceCategories → serviceTags (for your old UI)
//       serviceTags: (json['serviceCategories'] as List<dynamic>?)
//           ?.map((e) => ServiceCategory.fromJson(e as Map<String, dynamic>))
//           .toList(),
//
//       /// ✅ weeklyHours is List now
//       weeklyHours: (json['weeklyHours'] as List<dynamic>?)
//           ?.map((e) => WeeklyHour.fromJson(e as Map<String, dynamic>))
//           .toList(),
//
//       averageRating: json['averageRating'],
//       reviewCount: json['reviewCount'],
//       status: json['status'],
//       media: (json['media'] as List<dynamic>?)
//           ?.map((e) => Media.fromJson(e as Map<String, dynamic>))
//           .toList(),
//       products: (json['products'] as List<dynamic>?)
//           ?.map((e) => Product.fromJson(e as Map<String, dynamic>))
//           .toList(),
//       services: (json['services'] as List<dynamic>?)
//           ?.map((e) => Service.fromJson(e as Map<String, dynamic>))
//           .toList(),
//       reviews: json['reviews'] != null
//           ? List<dynamic>.from(json['reviews'])
//           : null,
//       offers: json['offers'] != null
//           ? List<dynamic>.from(json['offers'])
//           : null,
//       productSummary: json['productSummary'] != null
//           ? ProductSummary.fromJson(json['productSummary'])
//           : null,
//       productCategories: (json['productCategories'] as List<dynamic>?)
//           ?.map((e) => ProductCategory.fromJson(e as Map<String, dynamic>))
//           .toList(),
//       serviceSummary: json['serviceSummary'] != null
//           ? ServiceSummary.fromJson(json['serviceSummary'])
//           : null,
//       rating: json['rating'],
//
//       distanceKm: json['distanceKm'] != null
//           ? (json['distanceKm'] as num).toDouble()
//           : null,
//       distanceLabel: json['distanceLabel'],
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'createdAt': createdAt,
//     'updatedAt': updatedAt,
//     'category': category,
//     'subCategory': subCategory,
//     'shopKind': shopKind,
//     'englishName': englishName,
//     'tamilName': tamilName,
//     'descriptionEn': descriptionEn,
//     'descriptionTa': descriptionTa,
//     'addressEn': addressEn,
//     'addressTa': addressTa,
//     'gpsLatitude': gpsLatitude,
//     'gpsLongitude': gpsLongitude,
//     'primaryPhone': primaryPhone,
//     'alternatePhone': alternatePhone,
//     'contactEmail': contactEmail,
//     'ownerImageUrl': ownerImageUrl,
//     'doorDelivery': doorDelivery,
//     'isTrusted': isTrusted,
//     'city': city,
//     'state': state,
//     'country': country,
//     'postalCode': postalCode,
//
//     // if you want to send back serviceCategories:
//     'serviceCategories': serviceTags?.map((e) => e.toJson()).toList(),
//
//     'weeklyHours': weeklyHours?.map((e) => e.toJson()).toList(),
//     'averageRating': averageRating,
//     'reviewCount': reviewCount,
//     'status': status,
//     'media': media?.map((e) => e.toJson()).toList(),
//     'products': products?.map((e) => e.toJson()).toList(),
//     'services': services?.map((e) => e.toJson()).toList(),
//     'reviews': reviews,
//     'offers': offers,
//     'productSummary': productSummary?.toJson(),
//     'productCategories': productCategories?.map((e) => e.toJson()).toList(),
//     'serviceSummary': serviceSummary?.toJson(),
//     'rating': rating,
//     'distanceKm': distanceKm,
//     'distanceLabel': distanceLabel,
//   };
// }
//
// /// ✅ NEW: WeeklyHours model
// class WeeklyHour {
//   final String? day;
//   final String? opensAt;
//   final String? closesAt;
//   final bool? closed;
//
//   WeeklyHour({this.day, this.opensAt, this.closesAt, this.closed});
//
//   factory WeeklyHour.fromJson(Map<String, dynamic> json) {
//     return WeeklyHour(
//       day: json['day'],
//       opensAt: json['opensAt'],
//       closesAt: json['closesAt'],
//       closed: json['closed'],
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     'day': day,
//     'opensAt': opensAt,
//     'closesAt': closesAt,
//     'closed': closed,
//   };
// }
//
// /// MEDIA
// class Media {
//   final String? id;
//   final String? createdAt;
//   final String? updatedAt;
//   final String? type;
//   final String? url;
//   final int? displayOrder;
//
//   Media({
//     this.id,
//     this.createdAt,
//     this.updatedAt,
//     this.type,
//     this.url,
//     this.displayOrder,
//   });
//
//   factory Media.fromJson(Map<String, dynamic> json) => Media(
//     id: json['id'],
//     createdAt: json['createdAt'],
//     updatedAt: json['updatedAt'],
//     type: json['type'],
//     url: json['url'],
//     displayOrder: json['displayOrder'],
//   );
//
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'createdAt': createdAt,
//     'updatedAt': updatedAt,
//     'type': type,
//     'url': url,
//     'displayOrder': displayOrder,
//   };
// }
//
// /// PRODUCT
// class Product {
//   final String? id;
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
//   final bool? isFeatured;
//   final String? offerLabel;
//   final String? offerValue;
//   final String? description;
//   final List<String>? keywords;
//   final int? readyTimeMinutes;
//   final int? rating;
//   final int? ratingCount;
//   final bool? doorDelivery;
//   final String? status;
//   final List<ProductFeature>? features;
//   final bool? hasVariants;
//
//   Product({
//     this.id,
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
//     this.isFeatured,
//     this.offerLabel,
//     this.offerValue,
//     this.description,
//     this.keywords,
//     this.readyTimeMinutes,
//     this.rating,
//     this.ratingCount,
//     this.doorDelivery,
//     this.status,
//     this.features,
//     this.hasVariants,
//   });
//
//   factory Product.fromJson(Map<String, dynamic> json) => Product(
//     id: json['id'],
//     englishName: json['englishName'],
//     tamilName: json['tamilName'],
//     category: json['category'],
//     categoryLabel: json['categoryLabel'],
//     subCategory: json['subCategory'],
//     subCategoryLabel: json['subCategoryLabel'],
//     price: json['price'] != null ? (json['price'] as num).toDouble() : null,
//     offerPrice: json['offerPrice'] != null
//         ? (json['offerPrice'] as num).toDouble()
//         : null,
//     imageUrl: json['imageUrl'],
//     unitLabel: json['unitLabel'],
//     stockCount: json['stockCount'],
//     isFeatured: json['isFeatured'],
//     offerLabel: json['offerLabel'],
//     offerValue: json['offerValue'],
//     description: json['description'],
//     keywords: json['keywords'] != null
//         ? List<String>.from(json['keywords'])
//         : null,
//     readyTimeMinutes: json['readyTimeMinutes'],
//     rating: json['rating'],
//     ratingCount: json['ratingCount'],
//     doorDelivery: json['doorDelivery'],
//     status: json['status'],
//     features: (json['features'] as List<dynamic>?)
//         ?.map((e) => ProductFeature.fromJson(e as Map<String, dynamic>))
//         .toList(),
//     hasVariants: json['hasVariants'],
//   );
//
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'englishName': englishName,
//     'tamilName': tamilName,
//     'category': category,
//     'categoryLabel': categoryLabel,
//     'subCategory': subCategory,
//     'subCategoryLabel': subCategoryLabel,
//     'price': price,
//     'offerPrice': offerPrice,
//     'imageUrl': imageUrl,
//     'unitLabel': unitLabel,
//     'stockCount': stockCount,
//     'isFeatured': isFeatured,
//     'offerLabel': offerLabel,
//     'offerValue': offerValue,
//     'description': description,
//     'keywords': keywords,
//     'readyTimeMinutes': readyTimeMinutes,
//     'rating': rating,
//     'ratingCount': ratingCount,
//     'doorDelivery': doorDelivery,
//     'status': status,
//     'features': features?.map((e) => e.toJson()).toList(),
//     'hasVariants': hasVariants,
//   };
// }
//
// class ProductFeature {
//   final String? id;
//   final String? label;
//   final String? value;
//   final String? language;
//
//   ProductFeature({this.id, this.label, this.value, this.language});
//
//   factory ProductFeature.fromJson(Map<String, dynamic> json) => ProductFeature(
//     id: json['id'],
//     label: json['label'],
//     value: json['value'],
//     language: json['language'],
//   );
//
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'label': label,
//     'value': value,
//     'language': language,
//   };
// }
//
// /// SERVICE
// class Service {
//   final String? id;
//   final String? englishName;
//   final String? tamilName;
//   final double? startsAt;
//   final double? offerPrice;
//   final int? durationMinutes;
//   final String? offerLabel;
//   final String? offerValue;
//   final String? description;
//   final String? status;
//   final String? primaryImageUrl;
//   final String? category;
//   final String? subCategory;
//   final int? rating;
//   final int? reviewCount;
//
//   Service({
//     this.id,
//     this.englishName,
//     this.tamilName,
//     this.startsAt,
//     this.offerPrice,
//     this.durationMinutes,
//     this.offerLabel,
//     this.offerValue,
//     this.description,
//     this.status,
//     this.primaryImageUrl,
//     this.category,
//     this.subCategory,
//     this.rating,
//     this.reviewCount,
//   });
//
//   factory Service.fromJson(Map<String, dynamic> json) => Service(
//     id: json['id'],
//     englishName: json['englishName'],
//     tamilName: json['tamilName'],
//     startsAt: json['price'] != null ? (json['price'] as num).toDouble() : null,
//     offerPrice: json['offerPrice'] != null
//         ? (json['offerPrice'] as num).toDouble()
//         : null,
//     durationMinutes: json['durationMinutes'],
//     offerLabel: json['offerLabel'],
//     offerValue: json['offerValue'],
//     description: json['description'],
//     status: json['status'],
//     primaryImageUrl: json['imageUrl'],
//     category: json['category'],
//     subCategory: json['subCategory'],
//     rating: json['rating'] ?? 0,
//     reviewCount: json['reviewCount'] ?? 0,
//   );
//
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'englishName': englishName,
//     'tamilName': tamilName,
//     'price': startsAt,
//     'offerPrice': offerPrice,
//     'durationMinutes': durationMinutes,
//     'offerLabel': offerLabel,
//     'offerValue': offerValue,
//     'description': description,
//     'status': status,
//     'imageUrl': primaryImageUrl,
//     'category': category,
//     'subCategory': subCategory,
//     'rating': rating,
//     'reviewCount': reviewCount,
//   };
// }
//
// /// SUMMARY & CATEGORIES
//
// class ProductSummary {
//   final int? total;
//   final List<dynamic>? featured;
//
//   ProductSummary({this.total, this.featured});
//
//   factory ProductSummary.fromJson(Map<String, dynamic> json) => ProductSummary(
//     total: json['total'],
//     featured: json['featured'] != null
//         ? List<dynamic>.from(json['featured'])
//         : null,
//   );
//
//   Map<String, dynamic> toJson() => {'total': total, 'featured': featured};
// }
//
// class ServiceCategory {
//   final String? slug;
//   final String? label;
//   final int? count;
//
//   ServiceCategory({this.slug, this.label, this.count});
//
//   factory ServiceCategory.fromJson(Map<String, dynamic> json) =>
//       ServiceCategory(
//         slug: json['slug'],
//         label: json['label'],
//         count: json['count'],
//       );
//
//   Map<String, dynamic> toJson() => {
//     'slug': slug,
//     'label': label,
//     'count': count,
//   };
// }
//
// class ProductCategory {
//   final String? slug;
//   final String? label;
//   final int? count;
//
//   ProductCategory({this.slug, this.label, this.count});
//
//   factory ProductCategory.fromJson(Map<String, dynamic> json) =>
//       ProductCategory(
//         slug: json['slug'],
//         label: json['label'],
//         count: json['count'],
//       );
//
//   Map<String, dynamic> toJson() => {
//     'slug': slug,
//     'label': label,
//     'count': count,
//   };
// }
//
// class ServiceSummary {
//   final int? total;
//   final List<Service>? featured;
//
//   ServiceSummary({this.total, this.featured});
//
//   factory ServiceSummary.fromJson(Map<String, dynamic> json) => ServiceSummary(
//     total: json['total'],
//     featured: (json['featured'] as List<dynamic>?)
//         ?.map((e) => Service.fromJson(e as Map<String, dynamic>))
//         .toList(),
//   );
//
//   Map<String, dynamic> toJson() => {
//     'total': total,
//     'featured': featured?.map((e) => e.toJson()).toList(),
//   };
// }
