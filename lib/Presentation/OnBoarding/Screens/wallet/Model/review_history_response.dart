class ReviewHistoryResponse {
  final bool status;
  final int code;
  final ReviewHistoryData data;

  const ReviewHistoryResponse({
    required this.status,
    required this.code,
    required this.data,
  });

  factory ReviewHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ReviewHistoryResponse(
      status: json['status'] == true,
      code: (json['code'] as num?)?.toInt() ?? 0,
      data: ReviewHistoryData.fromJson(
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

class ReviewHistoryData {
  final int totalReviewRewardTcoin;
  final Paging paging;
  final List<ReviewSection> sections;

  const ReviewHistoryData({
    required this.totalReviewRewardTcoin,
    required this.paging,
    required this.sections,
  });

  factory ReviewHistoryData.fromJson(Map<String, dynamic> json) {
    return ReviewHistoryData(
      totalReviewRewardTcoin:
          (json['totalReviewRewardTcoin'] as num?)?.toInt() ?? 0,
      paging: Paging.fromJson(
        (json['paging'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      sections: ((json['sections'] as List?) ?? const [])
          .map(
            (e) => ReviewSection.fromJson(
              (e as Map?)?.cast<String, dynamic>() ?? const {},
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    "totalReviewRewardTcoin": totalReviewRewardTcoin,
    "paging": paging.toJson(),
    "sections": sections.map((e) => e.toJson()).toList(),
  };
}

class Paging {
  final int take;
  final int skip;
  final int total;

  const Paging({required this.take, required this.skip, required this.total});

  factory Paging.fromJson(Map<String, dynamic> json) {
    return Paging(
      take: (json['take'] as num?)?.toInt() ?? 0,
      skip: (json['skip'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {"take": take, "skip": skip, "total": total};
}

class ReviewSection {
  final String dayKey;
  final String dayLabel;
  final List<ReviewItem> items;

  const ReviewSection({
    required this.dayKey,
    required this.dayLabel,
    required this.items,
  });

  factory ReviewSection.fromJson(Map<String, dynamic> json) {
    return ReviewSection(
      dayKey: (json['dayKey'] ?? "").toString(),
      dayLabel: (json['dayLabel'] ?? "").toString(),
      items: ((json['items'] as List?) ?? const [])
          .map(
            (e) => ReviewItem.fromJson(
              (e as Map?)?.cast<String, dynamic>() ?? const {},
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    "dayKey": dayKey,
    "dayLabel": dayLabel,
    "items": items.map((e) => e.toJson()).toList(),
  };
}

class ReviewItem {
  final String reviewId;
  final String shopId;
  final String title;
  final String timeLabel;
  final String subtitle;
  final int amountTcoin;
  final String badgeLabel;
  final String badgeType;
  final int rating;
  final String heading;
  final String comment;

  const ReviewItem({
    required this.reviewId,
    required this.shopId,
    required this.title,
    required this.timeLabel,
    required this.subtitle,
    required this.amountTcoin,
    required this.badgeLabel,
    required this.badgeType,
    required this.rating,
    required this.heading,
    required this.comment,
  });

  factory ReviewItem.fromJson(Map<String, dynamic> json) {
    return ReviewItem(
      reviewId: (json['reviewId'] ?? "").toString(),
      shopId: (json['shopId'] ?? "").toString(),
      title: (json['title'] ?? "").toString(),
      timeLabel: (json['timeLabel'] ?? "").toString(),
      subtitle: (json['subtitle'] ?? "").toString(),
      amountTcoin: (json['amountTcoin'] as num?)?.toInt() ?? 0,
      badgeLabel: (json['badgeLabel'] ?? "").toString(),
      badgeType: (json['badgeType'] ?? "").toString(),
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      heading: (json['heading'] ?? "").toString(),
      comment: (json['comment'] ?? "").toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "reviewId": reviewId,
    "shopId": shopId,
    "title": title,
    "timeLabel": timeLabel,
    "subtitle": subtitle,
    "amountTcoin": amountTcoin,
    "badgeLabel": badgeLabel,
    "badgeType": badgeType,
    "rating": rating,
    "heading": heading,
    "comment": comment,
  };
}
