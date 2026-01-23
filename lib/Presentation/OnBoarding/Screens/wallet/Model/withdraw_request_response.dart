class WithdrawRequestResponse {
  final bool status;
  final int code;
  final WithdrawRequestData data;

  WithdrawRequestResponse({
    required this.status,
    required this.code,
    required this.data,
  });

  factory WithdrawRequestResponse.fromJson(Map<String, dynamic> json) {
    return WithdrawRequestResponse(
      status: json['status'] == true,
      code: (json['code'] as num?)?.toInt() ?? 0,
      data: WithdrawRequestData.fromJson(
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

class WithdrawRequestData {
  final bool success;
  final String requestId;
  final num inrAmount; // safe for int/double
  final num rate;

  WithdrawRequestData({
    required this.success,
    required this.requestId,
    required this.inrAmount,
    required this.rate,
  });

  factory WithdrawRequestData.fromJson(Map<String, dynamic> json) {
    return WithdrawRequestData(
      success: json['success'] == true,
      requestId: (json['requestId'] ?? '').toString(),
      inrAmount: json['inrAmount'] is num ? json['inrAmount'] : 0,
      rate: json['rate'] is num ? json['rate'] : 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'requestId': requestId,
    'inrAmount': inrAmount,
    'rate': rate,
  };
}
