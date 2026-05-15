class LogoutRequest {
  final String refreshToken;
  final String? sessionToken;

  const LogoutRequest({required this.refreshToken, this.sessionToken});

  Map<String, dynamic> toJson() => {
    "refreshToken": refreshToken,
    if ((sessionToken ?? '').trim().isNotEmpty) "sessionToken": sessionToken,
  };
}

class LogoutResponse {
  final bool status;
  final int code;
  final bool success;
  final String? message;

  const LogoutResponse({
    required this.status,
    required this.code,
    required this.success,
    this.message,
  });

  factory LogoutResponse.fromJson(Map<String, dynamic> json) {
    final data = (json["data"] is Map<String, dynamic>)
        ? (json["data"] as Map<String, dynamic>)
        : <String, dynamic>{};

    return LogoutResponse(
      status: json["status"] == true,
      code: (json["code"] is int)
          ? json["code"] as int
          : int.tryParse("${json["code"]}") ?? 0,
      success: data["success"] == true,
      message: (json["message"] ?? '').toString().trim().isEmpty
          ? null
          : (json["message"] ?? '').toString(),
    );
  }
}

