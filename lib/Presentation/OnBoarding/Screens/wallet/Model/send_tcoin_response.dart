class SendTcoinResponse {
  final bool status;
  final int code;
  final SendTcoinData data;

  SendTcoinResponse({
    required this.status,
    required this.code,
    required this.data,
  });

  factory SendTcoinResponse.fromJson(Map<String, dynamic> json) {
    return SendTcoinResponse(
      status: json['status'] == true,
      code: (json['code'] as num?)?.toInt() ?? 0,
      data: SendTcoinData.fromJson(
        (json['data'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'code': code,
    'data': data.toJson(),
  };
}

class SendTcoinData {
  final bool success;
  final num fromBalance; // num -> int/double safe

  SendTcoinData({
    required this.success,
    required this.fromBalance,
  });

  factory SendTcoinData.fromJson(Map<String, dynamic> json) {
    return SendTcoinData(
      success: json['success'] == true,
      fromBalance: json['fromBalance'] is num ? json['fromBalance'] : 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'fromBalance': fromBalance,
  };
}
