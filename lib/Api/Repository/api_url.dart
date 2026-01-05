class ApiUrl {
  static const String base =
      "https://fenizo-tringo-backend-12ebb106711d.herokuapp.com/";
  //  static const String base = "https://bknd.tringobiz.com/";
  // static const String base = "https://bknd.tringobiz.com/";
  static const String register = "${base}api/v1/auth/request-otp";
  static const String verifyOtp = "${base}api/v1/auth/verify-otp";
  static const String whatsAppVerify = "${base}api/v1/auth/check-whatsapp";
  static const String resendOtp = "${base}api/v1/auth/resend-otp";
  // static const String home = "${base}api/v1/public/home";
  static const String profile = "${base}api/v1/customer/profile";
  static const String version = "${base}api/v1/app/version";
  static const String mobileVerify = "${base}api/v1/auth/login-by-sim";
  static const String contactInfo = "${base}api/v1/contacts/sync";
  static String imageUrl =
      "https://next.fenizotechnologies.com/Adrox/api/image-save";
  static String shopDetails({required String shopId}) {
    return "${base}api/v1/public/shops/$shopId";
  }

  static String home({required double lng, required double lat}) {
    return "${base}api/v1/public/home?lat=$lat&lng=$lat";
  }

  static String shopList({required String kind, required String highlightId}) {
    return "${base}api/v1/public/shops?kind=$kind&highlightId=$highlightId";
  }

  static String viewAllProducts({required String shopId}) {
    return "${base}api/v1/public/shops/$shopId/products";
  }

  static String viewAllServices({required String shopId}) {
    return "${base}api/v1/public/shops/$shopId/services?page=1&limit=20";
  }

  static String putEnquiry({required String shopId}) {
    return "${base}api/v1/public/shops/$shopId/enquiries";
  }

  static String viewAllDetailedProducts({required String productId}) {
    return "${base}api/v1/public/products/$productId";
  }

  static String viewAllDetailedService({required String serviceId}) {
    return "${base}api/v1/public/services/$serviceId";
  }

  static String viewAllDetailedServices({required String serviceId}) {
    return "${base}api/v1/public/services/$serviceId";
  }

  static String searchSuggestions({
    required String searchWords,
    required double lat,
    required double lng,
  }) {
    return "${base}api/v1/public/search?q=$searchWords&lat=$lat&lng=$lng";
  }

  static String productList({
    required double lng,
    required double lat,
    required String kind,
    required String searchWords,
    required String highlightId,
  }) {
    return "${base}api/v1/public/listings?type=$kind&page=1&limit=0&highlightId=$highlightId";
  }

  // static String productList({
  //   required double lng,
  //   required double lat,
  //   required String searchWords,
  // }) {
  //   return "${base}api/v1/public/products?page=1&limit=20&q=$searchWords&lat=$lat&lng=$lng";
  // }
}
