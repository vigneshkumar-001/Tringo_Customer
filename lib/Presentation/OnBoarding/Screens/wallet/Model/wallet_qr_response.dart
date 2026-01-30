class WalletQrResponse {
  final bool status;
  final WalletQrData data;

  const WalletQrResponse({
    required this.status,
    required this.data,
  });

  factory WalletQrResponse.fromJson(Map<String, dynamic> json) {
    return WalletQrResponse(
      status: json['status'] == true,
      data: WalletQrData.fromJson((json['data'] ?? {}) as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'data': data.toJson(),
  };
}

class WalletQrData {
  final String uid;
  final String action;
  final String qrImageUrl;
  final String? downloadUrl;
  final String deepLink;
  final String payload;
  final String? expiresAt;

  const WalletQrData({
    required this.uid,
    required this.action,
    required this.qrImageUrl,
    this.downloadUrl,
    required this.deepLink,
    required this.payload,
    this.expiresAt,
  });

  factory WalletQrData.fromJson(Map<String, dynamic> json) {
    return WalletQrData(
      uid: (json['uid'] ?? '').toString(),
      action: (json['action'] ?? '').toString(),
      qrImageUrl: (json['qrImageUrl'] ?? '').toString(),
      downloadUrl: json['downloadUrl']?.toString(),
      deepLink: (json['deepLink'] ?? '').toString(),
      payload: (json['payload'] ?? '').toString(),
      expiresAt: json['expiresAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'action': action,
    'qrImageUrl': qrImageUrl,
    'downloadUrl': downloadUrl,
    'deepLink': deepLink,
    'payload': payload,
    'expiresAt': expiresAt,
  };
}
