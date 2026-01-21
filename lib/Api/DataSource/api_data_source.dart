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

import '../../Core/Utility/app_prefs.dart';
import '../../Presentation/OnBoarding/Screens/Edit Profile/Model/edit_number_otp_response.dart';
import '../../Presentation/OnBoarding/Screens/Edit Profile/Model/edit_number_verify_response.dart';
import '../../Presentation/OnBoarding/Screens/Edit Profile/Model/edit_profile_response.dart';
import '../../Presentation/OnBoarding/Screens/Login Screen/Model/app_version_response.dart';
import '../../Presentation/OnBoarding/Screens/Login Screen/Model/contact_response.dart';
import '../../Presentation/OnBoarding/Screens/Login Screen/Model/login_new_response.dart';
import '../../Presentation/OnBoarding/Screens/Mobile Nomber Verify/Model/sim_verify_response.dart';
import '../../Presentation/OnBoarding/Screens/Profile Screen/Model/delete_response.dart';
import '../../Presentation/OnBoarding/Screens/Services Screen/Models/service_data_response.dart';
import '../../Presentation/OnBoarding/Screens/Support/Model/chat_message_response.dart';
import '../../Presentation/OnBoarding/Screens/Support/Model/create_support_response.dart';
import '../../Presentation/OnBoarding/Screens/Support/Model/send_message_response.dart';
import '../../Presentation/OnBoarding/Screens/fill_profile/Model/update_profile_response.dart'
    show UserProfileResponse;
import '../../Presentation/OnBoarding/Screens/fill_profile/Model/user_image_response.dart';
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
    } catch (_) {
      return Left(ServerFailure("Unexpected error occurred"));
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
    } catch (_) {
      return Left(ServerFailure("Unexpected error occurred"));
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
    } catch (_) {
      return Left(ServerFailure("Unexpected error occurred"));
    }
  }

  // Future<Either<Failure, WhatsappResponse>> whatsAppNumberVerify({
  //   required String contact,
  //   required String purpose,
  // }) async {
  //   try {
  //     final url = ApiUrl.whatsAppVerify;
  //
  //     final payload = {"contact": "+91$contact", "purpose": 'customer'};
  //
  //     final response = await Request.sendRequest(url, payload, 'Post', true);
  //
  //     AppLogger.log.i(response);
  //
  //     final data = response.data;
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       if (data['status'] == true) {
  //         return Right(WhatsappResponse.fromJson(data));
  //       } else {
  //         return Left(ServerFailure(data['message'] ?? "Login failed"));
  //       }
  //     } else {
  //       return Left(ServerFailure(data['message'] ?? "Something went wrong"));
  //     }
  //   } on DioException catch (dioError) {
  //     final errorData = dioError.response?.data;
  //     if (errorData is Map && errorData.containsKey('message')) {
  //       return Left(ServerFailure(errorData['message']));
  //     }
  //     return Left(ServerFailure(dioError.message ?? "Unknown Dio error"));
  //   } catch (e) {
  //     return Left(ServerFailure(e.toString()));
  //   }
  // }

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

  // Future<Either<Failure, UserImageResponse>> userProfileUpload({
  //   required File imageFile,
  // }) async {
  //   try {
  //     if (!await imageFile.exists()) {
  //       return Left(ServerFailure('Image file does not exist.'));
  //     }
  //
  //     String url = ApiUrl.imageUrl;
  //     FormData formData = FormData.fromMap({
  //       'images': await MultipartFile.fromFile(
  //         imageFile.path,
  //         filename: imageFile.path.split('/').last,
  //       ),
  //     });
  //
  //     final response = await Request.formData(url, formData, 'POST', true);
  //     Map<String, dynamic> responseData =
  //         jsonDecode(response.data) as Map<String, dynamic>;
  //     if (response.statusCode == 200) {
  //       if (responseData['status'] == true) {
  //         return Right(UserImageResponse.fromJson(responseData));
  //       } else {
  //         return Left(ServerFailure(responseData['message']));
  //       }
  //     } else if (response is Response && response.statusCode == 409) {
  //       return Left(ServerFailure(responseData['message']));
  //     } else if (response is Response) {
  //       return Left(ServerFailure(responseData['message'] ?? "Unknown error"));
  //     } else {
  //       return Left(ServerFailure("Unexpected error"));
  //     }
  //   } catch (e) {
  //     AppLogger.log.e(e);
  //     print(e);
  //     return Left(ServerFailure('Something went wrong'));
  //   }
  // }

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
              ServerFailure(response.data['message'] ?? "OTP verification failed"),
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
    } catch (e,st) {
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
  }) async
  {
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

}
