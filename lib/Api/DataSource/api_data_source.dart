import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:tringo_app/Core/Const/app_logger.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Edit%20Profile/Model/edit_profile_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Home%20Screen/Model/enquiry_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Home%20Screen/Model/home_response.dart';

// ✅ Use SAME model files everywhere
import 'package:tringo_app/Presentation/OnBoarding/Screens/Login Screen/Model/login_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Login Screen/Model/otp_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Login Screen/Model/whatsapp_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Login%20Screen/Model/referral_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Products/Model/product_detail_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Products/Model/product_list_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Search%20Screen/Model/search_suggestion_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Services%20Screen/Models/service_details_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Services%20Screen/Models/service_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Services%20Screen/Models/services_list_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Shop%20Screen/Model/product_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Shop%20Screen/Model/shop_details_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Shop%20Screen/Model/shops_model.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Support/Model/chat_message_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Support/Model/support_list_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Surprise_Screens/Model/surprise_offer_response.dart';

import '../../Core/Utility/app_prefs.dart';
import '../../Presentation/OnBoarding/Screens/Edit Profile/Model/edit_number_otp_response.dart';
import '../../Presentation/OnBoarding/Screens/Edit Profile/Model/edit_number_verify_response.dart';
import '../../Presentation/OnBoarding/Screens/Edit Profile/Model/edit_profile_response.dart';
import '../../Presentation/OnBoarding/Screens/Login Screen/Model/app_version_response.dart';
import '../../Presentation/OnBoarding/Screens/Login Screen/Model/contact_response.dart';
import '../../Presentation/OnBoarding/Screens/Login Screen/Model/login_new_response.dart';
import '../../Presentation/OnBoarding/Screens/Mobile Nomber Verify/Model/sim_verify_response.dart';
import '../../Presentation/OnBoarding/Screens/Privacy Policy/model/terms_and_condition_model.dart';
import '../../Presentation/OnBoarding/Screens/Profile Screen/Model/delete_response.dart';
import '../../Presentation/OnBoarding/Screens/Services Screen/Models/service_data_response.dart';
import '../../Presentation/OnBoarding/Screens/Support/Model/chat_message_response.dart';
import '../../Presentation/OnBoarding/Screens/Support/Model/create_support_response.dart';
import '../../Presentation/OnBoarding/Screens/Support/Model/send_message_response.dart';
import '../../Presentation/OnBoarding/Screens/fill_profile/Model/update_profile_response.dart'
    show UserProfileResponse;
import '../../Presentation/OnBoarding/Screens/fill_profile/Model/user_image_response.dart';
import '../../Presentation/OnBoarding/Screens/wallet/Model/referral_history_response.dart';
import '../../Presentation/OnBoarding/Screens/wallet/Model/review_create_response.dart';
import '../../Presentation/OnBoarding/Screens/wallet/Model/review_history_response.dart';
import '../../Presentation/OnBoarding/Screens/wallet/Model/send_tcoin_response.dart';
import '../../Presentation/OnBoarding/Screens/wallet/Model/uid_name_response.dart';
import '../../Presentation/OnBoarding/Screens/wallet/Model/wallet_history_response.dart';
import '../../Presentation/OnBoarding/Screens/wallet/Model/withdraw_request_response.dart';
import '../Repository/api_url.dart';
import '../Repository/failure.dart';
import '../Repository/request.dart';

abstract class BaseApiDataSource {
  Future<Either<Failure, LoginResponse>> mobileNumberLogin(
    String mobileNumber,
    String page,
  );
}

class ApiDataSource extends BaseApiDataSource {
  @override
  Future<Either<Failure, LoginResponse>> mobileNumberLogin(
    String phone,
    String simToken, {
    String page = "",
  }) async {
    try {
      final url = page == "resendOtp" ? ApiUrl.resendOtp : ApiUrl.register;

      final response = await Request.sendRequest(
        url,
        {"contact": "+91$phone", "purpose": "customer", "simToken": simToken},
        'Post',
        false,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['status'] == true) {
          return Right(LoginResponse.fromJson(response.data));
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Login failed"),
          );
        }
      }

      return Left(
        ServerFailure(response.data['message'] ?? "Something went wrong"),
      );
    } on DioException catch (e) {
      // 🔴 NO INTERNET
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return Left(ServerFailure("No internet connection. Please try again"));
      }

      final errorData = e.response?.data;
      if (errorData is Map && errorData['message'] != null) {
        return Left(ServerFailure(errorData['message']));
      }

      return Left(ServerFailure("Request failed"));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, OtpLoginResponse>> mobileNewNumberLogin(
    String phone,
    String simToken, {
    String page = "",
  }) async {
    try {
      // final url = page == "resendOtp" ? ApiUrl.resendOtp : ApiUrl.register;
      final url = ApiUrl.requestLogin;
      final method = simToken.isEmpty ? 'OTP' : 'SIM';
      final response = await Request.sendRequest(
        url,
        {
          "contact": "+91$phone",
          "purpose": "customer",
          "loginMethod": method,
          "simToken": simToken,
        },
        'Post',
        false,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['status'] == true) {
          return Right(OtpLoginResponse.fromJson(response.data));
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Login failed"),
          );
        }
      }

      return Left(
        ServerFailure(response.data['message'] ?? "Something went wrong"),
      );
    } on DioException catch (e) {
      // 🔴 NO INTERNET
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return Left(ServerFailure("No internet connection. Please try again"));
      }

      final errorData = e.response?.data;
      if (errorData is Map && errorData['message'] != null) {
        return Left(ServerFailure(errorData['message']));
      }

      return Left(ServerFailure("Request failed"));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  // Future<Either<Failure, LoginResponse>> mobileNumberLogin(
  //   String phone,
  //   String simToken, {
  //   String page = "",
  // }) async {
  //   try {
  //     // You can pass `page` later if backend needs it (resend / register etc)
  //     final String url = page == "resendOtp"
  //         ? ApiUrl.resendOtp
  //         : ApiUrl.register;
  //
  //     final response = await Request.sendRequest(
  //       url,
  //       {
  //         "contact": "+91$phone", // NOTE: still hard-coded to +91
  //         "purpose": "customer",
  //         "sim_token": simToken,
  //       },
  //       'Post',
  //       false,
  //     );
  //
  //     // If your Request.sendRequest returns DioException on error:
  //     if (response is DioException) {
  //       final errorData = response.response?.data;
  //
  //       if (errorData is Map && errorData['message'] != null) {
  //         return Left(ServerFailure(errorData['message']));
  //       }
  //
  //       return Left(ServerFailure(response.message ?? "Unknown Dio error"));
  //     }
  //
  //     // Normal HTTP response
  //     final statusCode = response.statusCode ?? 0;
  //     final data = response.data;
  //
  //     if (statusCode == 200 || statusCode == 201) {
  //       if (data['status'] == true) {
  //         return Right(LoginResponse.fromJson(data));
  //       } else {
  //         return Left(ServerFailure(data['message'] ?? "Login failed"));
  //       }
  //     } else {
  //       return Left(ServerFailure(data['message'] ?? "Something went wrong"));
  //     }
  //   } on TimeoutException catch (_) {
  //     return Left(ServerFailure("Request timed out, please try again."));
  //   } on DioException catch (e) {
  //     final errorData = e.response?.data;
  //     if (errorData is Map && errorData['message'] != null) {
  //       return Left(ServerFailure(errorData['message']));
  //     }
  //     return Left(ServerFailure(e.message ?? "Network error"));
  //   } catch (e) {
  //     return Left(ServerFailure("Unexpected error: $e"));
  //   }
  // }

  Future<Either<Failure, OtpResponse>> otp({
    required String contact,
    required String otp,
  }) async {
    try {
      final String url = ApiUrl.verifyOtp;

      final response = await Request.sendRequest(
        url,
        {"contact": "+91$contact", "code": otp, "purpose": "customer"},
        'POST',
        false,
      );

      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(OtpResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Login failed"),
            );
          }
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e.toString());
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, WhatsappResponse>> whatsAppNumberVerify({
    required String contact,
    required String purpose,
  }) async {
    try {
      final url = ApiUrl.whatsAppVerify;

      final payload = {"contact": "+91$contact", "purpose": purpose};

      final response = await Request.sendRequest(url, payload, 'Post', true);

      final data = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['status'] == true) {
          return Right(WhatsappResponse.fromJson(data));
        } else {
          return Left(ServerFailure(data['message'] ?? "Verification failed"));
        }
      }

      return Left(ServerFailure(data['message'] ?? "Something went wrong"));
    }
    // 🔴 NETWORK / INTERNET ERRORS
    on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return Left(ServerFailure("No internet connection. Please try again"));
      }

      final errorData = e.response?.data;
      if (errorData is Map && errorData['message'] != null) {
        return Left(ServerFailure(errorData['message']));
      }

      return Left(ServerFailure("Request failed"));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, HomeResponse>> getHomeDetails({
    required double lng,
    required double lat,
  }) async {
    try {
      final url = ApiUrl.home(lat: lat, lng: lng);

      final response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      final data = response?.data;

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        if (data['status'] == true) {
          return Right(HomeResponse.fromJson(data));
        } else {
          return Left(ServerFailure(data['message'] ?? "Login failed"));
        }
      } else {
        return Left(ServerFailure(data['message'] ?? "Something went wrong"));
      }
    } on DioException catch (dioError) {
      final errorData = dioError.response?.data;
      if (errorData is Map && errorData.containsKey('message')) {
        return Left(ServerFailure(errorData['message']));
      }
      return Left(ServerFailure(dioError.message ?? "Unknown Dio error"));
    } catch (e) {
      print(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ShopsResponse>> getShopDetails({
    required String highlightId,
  }) async {
    try {
      final url = ApiUrl.shopList(kind: 'RETAIL', highlightId: highlightId);

      final response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      final data = response?.data;

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        if (data['status'] == true) {
          return Right(ShopsResponse.fromJson(data));
        } else {
          return Left(ServerFailure(data['message'] ?? "Login failed"));
        }
      } else {
        return Left(ServerFailure(data['message'] ?? "Something went wrong"));
      }
    } on DioException catch (dioError) {
      final errorData = dioError.response?.data;
      if (errorData is Map && errorData.containsKey('message')) {
        return Left(ServerFailure(errorData['message']));
      }
      return Left(ServerFailure(dioError.message ?? "Unknown Dio error"));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ShopDetailsResponse>> getSpecificDetails({
    required String shopId,
  }) async {
    try {
      final url = ApiUrl.shopDetails(shopId: shopId);

      final response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      final data = response?.data;

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        if (data['status'] == true) {
          return Right(ShopDetailsResponse.fromJson(data));
        } else {
          return Left(ServerFailure(data['message'] ?? "Login failed"));
        }
      } else {
        return Left(ServerFailure(data['message'] ?? "Something went wrong"));
      }
    } on DioException catch (dioError) {
      final errorData = dioError.response?.data;
      if (errorData is Map && errorData.containsKey('message')) {
        return Left(ServerFailure(errorData['message']));
      }
      return Left(ServerFailure(dioError.message ?? "Unknown Dio error"));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ProductResponse>> viewAllProducts({
    required String shopId,
  }) async {
    try {
      AppLogger.log.i(shopId);
      final url = ApiUrl.viewAllProducts(shopId: shopId);

      final response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      final data = response?.data;

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        if (data['status'] == true) {
          return Right(ProductResponse.fromJson(data));
        } else {
          return Left(ServerFailure(data['message'] ?? "Login failed"));
        }
      } else {
        return Left(ServerFailure(data['message'] ?? "Something went wrong"));
      }
    } on DioException catch (dioError) {
      final errorData = dioError.response?.data;
      if (errorData is Map && errorData.containsKey('message')) {
        return Left(ServerFailure(errorData['message']));
      }
      return Left(ServerFailure(dioError.message ?? "Unknown Dio error"));
    } catch (e) {
      print(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ServiceResponse>> getServiceDetails({
    required String highlightId,
  }) async {
    try {
      final url = ApiUrl.shopList(kind: 'SERVICE', highlightId: highlightId);

      final response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      final data = response?.data;

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        if (data['status'] == true) {
          return Right(ServiceResponse.fromJson(data));
        } else {
          return Left(ServerFailure(data['message'] ?? "Login failed"));
        }
      } else {
        return Left(ServerFailure(data['message'] ?? "Something went wrong"));
      }
    } on DioException catch (dioError) {
      final errorData = dioError.response?.data;
      if (errorData is Map && errorData.containsKey('message')) {
        return Left(ServerFailure(errorData['message']));
      }
      return Left(ServerFailure(dioError.message ?? "Unknown Dio error"));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ServiceDetailsResponse>> getServiceSpecificDetails({
    required String shopId,
  }) async {
    try {
      final url = ApiUrl.shopDetails(shopId: shopId);

      final response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      final data = response?.data;

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        if (data['status'] == true) {
          return Right(ServiceDetailsResponse.fromJson(data));
        } else {
          return Left(ServerFailure(data['message'] ?? "Login failed"));
        }
      } else {
        return Left(ServerFailure(data['message'] ?? "Something went wrong"));
      }
    } on DioException catch (dioError) {
      final errorData = dioError.response?.data;
      if (errorData is Map && errorData.containsKey('message')) {
        return Left(ServerFailure(errorData['message']));
      }
      return Left(ServerFailure(dioError.message ?? "Unknown Dio error"));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ServicesListResponse>> viewAllServices({
    required String shopId,
  }) async {
    try {
      AppLogger.log.i(shopId);
      final url = ApiUrl.viewAllServices(shopId: shopId);

      final response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      final data = response?.data;

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        if (data['status'] == true) {
          return Right(ServicesListResponse.fromJson(data));
        } else {
          return Left(ServerFailure(data['message'] ?? "Login failed"));
        }
      } else {
        return Left(ServerFailure(data['message'] ?? "Something went wrong"));
      }
    } on DioException catch (dioError) {
      final errorData = dioError.response?.data;
      if (errorData is Map && errorData.containsKey('message')) {
        return Left(ServerFailure(errorData['message']));
      }
      return Left(ServerFailure(dioError.message ?? "Unknown Dio error"));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, UserProfileResponse>> updateProfile({
    required String displayName,
    required String email,
    required String gender,
    required String dateOfBirth,
    required String avatarUrl,
  }) async {
    try {
      final String url = ApiUrl.profile;

      final response = await Request.sendRequest(
        url,
        {
          "displayName": displayName,
          "email": email,
          "gender": gender.toUpperCase(),
          "dateOfBirth": dateOfBirth,
          "avatarUrl": avatarUrl,
        },
        'PATCH',
        true,
      );

      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(UserProfileResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Login failed"),
            );
          }
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e.toString());
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, UserImageResponse>> userProfileUpload({
    required File imageFile,
  }) async {
    try {
      if (!await imageFile.exists()) {
        return Left(ServerFailure('Image file does not exist.'));
      }

      String url = ApiUrl.imageUrl;

      FormData formData = FormData.fromMap({
        'images': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await Request.formData(url, formData, 'POST', true);

      late final Map<String, dynamic> responseData;
      final data = response.data;

      if (data is String) {
        responseData = jsonDecode(data) as Map<String, dynamic>;
      } else if (data is Map<String, dynamic>) {
        responseData = data;
      } else {
        return Left(ServerFailure("Unexpected response format"));
      }

      if (response.statusCode == 200) {
        if (responseData['status'] == true) {
          return Right(UserImageResponse.fromJson(responseData));
        } else {
          return Left(
            ServerFailure((responseData['message'] ?? '').toString()),
          );
        }
      } else if (response.statusCode == 409) {
        return Left(ServerFailure((responseData['message'] ?? '').toString()));
      } else {
        return Left(
          ServerFailure(
            (responseData['message'] ?? "Unknown error").toString(),
          ),
        );
      }
    } catch (e) {
      AppLogger.log.e(e);
      return Left(ServerFailure('Something went wrong'));
    }
  }

  Future<Either<Failure, EnquiryResponse>> putEnquiry({
    required String serviceId,
    required String productId,
    required String message,
    required String shopId,
  }) async {
    try {
      final String url = ApiUrl.putEnquiry(shopId: shopId);
      final Map<String, dynamic> body = {'message': message};

      if (serviceId.trim().isNotEmpty) {
        body['serviceId'] = serviceId;
      }
      if (productId.trim().isNotEmpty) {
        body['productId'] = productId;
      }

      final response = await Request.sendRequest(url, body, 'POST', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(EnquiryResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Login failed"),
            );
          }
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e.toString());
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ProductDetailResponse>> viewDetailProducts({
    required String productId,
  }) async {
    try {
      AppLogger.log.i(productId);
      final url = ApiUrl.viewAllDetailedProducts(productId: productId);

      final response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      final data = response?.data;

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        if (data['status'] == true) {
          return Right(ProductDetailResponse.fromJson(data));
        } else {
          return Left(ServerFailure(data['message'] ?? "Login failed"));
        }
      } else {
        return Left(ServerFailure(data['message'] ?? "Something went wrong"));
      }
    } on DioException catch (dioError) {
      final errorData = dioError.response?.data;
      if (errorData is Map && errorData.containsKey('message')) {
        return Left(ServerFailure(errorData['message']));
      }
      return Left(ServerFailure(dioError.message ?? "Unknown Dio error"));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ServiceDataResponse>> viewDetailServices({
    required String serviceId,
  }) async {
    try {
      AppLogger.log.i(serviceId);
      final url = ApiUrl.viewAllDetailedServices(serviceId: serviceId);

      final response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      final data = response?.data;

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        if (data['status'] == true) {
          return Right(ServiceDataResponse.fromJson(data));
        } else {
          return Left(ServerFailure(data['message'] ?? "Login failed"));
        }
      } else {
        return Left(ServerFailure(data['message'] ?? "Something went wrong"));
      }
    } on DioException catch (dioError) {
      final errorData = dioError.response?.data;
      if (errorData is Map && errorData.containsKey('message')) {
        return Left(ServerFailure(errorData['message']));
      }
      return Left(ServerFailure(dioError.message ?? "Unknown Dio error"));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, SearchSuggestionResponse>> searchSuggestions({
    required String searchWords,
    required String query,
  }) async {
    try {
      final url = ApiUrl.searchSuggestions(
        lat: 0.0,
        lng: 0.0,
        searchWords: searchWords,
      );

      final response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i('response Datas \n $response');

      final data = response?.data;

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        if (data['status'] == true) {
          return Right(SearchSuggestionResponse.fromJson(data));
        } else {
          return Left(ServerFailure(data['message'] ?? "Login failed"));
        }
      } else {
        return Left(ServerFailure(data['message'] ?? "Something went wrong"));
      }
    } on DioException catch (dioError) {
      final errorData = dioError.response?.data;
      if (errorData is Map && errorData.containsKey('message')) {
        return Left(ServerFailure(errorData['message']));
      }
      return Left(ServerFailure(dioError.message ?? "Unknown Dio error"));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ProductListResponse>> productList({
    required String searchWords,
    required String kind,
    required String highlightId,
  }) async {
    try {
      AppLogger.log.i(searchWords);
      final url = ApiUrl.productList(
        highlightId: highlightId,
        kind: kind,
        searchWords: searchWords,
        lng: 0.0,
        lat: 0.0,
      );

      final response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      final data = response?.data;

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        if (data['status'] == true) {
          return Right(ProductListResponse.fromJson(data));
        } else {
          return Left(ServerFailure(data['message'] ?? "Login failed"));
        }
      } else {
        return Left(ServerFailure(data['message'] ?? "Something went wrong"));
      }
    } on DioException catch (dioError) {
      final errorData = dioError.response?.data;
      if (errorData is Map && errorData.containsKey('message')) {
        return Left(ServerFailure(errorData['message']));
      }
      return Left(ServerFailure(dioError.message ?? "Unknown Dio error"));
    } catch (e, st) {
      AppLogger.log.e(e);
      AppLogger.log.e(st);
      print(e);
      print(st);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, SimVerifyResponse>> mobileVerify({
    required String contact,
    required String simToken,
    required String purpose,
  }) async {
    try {
      final url = ApiUrl.mobileVerify;

      final payload = {
        'contact': "+91$contact",
        'simToken': simToken,
        'purpose': 'customer',
      };

      // Use your normal POST helper
      dynamic response = await Request.sendRequest(url, payload, 'Post', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            // ✅ API returns the same JSON you showed
            return Right(SimVerifyResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Login failed"),
            );
          }
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, AppVersionResponse>> getAppVersion({
    required String appName,
    required String appVersion,
    required String appPlatForm,
  }) async {
    try {
      final url = ApiUrl.version;

      dynamic response = await Request.sendGetRequest(
        url,
        {},
        'GET',
        false,
        appName: appName,
        appPlatForm: appPlatForm,
        appVersion: appVersion,
      );

      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(AppVersionResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Login failed"),
            );
          }
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ContactResponse>> syncContacts({
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final url = ApiUrl.contactInfo; // same endpoint

      final payload = {"items": items};

      final response = await Request.sendRequest(url, payload, 'Post', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(ContactResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Sync failed"),
            );
          }
        }
        return Left(
          ServerFailure(response.data['message'] ?? "Something went wrong"),
        );
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, EditNumberVerifyResponse>> changeNumberRequest({
    required String phone,
    required String type,
  }) async {
    String url = ApiUrl.changeNumberVerify;

    final response = await Request.sendRequest(
      url,
      {"phone": "+91$phone", "type": type},
      'Post',
      true,
    );

    if (response is! DioException) {
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['status'] == true) {
          return Right(EditNumberVerifyResponse.fromJson(response.data));
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Login failed"),
          );
        }
      } else {
        return Left(
          ServerFailure(response.data['message'] ?? "Something went wrong"),
        );
      }
    } else {
      final errorData = response.response?.data;
      if (errorData is Map && errorData.containsKey('message')) {
        return Left(ServerFailure(errorData['message']));
      }
      return Left(ServerFailure(response.message ?? "Unknown Dio error"));
    }
  }

  Future<Either<Failure, EditNumberOtpResponse>> changeOtpRequest({
    required String phone,
    required String type,
    required String code,
  }) async {
    try {
      String url = ApiUrl.changeNumberOtpVerify;

      final response = await Request.sendRequest(
        url,
        {"phone": "+91$phone", "code": code, "type": type},
        'Post',
        true,
      );

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(EditNumberOtpResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(
                response.data['message'] ?? "OTP verification failed",
              ),
            );
          }
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Network error"));
      }
    } on TimeoutException {
      return Left(ServerFailure("Request timed out. Please try again."));
    } catch (e) {
      return Left(ServerFailure("Unexpected error occurred"));
    }
  }

  // Future<Either<Failure, EditNumberOtpResponse>> changeOtpRequest({
  //   required String phone,
  //   required String type,
  //   required String code,
  // }) async
  // {
  //   String url = ApiUrl.changeNumberOtpVerify;
  //
  //   final response = await Request.sendRequest(
  //     url,
  //     {"phone": "+91$phone", "code": code, "type": type},
  //     'Post',
  //     true,
  //   );
  //
  //   if (response is! DioException) {
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       if (response.data['status'] == true) {
  //         return Right(EditNumberOtpResponse.fromJson(response.data));
  //       } else {
  //         return Left(
  //           ServerFailure(response.data['message'] ?? "Login failed"),
  //         );
  //       }
  //     } else {
  //       return Left(
  //         ServerFailure(response.data['message'] ?? "Something went wrong"),
  //       );
  //     }
  //   } else {
  //     final errorData = response.response?.data;
  //     if (errorData is Map && errorData.containsKey('message')) {
  //       return Left(ServerFailure(errorData['message']));
  //     }
  //     return Left(ServerFailure(response.message ?? "Unknown Dio error"));
  //   }
  // }

  Future<Either<Failure, DeleteResponse>> deleteAccount() async {
    try {
      final url = ApiUrl.deleteAccount;

      final response = await Request.sendRequest(
        url,
        {}, // no payload
        'DELETE',
        true,
      );

      // ✅ success
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['status'] == true) {
          return Right(DeleteResponse.fromJson(response.data));
        }
        return Left(ServerFailure(response.data['message'] ?? "Delete failed"));
      }

      return Left(
        ServerFailure(response.data['message'] ?? "Something went wrong"),
      );
    } on DioException catch (e) {
      final errorData = e.response?.data;

      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return Left(ServerFailure("No internet connection. Please try again"));
      }

      if (errorData is Map && errorData['message'] != null) {
        return Left(ServerFailure(errorData['message'].toString()));
      }

      return Left(ServerFailure("Request failed"));
    } catch (e) {
      AppLogger.log.e(e);
      return Left(ServerFailure("Unexpected error occurred"));
    }
  }

  Future<Either<Failure, EditProfileResponse>> editProfile({
    required String displayName,
    required String email,
    required String gender,
    required String dateOfBirth,
    String? avatarUrl,
    required String phoneNumber,
  }) async {
    try {
      final url = ApiUrl.editProfile;
      final verificationToken = await AppPrefs.getVerificationToken();

      final response = await Request.sendRequest(
        url,
        {
          "displayName": displayName,
          "email": email,
          "gender": gender,
          "dateOfBirth": dateOfBirth,
          "avatarUrl": avatarUrl,
          "phoneNumber": phoneNumber,
          "phoneVerificationToken": verificationToken,
        },
        'PATCH',
        true,
      );

      // If your Request.sendRequest RETURNS DioException instead of throwing it
      if (response is DioException) {
        final errorData = response.response?.data;
        final msg = (errorData is Map && errorData['message'] != null)
            ? errorData['message'].toString()
            : (response.message ?? "Unknown Dio error");
        return Left(ServerFailure(msg));
      }

      // Normal Response flow
      final int? code = response.statusCode;

      if (code == 200 || code == 201) {
        final dataRaw = response.data;

        if (dataRaw is Map && dataRaw['status'] == true) {
          final Map<String, dynamic> data = Map<String, dynamic>.from(dataRaw);
          return Right(EditProfileResponse.fromJson(data));
        } else {
          final msg =
              (dataRaw is Map ? dataRaw['message'] : null) ?? "Update failed";
          return Left(ServerFailure(msg.toString()));
        }
      } else {
        final dataRaw = response.data;
        final msg =
            (dataRaw is Map ? dataRaw['message'] : null) ??
            "Something went wrong";
        return Left(ServerFailure(msg.toString()));
      }
    } catch (e) {
      AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, SupportListResponse>> supportList() async {
    try {
      final String url = ApiUrl.supportTicketsList;

      final response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      final data = response?.data;

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        if (data['status'] == true) {
          return Right(SupportListResponse.fromJson(data));
        } else {
          return Left(ServerFailure(data['message'] ?? "Login failed"));
        }
      } else {
        return Left(ServerFailure(data['message'] ?? "Something went wrong"));
      }
    } on DioException catch (dioError) {
      final errorData = dioError.response?.data;
      if (errorData is Map && errorData.containsKey('message')) {
        return Left(ServerFailure(errorData['message']));
      }
      return Left(ServerFailure(dioError.message ?? "Unknown Dio error"));
    } catch (e, st) {
      AppLogger.log.e(e);
      AppLogger.log.e(st);
      print(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, CreateSupportResponse>> createSupportTicket({
    required String subject,
    required String description,
    required String imageUrl,
    required dynamic attachments,
  }) async {
    try {
      final String url = ApiUrl.supportTicketsList;
      final Map<String, dynamic> body = {
        "subject": subject,
        "description": description,
        "attachments": [
          {"url": imageUrl},
        ],
      };

      final response = await Request.sendRequest(url, body, 'POST', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(CreateSupportResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Login failed"),
            );
          }
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e.toString());
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ChatMessageResponse>> getChatMessages({
    required String id,
  }) async {
    try {
      final String url = ApiUrl.getChatMessages(id: id);

      final response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      final data = response?.data;

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        if (data['status'] == true) {
          return Right(ChatMessageResponse.fromJson(data));
        } else {
          return Left(ServerFailure(data['message'] ?? "Login failed"));
        }
      } else {
        return Left(ServerFailure(data['message'] ?? "Something went wrong"));
      }
    } on DioException catch (dioError) {
      final errorData = dioError.response?.data;
      if (errorData is Map && errorData.containsKey('message')) {
        return Left(ServerFailure(errorData['message']));
      }
      return Left(ServerFailure(dioError.message ?? "Unknown Dio error"));
    } catch (e) {
      print(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, SendMessageResponse>> sendMessage({
    required String subject,

    required String imageUrl,
    required String ticketId,
    required dynamic attachments,
  }) async {
    try {
      final String url = ApiUrl.sendMessage(ticketId: ticketId);
      final Map<String, dynamic> body = {
        "message": subject,

        "attachments": [
          {"url": imageUrl},
        ],
      };

      final response = await Request.sendRequest(url, body, 'POST', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(SendMessageResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Login failed"),
            );
          }
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e.toString());
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, TermsAndConditionResponse>>
  fetchTermsAndCondition() async {
    try {
      final url = ApiUrl.privacyPolicy;

      final response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      final data = response?.data;

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        if (data['status'] == true) {
          return Right(TermsAndConditionResponse.fromJson(data));
        } else {
          return Left(ServerFailure(data['message'] ?? "Login failed"));
        }
      } else {
        return Left(ServerFailure(data['message'] ?? "Something went wrong"));
      }
    } on DioException catch (dioError) {
      final errorData = dioError.response?.data;
      if (errorData is Map && errorData.containsKey('message')) {
        return Left(ServerFailure(errorData['message']));
      }
      return Left(ServerFailure(dioError.message ?? "Unknown Dio error"));
    } catch (e) {
      print(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ReferralResponse>> verifyReferralCode({
    required String referralCode,
  }) async {
    try {
      final url = ApiUrl.applyReferral;

      final payload = {"referralCode": referralCode};

      final response = await Request.sendRequest(url, payload, 'Post', true);

      final data = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['status'] == true) {
          return Right(ReferralResponse.fromJson(data));
        } else {
          return Left(ServerFailure(data['message'] ?? "Verification failed"));
        }
      }

      return Left(ServerFailure(data['message'] ?? "Something went wrong"));
    }
    // 🔴 NETWORK / INTERNET ERRORS
    on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return Left(ServerFailure("No internet connection. Please try again"));
      }

      final errorData = e.response?.data;
      if (errorData is Map && errorData['message'] != null) {
        return Left(ServerFailure(errorData['message']));
      }

      return Left(ServerFailure("Request failed"));
    } catch (e, st) {
      AppLogger.log.e('${e}\n\n${st}');

      print('${e}\n${st}');

      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, WalletHistoryResponse>> walletHistory({
    required String type,
  }) async {
    try {
      final String url = ApiUrl.walletHistory(type: type);

      final response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response?.statusCode == 200 || response?.statusCode == 201) {
          if (response?.data['status'] == true) {
            return Right(WalletHistoryResponse.fromJson(response?.data));
          } else {
            return Left(ServerFailure(response?.data['message'] ?? ""));
          }
        } else {
          return Left(
            ServerFailure(response?.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(errorData['message'] ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e.toString());
      return Left(ServerFailure(e.toString()));
    }
  }
  /*
  Future<Either<Failure, WalletHistoryResponse>> walletHistory({
    String type = "ALL",
  }) async {
    try {
      final String url = ApiUrl.walletHistory(type: type);

      final response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      final data = response?.data;

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        if (data['status'] == true) {
          return Right(WalletHistoryResponse.fromJson(data));
        } else {
          return Left(ServerFailure(data['message'] ?? "Login failed"));
        }
      } else {
        return Left(ServerFailure(data['message'] ?? "Something went wrong"));
      }
    } on DioException catch (dioError) {
      final errorData = dioError.response?.data;
      if (errorData is Map && errorData.containsKey('message')) {
        return Left(ServerFailure(errorData['message']));
      }
      return Left(ServerFailure(dioError.message ?? "Unknown Dio error"));
    } catch (e) {
     AppLogger.log.e(e);
      return Left(ServerFailure(e.toString()));
    }
  }*/

  Future<Either<Failure, UidNameResponse>> uIDPersonName({
    required String uid,
  }) async {
    try {
      final String url = ApiUrl.uIDPersonName;

      final payload = {"uid": uid};

      final response = await Request.sendRequest(url, payload, 'Post', true);

      AppLogger.log.i(response);

      if (response is DioException) {
        final errorData = response.response?.data;
        if (errorData is Map && errorData['message'] != null) {
          return Left(ServerFailure(errorData['message'].toString()));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        if (data is Map && data['status'] == true) {
          return Right(UidNameResponse.fromJson(data.cast<String, dynamic>()));
        }

        return Left(
          ServerFailure(
            (data is Map && data['message'] != null)
                ? data['message'].toString()
                : "Failed to fetch user",
          ),
        );
      }

      return Left(ServerFailure("HTTP ${response.statusCode}"));
    } catch (e) {
      AppLogger.log.e(e.toString());
      return Left(ServerFailure(e.toString()));
    }
  }
  //
  // Future<Either<Failure, SendTcoinResponse>> uIDSendApi({
  //   required String toUid,
  //   required String tcoin,
  // }) async {
  //   try {
  //     final String url = ApiUrl.uIDSendApi;
  //     final payload = {"toUid": toUid, "tcoin": tcoin};
  //
  //     final response = await Request.sendRequest(url, payload, 'Post', true);
  //
  //     if (response is DioException) {
  //       final errorData = response.response?.data;
  //       if (errorData is Map && errorData['message'] != null) {
  //         return Left(ServerFailure(errorData['message'].toString()));
  //       }
  //       return Left(ServerFailure(response.message ?? "Unknown Dio error"));
  //     }
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       final body = response.data;
  //
  //       if (body is Map<String, dynamic>) {
  //         if (body['status'] != true) {
  //           return Left(
  //             ServerFailure((body['message'] ?? "Send failed").toString()),
  //           );
  //         }
  //         final parsed = SendTcoinResponse.fromJson(body);
  //         if (parsed.data.success != true) {
  //           return Left(
  //             ServerFailure((body['message'] ?? "Send failed").toString()),
  //           );
  //         }
  //         return Right(parsed);
  //       }
  //
  //       return Left(ServerFailure("Invalid response format"));
  //     }
  //
  //     return Left(ServerFailure("HTTP ${response.statusCode}"));
  //   } catch (e) {
  //     return Left(ServerFailure(e.toString()));
  //   }
  // }

  Future<Either<Failure, SendTcoinResponse>> uIDSendApi({
    required String toUid,
    required String tCoin,
  }) async {
    try {
      final String url = ApiUrl.supportTicketsList;
      final payload = {"toUid": toUid, "tcoin": tCoin};

      final response = await Request.sendRequest(url, payload, 'POST', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(SendTcoinResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Login failed"),
            );
          }
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e.toString());
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, WithdrawRequestResponse>> uIDWithRawApi({
    required String upiId,
    required String tcoin,
  }) async {
    try {
      final String url = ApiUrl.uIDWithRawApi;
      final payload = {"upiId": upiId, "tcoin": tcoin};

      final response = await Request.sendRequest(url, payload, 'Post', true);

      if (response is DioException) {
        final errorData = response.response?.data;
        if (errorData is Map && errorData['message'] != null) {
          return Left(ServerFailure(errorData['message'].toString()));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data;

        if (body is Map<String, dynamic>) {
          // ✅ status=false -> show API message
          if (body['status'] != true) {
            return Left(
              ServerFailure((body['message'] ?? "Withdraw failed").toString()),
            );
          }

          // ✅ parse withdraw response (NOT SendTcoinResponse)
          final parsed = WithdrawRequestResponse.fromJson(body);

          // ✅ if inner success=false
          if (parsed.data.success != true) {
            return Left(
              ServerFailure((body['message'] ?? "Withdraw failed").toString()),
            );
          }

          return Right(parsed);
        }

        return Left(ServerFailure("Invalid response format"));
      }

      return Left(ServerFailure("HTTP ${response.statusCode}"));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ReferralHistoryResponse>> referralHistory() async {
    try {
      final url = ApiUrl.referralHistory;

      final response = await Request.sendGetRequest(url, {}, 'GET', true);

      final data = response?.data;

      // ✅ 반드시 Map format check
      if (data is! Map<String, dynamic>) {
        return Left(ServerFailure("Invalid response format"));
      }

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        if (data['status'] == true) {
          return Right(ReferralHistoryResponse.fromJson(data));
        } else {
          return Left(
            ServerFailure(
              data['message']?.toString() ?? "Referral history failed",
            ),
          );
        }
      } else {
        return Left(
          ServerFailure(data['message']?.toString() ?? "Something went wrong"),
        );
      }
    } on DioException catch (dioError) {
      final errorData = dioError.response?.data;

      if (errorData is Map && errorData.containsKey('message')) {
        return Left(ServerFailure(errorData['message']?.toString() ?? "Error"));
      }

      return Left(ServerFailure(dioError.message ?? "Unknown Dio error"));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ReviewHistoryResponse>> reviewHistory() async {
    try {
      final url = ApiUrl.reviewHistory;

      final response = await Request.sendGetRequest(url, {}, 'GET', true);

      final data = response?.data;

      // ✅ 반드시 Map format check
      if (data is! Map<String, dynamic>) {
        return Left(ServerFailure("Invalid response format"));
      }

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        if (data['status'] == true) {
          return Right(ReviewHistoryResponse.fromJson(data));
        } else {
          return Left(
            ServerFailure(
              data['message']?.toString() ?? "Review history failed",
            ),
          );
        }
      } else {
        return Left(
          ServerFailure(data['message']?.toString() ?? "Something went wrong"),
        );
      }
    } on DioException catch (dioError) {
      final errorData = dioError.response?.data;

      if (errorData is Map && errorData.containsKey('message')) {
        return Left(ServerFailure(errorData['message']?.toString() ?? "Error"));
      }

      return Left(ServerFailure(dioError.message ?? "Unknown Dio error"));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ReviewCreateResponse>> reviewCreate({
    required String shopId,
    required int rating,
    required String heading,
    required String comment,
  }) async {
    try {
      final String url = ApiUrl.reviewCreate;

      final body = {
        "shopId": shopId,
        "rating": rating,
        "heading": heading,
        "comment": comment,
      };

      final response = await Request.sendRequest(url, body, 'POST', true);

      AppLogger.log.i(response);

      if (response is! DioException) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(ReviewCreateResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Review create failed"),
            );
          }
        } else {
          return Left(
            ServerFailure(response.data['message'] ?? "Something went wrong"),
          );
        }
      } else {
        final errorData = response.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e) {
      AppLogger.log.e(e.toString());
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, SurpriseStatusResponse>> surpriseStatusCheck({
    required double lng,
    required double lat,
    required String shopId,
  }) async {
    try {
      final url = ApiUrl.surpriseStatusCheck(
        lat: lat,
        lng: lng,
        shopId: shopId,
      );

      final response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

      final data = response?.data;

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        if (data['status'] == true) {
          return Right(SurpriseStatusResponse.fromJson(data));
        } else {
          return Left(ServerFailure(data['message'] ?? "Login failed"));
        }
      } else {
        return Left(ServerFailure(data['message'] ?? "Something went wrong"));
      }
    } on DioException catch (dioError) {
      final errorData = dioError.response?.data;
      if (errorData is Map && errorData.containsKey('message')) {
        return Left(ServerFailure(errorData['message']));
      }
      return Left(ServerFailure(dioError.message ?? "Unknown Dio error"));
    } catch (e, st) {
      print('${e}\n${st}');
      AppLogger.log.e('${e}\n${st}');
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, SurpriseStatusResponse>> surpriseClaimed({
    required double lng,
    required double lat,
    required String shopId,
  }) async {
    try {
      final url = ApiUrl.surpriseClaimed(shopId: shopId);

      final response = await Request.sendRequest(
        url,
        {"lat": lat, "lng": lng},
        'Post',
        true,
      );

      AppLogger.log.i(response);

      final data = response?.data;

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        if (data['status'] == true) {
          return Right(SurpriseStatusResponse.fromJson(data));
        } else {
          return Left(ServerFailure(data['message'] ?? "Login failed"));
        }
      } else {
        return Left(ServerFailure(data['message'] ?? "Something went wrong"));
      }
    } on DioException catch (dioError) {
      final errorData = dioError.response?.data;
      if (errorData is Map && errorData.containsKey('message')) {
        return Left(ServerFailure(errorData['message']));
      }
      return Left(ServerFailure(dioError.message ?? "Unknown Dio error"));
    } catch (e, st) {
      print('${e}\n${st}');
      AppLogger.log.e('${e}\n${st}');
      return Left(ServerFailure(e.toString()));
    }
  }
}
