class EditProfileResponse {
  final bool status;
  final ProfileData data;

  EditProfileResponse({
    required this.status,
    required this.data,
  });

  factory EditProfileResponse.fromJson(Map<String, dynamic> json) {
    return EditProfileResponse(
      status: json['status'] ?? false,
      data: ProfileData.fromJson(json['data']),
    );
  }
}
class ProfileData {
  final String id;
  final String displayName;
  final String avatarUrl;
  final int coins;
  final String tier;
  final String referralCode;
  final String? gender;
  final DateTime? dateOfBirth;
  final User user;

  ProfileData({
    required this.id,
    required this.displayName,
    required this.avatarUrl,
    required this.coins,
    required this.tier,
    required this.referralCode,
    required this.user,
    this.gender,
    this.dateOfBirth,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['id'],
      displayName: json['displayName'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      coins: json['coins'] ?? 0,
      tier: json['tier'] ?? '',
      referralCode: json['referralCode'] ?? '',
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      user: User.fromJson(json['user']),
    );
  }
}
class User {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String activePhoneNumber;
  final String email;
  final String role;
  final String status;

  User({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.activePhoneNumber,
    required this.email,
    required this.role,
    required this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      activePhoneNumber: json['activePhoneNumber'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
