import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:country_picker/country_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../../Core/Utility/app_Images.dart';
import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/app_loader.dart';
import '../../../../../Core/Utility/app_snackbar.dart';
import '../../../../../Core/Utility/google_font.dart';
import '../../../../../Core/Utility/sim_token.dart';
import '../../../../../Core/Widgets/caller_id_role_helper.dart';
import '../../../../../Core/Widgets/common_container.dart';
import '../../../../../Core/app_go_routes.dart';

import '../../Login Screen/Controller/login_notifier.dart';
import '../Controller/mobile_verify_notifier.dart';

class LoginMobileNumber extends ConsumerStatefulWidget {
  final String loginNumber;
  final String simToken;

  const LoginMobileNumber({
    super.key,
    required this.loginNumber,
    required this.simToken,
  });

  @override
  ConsumerState<LoginMobileNumber> createState() => _LoginMobileNumberState();
}

class _LoginMobileNumberState extends ConsumerState<LoginMobileNumber>
    with WidgetsBindingObserver {
  String errorText = '';
  bool _isFormatting = false;

  final TextEditingController mobileNumberController = TextEditingController();
  String? _lastRawPhone;

  ProviderSubscription<LoginState>? _sub;

  String _selectedDialCode = '+91';
  String _selectedFlag = '🇮🇳';

  // ✅ native channel
  static const MethodChannel _native = MethodChannel('sim_info');

  bool _openingSystemRole = false;
  bool _askedOnce = false;

  // ---- SIM MATCH STATE ----
  bool loaded = false;
  bool anySimHasNumber = false;
  bool numberMatch = false;
  List<SimCard> sims = [];
  int? matchedSlotIndex; // 0=SIM1, 1=SIM2 (uiIndex)
  bool _simVerifyTriggered = false;

  // ---- BUTTON LOADING ----
  bool _buttonLoading = false;

  // ---------------- PERMISSION ----------------
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
  Future<bool> ensurePhonePermissionStrict() async {
    final status = await Permission.phone.status;
    if (status.isGranted) return true;

    final req = await Permission.phone.request();
    if (req.isGranted) return true;

    if (req.isPermanentlyDenied) {
      await openAppSettings();
    }
    return false;
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
      final ok = await ensurePhonePermissionStrict();
      if (!ok) {
        AppSnackBar.error(context, "Phone permission required");
        return;
      }

      final overlayOk = await CallerIdRoleHelper.isOverlayGranted();
      if (!overlayOk) await CallerIdRoleHelper.requestOverlayPermission();

      await CallerIdRoleHelper.maybeAskOnce(ref: ref);
    });


    // ✅ keep listener (optional for errors)
    _sub = ref.listenManual<LoginState>(loginNotifierProvider, (prev, next) {
      if (!mounted) return;

      if (prev?.error != next.error && next.error != null) {
        AppSnackBar.error(context, next.error!);
      }
    });
  }

  /// IMPORTANT: resumed ல auto-open செய்யாதீங்க (double popup stop)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await Future.delayed(const Duration(milliseconds: 400));
      final ok = await _isDefaultCallerIdApp();
      debugPrint("🔁 resumed default ok? $ok");
      if (ok) _askedOnce = true;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sub?.close();
    mobileNumberController.dispose();
    super.dispose();
  }

  // ---------------- PHONE FORMAT ----------------
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

  // ---------------- COUNTRY PICKER ----------------
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

  // ---------------- SIM UTILS (same as MobileNumberVerify) ----------------
  String _normalizeNumber(String num) {
    var n = num.replaceAll(RegExp(r'\D'), '');
    if (n.length > 10) {
      n = n.substring(n.length - 10);
    }
    return n;
  }

  int _uiIndexFromSlot(int? slotIndex, int listIndex) {
    if (slotIndex == null) return listIndex.clamp(0, 1);
    if (slotIndex == 0 || slotIndex == 1) return slotIndex;
    if (slotIndex == 2) return 1;
    if (slotIndex <= 0) return 0;
    return 1;
  }

  Future<void> _loadSimInfoFor(String enteredPhone) async {
    try {
      var hasPermission = await MobileNumber.hasPhonePermission;

      if (!hasPermission) {
        await MobileNumber.requestPhonePermission;
        hasPermission = await MobileNumber.hasPhonePermission;
      }

      if (!hasPermission) {
        if (!mounted) return;
        setState(() {
          loaded = true;
          anySimHasNumber = false;
          numberMatch = false;
          matchedSlotIndex = null;
          sims = [];
        });
        return;
      }

      final simCards = await MobileNumber.getSimCards;
      sims = simCards ?? [];
      matchedSlotIndex = null;

      bool localAnySimHasNumber = false;
      final loginNorm = _normalizeNumber(enteredPhone.trim());

      for (int i = 0; i < sims.length; i++) {
        final sim = sims[i];

        final raw = (sim.number ?? '').trim();
        final norm = _normalizeNumber(raw);
        final slot = sim.slotIndex;
        final uiIndex = _uiIndexFromSlot(slot, i);

        if (norm.isNotEmpty) {
          localAnySimHasNumber = true;

          if (norm == loginNorm) {
            matchedSlotIndex = uiIndex; // 0=SIM1, 1=SIM2
          }
        }
      }

      if (!mounted) return;
      setState(() {
        anySimHasNumber = localAnySimHasNumber;
        numberMatch = matchedSlotIndex != null;
        loaded = true;
      });
    } catch (e, st) {
      debugPrint("❌ SIM Load Error: $e");
      debugPrint("$st");
      if (!mounted) return;
      setState(() {
        loaded = true;
        numberMatch = false;
        matchedSlotIndex = null;
      });
    }
  }

  // ---------------- DIRECT SIM VERIFY (SIM1 only) ----------------
  Future<void> _triggerSimVerifyDirect({
    required String rawPhone,
    required String simToken,
  }) async
  {
    if (_simVerifyTriggered) return;
    _simVerifyTriggered = true;

    final notifier = ref.read(mobileVerifyProvider.notifier);

    await notifier.mobileVerify(
      contact: rawPhone.trim(),
      simToken: simToken,
      purpose: 'LOGIN',
    );

    if (!mounted) return;

    final mvState = ref.read(mobileVerifyProvider);

    if (mvState.error != null) {
      AppSnackBar.error(context, mvState.error!);
      _simVerifyTriggered = false; // allow retry
      return;
    }

    final simResponse = mvState.simVerifyResponse;
    if (simResponse != null && simResponse.data.simVerified == true) {
      if (simResponse.data.isNewOwner == true) {
        context.go(AppRoutes.privacyPolicyPath);
      } else {
        context.go(AppRoutes.homePath);
      }
    } else {
      // SIM verify failed -> OTP
      context.pushNamed(AppRoutes.otp, extra: rawPhone);
    }
  }

  // ---------------- VERIFY NOW CLICK (MAIN LOGIC) ----------------
  Future<void> _onVerifyNow() async {
    final formatted = mobileNumberController.text.trim();
    final rawPhone = formatted.replaceAll(' ', '');

    if (rawPhone.isEmpty) {
      AppSnackBar.info(context, 'Please enter phone number');
      return;
    }
    if (rawPhone.length != 10) {
      AppSnackBar.info(context, 'Please enter a valid 10-digit number');
      return;
    }

    _lastRawPhone = rawPhone;

    setState(() => _buttonLoading = true);

    // 1) load sim info for entered phone
    await _loadSimInfoFor(rawPhone);

    if (!mounted) return;

    // 2) if SIM1 matched -> direct SIM verify with loader on same button
    final bool sim1Matched = (numberMatch == true && matchedSlotIndex == 0);

    if (sim1Matched) {
      final fullPhone = '$_selectedDialCode$rawPhone';
      final simToken = generateSimToken(fullPhone);

      await _triggerSimVerifyDirect(rawPhone: rawPhone, simToken: simToken);

      if (!mounted) return;
      setState(() => _buttonLoading = false);
      return;
    }

    // 3) otherwise -> OTP screen
    setState(() => _buttonLoading = false);
    context.pushNamed(AppRoutes.otp, extra: rawPhone);
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginNotifierProvider);
    final mvState = ref.watch(mobileVerifyProvider);

    final bool showLoader =
        _buttonLoading || loginState.isLoading || mvState.isLoading;

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

                        // phone input
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

                        // ✅ Verify button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: CommonContainer.button2(
                            width: double.infinity,
                            loader: showLoader ? const ThreeDotsLoader() : null,
                            onTap: showLoader ? null : _onVerifyNow,
                            text: 'Verify Now',
                          ),
                        ),

                        const SizedBox(height: 12),

                        // (optional) tiny helper text
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: Text(
                            'If your number is in SIM1, we will verify automatically.\nOtherwise you will be redirected to OTP verification.',
                            style: GoogleFont.Mulish(
                              fontSize: 12,
                              color: AppColor.darkGrey,
                              fontWeight: FontWeight.w500,
                            ),
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

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:mobile_number/mobile_number.dart';
// import 'package:mobile_number/sim_card.dart';
//
// import '../../../../../Core/Utility/google_font.dart';
// import '../../../../../Core/Utility/app_Images.dart';
// import '../../../../../Core/Utility/app_color.dart';
// import '../../../../../Core/Utility/app_loader.dart';
// import '../../../../../Core/app_go_routes.dart';
// import '../../Login Screen/Controller/login_notifier.dart';
// import '../Controller/mobile_verify_notifier.dart';
//
// class MobileNumberVerify extends ConsumerStatefulWidget {
//   final String loginNumber;
//   final String simToken;
//
//   const MobileNumberVerify({
//     super.key,
//     required this.loginNumber,
//     required this.simToken,
//   });
//
//   @override
//   ConsumerState<MobileNumberVerify> createState() => _MobileNumberVerifyState();
// }
//
// class _MobileNumberVerifyState extends ConsumerState<MobileNumberVerify> {
//   bool numberMatch = false;
//   bool loaded = false;
//   bool _otpTriggered = false;
//
//   List<SimCard> sims = [];
//   int? matchedSlotIndex; // uiIndex (0 = SIM1 card, 1 = SIM2 card)
//   bool anySimHasNumber = false;
//   bool _otpLoading = false;
//
//   bool _simVerifyTriggered = false;
//
//   @override
//   void initState() {
//     super.initState();
//     loadSimInfo();
//   }
//
//   String _normalizeNumber(String num) {
//     var n = num.replaceAll(RegExp(r'\D'), '');
//     if (n.length > 10) {
//       n = n.substring(n.length - 10);
//     }
//     return n;
//   }
//
//   int _uiIndexFromSlot(int? slotIndex, int listIndex) {
//     if (slotIndex == null) return listIndex.clamp(0, 1);
//     if (slotIndex == 0 || slotIndex == 1) return slotIndex;
//     if (slotIndex == 2) return 1;
//     if (slotIndex <= 0) return 0;
//     return 1;
//   }
//
//   SimCard? _simForUiSlot(int uiIndex) {
//     for (int i = 0; i < sims.length; i++) {
//       final sim = sims[i];
//       final ui = _uiIndexFromSlot(sim.slotIndex, i);
//       if (ui == uiIndex) return sim;
//     }
//     return null;
//   }
//
//   Future<void> loadSimInfo() async {
//     try {
//       var hasPermission = await MobileNumber.hasPhonePermission;
//
//       if (!hasPermission) {
//         await MobileNumber.requestPhonePermission;
//         hasPermission = await MobileNumber.hasPhonePermission;
//       }
//
//       if (!hasPermission) {
//         if (!mounted) return;
//         setState(() {
//           loaded = true;
//           anySimHasNumber = false;
//           numberMatch = false;
//         });
//         return;
//       }
//
//       final simCards = await MobileNumber.getSimCards;
//       sims = simCards ?? [];
//       matchedSlotIndex = null;
//
//       bool localAnySimHasNumber = false;
//
//       final loginNorm = _normalizeNumber(widget.loginNumber.trim());
//
//       debugPrint("=== LOGIN NUMBER ===");
//       debugPrint("RAW        : ${widget.loginNumber}");
//       debugPrint("NORMALIZED : $loginNorm");
//       debugPrint("\n=== DEVICE SIM INFO ===");
//
//       for (int i = 0; i < sims.length; i++) {
//         final sim = sims[i];
//
//         final raw = (sim.number ?? '').trim();
//         final norm = _normalizeNumber(raw);
//         final carrier = (sim.carrierName ?? sim.displayName ?? "").trim();
//         final slot = sim.slotIndex;
//         final uiIndex = _uiIndexFromSlot(slot, i);
//
//         debugPrint("""
// -------------------------
// SIM (list index): $i
// UI Slot Index   : $uiIndex  (0 = SIM1 card, 1 = SIM2 card)
// Carrier         : $carrier
// RAW Number      : "$raw"
// Normalized      : "$norm"
// Slot Index      : $slot
// -------------------------
// """);
//
//         if (norm.isNotEmpty) {
//           localAnySimHasNumber = true;
//
//           if (norm == loginNorm) {
//             matchedSlotIndex = uiIndex;
//             debugPrint(" MATCH FOUND → uiIndex = $matchedSlotIndex");
//           }
//         } else {
//           debugPrint(
//             "❗ SIM uiIndex=$uiIndex has NO readable number (Number Hidden)",
//           );
//         }
//       }
//
//       if (!mounted) return;
//       setState(() {
//         anySimHasNumber = localAnySimHasNumber;
//         numberMatch = matchedSlotIndex != null;
//         loaded = true;
//       });
//
//       // ✅ ONLY SIM1 (uiIndex 0) should auto verify with no OTP
//       if (numberMatch && matchedSlotIndex == 0) {
//         _triggerSimVerify();
//       }
//
//       // ✅ SIM2 matched (uiIndex 1) -> do NOT auto verify.
//       // User must click "Verify by OTP"
//     } catch (e, st) {
//       debugPrint("❌ SIM Load Error: $e");
//       debugPrint("$st");
//       if (!mounted) return;
//       setState(() => loaded = true);
//     }
//   }
//
//   // ✅ NEW: Clear any stale error/response BEFORE sending OTP
//   void _clearLoginStateBeforeOtp() {
//     // This prevents "first click stays same screen, second click navigates"
//     // because stale error can block first attempt.
//     ref.read(loginNotifierProvider.notifier).resetState();
//   }
//
//   Future<bool> _sendOtpIfNeeded() async {
//     if (_otpTriggered) return true;
//     _otpTriggered = true;
//
//     // ✅ clear old state first (important)
//     _clearLoginStateBeforeOtp();
//
//     final loginNotifier = ref.read(loginNotifierProvider.notifier);
//
//     await loginNotifier.loginUser(
//       phoneNumber: widget.loginNumber.trim(),
//       simToken: widget.simToken,
//     );
//
//     if (!mounted) return false;
//
//     final loginState = ref.read(loginNotifierProvider);
//
//     if (loginState.error != null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(loginState.error!)));
//       _otpTriggered = false; // allow retry
//       return false;
//     }
//
//     // ✅ Stronger success check: ensure response is present
//     if (loginState.loginResponse == null) {
//       _otpTriggered = false;
//       return false;
//     }
//
//     return true;
//   }
//
//   Future<void> _triggerSimVerify() async {
//     if (_simVerifyTriggered) return;
//     _simVerifyTriggered = true;
//
//     final notifier = ref.read(mobileVerifyProvider.notifier);
//
//     await notifier.mobileVerify(
//       contact: widget.loginNumber.trim(),
//       simToken: widget.simToken,
//       purpose: 'LOGIN',
//     );
//
//     if (!mounted) return;
//
//     final state = ref.read(mobileVerifyProvider);
//
//     if (state.error != null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(state.error!)));
//       return;
//     }
//
//     final simResponse = state.simVerifyResponse;
//     if (simResponse != null && simResponse.data.simVerified == true) {
//       if (simResponse.data.isNewOwner == true) {
//         context.go(AppRoutes.privacyPolicyPath);
//       } else {
//         context.go(AppRoutes.homePath);
//       }
//     } else {
//       // ✅ SIM verify failed -> go OTP screen
//       context.pushNamed(AppRoutes.otp, extra: widget.loginNumber);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final simState = ref.watch(mobileVerifyProvider);
//
//     final bool isSim1 = matchedSlotIndex == 0;
//     final bool allowOtp = !isSim1; // ✅ SIM1 => false, SIM2/others => true
//
//     final otpButtonColor = (!allowOtp || simState.isLoading || _otpLoading)
//         ? AppColor.blue
//         : AppColor.blue;
//
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
//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               bottom: 100,
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.only(bottom: 20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(left: 35, top: 50),
//                       child: Image.asset(AppImages.logo, height: 88, width: 85),
//                     ),
//                     const SizedBox(height: 60),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 35, top: 20),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Text(
//                                 'Please Wait Verifying',
//                                 style: GoogleFont.Mulish(
//                                   fontWeight: FontWeight.w800,
//                                   fontSize: 24,
//                                   color: AppColor.darkBlue,
//                                 ),
//                               ),
//                               const SizedBox(width: 5),
//                               Text(
//                                 'the',
//                                 style: GoogleFont.Mulish(
//                                   fontSize: 24,
//                                   color: AppColor.darkBlue,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Text(
//                             'Mobile Number is in Mobile',
//                             style: GoogleFont.Mulish(
//                               fontSize: 24,
//                               color: AppColor.darkBlue,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 35),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 35),
//                       child: Stack(
//                         children: [
//                           Image.asset(AppImages.simBCImage, height: 208),
//                           Positioned(
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 vertical: 30,
//                                 horizontal: 20,
//                               ),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Expanded(child: Center(child: _simWidget(0))),
//                                   const SizedBox(width: 8),
//                                   Expanded(child: Center(child: _simWidget(1))),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 35),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           if (!loaded)
//                             Text(
//                               "Checking SIM details from your device...",
//                               style: GoogleFont.Mulish(
//                                 fontSize: 14,
//                                 color: Colors.black87,
//                               ),
//                             )
//                           else if (matchedSlotIndex == 0)
//                             Text(
//                               simState.isLoading
//                                   ? "SIM1 matched. Verifying with server..."
//                                   : "SIM1 matched with this mobile.",
//                               style: GoogleFont.Mulish(
//                                 fontSize: 14,
//                                 color: Colors.green.shade700,
//                               ),
//                             )
//                           else if (matchedSlotIndex == 1)
//                             Text(
//                               "SIM2 matched. Please click 'Verify by OTP' to continue.",
//                               style: GoogleFont.Mulish(
//                                 fontSize: 14,
//                                 color: Colors.orange.shade800,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             )
//                           else
//                             Text(
//                               anySimHasNumber
//                                   ? "This mobile number is not available in this device. Please verify using OTP."
//                                   : "Your device is not exposing SIM numbers. Please verify using OTP.",
//                               style: const TextStyle(
//                                 color: Colors.red,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           if (simState.error != null) ...[
//                             const SizedBox(height: 8),
//                             Text(
//                               simState.error!,
//                               style: const TextStyle(
//                                 color: Colors.red,
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 25),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 35),
//                       child: Row(
//                         children: [
//                           InkWell(
//                             borderRadius: BorderRadius.circular(15),
//                             onTap: simState.isLoading
//                                 ? null
//                                 : () => context.pop(),
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: AppColor.iceBlue,
//                                 borderRadius: BorderRadius.circular(15),
//                               ),
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 34,
//                                 vertical: 22,
//                               ),
//                               child: Text(
//                                 'Back',
//                                 style: GoogleFont.Mulish(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w800,
//                                   color: AppColor.darkBlue,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 15),
//                           Expanded(
//                             child: InkWell(
//                               borderRadius: BorderRadius.circular(15),
//                               onTap:
//                                   (!allowOtp ||
//                                       simState.isLoading ||
//                                       _otpLoading)
//                                   ? null
//                                   : () async {
//                                       setState(() => _otpLoading = true);
//
//                                       final ok = await _sendOtpIfNeeded();
//
//                                       if (!mounted) return;
//                                       setState(() => _otpLoading = false);
//
//                                       if (!ok) return;
//
//                                       // ✅ 1st click itself will navigate now
//                                       context.pushNamed(
//                                         AppRoutes.otp,
//                                         extra: widget.loginNumber,
//                                       );
//                                     },
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   color: otpButtonColor,
//                                   borderRadius: BorderRadius.circular(15),
//                                 ),
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 22,
//                                 ),
//                                 child: Center(
//                                   child: _otpLoading
//                                       ? ThreeDotsLoader()
//                                       : Text(
//                                           'Verify by OTP',
//                                           style: GoogleFont.Mulish(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w800,
//                                             color: AppColor.white,
//                                           ),
//                                         ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
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
//             if (simState.isLoading)
//               Container(
//                 color: Colors.black.withOpacity(0.3),
//                 child: const Center(child: CircularProgressIndicator()),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _simWidget(int index) {
//     if (!numberMatch) return _buildEmptySimCard(index + 1);
//
//     final SimCard? sim = _simForUiSlot(index);
//     if (sim == null) return _buildEmptySimCard(index + 1);
//
//     final bool isMatched = matchedSlotIndex == index;
//
//     String operatorName = ((sim.carrierName ?? sim.displayName) ?? '').trim();
//     final bool hasOperatorName = operatorName.isNotEmpty;
//
//     final rawNumber = (sim.number ?? '').trim();
//     final normalizedNumber = rawNumber.isNotEmpty
//         ? _normalizeNumber(rawNumber)
//         : '';
//     String maskedNumber = '';
//
//     if (normalizedNumber.length >= 4) {
//       maskedNumber =
//           '•••• ${normalizedNumber.substring(normalizedNumber.length - 4)}';
//     }
//
//     final bool hasSimCard = hasOperatorName || normalizedNumber.isNotEmpty;
//     if (!hasSimCard) operatorName = 'No SIM';
//
//     return Opacity(
//       opacity: hasSimCard ? 1.0 : 0.4,
//       child: Stack(
//         children: [
//           ColorFiltered(
//             colorFilter: isMatched
//                 ? const ColorFilter.mode(Colors.transparent, BlendMode.srcOver)
//                 : ColorFilter.mode(
//                     Colors.grey.withOpacity(0.4),
//                     BlendMode.srcATop,
//                   ),
//             child: Image.asset(
//               AppImages.simImage,
//               height: 150,
//               fit: BoxFit.contain,
//             ),
//           ),
//           Positioned.fill(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 35),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Text(
//                     'SIM ${index + 1}',
//                     style: GoogleFont.Mulish(
//                       fontSize: 16,
//                       fontWeight: isMatched ? FontWeight.w800 : FontWeight.w600,
//                       color: AppColor.darkBlue,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     operatorName,
//                     textAlign: TextAlign.center,
//                     style: GoogleFont.Mulish(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       color: isMatched ? AppColor.skyBlue : AppColor.darkBlue,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   if (maskedNumber.isNotEmpty)
//                     Text(
//                       maskedNumber,
//                       style: GoogleFont.Mulish(
//                         fontSize: 13,
//                         color: Colors.black87,
//                       ),
//                     )
//                   else if (hasOperatorName && normalizedNumber.isEmpty)
//                     Text(
//                       'Number Hidden',
//                       style: GoogleFont.Mulish(
//                         fontSize: 13,
//                         color: Colors.black54,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmptySimCard(int simIndex) {
//     return Opacity(
//       opacity: 0.4,
//       child: Stack(
//         children: [
//           Image.asset(AppImages.simImage, height: 150, fit: BoxFit.contain),
//           Positioned.fill(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 35),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Text(
//                     'SIM $simIndex',
//                     style: GoogleFont.Mulish(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: AppColor.darkBlue,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     'No SIM',
//                     textAlign: TextAlign.center,
//                     style: GoogleFont.Mulish(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       color: AppColor.darkBlue,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
