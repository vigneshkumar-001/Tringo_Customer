class MarkEnquiry {
  final bool success;

  MarkEnquiry({required this.success});

  factory MarkEnquiry.fromJson(Map<String, dynamic> json) {
    return MarkEnquiry(success: json['data']?['success'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {'success': success},
    };
  }
}
