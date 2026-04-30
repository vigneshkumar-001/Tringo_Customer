import 'dart:convert';

/// ✅ Root response model
class SmartConnectResponse {
  final bool status;
  final SmartConnectData data;

  const SmartConnectResponse({required this.status, required this.data});

  factory SmartConnectResponse.fromJson(Map<String, dynamic> json) {
    return SmartConnectResponse(
      status: json['status'] == true,
      data: SmartConnectData.fromJson(
        (json['data'] ?? {}) as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() => {'status': status, 'data': data.toJson()};

  /// Optional helpers if you receive raw string
  static SmartConnectResponse fromRawJson(String source) =>
      SmartConnectResponse.fromJson(jsonDecode(source) as Map<String, dynamic>);

  String toRawJson() => jsonEncode(toJson());
}

/// ✅ data section model
class SmartConnectData {
  final List<String> steps;
  final List<String> faq;

  const SmartConnectData({required this.steps, required this.faq});

  factory SmartConnectData.fromJson(Map<String, dynamic> json) {
    return SmartConnectData(
      steps: _toStringList(json['steps']),
      faq: _toStringList(json['faq']),
    );
  }

  Map<String, dynamic> toJson() => {'steps': steps, 'faq': faq};

  static List<String> _toStringList(dynamic v) {
    if (v is List) {
      return v
          .map((e) => (e ?? '').toString())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return const <String>[];
  }
}
