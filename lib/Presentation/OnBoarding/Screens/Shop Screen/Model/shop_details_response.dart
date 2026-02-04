/// ================= ROOT RESPONSE =================
class ShopDetailsResponse {
  final bool status;
  final ShopData? data;

  ShopDetailsResponse({
    required this.status,
    this.data,
  });

  factory ShopDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ShopDetailsResponse(
      status: json['status'] == true,
      data:
      json['data'] != null
          ? ShopData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data?.toJson(),
  };
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

  final List<String> serviceTags;
  final List<WeeklyHour> weeklyHours;

  final String averageRating;
  final int reviewCount;
  final String status;

  final List<Media> media;
  final List<Product> products;
  final List<Service> services;
  final List<Review> reviews;

  final List<dynamic> offers;

  final double distanceKm;
  final String distanceLabel;
  final String closeTime;

  final List<ProductCategory> productCategories;
  final List<ServiceCategory> serviceCategories;

  final ReviewUi? reviewUi;
  final Surprise? surprise;

  final bool isFollowing;
  final int followerCount;

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
    required this.closeTime,
    required this.productCategories,
    required this.serviceCategories,
    required this.reviewUi,
    required this.surprise,
    required this.isFollowing,
    required this.followerCount,
  });

  factory ShopData.fromJson(Map<String, dynamic> json) {
    return ShopData(
      id: json['id'].toString(),
      createdAt: json['createdAt'].toString(),
      updatedAt: json['updatedAt'].toString(),

      category: json['category'].toString(),
      subCategory: json['subCategory'].toString(),
      shopKind: json['shopKind'].toString(),

      englishName: json['englishName'].toString(),
      tamilName: json['tamilName'].toString(),

      descriptionEn: json['descriptionEn'].toString(),
      descriptionTa: json['descriptionTa'].toString(),

      addressEn: json['addressEn'].toString(),
      addressTa: json['addressTa'].toString(),

      gpsLatitude: json['gpsLatitude'].toString(),
      gpsLongitude: json['gpsLongitude'].toString(),

      primaryPhone: json['primaryPhone'].toString(),
      alternatePhone: json['alternatePhone'].toString(),

      contactEmail: json['contactEmail'].toString(),
      ownerImageUrl: json['ownerImageUrl'].toString(),

      doorDelivery: json['doorDelivery'] == true,
      isTrusted: json['isTrusted'] == true,

      city: json['city'].toString(),
      state: json['state'].toString(),
      country: json['country'].toString(),
      postalCode: json['postalCode'].toString(),

      serviceTags:
      (json['serviceTags'] as List?)
          ?.map((e) => e.toString())
          .toList() ??
          [],

      weeklyHours:
      (json['weeklyHours'] as List? ?? [])
          .map((e) => WeeklyHour.fromJson(e))
          .toList(),

      averageRating: json['averageRating'].toString(),
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      status: json['status'].toString(),

      media:
      (json['media'] as List? ?? [])
          .map((e) => Media.fromJson(e))
          .toList(),

      products:
      (json['products'] as List? ?? [])
          .map((e) => Product.fromJson(e))
          .toList(),

      services:
      (json['services'] as List? ?? [])
          .map((e) => Service.fromJson(e))
          .toList(),

      reviews:
      (json['reviews'] as List? ?? [])
          .map((e) => Review.fromJson(e))
          .toList(),

      offers: json['offers'] as List? ?? [],

      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
      distanceLabel: json['distanceLabel'].toString(),
      closeTime: json['closeTime'].toString(),

      productCategories:
      (json['productCategories'] as List? ?? [])
          .map((e) => ProductCategory.fromJson(e))
          .toList(),

      serviceCategories:
      (json['serviceCategories'] as List? ?? [])
          .map((e) => ServiceCategory.fromJson(e))
          .toList(),

      reviewUi:
      json['reviewUi'] != null
          ? ReviewUi.fromJson(json['reviewUi'])
          : null,

      surprise:
      json['surprise'] != null
          ? Surprise.fromJson(json['surprise'])
          : null,

      isFollowing: json['isFollowing'] == true,
      followerCount: (json['followerCount'] as num?)?.toInt() ?? 0,
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
    "closeTime": closeTime,
    "productCategories":
    productCategories.map((e) => e.toJson()).toList(),
    "serviceCategories":
    serviceCategories.map((e) => e.toJson()).toList(),
    "reviewUi": reviewUi?.toJson(),
    "surprise": surprise?.toJson(),
    "isFollowing": isFollowing,
    "followerCount": followerCount,
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

class Surprise {
  final bool hasOffer;
  final bool isClaimed;

  Surprise({
    required this.hasOffer,
    required this.isClaimed,
  });

  factory Surprise.fromJson(Map<String, dynamic> json) {
    return Surprise(
      hasOffer: json['hasOffer'] == true,
      isClaimed: json['isClaimed'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    "hasOffer": hasOffer,
    "isClaimed": isClaimed,
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
