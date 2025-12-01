class ApiUrl {
  static const String base =
      "https://fenizo-tringo-backend-12ebb106711d.herokuapp.com/";
  static const String register = "${base}api/v1/auth/request-otp";
  static const String verifyOtp = "${base}api/v1/auth/verify-otp";
  static const String whatsAppVerify = "${base}api/v1/auth/check-whatsapp";
  static const String resendOtp = "${base}api/v1/auth/resend-otp";
  static const String home = "${base}api/v1/public/home";
  static const String profile = "${base}api/v1/customer/profile";
  static String imageUrl =
      "https://next.fenizotechnologies.com/Adrox/api/image-save";
  static String shopDetails({required String shopId}) {
    return "${base}api/v1/public/shops/$shopId";
  }

  static String shopList({required String kind}) {
    return "${base}api/v1/public/shops?kind=$kind";
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

  static String viewAllDetailedServices({required String serviceId}) {
    return "${base}api/v1/public/services/$serviceId";
  }
}
