class ReviewCreateResponse {
  final bool status;
  final int code;
  final ReviewUpsertData data;

  ReviewCreateResponse({
    required this.status,
    required this.code,
    required this.data,
  });

  factory ReviewCreateResponse.fromJson(Map<String, dynamic> json) {
    return ReviewCreateResponse(
      status: json['status'] == true,
      code: (json['code'] as num?)?.toInt() ?? 0,
      data: ReviewUpsertData.fromJson(
        (json['data'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "code": code,
    "data": data.toJson(),
  };
}

class ReviewUpsertData {
  final ReviewItem review;
  final bool updated;
  final RewardedCoins rewarded;
  final String note;

  ReviewUpsertData({
    required this.review,
    required this.updated,
    required this.rewarded,
    required this.note,
  });

  factory ReviewUpsertData.fromJson(Map<String, dynamic> json) {
    return ReviewUpsertData(
      review: ReviewItem.fromJson(
        (json['review'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      updated: json['updated'] == true,
      rewarded: RewardedCoins.fromJson(
        (json['rewarded'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      note: (json['note'] ?? "").toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "review": review.toJson(),
    "updated": updated,
    "rewarded": rewarded.toJson(),
    "note": note,
  };
}

class ReviewItem {
  final String id;
  final String shopId;
  final String? productId;
  final String? serviceId;
  final String authorName;
  final int rating;
  final String heading;
  final String comment;
  final String createdAt;
  final String updatedAt;

  ReviewItem({
    required this.id,
    required this.shopId,
    required this.productId,
    required this.serviceId,
    required this.authorName,
    required this.rating,
    required this.heading,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewItem.fromJson(Map<String, dynamic> json) {
    return ReviewItem(
      id: (json['id'] ?? "").toString(),
      shopId: (json['shopId'] ?? "").toString(),
      productId: json['productId']?.toString(),
      serviceId: json['serviceId']?.toString(),
      authorName: (json['authorName'] ?? "").toString(),
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      heading: (json['heading'] ?? "").toString(),
      comment: (json['comment'] ?? "").toString(),
      createdAt: (json['createdAt'] ?? "").toString(),
      updatedAt: (json['updatedAt'] ?? "").toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "shopId": shopId,
    "productId": productId,
    "serviceId": serviceId,
    "authorName": authorName,
    "rating": rating,
    "heading": heading,
    "comment": comment,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}

class RewardedCoins {
  final int reviewerCoins;
  final int referrerCoins;

  RewardedCoins({required this.reviewerCoins, required this.referrerCoins});

  factory RewardedCoins.fromJson(Map<String, dynamic> json) {
    return RewardedCoins(
      reviewerCoins: (json['reviewerCoins'] as num?)?.toInt() ?? 0,
      referrerCoins: (json['referrerCoins'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "reviewerCoins": reviewerCoins,
    "referrerCoins": referrerCoins,
  };
}
