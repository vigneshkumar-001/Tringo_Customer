import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:tringo_app/Core/Utility/app_loader.dart';
import '../../../../Core/Utility/app_Images.dart';
import '../../../../Core/Utility/app_color.dart';
import '../../../../Core/Utility/app_snackbar.dart';
import '../../../../Core/Utility/google_font.dart';
import '../../../../Core/Widgets/common_container.dart';
import '../../../../Core/app_go_routes.dart';
import '../Login Screen/Controller/login_notifier.dart';
import '../Privacy Policy/privacy_policy.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final TextEditingController otp = TextEditingController();

  String? otpError;
  String verifyCode = '';

  Timer? _timer;
  int _secondsRemaining = 30;
  bool _canResend = false;

  String? lastLoginPage;

  @override
  void initState() {
    super.initState();

    // Start the countdown timer
    _startTimer(30);

    // Reset login state when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(loginNotifierProvider.notifier).resetState();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    otp.dispose();
    super.dispose();
  }

  void _startTimer(int seconds) {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = seconds;
      _canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        setState(() {
          _canResend = true;
        });
        _timer?.cancel();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginNotifierProvider);
    final notifier = ref.read(loginNotifierProvider.notifier);
    // Listen to login state changes (OTP, resend, errors)
    ref.listen<LoginState>(loginNotifierProvider, (previous, next) {
      final notifier = ref.read(loginNotifierProvider.notifier);

      // Error case
      if (next.error != null) {
        AppSnackBar.error(context, next.error!);
        notifier.resetState();
      }
      // OTP verified
      else if (next.otpResponse != null) {
        AppSnackBar.success(context, 'OTP verified successfully!');
        context.goNamed(AppRoutes.privacyPolicy);
        notifier.resetState();
      }
      // Login response (used for resend OTP)
      else if (next.loginResponse != null) {
        if (lastLoginPage == 'resendOtp') {
          AppSnackBar.success(context, 'OTP resent successfully!');
        }
        lastLoginPage = null;
        notifier.resetState();
      }
    });
    // phoneNumber is non-nullable, so no ??
    final String mobileNumber = widget.phoneNumber;
    late final String maskMobileNumber;

    if (mobileNumber.length <= 3) {
      maskMobileNumber = mobileNumber;
    } else {
      maskMobileNumber =
          'x' * (mobileNumber.length - 3) +
              mobileNumber.substring(mobileNumber.length - 3);
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Image.asset(
              AppImages.loginBCImage,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 140,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo
                    Padding(
                      padding: const EdgeInsets.only(left: 35, top: 50),
                      child: Image.asset(AppImages.logo, height: 88, width: 85),
                    ),

                    const SizedBox(height: 81),

                    // Title
                    Padding(
                      padding: const EdgeInsets.only(left: 35, top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Enter 4 Digit OTP',
                                style: GoogleFont.Mulish(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 24,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'sent to',
                                style: GoogleFont.Mulish(
                                  fontSize: 24,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'your given Mobile Number',
                            style: GoogleFont.Mulish(
                              fontSize: 24,
                              color: AppColor.darkBlue,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 35),

                    // OTP fields
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: PinCodeTextField(
                        appContext: context,
                        length: 4,
                        autoFocus: otp.text.isEmpty,
                        mainAxisAlignment: MainAxisAlignment.start,
                        autoDisposeControllers: false,
                        blinkWhenObscuring: true,
                        controller: otp,
                        keyboardType: TextInputType.number,
                        cursorColor: AppColor.black,
                        animationDuration: const Duration(milliseconds: 300),
                        enableActiveFill: true,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(17),
                          fieldHeight: 55,
                          fieldWidth: 55,
                          selectedColor: AppColor.darkBlue,
                          activeColor: AppColor.darkBlue,
                          activeFillColor: AppColor.white,
                          inactiveColor: AppColor.darkBlue,
                          selectedFillColor: AppColor.white,
                          inactiveFillColor: AppColor.white,
                          fieldOuterPadding: const EdgeInsets.symmetric(
                            horizontal: 9,
                          ),
                        ),
                        boxShadows: [
                          BoxShadow(
                            offset: const Offset(0, 1),
                            color: AppColor.skyBlue,
                            blurRadius: 5,
                          ),
                        ],
                        onCompleted: (value) {
                          verifyCode = value;
                        },
                        onChanged: (value) {
                          verifyCode = value;
                          if (otpError != null && value.isNotEmpty) {
                            setState(() {
                              otpError = null;
                            });
                          }
                        },
                        beforeTextPaste: (text) {
                          return true;
                        },
                      ),
                    ),

                    if (otpError != null)
                      Center(
                        child: Text(
                          otpError!,
                          style: GoogleFont.Mulish(
                            color: AppColor.red,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    const SizedBox(height: 35),

                    // Resend row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: _canResend
                                ? () {
                              // mark as resend call
                              lastLoginPage = 'resendOtp';
                              notifier.loginUser(
                                phoneNumber: widget.phoneNumber,
                                page: 'resendOtp',
                              );
                              _startTimer(30);
                            }
                                : null,
                            child: Text(
                              'Resend',
                              style: GoogleFont.Mulish(
                                fontWeight: FontWeight.w800,
                                color: _canResend
                                    ? AppColor.skyBlue
                                    : AppColor.gray84,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _canResend ? 'OTP' : 'code in',
                            style: GoogleFont.Mulish(
                              fontWeight: FontWeight.w800,
                              color: _canResend
                                  ? AppColor.skyBlue
                                  : AppColor.gray84,
                            ),
                          ),
                          if (!_canResend) ...[
                            const SizedBox(width: 4),
                            Text(
                              '00:${_secondsRemaining.toString().padLeft(2, '0')}',
                              style: GoogleFont.Mulish(
                                fontWeight: FontWeight.w800,
                                color: AppColor.darkBlue,
                              ),
                            ),
                          ],
                          const Spacer(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Info text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: Text(
                        'OTP sent to $maskMobileNumber, please check and enter below. '
                            'If you’ve not received OTP, you can resend after the timer ends.',
                        style: GoogleFont.Mulish(
                          fontSize: 14,
                          color: AppColor.darkGrey,
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),

                    // Verify button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: CommonContainer.button(
                        buttonColor: AppColor.skyBlue,
                        onTap: () {
                          final enteredOtp = otp.text.trim();
                          if (enteredOtp.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter OTP')),
                            );
                            return;
                          }
                          notifier.verifyOtp(
                            contact: widget.phoneNumber,
                            otp: enteredOtp,
                          );
                        },
                        text: state.isLoading
                            ? const ThreeDotsLoader()
                            : const Text('Verify Now'),
                      ),
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),

            // Bottom decoration
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                AppImages.loginScreenBottom,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';
//
// import '../../../../Core/Utility/app_Images.dart';
// import '../../../../Core/Utility/app_color.dart';
// import '../../../../Core/Utility/google_font.dart';
// import '../../../../Core/Widgets/common_container.dart';
// import '../Privacy Policy/privacy_policy.dart';
//
// class OtpScreen extends StatefulWidget {
//   final String? mobileNumber;
//   const OtpScreen({super.key, this.mobileNumber});
//
//   @override
//   State<OtpScreen> createState() => _OtpScreenState();
// }
//
// class _OtpScreenState extends State<OtpScreen> {
//   final TextEditingController otp = TextEditingController();
//   String? otpError;
//   String verifyCode = '';
//   @override
//   Widget build(BuildContext context) {
//     String mobileNumber = widget.mobileNumber ?? '';
//     String maskMobileNumber;
//
//     if (mobileNumber.length <= 3) {
//       maskMobileNumber = mobileNumber;
//     } else {
//       maskMobileNumber =
//           'x' * (mobileNumber.length - 3) +
//           mobileNumber.substring(mobileNumber.length - 3);
//     }
//     return Scaffold(
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Image.asset(
//               AppImages.loginBCImage,
//               width: double.infinity,
//               height: double.infinity,
//               fit: BoxFit.cover,
//             ),
//
//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               bottom: 140,
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.only(bottom: 20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(left: 35, top: 50),
//                       child: Image.asset(AppImages.logo, height: 88, width: 85),
//                     ),
//
//                     SizedBox(height: 81),
//
//                     Padding(
//                       padding: const EdgeInsets.only(left: 35, top: 20),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Text(
//                                 'Enter 4 Digit OTP',
//                                 style: GoogleFont.Mulish(
//                                   fontWeight: FontWeight.w800,
//                                   fontSize: 24,
//                                   color: AppColor.darkBlue,
//                                 ),
//                               ),
//                               SizedBox(width: 5),
//                               Text(
//                                 'sent to',
//                                 style: GoogleFont.Mulish(
//                                   fontSize: 24,
//                                   color: AppColor.darkBlue,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Text(
//                             'your given Mobile Number',
//                             style: GoogleFont.Mulish(
//                               fontSize: 24,
//                               color: AppColor.darkBlue,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     SizedBox(height: 35),
//
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 35),
//                       child: PinCodeTextField(
//                         onCompleted: (value) async {},
//
//                         autoFocus: otp.text.isEmpty,
//                         appContext: context,
//                         // pastedTextStyle: TextStyle(
//                         //   color: Colors.green.shade600,
//                         //   fontWeight: FontWeight.bold,
//                         // ),
//                         length: 4,
//
//                         // obscureText: true,
//                         // obscuringCharacter: '*',
//                         // obscuringWidget: const FlutterLogo(size: 24,),
//                         blinkWhenObscuring: true,
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         autoDisposeControllers: false,
//
//                         // validator: (v) {
//                         //   if (v == null || v.length != 4)
//                         //     return 'Enter valid 4-digit OTP';
//                         //   return null;
//                         // },
//                         pinTheme: PinTheme(
//                           shape: PinCodeFieldShape.box,
//                           borderRadius: BorderRadius.circular(17),
//                           fieldHeight: 55,
//                           fieldWidth: 55,
//                           selectedColor: AppColor.darkBlue,
//                           activeColor: AppColor.darkBlue,
//                           activeFillColor: AppColor.white,
//                           inactiveColor: AppColor.darkBlue,
//                           selectedFillColor: AppColor.white,
//                           fieldOuterPadding: EdgeInsets.symmetric(
//                             horizontal: 9,
//                           ),
//                           inactiveFillColor: AppColor.white,
//                         ),
//                         cursorColor: AppColor.black,
//                         animationDuration: const Duration(milliseconds: 300),
//                         enableActiveFill: true,
//                         // errorAnimationController: errorController,
//                         controller: otp,
//                         keyboardType: TextInputType.number,
//                         boxShadows: [
//                           BoxShadow(
//                             offset: Offset(0, 1),
//                             color: AppColor.blue,
//                             blurRadius: 5,
//                           ),
//                         ],
//                         // validator: (value) {
//                         //   if (value == null || value.length != 4) {
//                         //     return 'Please enter a valid 4-digit OTP';
//                         //   }
//                         //   return null;
//                         // },
//                         // onCompleted: (value) async {},
//                         onChanged: (value) {
//                           debugPrint(value);
//                           verifyCode = value;
//
//                           if (otpError != null && value.isNotEmpty) {
//                             setState(() {
//                               otpError = null;
//                             });
//                           }
//                         },
//
//                         beforeTextPaste: (text) {
//                           debugPrint("Allowing to paste $text");
//                           return true;
//                         },
//                       ),
//                     ),
//                     if (otpError != null)
//                       Center(
//                         child: Text(
//                           otpError!,
//                           style: GoogleFont.ibmPlexSans(
//                             color: AppColor.lightRed,
//                             fontSize: 14,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     SizedBox(height: 35),
//
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 35),
//                       child: Row(
//                         children: [
//                           Text(
//                             'Resend code in',
//                             style: GoogleFont.Mulish(
//                               fontWeight: FontWeight.w800,
//                               color: AppColor.darkBlue,
//                             ),
//                           ),
//                           SizedBox(width: 4),
//                           Text(
//                             '00.29',
//                             style: GoogleFont.Mulish(
//                               fontWeight: FontWeight.w800,
//                               color: AppColor.darkBlue,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 35),
//                       child: Text(
//                         'OTP sent to $maskMobileNumber, please check and enter below. If you’re not received OTP',
//                         style: GoogleFont.ibmPlexSans(
//                           fontSize: 14,
//                           color: AppColor.lightGray2,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 35),
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 35),
//                       child: CommonContainer.button(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => PrivacyPolicy(),
//                             ),
//                           );
//                         },
//                         text: Text('Verify Now'),
//                       ),
//                     ),
//                     SizedBox(height: 50),
//                   ],
//                 ),
//               ),
//             ),
//
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Image.asset(
//                 AppImages.loginScreenBottom,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
