import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:tringo_app/Core/Const/app_logger.dart';

// ✅ Use SAME model files everywhere
import 'package:tringo_app/Presentation/OnBoarding/Screens/Login Screen/Model/login_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Login Screen/Model/otp_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Login Screen/Model/whatsapp_response.dart';

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
      final String url = page == "resendOtp"
          ? ApiUrl.resendOtp
          : ApiUrl.register;

      AppLogger.log.i('🔐 mobileNumberLogin → $url');
      AppLogger.log.i('📲 payload: { contact: +91$phone, purpose: customer }');

      final response = await Request.sendRequest(
        url,
        {"contact": "+91$phone", "purpose": "customer"},
        'POST',
        false,
      );

      if (response is! DioException) {
        AppLogger.log.i(
          ' RESPONSE statusCode=${response.statusCode}, data=${response.data}',
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == true) {
            return Right(LoginResponse.fromJson(response.data));
          } else {
            return Left(
              ServerFailure(response.data['message'] ?? "Login failed"),
            );
          }
        } else {
          return Left(
            ServerFailure(
              response.data['message'] ??
                  "Something went wrong (code: ${response.statusCode})",
            ),
          );
        }
      } else {
        // DioException branch
        final errorData = response.response?.data;
        AppLogger.log.e('❌ DioException: ${response.message}, data=$errorData');

        if (errorData is Map && errorData.containsKey('message')) {
          return Left(ServerFailure(errorData['message']));
        }
        return Left(ServerFailure(response.message ?? "Unknown Dio error"));
      }
    } catch (e, st) {
      AppLogger.log.e('❌ mobileNumberLogin exception: $e\n$st');
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
        'POST', // 👈 use uppercase
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
}
