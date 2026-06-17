import 'dart:async';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_app/Core/Const/app_logger.dart';

class Request {
  static Future<dynamic> sendRequest(
    String url,
    Map<String, dynamic> body,
    String? method,
    bool isTokenRequired,
    {bool sendBearerToken = true, bool sendSessionToken = true}
  ) async {
    final prefs = await SharedPreferences.getInstance();
    // Token-gated requests: reload first so a stale in-memory prefs cache (seen
    // on iOS after login) can't drop the auth header and make the backend
    // return "no data" for endpoints that require auth.
    if (isTokenRequired) await prefs.reload();
    final String? token = prefs.getString('token');
    final String? sessionToken = prefs.getString('sessionToken');

    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          return handler.next(options);
        },
        onResponse:
            (Response<dynamic> response, ResponseInterceptorHandler handler) {
              AppLogger.log.i(
                "sendRequest \n"
                " API: $url \n"
                " STATUS: ${response.statusCode}",
              );
              return handler.next(response);
            },
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          final status = error.response?.statusCode;

          if (status == 402) {
            // app update new version
            return handler.reject(error);
          } else if (status == 406 || status == 401) {
            // unauthorized, etc.
            return handler.reject(error);
          } else if (status == 429) {
            // too many attempts
            return handler.reject(error);
          } else if (status == 409) {
            // conflict
            return handler.reject(error);
          }
          return handler.next(error);
        },
      ),
    );

    try {
      final headers = <String, dynamic>{
        "Content-Type": "application/json",
        if (sendBearerToken && token != null && isTokenRequired)
          "Authorization": "Bearer $token",
        if (sendSessionToken && sessionToken != null && isTokenRequired)
          "x-session-token": sessionToken,
      };

      final httpMethod = (method ?? 'POST').toUpperCase();

      final safeHeaders = Map<String, dynamic>.from(headers);
      if (safeHeaders.containsKey("Authorization")) {
        safeHeaders["Authorization"] = "Bearer ${AppLogger.redact(token, showLast: 6)}";
      }
      if (safeHeaders.containsKey("x-session-token")) {
        safeHeaders["x-session-token"] = AppLogger.redact(sessionToken, showLast: 6);
      }

      AppLogger.log.i(
        "REQUEST \n"
        " METHOD: $httpMethod \n"
        " API   : $url \n"
        " BODY  : ${_redactBody(body)} \n"
        " HEADERS: $safeHeaders",
      );

      late Response response;

      switch (httpMethod) {
        case 'GET':
          response = await dio
              .get(
                url,
                queryParameters: body.isEmpty ? null : body,
                options: Options(
                  headers: headers,
                  validateStatus: (status) => status != null && status < 503,
                ),
              )
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  throw TimeoutException("Request timed out after 10 seconds");
                },
              );
          break;

        case 'PUT':
          response = await dio
              .put(
                url,
                data: body,
                options: Options(
                  headers: headers,
                  validateStatus: (status) => status != null && status < 503,
                ),
              )
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  throw TimeoutException("Request timed out after 10 seconds");
                },
              );
          break;

        case 'PATCH':
          response = await dio
              .patch(
                url,
                data: body,
                options: Options(
                  headers: headers,
                  validateStatus: (status) => status != null && status < 503,
                ),
              )
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  throw TimeoutException("Request timed out after 10 seconds");
                },
              );
          break;

        ///  DELETE SUPPORT (THIS IS WHAT YOU NEEDED)
        case 'DELETE':
          response = await dio
              .delete(
                url,
                data: body.isEmpty ? null : body,
                options: Options(
                  headers: headers,
                  validateStatus: (status) => status != null && status < 503,
                ),
              )
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  throw TimeoutException("Request timed out after 10 seconds");
                },
              );
          break;

        /// Default → POST (for your existing usages)
        case 'POST':
        default:
          response = await dio
              .post(
                url,
                data: body,
                options: Options(
                  headers: headers,
                  validateStatus: (status) => status != null && status < 503,
                ),
              )
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  throw TimeoutException("Request timed out after 10 seconds");
                },
              );
          break;
      }

      AppLogger.log.i(
        "RESPONSE \n"
        " API: $url \n"
        " STATUS: ${response.statusCode}",
      );

      return response;
    } on DioException catch (e) {
      // THROW the DioException, do not return it
      throw e;
    } catch (e) {
      AppLogger.log.e("$e");
      // Throw clean exception
      throw Exception(e.toString());
    }
  }

  static Map<String, dynamic> _redactBody(Map<String, dynamic> body) {
    if (body.isEmpty) return const {};

    const sensitiveKeys = <String>{
      'token',
      'accessToken',
      'refreshToken',
      'sessionToken',
      'otp',
      'code',
      'password',
      'pin',
    };

    final safe = <String, dynamic>{};
    body.forEach((key, value) {
      final k = key.toString();
      if (sensitiveKeys.contains(k)) {
        safe[k] = value is String ? AppLogger.redact(value, showLast: 4) : '***';
      } else {
        safe[k] = value;
      }
    });
    return safe;
  }

  // static Future<dynamic> sendRequest(
  //   String url,
  //   Map<String, dynamic> body,
  //   String? method,
  //   bool isTokenRequired,
  // ) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? token = prefs.getString('token');
  //   String? sessionToken = prefs.getString('sessionToken');
  //   String? userId = prefs.getString('userId');
  //
  //   // AuthController authController = getx.Get.find();
  //   // // OtpController otpController = getx.Get.find();
  //   Dio dio = Dio(
  //     BaseOptions(
  //       connectTimeout: const Duration(seconds: 10),
  //       receiveTimeout: const Duration(seconds: 15),
  //     ),
  //   );
  //   dio.interceptors.add(
  //     InterceptorsWrapper(
  //       onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
  //         return handler.next(options);
  //       },
  //       onResponse:
  //           (Response<dynamic> response, ResponseInterceptorHandler handler) {
  //             AppLogger.log.i(body);
  //             AppLogger.log.i(
  //               "sendPostRequest \n API: $url \n Token : $token \n RESPONSE: ${response.toString()}",
  //             );
  //             return handler.next(response);
  //           },
  //       onError: (DioException error, ErrorInterceptorHandler handler) async {
  //         if (error.response?.statusCode == '402') {
  //           // app update new version
  //           return handler.reject(error);
  //         } else if (error.response?.statusCode == '406' ||
  //             error.response?.statusCode == '401') {
  //           return handler.reject(error);
  //         } else if (error.response?.statusCode == '429') {
  //           //Too many Attempts
  //           return handler.reject(error);
  //         } else if (error.response?.statusCode == '409') {
  //           //Too many Attempts
  //           return handler.reject(error);
  //         }
  //         return handler.next(error);
  //       },
  //     ),
  //   );
  //   try {
  //     final headers = {
  //       "Content-Type": "application/json",
  //       if (token != null && isTokenRequired) "Authorization": "Bearer $token",
  //       if (sessionToken != null && isTokenRequired)
  //         "x-session-token": sessionToken,
  //     };
  //
  //     final response = await dio
  //         .post(
  //           url,
  //           data: body,
  //           options: Options(
  //             headers: headers,
  //             validateStatus: (status) => status != null && status < 503,
  //           ),
  //         )
  //         .timeout(
  //           const Duration(seconds: 10),
  //           onTimeout: () {
  //             throw TimeoutException("Request timed out after 10 seconds");
  //           },
  //         );
  //     // 🔹 Debug print
  //
  //     AppLogger.log.i(
  //       "RESPONSE \n API: $url \n Token : $token \n session Token : $sessionToken \n Headers : $headers \n RESPONSE: ${response.toString()}",
  //     );
  //
  //     AppLogger.log.i("$body");
  //
  //     return response;
  //   }on DioException catch (e) {
  //     print(e);
  //     throw e;
  //   } catch (e) {
  //     print(e);
  //     // Throw clean exception
  //     throw Exception(e.toString());
  //   }
  // }
  static Future<dynamic> formData(
    String url,
    dynamic body,
    String? method,
    bool isTokenRequired,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Reload for token-gated requests to avoid a stale iOS prefs cache.
    if (isTokenRequired) await prefs.reload();
    String? token = prefs.getString('token');

    // AuthController authController = getx.Get.find();
    // // OtpController otpController = getx.Get.find();
    Dio dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          return handler.next(options);
        },
        onResponse:
            (Response<dynamic> response, ResponseInterceptorHandler handler) {
              AppLogger.log.i(
                "sendPostRequest \n API: $url \n STATUS: ${response.statusCode}",
              );
              return handler.next(response);
            },
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          if (error.response?.statusCode == '402') {
            // app update new version
            return handler.reject(error);
          } else if (error.response?.statusCode == '406' ||
              error.response?.statusCode == '401') {
            // Unauthorized user navigate to login page

            return handler.reject(error);
          } else if (error.response?.statusCode == '429') {
            //Too many Attempts
            return handler.reject(error);
          } else if (error.response?.statusCode == '409') {
            //Too many Attempts
            return handler.reject(error);
          }
          return handler.next(error);
        },
      ),
    );
    try {
      final response = await dio.post(
        url,
        data: body,
        options: Options(
          headers: {
            "Authorization": token != null ? "Bearer $token" : "",
            "Content-Type": body is FormData
                ? "multipart/form-data"
                : "application/json",
          },
          validateStatus: (status) {
            // Allow all status codes below 500 to be handled manually
            return status != null && status < 500;
          },
        ),
      );

      AppLogger.log.i(
        "RESPONSE \n API: $url \n STATUS: ${response.statusCode}",
      );

      return response;
    } catch (e) {
      AppLogger.log.e('API: $url \n ERROR: $e ');

      return e;
    }
  }

  static Future<Response?> sendGetRequest(
    String url,
    Map<String, dynamic> queryParams,
    String method,
    bool isTokenRequired, {
    String? appName,
    String? appVersion,
    String? appPlatForm,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Reload for token-gated requests to avoid a stale iOS prefs cache that would
    // otherwise drop the auth header and make list endpoints return no data.
    if (isTokenRequired) await prefs.reload();
    String? token = prefs.getString('token');
    String? sessionToken = prefs.getString('sessionToken');

    Dio dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          return handler.next(options);
        },
        onResponse:
            (Response<dynamic> response, ResponseInterceptorHandler handler) {
              AppLogger.log.i(
                "RESPONSE \n API: $url \n STATUS: ${response.statusCode}",
              );
              return handler.next(response);
            },
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          final status = error.response?.statusCode;
          if (status == 402) {
            return handler.reject(error);
          } else if (status == 406 || status == 401) {
            return handler.reject(error);
          } else if (status == 429) {
            return handler.reject(error);
          } else if (status == 409) {
            return handler.reject(error);
          }
          return handler.next(error);
        },
      ),
    );
    final headers = <String, dynamic>{
      "Content-Type": "application/json",
      if (token != null && isTokenRequired) "Authorization": "Bearer $token",
      if (sessionToken != null && isTokenRequired)
        "x-session-token": sessionToken,
      "X-App-Id": appName,
      "X-App-Version": appVersion,
      "X-Platform": appPlatForm,
    };
    try {
      Response response = await dio.get(
        url,
        queryParameters: queryParams,
        options: Options(
          headers: headers,
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );

      AppLogger.log.i(
        "GET RESPONSE \n API: $url \nSTATUS: ${response.statusCode}",
      );
      return response;
    } catch (e, st) {
      AppLogger.log.e('GET API: $url \n ERROR: $e\n\nStack Trace: $st');
      return null;
    }
  }
}
