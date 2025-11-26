class OtpResponse {
  final bool status;
  final int code;
  final AuthData? data;

  OtpResponse({required this.status, required this.code, this.data});

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      status: json['status'] as bool,
      code: json['code'] as int,
      data: json['data'] != null
          ? AuthData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'code': code, 'data': data?.toJson()};
  }
}

class AuthData {
  final String accessToken;
  final String refreshToken;
  final String role;
  final String sessionToken;

  AuthData({
    required this.accessToken,
    required this.refreshToken,
    required this.role,
    required this.sessionToken,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      role: json['role'] as String,
      sessionToken: json['sessionToken'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'role': role,
      'sessionToken': sessionToken,
    };
  }
}
