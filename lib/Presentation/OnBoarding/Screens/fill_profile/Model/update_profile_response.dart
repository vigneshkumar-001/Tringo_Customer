class UserProfileResponse {
  final bool status;
  final UserProfileData data;

  UserProfileResponse({
    required this.status,
    required this.data,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      status: json['status'] ?? false,
      data: UserProfileData.fromJson(json['data'] ?? {}),
    );
  }
}

class UserProfileData {
  final String id;
  final String createdAt;
  final String updatedAt;
  final UserInfo user;
  final String displayName;
  final String? avatarUrl;
  final String? primaryCity;
  final String? primaryState;
  final int coins;
  final String tier;
  final String referralCode;
  final double? lastKnownLatitude;
  final double? lastKnownLongitude;
  final dynamic savedLocations; // if needed, convert later
  final String gender;
  final String dateOfBirth;

  UserProfileData({
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
  });
  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    return UserProfileData(
      id: json['id'] ?? "",
      createdAt: json['createdAt'] ?? "",
      updatedAt: json['updatedAt'] ?? "",
      user: UserInfo.fromJson(json['user'] ?? {}),
      displayName: json['displayName'] ?? "",
      avatarUrl: json['avatarUrl'],
      primaryCity: json['primaryCity'],
      primaryState: json['primaryState'],
      coins: json['coins'] ?? 0,
      tier: json['tier'] ?? "",
      referralCode: json['referralCode'] ?? "",
      lastKnownLatitude:
      double.tryParse(json['lastKnownLatitude']?.toString() ?? '0'),
      lastKnownLongitude:
      double.tryParse(json['lastKnownLongitude']?.toString() ?? '0'),
      savedLocations: json['savedLocations'],
      gender: json['gender'] ?? "",
      dateOfBirth: json['dateOfBirth'] ?? "",
    );
  }



// factory UserProfileData.fromJson(Map<String, dynamic> json) {
  //   return UserProfileData(
  //     id: json['id'] ?? "",
  //     createdAt: json['createdAt'] ?? "",
  //     updatedAt: json['updatedAt'] ?? "",
  //     user: UserInfo.fromJson(json['user'] ?? {}),
  //     displayName: json['displayName'] ?? "",
  //     avatarUrl: json['avatarUrl'],
  //     primaryCity: json['primaryCity'],
  //     primaryState: json['primaryState'],
  //     coins: json['coins'] ?? 0,
  //     tier: json['tier'] ?? "",
  //     referralCode: json['referralCode'] ?? "",
  //     lastKnownLatitude: json['lastKnownLatitude']?.toDouble(),
  //     lastKnownLongitude: json['lastKnownLongitude']?.toDouble(),
  //     savedLocations: json['savedLocations'],
  //     gender: json['gender'] ?? "",
  //     dateOfBirth: json['dateOfBirth'] ?? "",
  //   );
  // }
}

class UserInfo {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String fullName;
  final String phoneNumber;
  final String email;
  final String role;
  final String status;

  UserInfo({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.role,
    required this.status,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] ?? "",
      createdAt: json['createdAt'] ?? "",
      updatedAt: json['updatedAt'] ?? "",
      fullName: json['fullName'] ?? "",
      phoneNumber: json['phoneNumber'] ?? "",
      email: json['email'] ?? "",
      role: json['role'] ?? "",
      status: json['status'] ?? "",
    );
  }
}
