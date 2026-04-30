class SubscriptionPlansResponse {
  final bool status;
  final List<SubscriptionPlan> data;

  const SubscriptionPlansResponse({
    required this.status,
    required this.data,
  });

  factory SubscriptionPlansResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final list = raw is List ? raw : const [];
    return SubscriptionPlansResponse(
      status: json['status'] == true,
      data: list
          .map((e) => e is Map<String, dynamic> ? SubscriptionPlan.fromJson(e) : null)
          .whereType<SubscriptionPlan>()
          .toList(),
    );
  }
}

class SubscriptionPlan {
  final String id;
  final String title;

  /// Display label from `/plans`, e.g. "1 Month", "3 Month", "1 Year"
  final String typeLabel;
  final int? durationDays;
  final int price;
  final List<dynamic> features;

  const SubscriptionPlan({
    required this.id,
    required this.title,
    required this.typeLabel,
    required this.durationDays,
    required this.price,
    required this.features,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      typeLabel: (json['type'] ?? '').toString(),
      durationDays: json['durationDays'] is int
          ? json['durationDays'] as int
          : int.tryParse('${json['durationDays']}'),
      price: json['price'] is int ? json['price'] as int : int.tryParse('${json['price']}') ?? 0,
      features: (json['features'] is List) ? (json['features'] as List) : const [],
    );
  }
}

