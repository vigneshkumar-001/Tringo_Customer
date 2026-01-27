class ReferralHistoryResponse {
  final bool status;
  final int code;
  final ReferralHistoryData data;

  const ReferralHistoryResponse({
    required this.status,
    required this.code,
    required this.data,
  });

  factory ReferralHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ReferralHistoryResponse(
      status: json['status'] == true,
      code: (json['code'] as num?)?.toInt() ?? 0,
      data: ReferralHistoryData.fromJson(
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

class ReferralHistoryData {
  final String referralCode;
  final int totalReferralRewardTcoin;
  final String shareLink;
  final String shareText;
  final Paging paging;
  final List<ReferralSection> sections;

  const ReferralHistoryData({
    required this.referralCode,
    required this.totalReferralRewardTcoin,
    required this.shareLink,
    required this.shareText,
    required this.paging,
    required this.sections,
  });

  factory ReferralHistoryData.fromJson(Map<String, dynamic> json) {
    return ReferralHistoryData(
      referralCode: (json['referralCode'] ?? "").toString(),
      totalReferralRewardTcoin:
          (json['totalReferralRewardTcoin'] as num?)?.toInt() ?? 0,
      shareLink: (json['shareLink'] ?? "").toString(),
      shareText: (json['shareText'] ?? "").toString(),
      paging: Paging.fromJson(
        (json['paging'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      sections: ((json['sections'] as List?) ?? const [])
          .map(
            (e) => ReferralSection.fromJson(
              (e as Map?)?.cast<String, dynamic>() ?? const {},
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    "referralCode": referralCode,
    "totalReferralRewardTcoin": totalReferralRewardTcoin,
    "shareLink": shareLink,
    "shareText": shareText,
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

class ReferralSection {
  final String dayKey;
  final String dayLabel;
  final List<ReferralItem> items;

  const ReferralSection({
    required this.dayKey,
    required this.dayLabel,
    required this.items,
  });

  factory ReferralSection.fromJson(Map<String, dynamic> json) {
    return ReferralSection(
      dayKey: (json['dayKey'] ?? "").toString(),
      dayLabel: (json['dayLabel'] ?? "").toString(),
      items: ((json['items'] as List?) ?? const [])
          .map(
            (e) => ReferralItem.fromJson(
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

class ReferralItem {
  final String id;
  final String timeLabel;
  final String dateLabel;
  final String title;
  final String subtitle;
  final int amountTcoin;
  final String badgeLabel;
  final String badgeType;

  const ReferralItem({
    required this.id,
    required this.timeLabel,
    required this.dateLabel,
    required this.title,
    required this.subtitle,
    required this.amountTcoin,
    required this.badgeLabel,
    required this.badgeType,
  });

  factory ReferralItem.fromJson(Map<String, dynamic> json) {
    return ReferralItem(
      id: (json['id'] ?? "").toString(),
      timeLabel: (json['timeLabel'] ?? "").toString(),
      dateLabel: (json['dateLabel'] ?? "").toString(),
      title: (json['title'] ?? "").toString(),
      subtitle: (json['subtitle'] ?? "").toString(),
      amountTcoin: (json['amountTcoin'] as num?)?.toInt() ?? 0,
      badgeLabel: (json['badgeLabel'] ?? "").toString(),
      badgeType: (json['badgeType'] ?? "").toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "timeLabel": timeLabel,
    "dateLabel": dateLabel,
    "title": title,
    "subtitle": subtitle,
    "amountTcoin": amountTcoin,
    "badgeLabel": badgeLabel,
    "badgeType": badgeType,
  };
}
