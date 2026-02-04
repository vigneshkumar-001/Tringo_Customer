class FollowResponse {
  final bool status;
  final FollowData data;

  FollowResponse({
    required this.status,
    required this.data,
  });

  factory FollowResponse.fromJson(Map<String, dynamic> json) {
    return FollowResponse(
      status: json['status'] as bool,
      data: FollowData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.toJson(),
    };
  }
}

class FollowData {
  final bool success;
  final bool isFollowing;
  final int followerCount;

  FollowData({
    required this.success,
    required this.isFollowing,
    required this.followerCount,
  });

  factory FollowData.fromJson(Map<String, dynamic> json) {
    return FollowData(
      success: json['success'] as bool,
      isFollowing: json['isFollowing'] as bool,
      followerCount: json['followerCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'isFollowing': isFollowing,
      'followerCount': followerCount,
    };
  }
}
