class CcavenueInitResponse {
  final bool status;
  final String? message;
  final CcavenueInitData? data;

  const CcavenueInitResponse({
    required this.status,
    this.message,
    this.data,
  });

  factory CcavenueInitResponse.fromJson(Map<String, dynamic> json) {
    return CcavenueInitResponse(
      status: json['status'] == true,
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? CcavenueInitData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class CcavenueInitData {
  final String provider;
  final String orderId;
  final String amount;
  final String currency;
  final String mode;

  final String? redirectUrl;
  final String? cancelUrl;

  final CcavenueForm? form;

  final String? planId;
  final String? businessProfileId;
  final String? shopId;

  const CcavenueInitData({
    required this.provider,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.mode,
    required this.redirectUrl,
    required this.cancelUrl,
    required this.form,
    required this.planId,
    required this.businessProfileId,
    required this.shopId,
  });

  factory CcavenueInitData.fromJson(Map<String, dynamic> json) {
    return CcavenueInitData(
      provider: (json['provider'] ?? '').toString(),
      orderId: (json['orderId'] ?? '').toString(),
      amount: (json['amount'] ?? '').toString(),
      currency: (json['currency'] ?? '').toString(),
      mode: (json['mode'] ?? '').toString(),
      redirectUrl: json['redirectUrl']?.toString(),
      cancelUrl: json['cancelUrl']?.toString(),
      form: json['form'] is Map<String, dynamic>
          ? CcavenueForm.fromJson(json['form'] as Map<String, dynamic>)
          : null,
      planId: json['planId']?.toString(),
      businessProfileId: json['businessProfileId']?.toString(),
      shopId: json['shopId']?.toString(),
    );
  }
}

class CcavenueForm {
  final String action;
  final String method;
  final Map<String, dynamic> fields;

  const CcavenueForm({
    required this.action,
    required this.method,
    required this.fields,
  });

  String get encRequest => (fields['encRequest'] ?? fields['enc_request'] ?? '').toString();
  String get accessCode => (fields['access_code'] ?? fields['accessCode'] ?? '').toString();

  factory CcavenueForm.fromJson(Map<String, dynamic> json) {
    return CcavenueForm(
      action: (json['action'] ?? '').toString(),
      method: (json['method'] ?? '').toString(),
      fields: json['fields'] is Map ? (json['fields'] as Map).cast<String, dynamic>() : const {},
    );
  }
}

