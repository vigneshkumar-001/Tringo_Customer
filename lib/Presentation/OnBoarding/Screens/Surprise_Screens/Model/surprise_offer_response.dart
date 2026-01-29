class SurpriseStatusResponse {
  final bool status;
  final SurpriseStatusData data;

  SurpriseStatusResponse({required this.status, required this.data});

  factory SurpriseStatusResponse.fromJson(Map<String, dynamic> json) {
    return SurpriseStatusResponse(
      status: json['status'],
      data: SurpriseStatusData.fromJson(json['data']),
    );
  }
}

class SurpriseStatusData {
  final bool success;
  final String stage;
  final String shopId;
  final Shop shop;
  final Offer offer;
  final Geo geo;
  final OfferState state;
  final UiConfig ui;
  final String? code;
  final Legacy legacy;
  final String? message; // 👈 NEW (Already claimed)

  SurpriseStatusData({
    required this.success,
    required this.stage,
    required this.shopId,
    required this.shop,
    required this.offer,
    required this.geo,
    required this.state,
    required this.ui,
    this.code,
    required this.legacy,
    this.message,
  });

  factory SurpriseStatusData.fromJson(Map<String, dynamic> json) {
    return SurpriseStatusData(
      success: json['success'],
      stage: json['stage'],
      shopId: json['shopId'],
      shop: Shop.fromJson(json['shop']),
      offer: Offer.fromJson(json['offer']),
      geo: Geo.fromJson(json['geo']),
      state: OfferState.fromJson(json['state']),
      ui: UiConfig.fromJson(json['ui']),
      code: json['code'],
      legacy: Legacy.fromJson(json['legacy']),
      message: json['message'],
    );
  }
}

class Shop {
  final String id;
  final String name;
  final String imageUrl;
  final int rating;
  final int reviewCount;
  final double distanceKm;
  final String distanceLabel;
  final String openLabel;
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
    required this.isOpen,
    required this.city,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      rating: json['rating'],
      reviewCount: json['reviewCount'],
      distanceKm: (json['distanceKm'] as num).toDouble(),
      distanceLabel: json['distanceLabel'],
      openLabel: json['openLabel'],
      isOpen: json['isOpen'],
      city: json['city'],
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
  final DateTime validUpto;

  Offer({
    required this.id,
    required this.title,
    this.bannerUrl,
    required this.shortText,
    required this.description,
    this.terms,
    required this.validUpto,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'],
      title: json['title'],
      bannerUrl: json['bannerUrl'],
      shortText: json['shortText'],
      description: json['description'],
      terms: json['terms'],
      validUpto: DateTime.parse(json['validUpto']),
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
    return Geo(
      unlockRadiusMeters: json['unlockRadiusMeters'],
      distanceMeters: json['distanceMeters'],
      remainingMeters: json['remainingMeters'],
      canUnlock: json['canUnlock'],
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
      isUnlocked: json['isUnlocked'],
      isClaimed: json['isClaimed'],
      isRedeemed: json['isRedeemed'],
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
    return UiConfig(
      screenTitle: json['screenTitle'],
      primaryText: json['primaryText'],
      secondaryText: json['secondaryText'],
      giftClosedKey: json['giftClosedKey'],
      giftOpenKey: json['giftOpenKey'],
      openingAnimationKey: json['openingAnimationKey'],
      openingDurationMs: json['openingDurationMs'],
      afterOpeningAction: json['afterOpeningAction'],
      codeLabel: json['codeLabel'],
      copyButtonText: json['copyButtonText'],
    );
  }
}

class Legacy {
  final bool hasSurpriseOffer;
  final String offerId;

  Legacy({required this.hasSurpriseOffer, required this.offerId});

  factory Legacy.fromJson(Map<String, dynamic> json) {
    return Legacy(
      hasSurpriseOffer: json['hasSurpriseOffer'],
      offerId: json['offerId'],
    );
  }
}
