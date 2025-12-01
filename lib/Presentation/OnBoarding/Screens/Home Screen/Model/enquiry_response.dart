class   EnquiryResponse{
  final bool status;
  final EnquiryData data;

  EnquiryResponse({
    required this.status,
    required this.data,
  });

  factory EnquiryResponse.fromJson(Map<String, dynamic> json) {
    return EnquiryResponse(
      status: json['status'] ?? false,
      data: EnquiryData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.toJson(),
    };
  }
}

class  EnquiryData {
  final String id;
  final String message;
  final String status;
  final DateTime createdAt;

  EnquiryData({
    required this.id,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory EnquiryData.fromJson(Map<String, dynamic> json) {
    return EnquiryData(
      id: json['id'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
