import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:tringo_app/Core/Utility/google_font.dart';

import '../Utility/app_Images.dart';
import '../Utility/app_color.dart';

class OwnerVerifyField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? validator;
  final bool isLoading;
  final bool isOtpVerifying;
  final bool readOnly;

  final Future<String?> Function(String mobile)? onSendOtp;

  final Future<bool> Function(String mobile, String otp)? onVerifyOtp;

  const OwnerVerifyField({
    super.key,
    this.controller,
    this.focusNode,
    this.validator,
    this.isLoading = false,
    this.isOtpVerifying = false,
    this.readOnly = false,
    this.onSendOtp,
    this.onVerifyOtp,
  });

  @override
  State<OwnerVerifyField> createState() => _OwnerVerifyFieldState();
}

class _OwnerVerifyFieldState extends State<OwnerVerifyField> {
  final List<TextEditingController> otpControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  bool showOtp = false;
  bool isVerified = false;
  bool showOtpError = false;

  int resendSeconds = 30;
  Timer? resendTimer;

  void startResendTimer() {
    resendTimer?.cancel();
    resendSeconds = 30;

    resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds == 0) {
        timer.cancel();
      } else {
        if (mounted) setState(() => resendSeconds--);
      }
    });
  }

  @override
  void dispose() {
    resendTimer?.cancel();
    for (final c in otpControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textValue = widget.controller?.text ?? '';
    final isTenDigits = textValue.length == 10;
    final hasMobile = textValue.isNotEmpty;
    final last4Digits = hasMobile && textValue.length >= 4
        ? textValue.substring(textValue.length - 4)
        : '';

    return FormField<String>(
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (state) {
        final hasError = state.hasError;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ When showOtp true -> hide phone field, show OTP card only
            if (showOtp && !isVerified && hasMobile)
              _buildOtpCard(last4Digits)
            else
              _buildPhoneField(hasError, state, isTenDigits, hasMobile),

            if (hasError)
              Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 4),
                child: Text(
                  state.errorText ?? '',
                  style: GoogleFont.Mulish(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        );

        // return Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     Container(
        //       decoration: BoxDecoration(
        //         borderRadius: BorderRadius.circular(20),
        //         // color: const Color(0xFFF5F5F5),
        //         border: Border.all(
        //           color: hasError ? Colors.red : AppColor.borderGray,
        //           width: 2,
        //         ),
        //       ),
        //       child: Padding(
        //         padding: const EdgeInsets.symmetric(
        //           horizontal: 16,
        //           vertical: 5,
        //         ),
        //         child: Column(
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           children: [
        //             Row(
        //               children: [
        //                 Expanded(
        //                   child: TextFormField(
        //                     controller: widget.controller,
        //                     focusNode: widget.focusNode,
        //                     readOnly: widget.readOnly,
        //                     maxLength: 10,
        //                     keyboardType: TextInputType.number,
        //                     inputFormatters: [
        //                       FilteringTextInputFormatter.digitsOnly,
        //                       LengthLimitingTextInputFormatter(10),
        //                     ],
        //                     decoration: InputDecoration(
        //                       counterText: '',
        //                       hintText: 'Photo Number',
        //                       border: InputBorder.none,
        //                       hintStyle: GoogleFont.Mulish(
        //                         fontWeight: FontWeight.w600,
        //                         color: AppColor.borderGray,
        //                         fontSize: 16,
        //                       ),
        //                     ),
        //                     style: const TextStyle(
        //                       fontSize: 17,
        //                       fontWeight: FontWeight.w600,
        //                       color: Colors.black,
        //                       letterSpacing: 0.5,
        //                     ),
        //                     onChanged: (v) {
        //                       state.didChange(v);
        //                       setState(() {
        //                         showOtpError = false;
        //                         if (!isVerified) showOtp = false;
        //                       });
        //                     },
        //                   ),
        //                 ),
        //
        //                 if (hasMobile && !isVerified)
        //                   GestureDetector(
        //                     onTap: () {
        //                       widget.controller?.clear();
        //                       state.didChange('');
        //                       setState(() {
        //                         showOtp = false;
        //                         showOtpError = false;
        //                         resendTimer?.cancel();
        //                       });
        //                     },
        //                     child: const Icon(
        //                       Icons.close,
        //                       color: Colors.grey,
        //                       size: 20,
        //                     ),
        //                   ),
        //
        //                 const SizedBox(width: 8),
        //
        //                 Container(
        //                   width: 2,
        //                   height: 40,
        //                   decoration: BoxDecoration(
        //                     gradient: LinearGradient(
        //                       begin: Alignment.topCenter,
        //                       end: Alignment.bottomCenter,
        //                       colors: [
        //                         AppColor.white.withOpacity(0),
        //                         AppColor.borderGray,
        //                         AppColor.white.withOpacity(0),
        //                       ],
        //                     ),
        //                   ),
        //                 ),
        //
        //                 const SizedBox(width: 8),
        //
        //                 if (!hasMobile)
        //                   Text(
        //                     'Phone Number',
        //                     style: GoogleFont.Mulish(
        //                       fontWeight: FontWeight.w800,
        //                       fontSize: 15,
        //                       color: AppColor.lightGray2,
        //                     ),
        //                   ),
        //
        //                 if (isTenDigits && !isVerified && !showOtp)
        //                   GestureDetector(
        //                     onTap: widget.isLoading
        //                         ? null
        //                         : () async {
        //                             if (widget.onSendOtp == null ||
        //                                 widget.controller == null)
        //                               return;
        //
        //                             final success = await widget.onSendOtp!(
        //                               widget.controller!.text,
        //                             );
        //                             if (success != null) {
        //                               showTopSnackBar(
        //                                 Overlay.of(context),
        //                                 CustomSnackBar.error(message: success),
        //                               );
        //                               return;
        //                             }
        //
        //                             if (!mounted) return;
        //                             setState(() {
        //                               showOtp = true; // this now persists
        //                               showOtpError = false;
        //                               for (final c in otpControllers) {
        //                                 c.clear();
        //                               }
        //                               startResendTimer();
        //                             });
        //                           },
        //                     child: Container(
        //                       padding: const EdgeInsets.symmetric(
        //                         horizontal: 14,
        //                         vertical: 8,
        //                       ),
        //                       decoration: BoxDecoration(
        //                         color: widget.isLoading
        //                             ? Colors.grey
        //                             : const Color(0xFF2196F3),
        //                         borderRadius: BorderRadius.circular(12),
        //                       ),
        //                       child: widget.isLoading
        //                           ? const SizedBox(
        //                               width: 18,
        //                               height: 18,
        //                               child: CircularProgressIndicator(
        //                                 strokeWidth: 2,
        //                                 color: Colors.white,
        //                               ),
        //                             )
        //                           : Text(
        //                               "Get OTP",
        //                               style: GoogleFont.Mulish(
        //                                 color: Colors.white,
        //                                 fontWeight: FontWeight.w700,
        //                               ),
        //                             ),
        //                     ),
        //                   ),
        //
        //                 if (isVerified)
        //                   Container(
        //                     decoration: BoxDecoration(
        //                       color: AppColor.green,
        //                       borderRadius: BorderRadius.circular(10),
        //                     ),
        //                     padding: const EdgeInsets.symmetric(
        //                       horizontal: 15,
        //                       vertical: 5,
        //                     ),
        //                     child: Row(
        //                       children: [
        //                         Image.asset(
        //                           AppImages.tickImage,
        //                           height: 11,
        //                           color: AppColor.white,
        //                         ),
        //                         const SizedBox(width: 6),
        //                         Text(
        //                           'Verified',
        //                           style: GoogleFont.Mulish(
        //                             color: Colors.white,
        //                             fontWeight: FontWeight.w700,
        //                           ),
        //                         ),
        //                       ],
        //                     ),
        //                   ),
        //               ],
        //             ),
        //
        //             if (showOtp && !isVerified && hasMobile) ...[
        //               const SizedBox(height: 16),
        //               Container(
        //                 decoration: BoxDecoration(
        //                   color: const Color(0xFFF2F2F2),
        //                   borderRadius: BorderRadius.circular(20),
        //                 ),
        //                 padding: const EdgeInsets.all(16),
        //                 child: Column(
        //                   crossAxisAlignment: CrossAxisAlignment.start,
        //                   children: [
        //                     Row(
        //                       children: [
        //                         GestureDetector(
        //                           onTap: () {
        //                             setState(() {
        //                               showOtp = false;
        //                               showOtpError = false;
        //                             });
        //                           },
        //                           child: Icon(
        //                             Icons.arrow_back_ios_new,
        //                             size: 14,
        //                             color: AppColor.mediumGray,
        //                           ),
        //                         ),
        //                         const SizedBox(width: 6),
        //                         Expanded(
        //                           child: Text(
        //                             "OTP Sent to your xxx$last4Digits",
        //                             style: GoogleFont.Mulish(
        //                               color: AppColor.black,
        //                               fontSize: 18,
        //                               fontWeight: FontWeight.bold,
        //                             ),
        //                           ),
        //                         ),
        //                       ],
        //                     ),
        //                     const SizedBox(height: 8),
        //                     Text(
        //                       "If you didn’t get otp by sms, resend otp using the button",
        //                       style: GoogleFont.Mulish(
        //                         color: AppColor.darkGrey,
        //                         fontSize: 14,
        //                       ),
        //                     ),
        //                     const SizedBox(height: 8),
        //                     GestureDetector(
        //                       onTap: resendSeconds > 0 || widget.isLoading
        //                           ? null
        //                           : () async {
        //                               if (widget.onSendOtp == null ||
        //                                   widget.controller == null)
        //                                 return;
        //                               final success = await widget.onSendOtp!(
        //                                 widget.controller!.text,
        //                               );
        //                               if (success != null) {
        //                                 CustomSnackBar.error(message: success);
        //                                 return;
        //                               }
        //                               if (!mounted) return;
        //                               setState(() {
        //                                 for (final c in otpControllers)
        //                                   c.clear();
        //                                 showOtpError = false;
        //                                 startResendTimer();
        //                               });
        //                             },
        //                       child: Text(
        //                         resendSeconds > 0
        //                             ? "Resend in ${resendSeconds}s"
        //                             : "Resend OTP",
        //                         style: GoogleFont.Mulish(
        //                           color: AppColor.blue,
        //                           fontWeight: FontWeight.bold,
        //                         ),
        //                       ),
        //                     ),
        //                     SizedBox(height: 16),
        //
        //                     Row(
        //                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //                       children: [
        //                         ...List.generate(4, (index) {
        //                           return SizedBox(
        //                             width: 53,
        //                             height: 52,
        //                             child: TextField(
        //                               controller: otpControllers[index],
        //                               textAlign: TextAlign.center,
        //                               keyboardType: TextInputType.number,
        //                               maxLength: 1,
        //                               style: GoogleFont.Mulish(
        //                                 fontSize: 22,
        //                                 fontWeight: FontWeight.bold,
        //                                 color: Colors.black,
        //                               ),
        //                               decoration: InputDecoration(
        //                                 filled: true,
        //                                 fillColor: Colors.white,
        //                                 counterText: '',
        //                                 border: OutlineInputBorder(
        //                                   borderRadius: BorderRadius.circular(
        //                                     15,
        //                                   ),
        //                                   borderSide: BorderSide(
        //                                     color: showOtpError
        //                                         ? Colors.red
        //                                         : Colors.white,
        //                                   ),
        //                                 ),
        //                                 enabledBorder: OutlineInputBorder(
        //                                   borderRadius: BorderRadius.circular(
        //                                     15,
        //                                   ),
        //                                   borderSide: BorderSide(
        //                                     color: showOtpError
        //                                         ? Colors.red
        //                                         : Colors.white,
        //                                   ),
        //                                 ),
        //                                 focusedBorder: OutlineInputBorder(
        //                                   borderRadius: BorderRadius.circular(
        //                                     15,
        //                                   ),
        //                                   borderSide: const BorderSide(
        //                                     color: Colors.black,
        //                                     width: 2.5,
        //                                   ),
        //                                 ),
        //                               ),
        //                               onChanged: (value) {
        //                                 if (value.isNotEmpty && index < 3) {
        //                                   FocusScope.of(context).nextFocus();
        //                                 } else if (value.isEmpty && index > 0) {
        //                                   FocusScope.of(
        //                                     context,
        //                                   ).previousFocus();
        //                                 }
        //                               },
        //                             ),
        //                           );
        //                         }),
        //
        //                         GestureDetector(
        //                           onTap: widget.isOtpVerifying
        //                               ? null
        //                               : () async {
        //                                   if (widget.onVerifyOtp == null ||
        //                                       widget.controller == null)
        //                                     return;
        //
        //                                   final otp = otpControllers
        //                                       .map((c) => c.text)
        //                                       .join();
        //                                   if (otp.length != 4) {
        //                                     setState(() => showOtpError = true);
        //                                     return;
        //                                   }
        //
        //                                   final success =
        //                                       await widget.onVerifyOtp!(
        //                                         widget.controller!.text,
        //                                         otp,
        //                                       );
        //                                   if (!success) {
        //                                     setState(() => showOtpError = true);
        //                                     return;
        //                                   }
        //
        //                                   if (!mounted) return;
        //                                   setState(() {
        //                                     isVerified = true;
        //                                     showOtp = false;
        //                                     showOtpError = false;
        //                                     resendTimer?.cancel();
        //                                   });
        //                                 },
        //                           child: Container(
        //                             width: 53,
        //                             height: 52,
        //                             decoration: BoxDecoration(
        //                               color: widget.isOtpVerifying
        //                                   ? Colors.grey
        //                                   : Colors.black,
        //                               borderRadius: BorderRadius.circular(15),
        //                             ),
        //                             child: widget.isOtpVerifying
        //                                 ? const Padding(
        //                                     padding: EdgeInsets.all(12),
        //                                     child: CircularProgressIndicator(
        //                                       strokeWidth: 2,
        //                                       color: Colors.white,
        //                                     ),
        //                                   )
        //                                 : const Icon(
        //                                     Icons.check,
        //                                     color: Colors.white,
        //                                   ),
        //                           ),
        //                         ),
        //                       ],
        //                     ),
        //
        //                     if (showOtpError)
        //                       Padding(
        //                         padding: const EdgeInsets.only(top: 8, left: 4),
        //                         child: Text(
        //                           "⚠️ Please Enter Valid OTP",
        //                           style: GoogleFont.Mulish(
        //                             color: Colors.red,
        //                             fontSize: 13,
        //                           ),
        //                         ),
        //                       ),
        //                   ],
        //                 ),
        //               ),
        //             ],
        //           ],
        //         ),
        //       ),
        //     ),
        //
        //     if (hasError)
        //       Padding(
        //         padding: const EdgeInsets.only(left: 12.0, top: 4),
        //         child: Text(
        //           state.errorText ?? '',
        //           style: GoogleFont.Mulish(color: Colors.red, fontSize: 12),
        //         ),
        //       ),
        //   ],
        // );
      },
    );
  }

  Widget _buildPhoneField(
    bool hasError,
    FormFieldState<String> state,
    bool isTenDigits,
    bool hasMobile,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasError ? Colors.red : AppColor.borderGray,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                readOnly: widget.readOnly,
                maxLength: 10,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Phone Number',
                  border: InputBorder.none,
                  hintStyle: GoogleFont.Mulish(
                    fontWeight: FontWeight.w600,
                    color: AppColor.borderGray,
                    fontSize: 16,
                  ),
                ),
                style: GoogleFont.Mulish(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
                onChanged: (v) {
                  state.didChange(v);
                  setState(() {
                    showOtpError = false;
                    if (!isVerified) showOtp = false;
                  });
                },
              ),
            ),

            // clear X
            if (hasMobile && !isVerified)
              GestureDetector(
                onTap: () {
                  widget.controller?.clear();
                  state.didChange('');
                  setState(() {
                    showOtp = false;
                    showOtpError = false;
                    resendTimer?.cancel();
                  });
                },
                child: const Icon(Icons.close, color: Colors.grey, size: 20),
              ),

            const SizedBox(width: 0),

            // ✅ Get OTP OR Verified (same position - divider LEFT side)
            if (!isVerified && isTenDigits)
              InkWell(
                onTap: widget.isLoading
                    ? null
                    : () async {
                        if (widget.onSendOtp == null ||
                            widget.controller == null)
                          return;

                        final err = await widget.onSendOtp!(
                          widget.controller!.text,
                        );
                        if (err != null) {
                          showTopSnackBar(
                            Overlay.of(context),
                            CustomSnackBar.error(message: err),
                          );
                          return;
                        }

                        if (!mounted) return;
                        setState(() {
                          showOtp = true;
                          showOtpError = false;
                          for (final c in otpControllers) c.clear();
                          startResendTimer();
                        });
                      },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          "Get OTP",
                          style: GoogleFont.Mulish(
                            color: AppColor.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                ),
              )
            else if (isVerified)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: Text(
                  "Verified",
                  style: GoogleFont.Mulish(
                    color: AppColor.green, // ✅ green text like screenshot
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),

            const SizedBox(width: 2),

            // ✅ divider
            Container(
              width: 2,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColor.white.withOpacity(0),
                    AppColor.borderGray,
                    AppColor.white.withOpacity(0),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 10),

            // right label (like screenshot)
            Text(
              "Phone Number",
              style: GoogleFont.Mulish(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: AppColor.lightGray2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpCard(String last4Digits) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDEDED)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    // ✅ go back to phone field
                    showOtp = false;
                    showOtpError = false;
                  });
                },
                child: const Icon(Icons.arrow_back_ios_new, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "OTP Sent to your xxx$last4Digits",
                  style: GoogleFont.Mulish(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "If you didn’t get otp by sms, resend otp using the button",
            style: GoogleFont.Mulish(fontSize: 14, color: AppColor.darkGrey),
          ),
          const SizedBox(height: 10),

          InkWell(
            onTap: resendSeconds > 0 || widget.isLoading
                ? null
                : () async {
                    if (widget.onSendOtp == null || widget.controller == null)
                      return;
                    final err = await widget.onSendOtp!(
                      widget.controller!.text,
                    );
                    if (err != null) {
                      showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.error(message: err),
                      );
                      return;
                    }
                    if (!mounted) return;
                    setState(() {
                      for (final c in otpControllers) c.clear();
                      showOtpError = false;
                      startResendTimer();
                    });
                  },
            child: Text(
              resendSeconds > 0 ? "Resend in ${resendSeconds}s" : "Resend OTP",
              style: GoogleFont.Mulish(
                color: AppColor.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              ...List.generate(4, (index) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: index == 3 ? 10 : 10),
                    child: SizedBox(
                      height: 52,
                      child: TextField(
                        controller: otpControllers[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: showOtpError
                                  ? Colors.red
                                  : const Color(0xFFE3E3E3),
                              width: 1.2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 3) {
                            FocusScope.of(context).nextFocus();
                          } else if (value.isEmpty && index > 0) {
                            FocusScope.of(context).previousFocus();
                          }
                        },
                      ),
                    ),
                  ),
                );
              }),

              InkWell(
                onTap: widget.isOtpVerifying
                    ? null
                    : () async {
                        if (widget.onVerifyOtp == null ||
                            widget.controller == null)
                          return;

                        final otp = otpControllers.map((c) => c.text).join();
                        if (otp.length != 4) {
                          setState(() => showOtpError = true);
                          return;
                        }

                        final ok = await widget.onVerifyOtp!(
                          widget.controller!.text,
                          otp,
                        );
                        if (!ok) {
                          setState(() => showOtpError = true);
                          return;
                        }

                        if (!mounted) return;
                        setState(() {
                          isVerified = true;
                          showOtp = false;
                          showOtpError = false;
                          resendTimer?.cancel();
                        });
                      },
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: widget.isOtpVerifying
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check, color: Colors.white),
                ),
              ),
            ],
          ),

          if (showOtpError)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Please Enter Valid OTP",
                    style: GoogleFont.Mulish(
                      color: Colors.red,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
