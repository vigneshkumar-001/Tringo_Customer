import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_app/Core/Const/app_logger.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Utility/app_color.dart';
import 'package:tringo_app/Core/Utility/app_loader.dart';
import 'package:tringo_app/Core/Utility/app_snackbar.dart';
import 'package:tringo_app/Core/Utility/google_font.dart';
import 'package:tringo_app/Core/Widgets/common_container.dart';
import 'package:tringo_app/Core/app_go_routes.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Login%20Screen/Controller/login_notifier.dart';

class ReferralScreens extends ConsumerStatefulWidget {
  const ReferralScreens({super.key});

  @override
  ConsumerState<ReferralScreens> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<ReferralScreens> {
  final TextEditingController referralCode = TextEditingController();

  String? otpError;
  String verifyCode = '';

  String? lastLoginPage;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(loginNotifierProvider.notifier).resetState();
    });
  }

  @override
  void dispose() {
    referralCode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginNotifierProvider);
    final notifier = ref.read(loginNotifierProvider.notifier);
    // Listen to login state changes (OTP, resend, errors)
    ref.listen<LoginState>(loginNotifierProvider, (previous, next) async {
      final notifier = ref.read(loginNotifierProvider.notifier);

      // Error case
      if (next.error != null) {
        AppSnackBar.error(context, next.error!);
        notifier.resetState();
      }
      // OTP verified
      else if (next.referralResponse != null) {
        AppSnackBar.success(context, 'Referral Code verified successfully!');
        context.pushNamed(AppRoutes.privacyPolicy);
        notifier.resetState();
      }
    });

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
            // Positioned(
            //   top: 0,
            //   left: 0,
            //   right: 0,
            //   bottom: 140,
            //   child:
            // ),

            // Bottom decoration
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo
                        Padding(
                          padding: const EdgeInsets.only(left: 35, top: 5),
                          child: Image.asset(
                            AppImages.logo,
                            height: 88,
                            width: 85,
                          ),
                        ),

                        const SizedBox(height: 50),

                        // Title
                        Padding(
                          padding: const EdgeInsets.only(left: 35, top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Enter 6 Digit',
                                style: GoogleFont.Mulish(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 24,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                              Text(
                                'Referral Code ( Optional )',
                                style: GoogleFont.Mulish(
                                  fontSize: 24,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 35),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: PinCodeTextField(
                            appContext: context,
                            length: 6,
                            autoFocus: referralCode.text.isEmpty,
                            mainAxisAlignment: MainAxisAlignment.start,
                            autoDisposeControllers: false,
                            blinkWhenObscuring: true,
                            controller: referralCode,
                            keyboardType: TextInputType.number,
                            cursorColor: AppColor.black,
                            animationDuration: const Duration(
                              milliseconds: 300,
                            ),
                            enableActiveFill: true,
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(17),
                              fieldHeight: 70,
                              fieldWidth: 45,
                              selectedColor: AppColor.darkBlue,
                              activeColor: AppColor.darkBlue,
                              activeFillColor: AppColor.white,
                              inactiveColor: AppColor.darkBlue,
                              selectedFillColor: AppColor.white,
                              inactiveFillColor: AppColor.white,
                              fieldOuterPadding: const EdgeInsets.symmetric(
                                horizontal: 5,
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

                        // Resend row

                        // Info text
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 35),
                        //   child: Text(
                        //     'OTP sent to $maskMobileNumber, please check and enter below. '
                        //         'If you’ve not received OTP, you can resend after the timer ends.',
                        //     style: GoogleFont.Mulish(
                        //       fontSize: 14,
                        //       color: AppColor.darkGrey,
                        //     ),
                        //   ),
                        // ),
                        const SizedBox(height: 35),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(15),
                                  onTap: () {
                                    context.pushNamed(AppRoutes.privacyPolicy);

                                    // TODO: Reject action (maybe pop/back or close app)
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColor.textWhite,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 34,
                                      vertical: 20,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Skip',
                                        style: GoogleFont.Mulish(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: AppColor.darkBlue,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                flex: 2,

                                child: CommonContainer.button(
                                  buttonColor: AppColor.skyBlue,
                                  onTap: () {
                                    final enteredReferralCode = referralCode
                                        .text
                                        .trim();
                                    if (enteredReferralCode.isEmpty) {
                                      AppSnackBar.info(
                                        context,
                                        'Please enter referral Code',
                                      );

                                      return;
                                    }
                                    notifier.verifyReferralCode(
                                      referralCode: enteredReferralCode,
                                    );
                                  },
                                  text: state.isReferralCodeLoading
                                      ? const ThreeDotsLoader()
                                      : const Text('Continue '),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                  Image.asset(
                    AppImages.loginScreenBottom,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
