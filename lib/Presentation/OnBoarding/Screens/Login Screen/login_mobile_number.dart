import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tringo_app/Core/Utility/app_loader.dart';
import 'package:tringo_app/Core/Utility/google_font.dart';
import 'package:tringo_app/Core/Widgets/common_container.dart';
import 'package:tringo_app/Core/app_go_routes.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Login%20Screen/Controller/login_notifier.dart';
 

import '../../../../Core/Utility/app_Images.dart';
import '../../../../Core/Utility/app_color.dart';
import '../../../../Core/Utility/app_snackbar.dart';
 

class LoginMobileNumber extends ConsumerStatefulWidget {
  const LoginMobileNumber({super.key});

  @override
  ConsumerState<LoginMobileNumber> createState() => _LoginMobileNumberState();
}

class _LoginMobileNumberState extends ConsumerState<LoginMobileNumber> {
  bool isWhatsappChecked = false; // ⬅ start unchecked
  String errorText = '';
  bool _isFormatting = false;
  final TextEditingController mobileNumberController = TextEditingController();

  String? _lastRawPhone;

  @override
  void initState() {
    super.initState();

  }

  void _formatPhoneNumber(String value) {
    setState(() => errorText = '');

    if (_isFormatting) return;

    _isFormatting = true;
    String digitsOnly = value.replaceAll(' ', '');

    if (digitsOnly.length > 10) {
      digitsOnly = digitsOnly.substring(0, 10);
    }

    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 4 || i == 7) {
        formatted += ' ';
      }
      formatted += digitsOnly[i];
    }

    mobileNumberController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );

    _isFormatting = false;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginNotifierProvider);
    final notifier = ref.read(loginNotifierProvider.notifier);

    ref.listen<LoginState>(loginNotifierProvider, (prev, next) {
      if (!mounted) return;

      if (next.error != null) {
        AppSnackBar.error(context, next.error!);
        return;
      }

      if (next.whatsappResponse != null) {
        final hasWhatsapp = next.whatsappResponse!.data.hasWhatsapp;

        if (hasWhatsapp) {
          setState(() => isWhatsappChecked = true);

          final raw = _lastRawPhone;
          if (raw != null) {
            ref
                .read(loginNotifierProvider.notifier)
                .loginUser(phoneNumber: raw);
          }
        } else {
          setState(() => isWhatsappChecked = false);
          AppSnackBar.error(
            context,
            'This number is not registered on WhatsApp. Please use a WhatsApp number.',
          );
        }
      }

      if (next.loginResponse != null) {
        AppSnackBar.success(context, 'OTP sent successfully!');
        final raw = _lastRawPhone ?? '';
        context.pushNamed(AppRoutes.otp, extra: raw);
        ref.read(loginNotifierProvider.notifier).resetState();
      }
    });
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Image.asset(
              AppImages.loginBCImage,
              width: double.infinity,
              fit: BoxFit.cover,
              height: double.infinity,
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 120,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LOGO
                    Padding(
                      padding: const EdgeInsets.only(left: 35, top: 50),
                      child: Image.asset(AppImages.logo, height: 88, width: 85),
                    ),
                    SizedBox(height: 81),

                    Padding(
                      padding: const EdgeInsets.only(left: 35, top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Login',
                                style: GoogleFont.Mulish(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 24,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                              SizedBox(width: 5),
                              Text(
                                'With',
                                style: GoogleFont.Mulish(
                                  fontSize: 24,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Your Mobile Number',
                            style: GoogleFont.Mulish(
                              fontSize: 24,
                              color: AppColor.darkBlue,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 35),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.white,
                          borderRadius: BorderRadius.circular(17),
                          border: Border.all(
                            color: mobileNumberController.text.isNotEmpty
                                ? AppColor.skyBlue
                                : AppColor.black,
                            width: mobileNumberController.text.isNotEmpty
                                ? 2
                                : 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '+91',
                              style: GoogleFont.Mulish(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppColor.gray84,
                              ),
                            ),
                            SizedBox(width: 8),
                            Image.asset(
                              AppImages.drapDownImage,
                              height: 14,
                              color: AppColor.darkGrey,
                            ),
                            SizedBox(width: 8),
                            Container(
                              width: 2,
                              height: 35,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColor.white.withOpacity(0.5),
                                    AppColor.white3,
                                    AppColor.white3,
                                    AppColor.white.withOpacity(0.5),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                            SizedBox(width: 9),
                            Expanded(
                              child: TextFormField(
                                controller: mobileNumberController,
                                keyboardType: TextInputType.phone,
                                maxLength: 12, // 10 digits + 2 spaces
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: GoogleFont.Mulish(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                ),
                                onChanged: _formatPhoneNumber,
                                decoration: InputDecoration(
                                  counterText: '',
                                  hintText: 'Enter Mobile Number',
                                  hintStyle: GoogleFont.Mulish(
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.borderLightGrey,
                                    fontSize: 16,
                                  ),
                                  border: InputBorder.none,
                                  suffixIcon:
                                  mobileNumberController.text.isNotEmpty
                                      ? GestureDetector(
                                    onTap: () {
                                      mobileNumberController.clear();
                                      setState(() {});
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 17,
                                      ),
                                      child: Image.asset(
                                        AppImages.closeImage,
                                        width: 10,
                                        height: 10,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  )
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 35),

                    Padding(
                      padding: const EdgeInsets.only(left: 25, right: 10),
                      child: ListTile(
                        dense: true,
                        minLeadingWidth: 0,
                        horizontalTitleGap: 10,
                        leading: Image.asset(
                          AppImages.whatsAppBlack,
                          height: 20,
                        ),
                        title: Text(
                          'Get Instant Updates',
                          style: GoogleFont.Mulish(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColor.darkBlue,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              'From Tringo on your',
                              style: GoogleFont.Mulish(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: AppColor.darkGrey,
                              ),
                            ),
                            SizedBox(width: 5),
                            Text(
                              'whatsapp',
                              style: GoogleFont.Mulish(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColor.gray84,
                              ),
                            ),
                          ],
                        ),

                        trailing: GestureDetector(
                          onTap: () {
                            setState(() {
                              isWhatsappChecked = !isWhatsappChecked;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isWhatsappChecked
                                    ? AppColor.green
                                    : AppColor.darkGrey,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: isWhatsappChecked
                                  ? Image.asset(
                                AppImages.tickImage,
                                height: 12,
                                color: AppColor.green,
                              )
                                  : SizedBox(width: 12, height: 12),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 35),

                    // VERIFY BUTTON
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: CommonContainer.button(
                       
                        loader: state.isLoading ? ThreeDotsLoader(dotColor: AppColor.black,) : null,
                        onTap: state.isLoading
                            ? null
                            : () async {
                          final formatted = mobileNumberController.text
                              .trim();
                          final rawPhone = formatted.replaceAll(' ', '');

                          if (rawPhone.isEmpty) {
                            AppSnackBar.info(
                              context,
                              'Please enter phone number',
                            );
                            return;
                          }
                          if (rawPhone.length != 10) {
                            AppSnackBar.info(
                              context,
                              'Please enter a valid 10-digit number',
                            );
                            return;
                          }

                          _lastRawPhone = rawPhone;

                          await notifier.verifyWhatsappNumber(
                            contact: rawPhone,
                            purpose: 'owner', //  important
                          );
                        },
                        text: Text('Verify Now'),
                      ),
                    ),

                    SizedBox(height: 50),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                AppImages.loginScreenBottom,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// // lib/Presentation/OnBoarding/Screens/Login Screen/login_mobile_number.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
//
// import 'package:tringo_app/Core/Utility/app_Images.dart';
// import 'package:tringo_app/Core/Utility/app_color.dart';
// import 'package:tringo_app/Core/Utility/google_font.dart';
// import 'package:tringo_app/Core/Widgets/common_container.dart';
//
// import '../../../../Core/Utility/app_loader.dart';
// import '../../../../Core/Utility/app_snackbar.dart';
// import '../../../../Core/app_go_routes.dart';
// import 'Controller/login_notifier.dart';
//
// class LoginMobileNumber extends ConsumerStatefulWidget {
//   const LoginMobileNumber({super.key});
//
//   @override
//   ConsumerState<LoginMobileNumber> createState() => _LoginMobileNumberState();
// }
//
// class _LoginMobileNumberState extends ConsumerState<LoginMobileNumber> {
//   String errorText = '';
//   bool _isFormatting = false;
//   bool isWhatsappChecked = false;
//   String? _lastRawPhone;
//
//   final TextEditingController mobileNumberController = TextEditingController();
//
//   // void _formatPhoneNumber(String value) {
//   //   setState(() => errorText = '');
//   //
//   //   if (_isFormatting) return;
//   //
//   //   _isFormatting = true;
//   //   String digitsOnly = value.replaceAll(' ', '');
//   //
//   //   if (digitsOnly.length > 10) {
//   //     digitsOnly = digitsOnly.substring(0, 10);
//   //   }
//   //
//   //   String formatted = '';
//   //   for (int i = 0; i < digitsOnly.length; i++) {
//   //     if (i == 4 || i == 7) {
//   //       formatted += ' ';
//   //     }
//   //     formatted += digitsOnly[i];
//   //   }
//   //
//   //   mobileNumberController.value = TextEditingValue(
//   //     text: formatted,
//   //     selection: TextSelection.collapsed(offset: formatted.length),
//   //   );
//   //
//   //   _isFormatting = false;
//   // }
//
//   void _formatPhoneNumber(String value) {
//     setState(() => errorText = '');
//
//     if (_isFormatting) return;
//
//     _isFormatting = true;
//     String digitsOnly = value.replaceAll(' ', '');
//
//     if (digitsOnly.length > 10) {
//       digitsOnly = digitsOnly.substring(0, 10);
//     }
//
//     String formatted = '';
//     for (int i = 0; i < digitsOnly.length; i++) {
//       if (i == 4 || i == 7) {
//         formatted += ' ';
//       }
//       formatted += digitsOnly[i];
//     }
//
//     mobileNumberController.value = TextEditingValue(
//       text: formatted,
//       selection: TextSelection.collapsed(offset: formatted.length),
//     );
//
//     _isFormatting = false;
//   }
//
//   ProviderSubscription<LoginState>? _subscription;
//
//   @override
//   void initState() {
//     super.initState();
//
//
//     _subscription = ref.listenManual<LoginState>(loginNotifierProvider, (
//       prev,
//       next,
//     ) {
//       if (!mounted) return;
//
//       // ERROR
//       if (next.error != null) {
//         AppSnackBar.error(context, next.error!);
//         return;
//       }
//
//       // WHATSAPP CHECK
//       if (next.whatsappResponse != null) {
//         final resp = next.whatsappResponse!;
//         final hasWhatsapp = resp.data.hasWhatsapp;
//
//         if (hasWhatsapp) {
//           setState(() => isWhatsappChecked = true);
//
//           if (_lastRawPhone != null) {
//             ref
//                 .read(loginNotifierProvider.notifier)
//                 .loginUser(phoneNumber: _lastRawPhone!);
//           }
//         } else {
//           setState(() => isWhatsappChecked = false);
//           AppSnackBar.error(
//             context,
//             'This number is not registered on WhatsApp. Please use a WhatsApp number.',
//           );
//         }
//       }
//
//       // LOGIN SUCCESS → GO NEXT
//       if (next.loginResponse != null) {
//         AppSnackBar.success(context, 'OTP sent successfully!');
//
//         if (_lastRawPhone != null) {
//           context.pushNamed(
//             AppGoRoutes.mobileNumberVerify,
//             extra: _lastRawPhone!,
//           );
//         }
//
//         ref.read(loginNotifierProvider.notifier).resetState();
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _subscription?.close(); // VERY IMPORTANT
//     mobileNumberController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(loginNotifierProvider);
//     final notifier = ref.read(loginNotifierProvider.notifier);
//     return Scaffold(
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Image.asset(
//               AppImages.loginBCImage,
//               width: double.infinity,
//               fit: BoxFit.cover,
//               height: double.infinity,
//             ),
//
//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               bottom: 120,
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.only(bottom: 20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Logo
//                     Padding(
//                       padding: const EdgeInsets.only(left: 35, top: 50),
//                       child: Image.asset(AppImages.logo, height: 88, width: 85),
//                     ),
//                     const SizedBox(height: 81),
//
//                     // Titles
//                     Padding(
//                       padding: const EdgeInsets.only(left: 35, top: 20),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Text(
//                                 'Login',
//                                 style: GoogleFont.Mulish(
//                                   fontWeight: FontWeight.w800,
//                                   fontSize: 24,
//                                   color: AppColor.darkBlue,
//                                 ),
//                               ),
//                               const SizedBox(width: 5),
//                               Text(
//                                 'With',
//                                 style: GoogleFont.Mulish(
//                                   fontSize: 24,
//                                   color: AppColor.darkBlue,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Text(
//                             'Your Mobile Number',
//                             style: GoogleFont.Mulish(
//                               fontSize: 24,
//                               color: AppColor.darkBlue,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: 35),
//
//                     // Phone input
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 35),
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 20,
//                           vertical: 6,
//                         ),
//                         decoration: BoxDecoration(
//                           color: AppColor.white,
//                           borderRadius: BorderRadius.circular(17),
//                           border: Border.all(
//                             color: mobileNumberController.text.isNotEmpty
//                                 ? AppColor.blue
//                                 : AppColor.black,
//                             width: mobileNumberController.text.isNotEmpty
//                                 ? 2
//                                 : 1.5,
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             Text(
//                               '+91',
//                               style: GoogleFont.Mulish(
//                                 fontWeight: FontWeight.w700,
//                                 fontSize: 14,
//                                 color: AppColor.lightGray3,
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Image.asset(
//                               AppImages.drapDownImage,
//                               height: 14,
//                               color: AppColor.lightGray2,
//                             ),
//                             const SizedBox(width: 8),
//                             Container(
//                               width: 2,
//                               height: 35,
//                               decoration: BoxDecoration(
//                                 gradient: LinearGradient(
//                                   begin: Alignment.topCenter,
//                                   end: Alignment.bottomCenter,
//                                   colors: [
//                                     AppColor.white.withOpacity(0.5),
//                                     AppColor.white3,
//                                     AppColor.white3,
//                                     AppColor.white.withOpacity(0.5),
//                                   ],
//                                 ),
//                                 borderRadius: BorderRadius.circular(1),
//                               ),
//                             ),
//                             const SizedBox(width: 9),
//                             Expanded(
//                               child: TextFormField(
//                                 controller: mobileNumberController,
//                                 keyboardType: TextInputType.phone,
//                                 maxLength: 12,
//                                 inputFormatters: [
//                                   FilteringTextInputFormatter.digitsOnly,
//                                 ],
//                                 style: GoogleFont.inter(
//                                   fontWeight: FontWeight.w700,
//                                   fontSize: 20,
//                                 ),
//                                 onChanged: _formatPhoneNumber,
//                                 decoration: InputDecoration(
//                                   counterText: '',
//                                   hintText: 'Enter Mobile Number',
//                                   hintStyle: GoogleFont.inter(
//                                     fontWeight: FontWeight.w600,
//                                     color: AppColor.borderGray,
//                                     fontSize: 16,
//                                   ),
//                                   border: InputBorder.none,
//                                   suffixIcon:
//                                       mobileNumberController.text.isNotEmpty
//                                       ? GestureDetector(
//                                           onTap: () {
//                                             mobileNumberController.clear();
//                                             setState(() {});
//                                           },
//                                           child: Padding(
//                                             padding: const EdgeInsets.symmetric(
//                                               vertical: 17,
//                                             ),
//                                             child: Image.asset(
//                                               AppImages.closeImageBlack,
//                                               width: 10,
//                                               height: 10,
//                                               fit: BoxFit.contain,
//                                             ),
//                                           ),
//                                         )
//                                       : null,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 35),
//
//                     // WhatsApp checkbox row
//                     Padding(
//                       padding: const EdgeInsets.only(left: 25, right: 10),
//                       child: ListTile(
//                         dense: true,
//                         minLeadingWidth: 0,
//                         horizontalTitleGap: 10,
//                         leading: Image.asset(
//                           AppImages.whatsAppBlack,
//                           height: 20,
//                         ),
//                         title: Text(
//                           'Get Instant Updates',
//                           style: GoogleFont.Mulish(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w800,
//                             color: AppColor.darkBlue,
//                           ),
//                         ),
//                         subtitle: Row(
//                           children: [
//                             Text(
//                               'From Tringo on your',
//                               style: GoogleFont.Mulish(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.w500,
//                                 color: AppColor.lightGray2,
//                               ),
//                             ),
//                             const SizedBox(width: 5),
//                             Text(
//                               'whatsapp',
//                               style: GoogleFont.Mulish(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.w700,
//                                 color: AppColor.lightGray3,
//                               ),
//                             ),
//                           ],
//                         ),
//                         trailing: GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               isWhatsappChecked = !isWhatsappChecked;
//                             });
//                           },
//                           child: Container(
//                             decoration: BoxDecoration(
//                               border: Border.all(
//                                 color: isWhatsappChecked
//                                     ? AppColor.green
//                                     : AppColor.lightGray2,
//                                 width: 2,
//                               ),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: isWhatsappChecked
//                                   ? Image.asset(
//                                       AppImages.tickImage,
//                                       height: 12,
//                                       color: AppColor.green,
//                                     )
//                                   : const SizedBox(width: 12, height: 12),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 35),
//
//                     // Verify Now button
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 35),
//                       child: CommonContainer.button(
//                         loader: state.isLoading
//                             ? const ThreeDotsLoader()
//                             : null,
//                         onTap: state.isLoading
//                             ? null
//                             : () async {
//                                 final formatted = mobileNumberController.text
//                                     .trim();
//                                 final rawPhone = formatted.replaceAll(' ', '');
//
//                                 if (rawPhone.isEmpty) {
//                                   AppSnackBar.info(
//                                     context,
//                                     'Please enter phone number',
//                                   );
//                                   return;
//                                 }
//                                 if (rawPhone.length != 10) {
//                                   AppSnackBar.info(
//                                     context,
//                                     'Please enter a valid 10-digit number',
//                                   );
//                                   return;
//                                 }
//
//                                 _lastRawPhone = rawPhone;
//
//                                 await notifier.verifyWhatsappNumber(
//                                   contact: rawPhone,
//                                   purpose: 'customer', // matches API
//                                 );
//                               },
//                         text: Text(
//                           'Verify Now',
//                           style: GoogleFont.Mulish(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w800,
//                             color: AppColor.white,
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 50),
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
//                 fit: BoxFit.cover,
//                 width: double.infinity,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
