import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_app/Api/DataSource/api_data_source.dart';

class ReviewModeration {
  ReviewModeration._();

  static const termsAcceptedKey = 'ugc_review_terms_accepted_v1';
  static const hiddenReviewIdsKey = 'ugc_hidden_review_ids_v1';
  static const blockedAuthorKeysKey = 'ugc_blocked_review_authors_v1';

  static const supportContactLabel = 'Profile > Support > Create Ticket';
  static const moderationResponseText =
      'Reports are reviewed within 24 hours. Objectionable content is removed and abusive users may be ejected.';

  static final List<RegExp> _blockedTextPatterns = [
    RegExp(
      r'\b(porn|xxx|nude|naked|sex|sexual|escort|abuse|abusive|harass|harassment|threat|threaten|kill|rape|terror|suicide|self\s*harm|hate|racist|drug|drugs|scam|fraud)\b',
      caseSensitive: false,
    ),
    RegExp(
      r'(f[\W_]*u[\W_]*c[\W_]*k|b[\W_]*i[\W_]*t[\W_]*c[\W_]*h)',
      caseSensitive: false,
    ),
  ];

  static bool containsObjectionableText(String text) {
    final normalized = text.trim();
    if (normalized.isEmpty) return false;
    return _blockedTextPatterns.any((pattern) => pattern.hasMatch(normalized));
  }

  static Future<bool> hasAcceptedTerms() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(termsAcceptedKey) ?? false;
  }

  static Future<void> acceptTerms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(termsAcceptedKey, true);
  }

  static Future<Set<String>> hiddenReviewIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(hiddenReviewIdsKey) ?? const <String>[])
        .toSet();
  }

  static Future<Set<String>> blockedAuthorKeys() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(blockedAuthorKeysKey) ?? const <String>[])
        .toSet();
  }

  static Future<void> hideReview(String reviewId) async {
    final id = reviewId.trim();
    if (id.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final ids = (prefs.getStringList(hiddenReviewIdsKey) ?? const <String>[])
        .toSet();
    ids.add(id);
    await prefs.setStringList(hiddenReviewIdsKey, ids.toList()..sort());
  }

  static String authorKey({
    required String authorUserId,
    required String authorName,
  }) {
    final id = authorUserId.trim();
    if (id.isNotEmpty) return 'id:$id';

    final name = authorName.trim().toLowerCase();
    if (name.isNotEmpty) return 'name:$name';

    return '';
  }

  static Future<void> blockAuthor({
    required String authorUserId,
    required String authorName,
  }) async {
    final key = authorKey(authorUserId: authorUserId, authorName: authorName);
    if (key.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final keys = (prefs.getStringList(blockedAuthorKeysKey) ?? const <String>[])
        .toSet();
    keys.add(key);
    await prefs.setStringList(blockedAuthorKeysKey, keys.toList()..sort());
  }

  static bool shouldHideReview({
    required String reviewId,
    required String authorUserId,
    required String authorName,
    required String heading,
    required String comment,
    required Set<String> hiddenReviewIds,
    required Set<String> blockedAuthorKeys,
  }) {
    if (hiddenReviewIds.contains(reviewId.trim())) return true;

    final key = authorKey(authorUserId: authorUserId, authorName: authorName);
    if (key.isNotEmpty && blockedAuthorKeys.contains(key)) return true;

    return containsObjectionableText('$heading $comment');
  }

  static Future<bool> submitReviewReport({
    required ApiDataSource api,
    required String reviewId,
    required String shopId,
    required String shopName,
    required String authorUserId,
    required String authorName,
    required String reason,
    required String heading,
    required String comment,
  }) async {
    final description = [
      'User generated content moderation report',
      'Reason: $reason',
      'Review ID: $reviewId',
      'Shop ID: $shopId',
      'Shop name: $shopName',
      'Author user ID: $authorUserId',
      'Author name: $authorName',
      'Heading: $heading',
      'Comment: $comment',
      moderationResponseText,
    ].join('\n');

    final result = await api.createSupportTicket(
      subject: 'Review moderation report: $reason',
      description: description,
      imageUrl: '',
      attachments: const [],
    );

    return result.fold((_) => false, (_) => true);
  }
}
