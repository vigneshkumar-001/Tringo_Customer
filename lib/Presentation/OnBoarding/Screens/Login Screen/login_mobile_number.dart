

import 'dart:async';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:go_router/go_router.dart';

import '../../../../Core/Utility/app_Images.dart';
import '../../../../Core/Utility/app_color.dart';
import '../../../../Core/Utility/app_loader.dart';
import '../../../../Core/Utility/app_snackbar.dart';
import '../../../../Core/Utility/google_font.dart';
import '../../../../Core/Utility/sim_token.dart';
import '../../../../Core/Widgets/common_container.dart';
import '../../../../Core/app_go_routes.dart';
import 'Controller/login_notifier.dart';

class LoginMobileNumber extends ConsumerStatefulWidget {
  const LoginMobileNumber({super.key});

  @override
  ConsumerState<LoginMobileNumber> createState() => _LoginMobileNumberState();
}

class _LoginMobileNumberState extends ConsumerState<LoginMobileNumber> {
  bool isWhatsappChecked = false;
  String errorText = '';
  bool _isFormatting = false;

  final TextEditingController mobileNumberController = TextEditingController();
  String? _lastRawPhone;

  ProviderSubscription<LoginState>? _sub;

  String _selectedDialCode = '+91';
  String _selectedFlag = '🇮🇳';

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

  @override
  void initState() {
    super.initState();

    // ✅ Request permission immediately
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _ensurePhonePermission();
    });

    _sub = ref.listenManual<LoginState>(loginNotifierProvider, (
        prev,
        next,
        ) async {
      if (!mounted) return;

      // ❌ remove this line from here:
      // _ensurePhonePermission();

      if (next.error != null) {
        AppSnackBar.error(context, next.error!);
        return;
      }

      if (next.whatsappResponse != null) {
        final resp = next.whatsappResponse!;
        final hasWhatsapp = resp.data.hasWhatsapp;

        if (hasWhatsapp) {
          setState(() => isWhatsappChecked = true);

          final raw = _lastRawPhone;
          if (raw != null) {
            final fullPhone = '$_selectedDialCode$raw';
            final simToken = generateSimToken(fullPhone);

            ref
                .read(loginNotifierProvider.notifier)
                .loginUser(phoneNumber: raw, simToken: simToken);
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
        // ✅ Ensure permission before going to SIM screen
        await _ensurePhonePermission();

        final raw = _lastRawPhone ?? '';
        final fullPhone = '$_selectedDialCode$raw';
        final simToken = generateSimToken(fullPhone);

        context.pushNamed(
          AppRoutes.mobileNumberVerify,
          extra: {'phone': raw, 'simToken': simToken},
        );

        ref.read(loginNotifierProvider.notifier).resetState();
      }
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //
  //   // Ask permission once when screen opens
  //   _ensurePhonePermission();
  //
  //   // Listen to LoginState changes
  //   _sub = ref.listenManual<LoginState>(
  //     loginNotifierProvider,
  //         (prev, next) {
  //       if (!mounted) return;
  //
  //       // 1) New error (only when changed)
  //       if (prev?.error != next.error && next.error != null) {
  //         AppSnackBar.error(context, next.error!);
  //       }
  //
  //       // 2) WhatsApp verification result (only when updated)
  //       if (prev?.whatsappResponse != next.whatsappResponse &&
  //           next.whatsappResponse != null) {
  //         final resp = next.whatsappResponse!;
  //         final hasWhatsapp = resp.data.hasWhatsapp; // adjust to your model
  //
  //         if (hasWhatsapp) {
  //           setState(() => isWhatsappChecked = true);
  //
  //           final raw = _lastRawPhone;
  //           if (raw != null) {
  //             final fullPhone = '$_selectedDialCode$raw';
  //             final simToken = generateSimToken(fullPhone);
  //
  //             // NOTE: your backend currently builds "+91$phone" inside request.
  //             // For full multi-country support, update backend later.
  //             debugPrint('Generated simToken: $simToken');
  //
  //             ref
  //                 .read(loginNotifierProvider.notifier)
  //                 .loginUser(phoneNumber: raw, simToken: simToken);
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
  //       // 3) Login result (only when updated) → navigate once
  //       if (prev?.loginResponse != next.loginResponse &&
  //           next.loginResponse != null) {
  //         final raw = _lastRawPhone ?? '';
  //         final fullPhone = '$_selectedDialCode$raw';
  //         final simToken = generateSimToken(fullPhone);
  //
  //         context.pushNamed(
  //           AppRoutes.mobileNumberVerify,
  //           extra: {'phone': raw, 'simToken': simToken},
  //         );
  //
  //         // Clear state so listener won't re-trigger
  //         ref.read(loginNotifierProvider.notifier).resetState();
  //       }
  //     },
  //   );
  // }

  @override
  void dispose() {
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
      countryListTheme: CountryListThemeData(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        inputDecoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade100,
          hintText: 'Search country or code',
          hintStyle: GoogleFont.Mulish(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColor.borderLightGrey,
          ),
          prefixIcon: const Icon(Icons.search_rounded, size: 22),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: AppColor.skyBlue, width: 1.5),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
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
                        // Logo
                        Padding(
                          padding: const EdgeInsets.only(left: 35, top: 50),
                          child: Image.asset(
                            AppImages.logo,
                            height: 88,
                            width: 85,
                          ),
                        ),
                        const SizedBox(height: 81),

                        // Titles
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

                        // Phone input
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
                                // Country selector
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
                                          mobileNumberController
                                              .clear();
                                          setState(() {});
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets
                                              .symmetric(
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

                        const SizedBox(height: 35),

                        // WhatsApp checkbox row
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
                                const SizedBox(width: 5),
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
                                      : const SizedBox(width: 12, height: 12),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 35),

                        // VERIFY BUTTON
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
                              final formatted =
                              mobileNumberController.text.trim();
                              final rawPhone =
                              formatted.replaceAll(' ', '');

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
