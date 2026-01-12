// ===============================
// LoginMobileNumber.dart (FULL)
// ===============================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:country_picker/country_picker.dart';

import '../../../../../Core/Utility/app_Images.dart';
import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/app_loader.dart';
import '../../../../../Core/Utility/google_font.dart';
import '../../../../../Core/app_go_routes.dart';
import '../../../../Core/Utility/app_snackbar.dart';
import '../../../../Core/Utility/network_util.dart';
import '../../../../Core/Utility/sim_token.dart';
import '../../../../Core/Widgets/caller_id_role_helper.dart';
import '../../../../Core/Widgets/common_container.dart';
import 'Controller/login_notifier.dart';

class LoginMobileNumber extends ConsumerStatefulWidget {
  const LoginMobileNumber({super.key});

  @override
  ConsumerState<LoginMobileNumber> createState() => _LoginMobileNumberState();
}

class _LoginMobileNumberState extends ConsumerState<LoginMobileNumber>
    with WidgetsBindingObserver {
  bool isWhatsappChecked = false;
  String errorText = '';
  bool _isFormatting = false;

  final TextEditingController mobileNumberController = TextEditingController();
  String? _lastRawPhone;

  ProviderSubscription<LoginState>? _sub;

  String _selectedDialCode = '+91';
  String _selectedFlag = '🇮🇳';

  // ✅ native channel
  static const MethodChannel _native = MethodChannel('sim_info');

  bool _openingSystemRole = false; // ✅ prevent double open
  bool _askedOnce = false; // ✅ show only once on first open

  // ---- PERMISSION ----
  Future<void> _ensurePhonePermission() async {
    try {
      final hasPermission = await MobileNumber.hasPhonePermission;
      if (!hasPermission) {
        await MobileNumber.requestPhonePermission;
      }
      final after = await MobileNumber.hasPhonePermission;
      debugPrint('PHONE PERMISSION AFTER REQUEST: $after');
    } catch (e, st) {
      debugPrint('❌ Error requesting phone permission: $e');
      debugPrint('$st');
    }
  }

  // ✅ default caller id check
  Future<bool> _isDefaultCallerIdApp() async {
    try {
      if (!Platform.isAndroid) return true;
      final ok = await _native.invokeMethod<bool>('isDefaultCallerIdApp');
      debugPrint("✅ isDefaultCallerIdApp => $ok");
      return ok ?? false;
    } catch (e) {
      debugPrint('❌ isDefaultCallerIdApp error: $e');
      return false;
    }
  }

  // ✅ request system popup (returns true if granted)
  Future<void> _requestDefaultCallerIdApp() async {
    try {
      if (!Platform.isAndroid) return;
      debugPrint("🔥 calling requestDefaultCallerIdApp...");
      await _native.invokeMethod('requestDefaultCallerIdApp');
      debugPrint("✅ requestDefaultCallerIdApp invoked");
    } catch (e) {
      debugPrint('❌ requestDefaultCallerIdApp error: $e');
    }
  }

  /// ✅ SHOW ONLY SYSTEM POPUP ONCE
  Future<void> _maybeShowSystemCallerIdPopupOnce() async {
    if (!mounted) return;
    if (!Platform.isAndroid) return;
    if (_openingSystemRole) return;
    if (_askedOnce) return;

    final ok = await _isDefaultCallerIdApp();
    if (ok) return;

    _askedOnce = true;
    _openingSystemRole = true;

    await _requestDefaultCallerIdApp();

    await Future.delayed(const Duration(milliseconds: 300));
    _openingSystemRole = false;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _ensurePhonePermission();

      // ✅ keep your original overlay / callerId role logic
      final overlayOk = await CallerIdRoleHelper.isOverlayGranted();
      if (!overlayOk) {
        await CallerIdRoleHelper.requestOverlayPermission();
      }

      await CallerIdRoleHelper.maybeAskOnce(ref: ref);
    });

    // ✅ IMPORTANT CHANGE:
    // We will ONLY react to whatsappResponse here.
    // We will NOT auto react to loginResponse here (that was causing OTP send / side-effect sometimes).
    _sub = ref.listenManual<LoginState>(loginNotifierProvider, (
      prev,
      next,
    ) async {
      if (!mounted) return;

      if (prev?.error != next.error && next.error != null) {
        AppSnackBar.error(context, next.error!);
        return;
      }

      // ✅ WhatsApp verify success -> navigate to MobileNumberVerify
      if (prev?.whatsappResponse != next.whatsappResponse &&
          next.whatsappResponse != null) {
        final resp = next.whatsappResponse!;
        final hasWhatsapp = resp.data.hasWhatsapp;

        if (!hasWhatsapp) {
          if (mounted) setState(() => isWhatsappChecked = false);
          AppSnackBar.error(
            context,
            'This number is not registered on WhatsApp. Please use a WhatsApp number.',
          );
          return;
        }

        if (mounted) setState(() => isWhatsappChecked = true);

        final raw = _lastRawPhone;
        if (raw == null) return;

        final fullPhone = '$_selectedDialCode$raw';
        final simToken = generateSimToken(fullPhone);

        if (!mounted) return;
        context.pushNamed(
          AppRoutes.mobileNumberVerify,
          extra: {'phone': raw, 'simToken': simToken},
        );

        // ✅ reset after navigation
        ref.read(loginNotifierProvider.notifier).resetState();
        return;
      }

      // ❌ REMOVED:
      // loginResponse listener block is removed to prevent OTP being sent unexpectedly.
    });
  }

  /// IMPORTANT: resumed ல auto-open செய்யாதீங்க (double popup stop)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await Future.delayed(const Duration(milliseconds: 400));
      final ok = await _isDefaultCallerIdApp();
      debugPrint("🔁 resumed default ok? $ok");

      if (ok) {
        _askedOnce = true;
      } else {
        // don't auto open again
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sub?.close();
    mobileNumberController.dispose();
    super.dispose();
  }

  void _formatPhoneNumber(String value) {
    setState(() => errorText = '');
    if (_isFormatting) return;
    _isFormatting = true;

    String digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length > 10) digitsOnly = digitsOnly.substring(0, 10);

    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 4 || i == 7) formatted += ' ';
      formatted += digitsOnly[i];
    }

    mobileNumberController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );

    _isFormatting = false;
  }

  void _showCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        setState(() {
          _selectedDialCode = '+${country.phoneCode}';
          _selectedFlag = country.flagEmoji;
        });
      },
      countryListTheme: const CountryListThemeData(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        bottomSheetHeight: 500,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginNotifierProvider);
    final notifier = ref.read(loginNotifierProvider.notifier);

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
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 35, top: 50),
                          child: Image.asset(
                            AppImages.logo,
                            height: 88,
                            width: 85,
                          ),
                        ),
                        const SizedBox(height: 81),
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
                                  const SizedBox(width: 5),
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
                        const SizedBox(height: 35),

                        // phone input (same)
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
                                GestureDetector(
                                  onTap: _showCountryPicker,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _selectedFlag,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _selectedDialCode,
                                        style: GoogleFont.Mulish(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: AppColor.gray84,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Image.asset(
                                        AppImages.drapDownImage,
                                        height: 14,
                                        color: AppColor.darkGrey,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 2,
                                  height: 35,
                                  color: AppColor.white3,
                                ),
                                const SizedBox(width: 9),
                                Expanded(
                                  child: TextFormField(
                                    controller: mobileNumberController,
                                    keyboardType: TextInputType.phone,
                                    maxLength: 12,
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 18,
                                                    ),
                                                child: Image.asset(
                                                  AppImages.closeImageBlack,
                                                  width: 6,
                                                  height: 6,
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

                        const SizedBox(height: 35),

                        // verify button (same)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: CommonContainer.button2(
                            width: double.infinity,
                            loader: state.isLoading
                                ? const ThreeDotsLoader()
                                : null,
                            onTap: state.isLoading
                                ? null
                                : () async {
                                    final hasInternet =
                                        await NetworkUtil.hasInternet();
                                    if (!hasInternet) {
                                      AppSnackBar.error(
                                        context,
                                        "You're offline. Check your network connection",
                                      );
                                      return;
                                    }

                                    final formatted = mobileNumberController
                                        .text
                                        .trim();
                                    final rawPhone = formatted.replaceAll(
                                      ' ',
                                      '',
                                    );

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
                                      purpose: 'customer',
                                    );
                                  },
                            text: 'Verify Now',
                          ),
                        ),

                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                  Image.asset(
                    AppImages.loginScreenBottom,
                    fit: BoxFit.cover,
                    width: double.infinity,
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

// import 'dart:io';
// import 'package:country_picker/country_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mobile_number/mobile_number.dart';
// import 'package:go_router/go_router.dart';
//
// import '../../../../Core/Utility/app_Images.dart';
// import '../../../../Core/Utility/app_color.dart';
// import '../../../../Core/Utility/app_loader.dart';
// import '../../../../Core/Utility/app_snackbar.dart';
// import '../../../../Core/Utility/google_font.dart';
// import '../../../../Core/Utility/network_util.dart';
// import '../../../../Core/Utility/sim_token.dart';
// import '../../../../Core/Widgets/caller_id_role_helper.dart';
// import '../../../../Core/Widgets/common_container.dart';
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
// class _LoginMobileNumberState extends ConsumerState<LoginMobileNumber>
//     with WidgetsBindingObserver {
//   bool isWhatsappChecked = false;
//   String errorText = '';
//   bool _isFormatting = false;
//
//   final TextEditingController mobileNumberController = TextEditingController();
//   String? _lastRawPhone;
//
//   ProviderSubscription<LoginState>? _sub;
//
//   String _selectedDialCode = '+91';
//   String _selectedFlag = '🇮🇳';
//
//   // ✅ native channel
//   static const MethodChannel _native = MethodChannel('sim_info');
//
//   bool _openingSystemRole = false; // ✅ prevent double open
//   bool _askedOnce = false; // ✅ show only once on first open
//
//   // ---- PERMISSION ----
//   Future<void> _ensurePhonePermission() async {
//     try {
//       final hasPermission = await MobileNumber.hasPhonePermission;
//       if (!hasPermission) {
//         await MobileNumber.requestPhonePermission;
//       }
//       final after = await MobileNumber.hasPhonePermission;
//       debugPrint('PHONE PERMISSION AFTER REQUEST: $after');
//     } catch (e, st) {
//       debugPrint('❌ Error requesting phone permission: $e');
//       debugPrint('$st');
//     }
//   }
//
//   // ✅ default caller id check
//   Future<bool> _isDefaultCallerIdApp() async {
//     try {
//       if (!Platform.isAndroid) return true;
//       final ok = await _native.invokeMethod<bool>('isDefaultCallerIdApp');
//       debugPrint("✅ isDefaultCallerIdApp => $ok");
//       return ok ?? false;
//     } catch (e) {
//       debugPrint('❌ isDefaultCallerIdApp error: $e');
//       return false;
//     }
//   }
//
//   // ✅ request system popup (returns true if granted)
//   Future<void> _requestDefaultCallerIdApp() async {
//     try {
//       if (!Platform.isAndroid) return;
//       debugPrint("🔥 calling requestDefaultCallerIdApp...");
//       await _native.invokeMethod('requestDefaultCallerIdApp');
//       debugPrint("✅ requestDefaultCallerIdApp invoked");
//     } catch (e) {
//       debugPrint('❌ requestDefaultCallerIdApp error: $e');
//     }
//   }
//
//   /// ✅ SHOW ONLY SYSTEM POPUP ONCE
//   Future<void> _maybeShowSystemCallerIdPopupOnce() async {
//     if (!mounted) return;
//     if (!Platform.isAndroid) return;
//     if (_openingSystemRole) return;
//     if (_askedOnce) return;
//
//     final ok = await _isDefaultCallerIdApp();
//     if (ok) return;
//
//     _askedOnce = true;
//     _openingSystemRole = true;
//
//     await _requestDefaultCallerIdApp();
//
//     await Future.delayed(const Duration(milliseconds: 300));
//     _openingSystemRole = false;
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//
//     //  On first open -> ask phone permission + show ONLY system popup once
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await _ensurePhonePermission();
//
//       final overlayOk = await CallerIdRoleHelper.isOverlayGranted();
//       if (!overlayOk) {
//         await CallerIdRoleHelper.requestOverlayPermission(); // settings open
//       }
//
//       await CallerIdRoleHelper.maybeAskOnce(ref: ref); // caller id role popup
//     });
//
//     // login state listener (same as yours)
//     _sub = ref.listenManual<LoginState>(loginNotifierProvider, (
//       prev,
//       next,
//     ) async {
//       if (!mounted) return;
//
//       if (prev?.error != next.error && next.error != null) {
//         AppSnackBar.error(context, next.error!);
//         return;
//       }
//
//       // if (prev?.whatsappResponse != next.whatsappResponse &&
//       //     next.whatsappResponse != null) {
//       //   final resp = next.whatsappResponse!;
//       //   final hasWhatsapp = resp.data.hasWhatsapp;
//       //
//       //   if (!hasWhatsapp) {
//       //     if (mounted) setState(() => isWhatsappChecked = false);
//       //     AppSnackBar.error(
//       //       context,
//       //       'This number is not registered on WhatsApp. Please use a WhatsApp number.',
//       //     );
//       //     return;
//       //   }
//       //
//       //   if (mounted) setState(() => isWhatsappChecked = true);
//       //
//       //   final raw = _lastRawPhone;
//       //   if (raw == null) return;
//       //
//       //   final fullPhone = '$_selectedDialCode$raw';
//       //   final simToken = generateSimToken(fullPhone);
//       //
//       //   ref
//       //       .read(loginNotifierProvider.notifier)
//       //       .loginUser(phoneNumber: raw, simToken: simToken);
//       //   return;
//       // }
//
//       if (prev?.whatsappResponse != next.whatsappResponse &&
//           next.whatsappResponse != null) {
//         final resp = next.whatsappResponse!;
//         final hasWhatsapp = resp.data.hasWhatsapp;
//
//         if (!hasWhatsapp) {
//           if (mounted) setState(() => isWhatsappChecked = false);
//           AppSnackBar.error(
//             context,
//             'This number is not registered on WhatsApp. Please use a WhatsApp number.',
//           );
//           return;
//         }
//
//         if (mounted) setState(() => isWhatsappChecked = true);
//
//         final raw = _lastRawPhone;
//         if (raw == null) return;
//
//         final fullPhone = '$_selectedDialCode$raw';
//         final simToken = generateSimToken(fullPhone);
//
//         // ✅ ONLY navigate (NO OTP send here)
//         if (!mounted) return;
//         context.pushNamed(
//           AppRoutes.mobileNumberVerify,
//           extra: {'phone': raw, 'simToken': simToken},
//         );
//
//         ref.read(loginNotifierProvider.notifier).resetState();
//         return;
//       }
//
//
//       if (prev?.loginResponse != next.loginResponse &&
//           next.loginResponse != null) {
//         await _ensurePhonePermission();
//
//         final raw = _lastRawPhone ?? '';
//         final fullPhone = '$_selectedDialCode$raw';
//         final simToken = generateSimToken(fullPhone);
//
//         if (!mounted) return;
//
//         context.pushNamed(
//           AppRoutes.mobileNumberVerify,
//           extra: {'phone': raw, 'simToken': simToken},
//         );
//
//         ref.read(loginNotifierProvider.notifier).resetState();
//       }
//     });
//   }
//
//   ///  IMPORTANT: resumed ல auto-open செய்யாதீங்க (double popup stop)
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) async {
//     if (state == AppLifecycleState.resumed) {
//       await Future.delayed(const Duration(milliseconds: 400));
//       final ok = await _isDefaultCallerIdApp();
//       debugPrint("🔁 resumed default ok? $ok");
//
//       // ✅ if user granted, stop asking
//       if (ok) {
//         _askedOnce = true; // keep asked
//       } else {
//         // ❌ user cancel/back -> DON'T auto open again here (avoid loop)
//         // next app launch / next screen you can ask again if you want
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _sub?.close();
//     mobileNumberController.dispose();
//     super.dispose();
//   }
//
//   void _formatPhoneNumber(String value) {
//     setState(() => errorText = '');
//     if (_isFormatting) return;
//     _isFormatting = true;
//
//     String digitsOnly = value.replaceAll(RegExp(r'\D'), '');
//     if (digitsOnly.length > 10) digitsOnly = digitsOnly.substring(0, 10);
//
//     String formatted = '';
//     for (int i = 0; i < digitsOnly.length; i++) {
//       if (i == 4 || i == 7) formatted += ' ';
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
//   void _showCountryPicker() {
//     showCountryPicker(
//       context: context,
//       showPhoneCode: true,
//       onSelect: (Country country) {
//         setState(() {
//           _selectedDialCode = '+${country.phoneCode}';
//           _selectedFlag = country.flagEmoji;
//         });
//       },
//       countryListTheme: CountryListThemeData(
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(16),
//           topRight: Radius.circular(16),
//         ),
//         bottomSheetHeight: 500,
//       ),
//     );
//   }
//
//   // ✅ உங்கள் existing UI build same — unchanged
//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(loginNotifierProvider);
//     final notifier = ref.read(loginNotifierProvider.notifier);
//
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
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Column(
//                 children: [
//                   SingleChildScrollView(
//                     padding: const EdgeInsets.only(bottom: 20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.only(left: 35, top: 50),
//                           child: Image.asset(
//                             AppImages.logo,
//                             height: 88,
//                             width: 85,
//                           ),
//                         ),
//                         const SizedBox(height: 81),
//
//                         Padding(
//                           padding: const EdgeInsets.only(left: 35, top: 20),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Text(
//                                     'Login',
//                                     style: GoogleFont.Mulish(
//                                       fontWeight: FontWeight.w800,
//                                       fontSize: 24,
//                                       color: AppColor.darkBlue,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 5),
//                                   Text(
//                                     'With',
//                                     style: GoogleFont.Mulish(
//                                       fontSize: 24,
//                                       color: AppColor.darkBlue,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               Text(
//                                 'Your Mobile Number',
//                                 style: GoogleFont.Mulish(
//                                   fontSize: 24,
//                                   color: AppColor.darkBlue,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         const SizedBox(height: 35),
//
//                         // phone input (same)
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 35),
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 20,
//                               vertical: 6,
//                             ),
//                             decoration: BoxDecoration(
//                               color: AppColor.white,
//                               borderRadius: BorderRadius.circular(17),
//                               border: Border.all(
//                                 color: mobileNumberController.text.isNotEmpty
//                                     ? AppColor.skyBlue
//                                     : AppColor.black,
//                                 width: mobileNumberController.text.isNotEmpty
//                                     ? 2
//                                     : 1.5,
//                               ),
//                             ),
//                             child: Row(
//                               children: [
//                                 GestureDetector(
//                                   onTap: _showCountryPicker,
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Text(
//                                         _selectedFlag,
//                                         style: const TextStyle(fontSize: 20),
//                                       ),
//                                       const SizedBox(width: 6),
//                                       Text(
//                                         _selectedDialCode,
//                                         style: GoogleFont.Mulish(
//                                           fontWeight: FontWeight.w700,
//                                           fontSize: 14,
//                                           color: AppColor.gray84,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 4),
//                                       Image.asset(
//                                         AppImages.drapDownImage,
//                                         height: 14,
//                                         color: AppColor.darkGrey,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Container(
//                                   width: 2,
//                                   height: 35,
//                                   color: AppColor.white3,
//                                 ),
//                                 const SizedBox(width: 9),
//                                 Expanded(
//                                   child: TextFormField(
//                                     controller: mobileNumberController,
//                                     keyboardType: TextInputType.phone,
//                                     maxLength: 12,
//                                     inputFormatters: [
//                                       FilteringTextInputFormatter.digitsOnly,
//                                     ],
//                                     style: GoogleFont.Mulish(
//                                       fontWeight: FontWeight.w700,
//                                       fontSize: 20,
//                                     ),
//                                     onChanged: _formatPhoneNumber,
//                                     decoration: InputDecoration(
//                                       counterText: '',
//                                       hintText: 'Enter Mobile Number',
//                                       hintStyle: GoogleFont.Mulish(
//                                         fontWeight: FontWeight.w600,
//                                         color: AppColor.borderLightGrey,
//                                         fontSize: 16,
//                                       ),
//                                       border: InputBorder.none,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//
//                         const SizedBox(height: 35),
//
//                         // verify button (same)
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 35),
//                           child: CommonContainer.button2(
//                             width: double.infinity,
//                             loader: state.isLoading
//                                 ? const ThreeDotsLoader()
//                                 : null,
//                             onTap: state.isLoading
//                                 ? null
//                                 : () async {
//                                     //🔴 INTERNET CHECK FIRST
//                                     final hasInternet =
//                                         await NetworkUtil.hasInternet();
//                                     if (!hasInternet) {
//                                       AppSnackBar.error(
//                                         context,
//                                         "You're offline. Check your network connection",
//                                       );
//                                       return; //⛔ STOP HERE
//                                     }
//
//                                     final formatted = mobileNumberController
//                                         .text
//                                         .trim();
//                                     final rawPhone = formatted.replaceAll(
//                                       ' ',
//                                       '',
//                                     );
//
//                                     if (rawPhone.isEmpty) {
//                                       AppSnackBar.info(
//                                         context,
//                                         'Please enter phone number',
//                                       );
//                                       return;
//                                     }
//                                     if (rawPhone.length != 10) {
//                                       AppSnackBar.info(
//                                         context,
//                                         'Please enter a valid 10-digit number',
//                                       );
//                                       return;
//                                     }
//
//                                     _lastRawPhone = rawPhone;
//
//                                     await notifier.verifyWhatsappNumber(
//                                       contact: rawPhone,
//                                       purpose: 'customer',
//                                     );
//                                   },
//                             text: 'Verify Now',
//                           ),
//                         ),
//
//                         const SizedBox(height: 50),
//                       ],
//                     ),
//                   ),
//                   Image.asset(
//                     AppImages.loginScreenBottom,
//                     fit: BoxFit.cover,
//                     width: double.infinity,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
