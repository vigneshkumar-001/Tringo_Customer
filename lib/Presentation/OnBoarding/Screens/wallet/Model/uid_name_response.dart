class UidNameResponse {
  final bool status;
  final int code;
  final UserMiniData data;

  const UidNameResponse({
    required this.status,
    required this.code,
    required this.data,
  });

  factory UidNameResponse.fromJson(Map<String, dynamic> json) {
    return UidNameResponse(
      status: json['status'] == true,
      code: (json['code'] is num) ? (json['code'] as num).toInt() : 0,
      data: UserMiniData.fromJson(
        (json['data'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "code": code,
    "data": data.toJson(),
  };
}

class UserMiniData {
  final String uid;
  final String userId;
  final String role; // if you want, make enum
  final String? displayName;

  const UserMiniData({
    required this.uid,
    required this.userId,
    required this.role,
    required this.displayName,
  });

  factory UserMiniData.fromJson(Map<String, dynamic> json) {
    return UserMiniData(
      uid: (json['uid'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      displayName: (json['displayName'] == null)
          ? null
          : (json['displayName']).toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "userId": userId,
    "role": role,
    "displayName": displayName,
  };
}
