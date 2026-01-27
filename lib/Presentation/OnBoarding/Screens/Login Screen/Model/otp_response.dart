class OtpResponse {
  final bool status;
  final int code;
  final OtpData? data;

  const OtpResponse({required this.status, required this.code, this.data});

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      status: json['status'] == true, // ✅ safe bool
      code: (json['code'] as num?)?.toInt() ?? 0,
      data: json['data'] != null
          ? OtpData.fromJson((json['data'] as Map).cast<String, dynamic>())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'code': code,
    'data': data?.toJson(),
  };
}

class OtpData {
  final String accessToken;
  final String refreshToken;
  final String role;
  final String sessionToken;
  final bool isReferralApplied;

  const OtpData({
    required this.accessToken,
    required this.refreshToken,
    required this.role,
    required this.sessionToken,
    required this.isReferralApplied,
  });

  // ✅ convert anything into bool safely
  static bool _toBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v == 1;
    if (v is String) {
      final s = v.trim().toLowerCase();
      return s == "true" || s == "1" || s == "yes";
    }
    return false;
  }

  factory OtpData.fromJson(Map<String, dynamic> json) {
    return OtpData(
      accessToken: (json['accessToken'] ?? '').toString(),
      refreshToken: (json['refreshToken'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      sessionToken: (json['sessionToken'] ?? '').toString(),
      isReferralApplied: _toBool(json['isReferralApplied']), // ✅ FIX
    );
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'role': role,
    'sessionToken': sessionToken,
    'isReferralApplied': isReferralApplied,
  };
}
