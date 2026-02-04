// surprise_offer_response.dart

class SurpriseStatusResponse {
  final bool status;
  final SurpriseStatusData data;

  SurpriseStatusResponse({required this.status, required this.data});

  factory SurpriseStatusResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return SurpriseStatusResponse(
      status: json['status'] == true,
      data: SurpriseStatusData.fromJson(
        rawData is Map<String, dynamic> ? rawData : <String, dynamic>{},
      ),
    );
  }
}

class SurpriseStatusData {
  final bool success;
  final String stage;
  final String shopId;

  // ✅ nullable (because API returns null in LOCKED stage)
  final Shop? shop;
  final Offer? offer;
  final Geo? geo;
  final OfferState? state;
  final Legacy? legacy;

  final UiConfig ui;
  final String? code;
  final String? message;

  SurpriseStatusData({
    required this.success,
    required this.stage,
    required this.shopId,
    required this.ui,
    this.shop,
    this.offer,
    this.geo,
    this.state,
    this.legacy,
    this.code,
    this.message,
  });

  factory SurpriseStatusData.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? _asMap(dynamic v) =>
        v is Map<String, dynamic> ? v : null;

    return SurpriseStatusData(
      success: json['success'] == true,
      stage: (json['stage'] ?? '').toString(),
      shopId: (json['shopId'] ?? '').toString(),

      shop: _asMap(json['shop']) != null
          ? Shop.fromJson(_asMap(json['shop'])!)
          : null,
      offer: _asMap(json['offer']) != null
          ? Offer.fromJson(_asMap(json['offer'])!)
          : null,
      geo: _asMap(json['geo']) != null
          ? Geo.fromJson(_asMap(json['geo'])!)
          : null,
      state: _asMap(json['state']) != null
          ? OfferState.fromJson(_asMap(json['state'])!)
          : null,
      legacy: _asMap(json['legacy']) != null
          ? Legacy.fromJson(_asMap(json['legacy'])!)
          : null,

      ui: UiConfig.fromJson(_asMap(json['ui']) ?? <String, dynamic>{}),
      code: json['code'] ?? ''.toString(),
      message: json['message']?.toString(),
    );
  }
}

class Shop {
  final String id;
  final String name;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final double distanceKm;
  final String distanceLabel;
  final String openLabel;
  final String closeTime;
  final bool isOpen;
  final String city;

  Shop({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.distanceKm,
    required this.distanceLabel,
    required this.openLabel,
    required this.closeTime,
    required this.isOpen,
    required this.city,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) =>
        (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0.0;
    int _toInt(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;

    return Shop(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      rating: _toDouble(json['rating']),
      reviewCount: _toInt(json['reviewCount']),
      distanceKm: _toDouble(json['distanceKm']),
      distanceLabel: (json['distanceLabel'] ?? '').toString(),
      openLabel: (json['openLabel'] ?? '').toString(),
      closeTime: (json['closeTime'] ?? '').toString(),
      isOpen: json['isOpen'] == true,
      city: (json['city'] ?? '').toString(),
    );
  }
}

class Offer {
  final String id;
  final String title;
  final String? bannerUrl;
  final String shortText;
  final String description;
  final String? terms;
  final DateTime? validUpto; // ✅ null-safe parse

  Offer({
    required this.id,
    required this.title,
    this.bannerUrl,
    required this.shortText,
    required this.description,
    this.terms,
    this.validUpto,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    DateTime? _tryDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    return Offer(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      bannerUrl: json['bannerUrl']?.toString(),
      shortText: (json['shortText'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      terms: json['terms']?.toString(),
      validUpto: _tryDate(json['validUpto']),
    );
  }
}

class Geo {
  final int unlockRadiusMeters;
  final int distanceMeters;
  final int remainingMeters;
  final bool canUnlock;

  Geo({
    required this.unlockRadiusMeters,
    required this.distanceMeters,
    required this.remainingMeters,
    required this.canUnlock,
  });

  factory Geo.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;

    return Geo(
      unlockRadiusMeters: _toInt(json['unlockRadiusMeters']),
      distanceMeters: _toInt(json['distanceMeters']),
      remainingMeters: _toInt(json['remainingMeters']),
      canUnlock: json['canUnlock'] == true,
    );
  }
}

class OfferState {
  final bool isUnlocked;
  final bool isClaimed;
  final bool isRedeemed;

  OfferState({
    required this.isUnlocked,
    required this.isClaimed,
    required this.isRedeemed,
  });

  factory OfferState.fromJson(Map<String, dynamic> json) {
    return OfferState(
      isUnlocked: json['isUnlocked'] == true,
      isClaimed: json['isClaimed'] == true,
      isRedeemed: json['isRedeemed'] == true,
    );
  }
}

class UiConfig {
  final String screenTitle;
  final String? primaryText;
  final String? secondaryText;
  final String giftClosedKey;
  final String giftOpenKey;
  final String openingAnimationKey;
  final int openingDurationMs;
  final String afterOpeningAction;
  final String codeLabel;
  final String copyButtonText;

  UiConfig({
    required this.screenTitle,
    this.primaryText,
    this.secondaryText,
    required this.giftClosedKey,
    required this.giftOpenKey,
    required this.openingAnimationKey,
    required this.openingDurationMs,
    required this.afterOpeningAction,
    required this.codeLabel,
    required this.copyButtonText,
  });

  factory UiConfig.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;

    return UiConfig(
      screenTitle: (json['screenTitle'] ?? 'Open Offer').toString(),
      primaryText: json['primaryText']?.toString(),
      secondaryText: json['secondaryText'] ?? ''.toString(),
      giftClosedKey: (json['giftClosedKey'] ?? 'GIFT_CLOSED').toString(),
      giftOpenKey: (json['giftOpenKey'] ?? 'GIFT_OPEN').toString(),
      openingAnimationKey: (json['openingAnimationKey'] ?? 'GIFT_OPEN')
          .toString(),
      openingDurationMs: _toInt(json['openingDurationMs']),
      afterOpeningAction: (json['afterOpeningAction'] ?? 'AUTO_CLAIM')
          .toString(),
      codeLabel: (json['codeLabel'] ?? 'Offer Code').toString(),
      copyButtonText: (json['copyButtonText'] ?? 'Copy').toString(),
    );
  }
}

class Legacy {
  final bool hasSurpriseOffer;
  final String offerId;

  Legacy({required this.hasSurpriseOffer, required this.offerId});

  factory Legacy.fromJson(Map<String, dynamic> json) {
    return Legacy(
      hasSurpriseOffer: json['hasSurpriseOffer'] == true,
      offerId: (json['offerId'] ?? '').toString(),
    );
  }
}
