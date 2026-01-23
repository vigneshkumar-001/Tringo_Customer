class ReferralResponse {
  final bool status;
  final int code;
  final ReferralData data;

  ReferralResponse({
    required this.status,
    required this.code,
    required this.data,
  });

  factory ReferralResponse.fromJson(Map<String, dynamic> json) {
    return ReferralResponse(
      status: json['status'],
      code: json['code'],
      data: ReferralData.fromJson(json['data']),
    );
  }
}
class ReferralData {
  final bool applied;
  final bool skipped;
  final int rewardCoins;
  final String referrerUserId;
  final String referrerReferralCode;

  ReferralData({
    required this.applied,
    required this.skipped,
    required this.rewardCoins,
    required this.referrerUserId,
    required this.referrerReferralCode,
  });

  factory ReferralData.fromJson(Map<String, dynamic> json) {
    return ReferralData(
      applied: json['applied'],
      skipped: json['skipped'],
      rewardCoins: json['rewardCoins'],
      referrerUserId: json['referrerUserId'],
      referrerReferralCode: json['referrerReferralCode'],
    );
  }
}
