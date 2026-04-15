class ShareInfo {
  final String entityType;
  final String webUrl;
  final String deepLink;
  final String packageId;
  final String shareText;

  ShareInfo({
    required this.entityType,
    required this.webUrl,
    required this.deepLink,
    required this.packageId,
    required this.shareText,
  });

  factory ShareInfo.fromJson(Map<String, dynamic> json) {
    return ShareInfo(
      entityType: (json['entityType'] ?? '').toString(),
      webUrl: (json['webUrl'] ?? '').toString(),
      deepLink: (json['deepLink'] ?? '').toString(),
      packageId: (json['packageId'] ?? '').toString(),
      shareText: (json['shareText'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entityType': entityType,
      'webUrl': webUrl,
      'deepLink': deepLink,
      'packageId': packageId,
      'shareText': shareText,
    };
  }
}

