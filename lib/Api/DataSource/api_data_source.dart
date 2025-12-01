import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:tringo_app/Core/Const/app_logger.dart';
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

import '../../Presentation/OnBoarding/Screens/Services Screen/Models/service_data_response.dart';
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
    String page,
  ) async {
    try {
      String url = page == "resendOtp" ? ApiUrl.resendOtp : ApiUrl.register;
      AppLogger.log.i(url);

      dynamic response = await Request.sendRequest(
        url,
        {"contact": "+91$phone", "purpose": "customer"},
        'Post',
        false,
      );

      AppLogger.log.i(response);

      if (response is! DioException) {
        // If status code is success
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(LoginResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Login failed"),
            );
          }
        } else {
          // ❗ API returned non-success code but has JSON error message
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
      return Left(ServerFailure(e.toString()));
    }
  }

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

      AppLogger.log.i(response);

      final data = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['status'] == true) {
          return Right(WhatsappResponse.fromJson(data));
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

  Future<Either<Failure, HomeResponse>> getHomeDetails() async {
    try {
      final url = ApiUrl.home;

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
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ShopsResponse>> getShopDetails() async {
    try {
      final url = ApiUrl.shopList(kind: 'RETAIL');

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
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ServiceResponse>> getServiceDetails() async {
    try {
      final url = ApiUrl.shopList(kind: 'SERVICE');

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
      Map<String, dynamic> responseData =
          jsonDecode(response.data) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        if (responseData['status'] == true) {
          return Right(UserImageResponse.fromJson(responseData));
        } else {
          return Left(ServerFailure(responseData['message']));
        }
      } else if (response is Response && response.statusCode == 409) {
        return Left(ServerFailure(responseData['message']));
      } else if (response is Response) {
        return Left(ServerFailure(responseData['message'] ?? "Unknown error"));
      } else {
        return Left(ServerFailure("Unexpected error"));
      }
    } catch (e) {
      // CommonLogger.log.e(e);
      print(e);
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
  }) async {
    try {
      final url = ApiUrl.searchSuggestions(
        lat: 0.0,
        lng: 0.0,
        searchWords: searchWords,
      );

      final response = await Request.sendGetRequest(url, {}, 'GET', true);

      AppLogger.log.i(response);

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
  }) async {
    try {
      AppLogger.log.i(searchWords);
      final url = ApiUrl.productList(
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
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
