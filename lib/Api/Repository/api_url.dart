class ApiUrl {
  // static const String base =
  //     "https://fenizo-tringo-backend-12ebb106711d.herokuapp.com/";


   static const String base = "https://bknd.tringobiz.com/";

  static const String register = "${base}api/v1/auth/request-otp";
  static const String verifyOtp = "${base}api/v1/auth/verify-otp";
  static const String requestLogin = "${base}api/v1/auth/request-login";
  static const String whatsAppVerify = "${base}api/v1/auth/check-whatsapp";
  static const String applyReferral = "${base}api/v1/auth/apply-referral";
  static const String resendOtp = "${base}api/v1/auth/resend-otp";
  static const String deleteAccount = "${base}api/v1/auth/me";
  // static const String home = "${base}api/v1/public/home";
  static const String profile = "${base}api/v1/customer/profile";
  static const String version = "${base}api/v1/app/version";
  static const String mobileVerify = "${base}api/v1/auth/login-by-sim";
  static const String contactInfo = "${base}api/v1/contacts/sync";
  static const String editProfile = "${base}api/v1/customer/profile";
  static const String imageUrl = "${base}api/media/image-save";
  static const String supportTicketsList = "${base}api/v1/support/tickets";
  static const String walletQrCode = "${base}api/v1/wallet/my-qr";

  static const String privacyPolicy =
      "${base}api/v1/public/pages/privacy-policy";
  static const String uIDPersonName = "${base}api/v1/wallet/resolve-uid";
  static const String uIDSendApi = "${base}api/v1/wallet/transfer";
  static const String uIDWithRawApi = "${base}api/v1/wallet/withdraw-request";
  static const String referralHistory = "${base}api/v1/wallet/referral";
  static const String reviewHistory = "${base}api/v1/reviews/history";
  static const String reviewCreate = "${base}api/v1/reviews";

  static String getChatMessages({required String id}) {
    return "${base}api/v1/support/tickets/$id";
  }

  static String sendMessage({required String ticketId}) {
    return "${base}api/v1/support/tickets/$ticketId/messages";
  }

  // static String imageUrl =
  //     "https://next.fenizotechnologies.com/Adrox/api/image-save";

  static const String changeNumberVerify =
      "${base}api/v1/auth/phone-verification/request";

  static const String changeNumberOtpVerify =
      "${base}api/v1/auth/phone-verification/verify";

  static String shopDetails({required String shopId}) {
    return "${base}api/v1/public/shops/$shopId";
  }

  static String home({required double lng, required double lat}) {
    return "${base}api/v1/public/home?lat=$lat&lng=$lng";
  }

  static String surpriseStatusCheck({
    required double lng,
    required String shopId,
    required double lat,
  }) {
    return "${base}api/v1/public/shops/$shopId/surprise/status?lat=$lat&lng=$lng";

  }
  static String surpriseClaimed({

    required String shopId,

  }) {
    return "${base}api/v1/public/shops/$shopId/surprise/claim";

  }

  static String walletHistory({required String type}) {
    return "${base}api/v1/wallet/history?type=$type";
  }

  // static String sendMessage({required String ticketId,  }) {
  //   return "${base}api/v1/support/tickets/$ticketId/messages";
  // }

  static String shopList({required String kind, required String highlightId}) {
    return "${base}api/v1/public/shops?kind=$kind&highlightId=$highlightId";
  }

  static String viewAllProducts({required String shopId}) {
    return "${base}api/v1/public/shops/$shopId/products";
  }

  static String viewAllServices({required String shopId}) {
    return "${base}api/v1/public/shops/$shopId/services?page=1&limit=20";
  }

  // static String getChatMessages({required String id}) {
  //   return "${base}api/v1/support/tickets/$id";
  // }

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
    return "${base}api/v1/public/search?q=$searchWords";
  }

  static String productList({
    required double lng,
    required double lat,
    required String kind,
    required String searchWords,
    required String highlightId,
  }) {
    return "${base}api/v1/public/listings?type=$kind&page=1&limit=15&highlightId=$highlightId";
  }

  // static String productList({
  //   required double lng,
  //   required double lat,
  //   required String searchWords,
  // }) {
  //   return "${base}api/v1/public/products?page=1&limit=20&q=$searchWords&lat=$lat&lng=$lng";
  // }
}
