class LoginResponse {
  final bool status;
  final int code;
  final OtpInitData? data;

  LoginResponse({required this.status, required this.code, this.data});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'] as bool,
      code: json['code'] as int,
      data: json['data'] != null
          ? OtpInitData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'code': code, 'data': data?.toJson()};
  }
}

class OtpInitData {
  final String maskedContact;
  final int waitSeconds;

  OtpInitData({required this.maskedContact, required this.waitSeconds});

  factory OtpInitData.fromJson(Map<String, dynamic> json) {
    return OtpInitData(
      maskedContact: json['maskedContact'] as String,
      waitSeconds: json['waitSeconds'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'maskedContact': maskedContact, 'waitSeconds': waitSeconds};
  }
}
