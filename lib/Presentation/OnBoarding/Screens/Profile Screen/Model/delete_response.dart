class DeleteResponse {
  final bool status;
  final int code;
  final DeleteData data;

  DeleteResponse({
    required this.status,
    required this.code,
    required this.data,
  });

  factory DeleteResponse.fromJson(Map<String, dynamic> json) {
    return DeleteResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      data: DeleteData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'code': code,
    'data': data.toJson(),
  };
}

class DeleteData {
  final bool deleted;

  DeleteData({required this.deleted});

  factory DeleteData.fromJson(Map<String, dynamic> json) {
    return DeleteData(deleted: json['deleted'] ?? false);
  }

  Map<String, dynamic> toJson() => {'deleted': deleted};
}
