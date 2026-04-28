class SubscriptionCurrentResponse {
  final bool status;
  final String? message;
  final SubscriptionCurrentData? data;

  const SubscriptionCurrentResponse({
    required this.status,
    this.message,
    this.data,
  });

  factory SubscriptionCurrentResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionCurrentResponse(
      status: json['status'] == true,
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? SubscriptionCurrentData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SubscriptionCurrentData {
  final String? subscriptionId;
  final String? businessProfileId;
  final bool isFreemium;
  final String status;
  final SubscriptionPlanInfo? plan;
  final SubscriptionPaymentInfo? payment;
  final SubscriptionPeriodInfo? period;

  const SubscriptionCurrentData({
    required this.subscriptionId,
    required this.businessProfileId,
    required this.isFreemium,
    required this.status,
    required this.plan,
    required this.payment,
    required this.period,
  });

  factory SubscriptionCurrentData.fromJson(Map<String, dynamic> json) {
    return SubscriptionCurrentData(
      subscriptionId: json['subscriptionId']?.toString(),
      businessProfileId: json['businessProfileId']?.toString(),
      isFreemium: json['isFreemium'] == true,
      status: (json['status'] ?? '').toString(),
      plan: json['plan'] is Map<String, dynamic>
          ? SubscriptionPlanInfo.fromJson(json['plan'] as Map<String, dynamic>)
          : null,
      payment: json['payment'] is Map<String, dynamic>
          ? SubscriptionPaymentInfo.fromJson(json['payment'] as Map<String, dynamic>)
          : null,
      period: json['period'] is Map<String, dynamic>
          ? SubscriptionPeriodInfo.fromJson(json['period'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SubscriptionPlanInfo {
  final String id;
  final String title;
  final String planCategory;
  final String type;
  final int? durationDays;
  final String durationLabel;
  final int price;

  const SubscriptionPlanInfo({
    required this.id,
    required this.title,
    required this.planCategory,
    required this.type,
    required this.durationDays,
    required this.durationLabel,
    required this.price,
  });

  factory SubscriptionPlanInfo.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanInfo(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      planCategory: (json['planCategory'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      durationDays: json['durationDays'] is int
          ? json['durationDays'] as int
          : int.tryParse('${json['durationDays']}'),
      durationLabel: (json['durationLabel'] ?? '').toString(),
      price: json['price'] is int ? json['price'] as int : int.tryParse('${json['price']}') ?? 0,
    );
  }
}

class SubscriptionPaymentInfo {
  final String provider;
  final int? paidAmount;
  final String currency;
  final String orderId;
  final String? paymentId;
  final String? txId;
  final String status;

  const SubscriptionPaymentInfo({
    required this.provider,
    required this.paidAmount,
    required this.currency,
    required this.orderId,
    required this.paymentId,
    required this.txId,
    required this.status,
  });

  factory SubscriptionPaymentInfo.fromJson(Map<String, dynamic> json) {
    return SubscriptionPaymentInfo(
      provider: (json['provider'] ?? '').toString(),
      paidAmount: json['paidAmount'] is int
          ? json['paidAmount'] as int
          : int.tryParse('${json['paidAmount']}'),
      currency: (json['currency'] ?? '').toString(),
      orderId: (json['orderId'] ?? '').toString(),
      paymentId: json['paymentId']?.toString(),
      txId: json['txId']?.toString(),
      status: (json['status'] ?? '').toString(),
    );
  }
}

class SubscriptionPeriodInfo {
  final String? startsAt;
  final String? endsAt;
  final String? startsAtLabel;
  final String? endsAtLabel;
  final int? daysLeft;
  final int? durationDays;

  const SubscriptionPeriodInfo({
    required this.startsAt,
    required this.endsAt,
    required this.startsAtLabel,
    required this.endsAtLabel,
    required this.daysLeft,
    required this.durationDays,
  });

  factory SubscriptionPeriodInfo.fromJson(Map<String, dynamic> json) {
    return SubscriptionPeriodInfo(
      startsAt: json['startsAt']?.toString(),
      endsAt: json['endsAt']?.toString(),
      startsAtLabel: json['startsAtLabel']?.toString(),
      endsAtLabel: json['endsAtLabel']?.toString(),
      daysLeft: json['daysLeft'] is int ? json['daysLeft'] as int : int.tryParse('${json['daysLeft']}'),
      durationDays: json['durationDays'] is int
          ? json['durationDays'] as int
          : int.tryParse('${json['durationDays']}'),
    );
  }
}

