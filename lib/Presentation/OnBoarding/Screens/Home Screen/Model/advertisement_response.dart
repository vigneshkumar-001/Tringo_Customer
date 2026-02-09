class  AdvertisementResponse  {
  final bool status;
  final List<AdvertisementBanner> data;

  const AdvertisementResponse({
    required this.status,
    required this.data,
  });

  factory AdvertisementResponse.fromJson(Map<String, dynamic> json) {
    return AdvertisementResponse(
      status: json['status'] == true,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => AdvertisementBanner.fromJson(e))
          .toList(),
    );
  }
}
class AdvertisementBanner {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String? ctaUrl;
  final String placement;
  final String? shopId;
  final String shopKind; // RETAIL / SERVICE

  const AdvertisementBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.ctaUrl,
    required this.placement,
    this.shopId,
    required this.shopKind,
  });

  factory AdvertisementBanner.fromJson(Map<String, dynamic> json) {
    return AdvertisementBanner(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      ctaUrl: json['ctaUrl'] as String?,
      placement: json['placement']?.toString() ?? '',
      shopId: json['shopId'] as String?,
      shopKind: json['shopKind']?.toString().toUpperCase() ?? '',
    );
  }
}
