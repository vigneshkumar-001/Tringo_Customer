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
    String sanitizeUrl(String input) {
      var s = input.trim();
      // Backend sometimes includes a trailing quote (") or URL-encoded quote (%22).
      while (s.endsWith('"')) {
        s = s.substring(0, s.length - 1).trimRight();
      }
      if (s.endsWith('%22')) {
        s = s.substring(0, s.length - 3).trimRight();
      }
      return s;
    }

    String sanitizeShareText(String input) {
      final t = input.trim();
      if (t.isEmpty) return '';
      // Clean trailing quotes/%22 at end of the message or URL line.
      final lines = t.split('\n').map((l) => sanitizeUrl(l)).toList();
      return lines.join('\n').trim();
    }

    return ShareInfo(
      entityType: (json['entityType'] ?? '').toString(),
      webUrl: sanitizeUrl((json['webUrl'] ?? '').toString()),
      deepLink: sanitizeUrl((json['deepLink'] ?? '').toString()),
      packageId: (json['packageId'] ?? '').toString(),
      shareText: sanitizeShareText((json['shareText'] ?? '').toString()),
    );
  }

  String shareMessage({String? fallbackTitle}) {
    final t = shareText.trim();
    if (t.isNotEmpty) return t;

    final url = webUrl.trim();
    final title = (fallbackTitle ?? '').trim();
    if (url.isNotEmpty && title.isNotEmpty) return '$title\n$url';
    if (url.isNotEmpty) return url;
    return title;
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
