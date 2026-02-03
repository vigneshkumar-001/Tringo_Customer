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
  final String gender;
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
    required this.gender,
    this.dateOfBirth,
  });

  static String _clean(dynamic v) {
    final s = (v ?? '').toString().trim();
    if (s.toLowerCase() == 'null') return '';
    return s;
  }

  static DateTime? _tryDate(dynamic v) {
    final s = _clean(v);
    if (s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: _clean(json['id']),
      displayName: _clean(json['displayName']),
      avatarUrl: _clean(json['avatarUrl']),
      coins: (json['coins'] is num) ? (json['coins'] as num).toInt() : int.tryParse('${json['coins']}') ?? 0,
      tier: _clean(json['tier']),
      referralCode: _clean(json['referralCode']),
      gender: _clean(json['gender']),
      dateOfBirth: _tryDate(json['dateOfBirth']),
      user: User.fromJson((json['user'] as Map<String, dynamic>?) ?? {}),
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
