class DeepLinks {
  DeepLinks._();

  static const String scheme = 'tringo';
  static const String host = 'app';

  // WhatsApp normally linkifies only http/https links.
  // Configure this host for Android App Links + iOS Universal Links.
  static const String httpsHost = 'bknd.tringobiz.com';

  static Uri productDetails({required String productId}) {
    return Uri(
      scheme: scheme,
      host: host,
      path: '/product/details',
      queryParameters: {'productId': productId},
    );
  }

  static Uri home() {
    return Uri(
      scheme: scheme,
      host: host,
      path: '/home',
    );
  }

  static Uri homeHttps() {
    return Uri(
      scheme: 'https',
      host: httpsHost,
      path: '/home',
    );
  }

  static String homeShareText({String? title}) {
    final https = homeHttps();
    final t = (title ?? '').trim();
    return t.isEmpty ? '$https' : '$t\n$https';
  }

  static Uri productDetailsHttps({required String productId}) {
    return Uri(
      scheme: 'https',
      host: httpsHost,
      path: '/product/details',
      queryParameters: {'productId': productId},
    );
  }

  static String productShareText({required String productId}) {
    final https = productDetailsHttps(productId: productId);
    final app = productDetails(productId: productId);
    return 'Tringo product link:\n$https\n\n(If link not opening in app, try this):\n$app';
  }

  static Uri shopDetails({required String shopId, int? tab}) {
    final qp = <String, String>{'shopId': shopId};
    if (tab != null) qp['tab'] = tab.toString();
    return Uri(
      scheme: scheme,
      host: host,
      path: '/shop/details',
      queryParameters: qp,
    );
  }

  static Uri shopDetailsHttps({required String shopId, int? tab}) {
    final qp = <String, String>{'shopId': shopId};
    if (tab != null) qp['tab'] = tab.toString();
    return Uri(
      scheme: 'https',
      host: httpsHost,
      path: '/shop/details',
      queryParameters: qp,
    );
  }

  static String shopShareText({required String shopId, int? tab}) {
    final https = shopDetailsHttps(shopId: shopId, tab: tab);
    final app = shopDetails(shopId: shopId, tab: tab);
    return 'Tringo shop link:\n$https\n\n(If link not opening in app, try this):\n$app';
  }

  static Uri serviceDetails({required String serviceId}) {
    return Uri(
      scheme: scheme,
      host: host,
      path: '/service/details',
      queryParameters: {'serviceId': serviceId},
    );
  }

  static Uri serviceDetailsHttps({required String serviceId}) {
    return Uri(
      scheme: 'https',
      host: httpsHost,
      path: '/service/details',
      queryParameters: {'serviceId': serviceId},
    );
  }

  static String serviceShareText({required String serviceId}) {
    final https = serviceDetailsHttps(serviceId: serviceId);
    final app = serviceDetails(serviceId: serviceId);
    return 'Tringo service link:\n$https\n\n(If link not opening in app, try this):\n$app';
  }

  static Uri surpriseDetails({
    required String shopId,
    required String offerId,
  }) {
    return Uri(
      scheme: scheme,
      host: host,
      path: '/surprise/details',
      queryParameters: {'shopId': shopId, 'offerId': offerId},
    );
  }

  static Uri surpriseDetailsHttps({
    required String shopId,
    required String offerId,
  }) {
    return Uri(
      scheme: 'https',
      host: httpsHost,
      path: '/surprise/details',
      queryParameters: {'shopId': shopId, 'offerId': offerId},
    );
  }

  static String surpriseShareText({
    required String shopId,
    required String offerId,
  }) {
    final https = surpriseDetailsHttps(shopId: shopId, offerId: offerId);
    final app = surpriseDetails(shopId: shopId, offerId: offerId);
    return 'Tringo surprise offer link:\n$https\n\n(If link not opening in app, try this):\n$app';
  }
}
