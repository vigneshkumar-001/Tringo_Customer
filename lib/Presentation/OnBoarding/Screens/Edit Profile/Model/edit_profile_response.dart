class EditProfileResponse {
  final bool status;
  final String? message;
  final UserData? data;

  EditProfileResponse({
    required this.status,
    required this.data,
    this.message,
  });

  factory EditProfileResponse.fromJson(Map<String, dynamic> json) {
    return EditProfileResponse(
      status: json['status'] == true,
      message: json['message'] as String?,
      data: json['data'] == null ? null : UserData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.toJson(),
  };
}

class UserData {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;

  final User user;

  final String displayName;
  final String avatarUrl;

  final String? primaryCity;
  final String? primaryState;

  final int coins;
  final String tier;
  final String referralCode;

  final String lastKnownLatitude;
  final String lastKnownLongitude;

  final dynamic savedLocations;

  final String gender;
  final DateTime dateOfBirth;

  // ✅ ADD THESE (because you use them later)
  final bool verified;
  final String verificationToken;

  UserData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.displayName,
    required this.avatarUrl,
    required this.primaryCity,
    required this.primaryState,
    required this.coins,
    required this.tier,
    required this.referralCode,
    required this.lastKnownLatitude,
    required this.lastKnownLongitude,
    required this.savedLocations,
    required this.gender,
    required this.dateOfBirth,
    required this.verified,
    required this.verificationToken,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic v) =>
        v == null ? DateTime.fromMillisecondsSinceEpoch(0) : DateTime.parse('$v');

    int parseInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse('$v') ?? 0;
    }

    return UserData(
      id: (json['id'] ?? '') as String,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      user: User.fromJson((json['user'] ?? {}) as Map<String, dynamic>),
      displayName: (json['displayName'] ?? '') as String,
      avatarUrl: (json['avatarUrl'] ?? '') as String,
      primaryCity: json['primaryCity'] as String?,
      primaryState: json['primaryState'] as String?,
      coins: parseInt(json['coins']),
      tier: (json['tier'] ?? '') as String,
      referralCode: (json['referralCode'] ?? '') as String,
      lastKnownLatitude: (json['lastKnownLatitude'] ?? '') as String,
      lastKnownLongitude: (json['lastKnownLongitude'] ?? '') as String,
      savedLocations: json['savedLocations'],
      gender: (json['gender'] ?? '') as String,
      dateOfBirth: parseDate(json['dateOfBirth']),

      // ✅ safe defaults
      verified: json['verified'] == true,
      verificationToken: (json['verificationToken'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'user': user.toJson(),
    'displayName': displayName,
    'avatarUrl': avatarUrl,
    'primaryCity': primaryCity,
    'primaryState': primaryState,
    'coins': coins,
    'tier': tier,
    'referralCode': referralCode,
    'lastKnownLatitude': lastKnownLatitude,
    'lastKnownLongitude': lastKnownLongitude,
    'savedLocations': savedLocations,
    'gender': gender,
    'dateOfBirth': dateOfBirth.toIso8601String(),

    // ✅
    'verified': verified,
    'verificationToken': verificationToken,
  };
}

class User {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;

  final String fullName;
  final String phoneNumber;
  final String activePhoneNumber;
  final String email;

  final String role;
  final String status;

  final bool isDeleted;
  final DateTime? deletedAt;

  User({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.fullName,
    required this.phoneNumber,
    required this.activePhoneNumber,
    required this.email,
    required this.role,
    required this.status,
    required this.isDeleted,
    required this.deletedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic v) =>
        v == null ? DateTime.fromMillisecondsSinceEpoch(0) : DateTime.parse('$v');

    DateTime? tryParseDate(dynamic v) =>
        v == null ? null : DateTime.tryParse('$v');

    return User(
      id: (json['id'] ?? '') as String,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      fullName: (json['fullName'] ?? '') as String,
      phoneNumber: (json['phoneNumber'] ?? '') as String,
      activePhoneNumber: (json['activePhoneNumber'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      role: (json['role'] ?? '') as String,
      status: (json['status'] ?? '') as String,
      isDeleted: json['isDeleted'] == true,
      deletedAt: tryParseDate(json['deletedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'fullName': fullName,
    'phoneNumber': phoneNumber,
    'activePhoneNumber': activePhoneNumber,
    'email': email,
    'role': role,
    'status': status,
    'isDeleted': isDeleted,
    'deletedAt': deletedAt?.toIso8601String(),
  };
}
