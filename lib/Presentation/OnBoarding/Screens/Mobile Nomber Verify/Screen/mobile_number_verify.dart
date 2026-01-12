// ===============================
// MobileNumberVerify.dart (FULL)
// ===============================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:mobile_number/sim_card.dart';

import '../../../../../Core/Utility/google_font.dart';
import '../../../../../Core/Utility/app_Images.dart';
import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/app_loader.dart';
import '../../../../../Core/app_go_routes.dart';
import '../../Login Screen/Controller/login_notifier.dart';
import '../Controller/mobile_verify_notifier.dart';

class MobileNumberVerify extends ConsumerStatefulWidget {
  final String loginNumber;
  final String simToken;

  const MobileNumberVerify({
    super.key,
    required this.loginNumber,
    required this.simToken,
  });

  @override
  ConsumerState<MobileNumberVerify> createState() => _MobileNumberVerifyState();
}

class _MobileNumberVerifyState extends ConsumerState<MobileNumberVerify> {
  bool numberMatch = false;
  bool loaded = false;
  bool _otpTriggered = false;

  List<SimCard> sims = [];
  int? matchedSlotIndex; // uiIndex (0 = SIM1 card, 1 = SIM2 card)
  bool anySimHasNumber = false;
  bool _otpLoading = false;

  bool _simVerifyTriggered = false;

  @override
  void initState() {
    super.initState();
    loadSimInfo();
  }

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

  SimCard? _simForUiSlot(int uiIndex) {
    for (int i = 0; i < sims.length; i++) {
      final sim = sims[i];
      final ui = _uiIndexFromSlot(sim.slotIndex, i);
      if (ui == uiIndex) return sim;
    }
    return null;
  }

  Future<void> loadSimInfo() async {
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
        });
        return;
      }

      final simCards = await MobileNumber.getSimCards;
      sims = simCards ?? [];
      matchedSlotIndex = null;

      bool localAnySimHasNumber = false;

      final loginNorm = _normalizeNumber(widget.loginNumber.trim());

      debugPrint("=== LOGIN NUMBER ===");
      debugPrint("RAW        : ${widget.loginNumber}");
      debugPrint("NORMALIZED : $loginNorm");
      debugPrint("\n=== DEVICE SIM INFO ===");

      for (int i = 0; i < sims.length; i++) {
        final sim = sims[i];

        final raw = (sim.number ?? '').trim();
        final norm = _normalizeNumber(raw);
        final carrier = (sim.carrierName ?? sim.displayName ?? "").trim();
        final slot = sim.slotIndex;
        final uiIndex = _uiIndexFromSlot(slot, i);

        debugPrint("""
-------------------------
SIM (list index): $i
UI Slot Index   : $uiIndex  (0 = SIM1 card, 1 = SIM2 card)
Carrier         : $carrier
RAW Number      : "$raw"
Normalized      : "$norm"
Slot Index      : $slot
-------------------------
""");

        if (norm.isNotEmpty) {
          localAnySimHasNumber = true;

          if (norm == loginNorm) {
            matchedSlotIndex = uiIndex;
            debugPrint(" MATCH FOUND → uiIndex = $matchedSlotIndex");
          }
        } else {
          debugPrint(
            "❗ SIM uiIndex=$uiIndex has NO readable number (Number Hidden)",
          );
        }
      }

      if (!mounted) return;
      setState(() {
        anySimHasNumber = localAnySimHasNumber;
        numberMatch = matchedSlotIndex != null;
        loaded = true;
      });

      // ✅ ONLY SIM1 (uiIndex 0) should auto verify with no OTP
      if (numberMatch && matchedSlotIndex == 0) {
        _triggerSimVerify();
      }

      // ✅ SIM2 matched (uiIndex 1) -> do NOT auto verify.
      // User must click "Verify by OTP"
    } catch (e, st) {
      debugPrint("❌ SIM Load Error: $e");
      debugPrint("$st");
      if (!mounted) return;
      setState(() => loaded = true);
    }
  }

  // ✅ NEW: Clear any stale error/response BEFORE sending OTP
  void _clearLoginStateBeforeOtp() {
    // This prevents "first click stays same screen, second click navigates"
    // because stale error can block first attempt.
    ref.read(loginNotifierProvider.notifier).resetState();
  }

  Future<bool> _sendOtpIfNeeded() async {
    if (_otpTriggered) return true;
    _otpTriggered = true;

    // ✅ clear old state first (important)
    _clearLoginStateBeforeOtp();

    final loginNotifier = ref.read(loginNotifierProvider.notifier);

    await loginNotifier.loginUser(
      phoneNumber: widget.loginNumber.trim(),
      simToken: widget.simToken,
    );

    if (!mounted) return false;

    final loginState = ref.read(loginNotifierProvider);

    if (loginState.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loginState.error!)));
      _otpTriggered = false; // allow retry
      return false;
    }

    // ✅ Stronger success check: ensure response is present
    if (loginState.loginResponse == null) {
      _otpTriggered = false;
      return false;
    }

    return true;
  }

  Future<void> _triggerSimVerify() async {
    if (_simVerifyTriggered) return;
    _simVerifyTriggered = true;

    final notifier = ref.read(mobileVerifyProvider.notifier);

    await notifier.mobileVerify(
      contact: widget.loginNumber.trim(),
      simToken: widget.simToken,
      purpose: 'LOGIN',
    );

    if (!mounted) return;

    final state = ref.read(mobileVerifyProvider);

    if (state.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.error!)));
      return;
    }

    final simResponse = state.simVerifyResponse;
    if (simResponse != null && simResponse.data.simVerified == true) {
      if (simResponse.data.isNewOwner == true) {
        context.go(AppRoutes.privacyPolicyPath);
      } else {
        context.go(AppRoutes.homePath);
      }
    } else {
      // ✅ SIM verify failed -> go OTP screen
      context.pushNamed(AppRoutes.otp, extra: widget.loginNumber);
    }
  }

  @override
  Widget build(BuildContext context) {
    final simState = ref.watch(mobileVerifyProvider);

    final bool isSim1 = matchedSlotIndex == 0;
    final bool allowOtp = !isSim1; // ✅ SIM1 => false, SIM2/others => true

    final otpButtonColor = (!allowOtp || simState.isLoading || _otpLoading)
        ? AppColor.blue
        : AppColor.blue;

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
              bottom: 100,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 35, top: 50),
                      child: Image.asset(AppImages.logo, height: 88, width: 85),
                    ),
                    const SizedBox(height: 60),
                    Padding(
                      padding: const EdgeInsets.only(left: 35, top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Please Wait Verifying',
                                style: GoogleFont.Mulish(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 24,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'the',
                                style: GoogleFont.Mulish(
                                  fontSize: 24,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Mobile Number is in Mobile',
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
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: Stack(
                        children: [
                          Image.asset(AppImages.simBCImage, height: 208),
                          Positioned(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 30,
                                horizontal: 20,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Center(child: _simWidget(0))),
                                  const SizedBox(width: 8),
                                  Expanded(child: Center(child: _simWidget(1))),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!loaded)
                            Text(
                              "Checking SIM details from your device...",
                              style: GoogleFont.Mulish(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            )
                          else if (matchedSlotIndex == 0)
                            Text(
                              simState.isLoading
                                  ? "SIM1 matched. Verifying with server..."
                                  : "SIM1 matched with this mobile.",
                              style: GoogleFont.Mulish(
                                fontSize: 14,
                                color: Colors.green.shade700,
                              ),
                            )
                          else if (matchedSlotIndex == 1)
                            Text(
                              "SIM2 matched. Please click 'Verify by OTP' to continue.",
                              style: GoogleFont.Mulish(
                                fontSize: 14,
                                color: Colors.orange.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          else
                            Text(
                              anySimHasNumber
                                  ? "This mobile number is not available in this device. Please verify using OTP."
                                  : "Your device is not exposing SIM numbers. Please verify using OTP.",
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (simState.error != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              simState.error!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: Row(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: simState.isLoading
                                ? null
                                : () => context.pop(),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColor.iceBlue,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 34,
                                vertical: 22,
                              ),
                              child: Text(
                                'Back',
                                style: GoogleFont.Mulish(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(15),
                              onTap:
                                  (!allowOtp ||
                                      simState.isLoading ||
                                      _otpLoading)
                                  ? null
                                  : () async {
                                      setState(() => _otpLoading = true);

                                      final ok = await _sendOtpIfNeeded();

                                      if (!mounted) return;
                                      setState(() => _otpLoading = false);

                                      if (!ok) return;

                                      // ✅ 1st click itself will navigate now
                                      context.pushNamed(
                                        AppRoutes.otp,
                                        extra: widget.loginNumber,
                                      );
                                    },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: otpButtonColor,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 22,
                                ),
                                child: Center(
                                  child: _otpLoading
                                      ? ThreeDotsLoader()
                                      : Text(
                                          'Verify by OTP',
                                          style: GoogleFont.Mulish(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: AppColor.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            if (simState.isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _simWidget(int index) {
    if (!numberMatch) return _buildEmptySimCard(index + 1);

    final SimCard? sim = _simForUiSlot(index);
    if (sim == null) return _buildEmptySimCard(index + 1);

    final bool isMatched = matchedSlotIndex == index;

    String operatorName = ((sim.carrierName ?? sim.displayName) ?? '').trim();
    final bool hasOperatorName = operatorName.isNotEmpty;

    final rawNumber = (sim.number ?? '').trim();
    final normalizedNumber = rawNumber.isNotEmpty
        ? _normalizeNumber(rawNumber)
        : '';
    String maskedNumber = '';

    if (normalizedNumber.length >= 4) {
      maskedNumber =
          '•••• ${normalizedNumber.substring(normalizedNumber.length - 4)}';
    }

    final bool hasSimCard = hasOperatorName || normalizedNumber.isNotEmpty;
    if (!hasSimCard) operatorName = 'No SIM';

    return Opacity(
      opacity: hasSimCard ? 1.0 : 0.4,
      child: Stack(
        children: [
          ColorFiltered(
            colorFilter: isMatched
                ? const ColorFilter.mode(Colors.transparent, BlendMode.srcOver)
                : ColorFilter.mode(
                    Colors.grey.withOpacity(0.4),
                    BlendMode.srcATop,
                  ),
            child: Image.asset(
              AppImages.simImage,
              height: 150,
              fit: BoxFit.contain,
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'SIM ${index + 1}',
                    style: GoogleFont.Mulish(
                      fontSize: 16,
                      fontWeight: isMatched ? FontWeight.w800 : FontWeight.w600,
                      color: AppColor.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    operatorName,
                    textAlign: TextAlign.center,
                    style: GoogleFont.Mulish(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isMatched ? AppColor.skyBlue : AppColor.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (maskedNumber.isNotEmpty)
                    Text(
                      maskedNumber,
                      style: GoogleFont.Mulish(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    )
                  else if (hasOperatorName && normalizedNumber.isEmpty)
                    Text(
                      'Number Hidden',
                      style: GoogleFont.Mulish(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySimCard(int simIndex) {
    return Opacity(
      opacity: 0.4,
      child: Stack(
        children: [
          Image.asset(AppImages.simImage, height: 150, fit: BoxFit.contain),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'SIM $simIndex',
                    style: GoogleFont.Mulish(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColor.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'No SIM',
                    textAlign: TextAlign.center,
                    style: GoogleFont.Mulish(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColor.darkBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:mobile_number/mobile_number.dart';
// import 'package:mobile_number/sim_card.dart';
// import 'package:tringo_app/Core/Utility/google_font.dart';
//
// import '../../../../../Core/Utility/app_Images.dart';
// import '../../../../../Core/Utility/app_color.dart';
// import '../../../../../Core/app_go_routes.dart';
// import '../../Login Screen/Controller/login_notifier.dart';
// import '../controller/mobile_verify_notifier.dart';
//
// class MobileNumberVerify extends ConsumerStatefulWidget {
//   final String loginNumber;
//   final String simToken;
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
//   bool numberMatch = false; // true => SIM in this device matches loginNumber
//   bool loaded = false;
//
//   List<SimCard> sims = [];
//   int? matchedSlotIndex; // uiIndex (0 = SIM1 card, 1 = SIM2 card)
//   bool anySimHasNumber = false;
//
//   bool _simVerifyTriggered = false; // to avoid duplicate API calls
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
//     // Map device slot index to UI slot (0 = SIM1, 1 = SIM2)
//     if (slotIndex == null) {
//       return listIndex.clamp(0, 1);
//     }
//
//     if (slotIndex == 0 || slotIndex == 1) {
//       return slotIndex;
//     }
//
//     // Some devices use 1/2 instead of 0/1
//     if (slotIndex == 2) return 1;
//
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
//   //   Future<void> loadSimInfo() async {
//   //     try {
//   //       // 📌 IMPORTANT:
//   //       // Permission should already be handled in LoginMobileNumber screen.
//   //       // Here we ONLY CHECK, we DO NOT REQUEST again.
//   //
//   //       // final hasPermission = await MobileNumber.hasPhonePermission;
//   //       // if (!hasPermission) {
//   //       //   debugPrint(
//   //       //     "⚠️ Phone/SIM permission not granted. Skipping SIM auto-verify.",
//   //       //   );
//   //       //
//   //       //   if (!mounted) return;
//   //       //   setState(() {
//   //       //     loaded = true;
//   //       //     anySimHasNumber = false;
//   //       //     numberMatch = false;
//   //       //   });
//   //       //
//   //       //   // Directly fall back to OTP UI (text + button already there)
//   //       //   return;
//   //       // }
//   //       var hasPermission = await MobileNumber.hasPhonePermission;
//   //
//   //       if (!hasPermission) {
//   //         await MobileNumber.requestPhonePermission;
//   //         hasPermission = await MobileNumber.hasPhonePermission;
//   //       }
//   //
//   //       if (!hasPermission) {
//   //         if (!mounted) return;
//   //         setState(() {
//   //           loaded = true;
//   //           anySimHasNumber = false;
//   //           numberMatch = false;
//   //         });
//   //         return;
//   //       }
//   //
//   //       // ✅ We have permission → proceed with SIM reading
//   //       final simCards = await MobileNumber.getSimCards;
//   //       sims = simCards ?? [];
//   //       matchedSlotIndex = null;
//   //
//   //       bool localAnySimHasNumber = false;
//   //
//   //       final loginNorm = _normalizeNumber(widget.loginNumber.trim());
//   //
//   //       debugPrint("=== LOGIN NUMBER ===");
//   //       debugPrint("RAW        : ${widget.loginNumber}");
//   //       debugPrint("NORMALIZED : $loginNorm");
//   //       debugPrint("\n=== DEVICE SIM INFO ===");
//   //
//   //       for (int i = 0; i < sims.length; i++) {
//   //         final sim = sims[i];
//   //
//   //         final raw = (sim.number ?? '').trim();
//   //         final norm = _normalizeNumber(raw);
//   //         final carrier = (sim.carrierName ?? sim.displayName ?? "").trim();
//   //         final slot = sim.slotIndex;
//   //         final uiIndex = _uiIndexFromSlot(slot, i);
//   //
//   //         debugPrint("""
//   // -------------------------
//   // SIM (list index): $i
//   // UI Slot Index   : $uiIndex  (0 = SIM1 card, 1 = SIM2 card)
//   // Carrier         : $carrier
//   // RAW Number      : "$raw"
//   // Normalized      : "$norm"
//   // Slot Index      : $slot
//   // -------------------------
//   // """);
//   //
//   //         if (norm.isNotEmpty) {
//   //           localAnySimHasNumber = true;
//   //
//   //           if (norm == loginNorm) {
//   //             matchedSlotIndex = uiIndex;
//   //             debugPrint(" MATCH FOUND → uiIndex = $matchedSlotIndex");
//   //           }
//   //         } else {
//   //           debugPrint(
//   //             "❗ SIM uiIndex=$uiIndex has NO readable number (Number Hidden)",
//   //           );
//   //         }
//   //       }
//   //
//   //       if (!mounted) return;
//   //       setState(() {
//   //         anySimHasNumber = localAnySimHasNumber;
//   //         numberMatch =
//   //             matchedSlotIndex != null; // true only if any uiIndex matched
//   //         loaded = true;
//   //       });
//   //
//   //       // // If SIM matches → call backend SIM verification
//   //       // if (numberMatch) {
//   //       //   _triggerSimVerify();
//   //       // }
//   //       // ✅ Only SIM1 (uiIndex 0) should auto verify with no OTP
//   //       if (numberMatch && matchedSlotIndex == 0) {
//   //         _triggerSimVerify();
//   //       }
//   //
//   //       // ✅ If SIM2 matched (uiIndex 1) -> do NOT auto verify.
//   //       // User must click "Verify by OTP"
//   //     } catch (e, st) {
//   //       debugPrint("❌ SIM Load Error: $e");
//   //       debugPrint("$st");
//   //       if (!mounted) return;
//   //       setState(() => loaded = true);
//   //     }
//   //   }
//   //
//   //
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
//           matchedSlotIndex = null;
//         });
//
//         // ✅ Permission இல்லை => OTP only (optional)
//         _sendOtpIfNeeded();
//         return;
//       }
//
//       final simCards = await MobileNumber.getSimCards;
//       sims = simCards ?? [];
//       matchedSlotIndex = null;
//
//       if (sims.isEmpty) {
//         debugPrint("❗ No SIM info available on this device.");
//         if (!mounted) return;
//         setState(() {
//           loaded = true;
//           anySimHasNumber = false;
//           numberMatch = false;
//           matchedSlotIndex = null;
//         });
//
//         // ✅ No sims => OTP only
//         _sendOtpIfNeeded();
//         return;
//       }
//
//       bool localAnySimHasNumber = false;
//       final loginNorm = _normalizeNumber(widget.loginNumber.trim());
//
//       for (int i = 0; i < sims.length; i++) {
//         final sim = sims[i];
//
//         final raw = (sim.number ?? '').trim();
//         final norm = _normalizeNumber(raw);
//         final slot = sim.slotIndex;
//         final uiIndex = _uiIndexFromSlot(slot, i);
//
//         if (norm.isNotEmpty) {
//           localAnySimHasNumber = true;
//
//           if (norm == loginNorm) {
//             matchedSlotIndex = uiIndex; // 0 => SIM1, 1 => SIM2
//           }
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
//       // ✅ RULES:
//       if (matchedSlotIndex == 0) {
//         // ✅ SIM1 matched => SIM verify மட்டும் (NO OTP)
//         _triggerSimVerify();
//       } else {
//         // ✅ SIM2 matched OR no match OR hidden => OTP only
//         // _triggerOtpFlowIfNeeded();
//       }
//     } catch (e, st) {
//       debugPrint("❌ SIM Load Error: $e");
//       debugPrint("$st");
//       if (!mounted) return;
//       setState(() => loaded = true);
//
//       // ✅ Error case => OTP only
//       _sendOtpIfNeeded();
//     }
//   }
//
//   bool _otpTriggered = false; // avoid duplicate otp send
//
//   Future<bool> _sendOtpIfNeeded() async {
//     if (_otpTriggered) return true; // already sent
//     _otpTriggered = true;
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
//       _otpTriggered = false; // ✅ allow retry
//       return false;
//     }
//
//     return true; // ✅ OTP sent success
//   }
//
//   Future<void> _triggerSimVerify() async {
//     if (_simVerifyTriggered) return; // Prevent multiple calls
//     _simVerifyTriggered = true;
//
//     final notifier = ref.read(mobileVerifyProvider.notifier);
//
//     // TODO: replace with real simToken from your native/plugin integration
//     const String simToken = '';
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
//     if (simResponse != null && simResponse.data.simVerified) {
//       // SIM verified successfully → go to Privacy Policy
//       context.go(AppRoutes.privacyPolicyPath);
//     } else {
//       // Backend says SIM not verified → fallback to OTP screen
//       context.pushNamed(AppRoutes.otp, extra: widget.loginNumber);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final simState = ref.watch(mobileVerifyProvider);
//
//     // final otpButtonColor = (numberMatch || simState.isLoading)
//     //     ? Colors.grey.shade400
//     //     : AppColor.blue;
//
//     final bool isSim1 = matchedSlotIndex == 0;
//     final bool allowOtp = !isSim1; // ✅ SIM1 => false, SIM2/others => true
//
//     final otpButtonColor = (!allowOtp || simState.isLoading)
//         ? Colors.grey.shade400
//         : AppColor.blue;
//
//     return Scaffold(
//       body: SafeArea(
//         child: Stack(
//           children: [
//             // Background image
//             Image.asset(
//               AppImages.loginBCImage,
//               width: double.infinity,
//               height: double.infinity,
//               fit: BoxFit.cover,
//             ),
//
//             // Main content
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
//                     // Logo
//                     Padding(
//                       padding: const EdgeInsets.only(left: 35, top: 50),
//                       child: Image.asset(AppImages.logo, height: 88, width: 85),
//                     ),
//
//                     const SizedBox(height: 60),
//
//                     // Title
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
//
//                     const SizedBox(height: 35),
//
//                     // SIM cards
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
//
//                     const SizedBox(height: 20),
//
//                     // Status message: matching / not matching / api error
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 35),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // if (!loaded)
//                           //   Text(
//                           //     "Checking SIM details from your device...",
//                           //     style: GoogleFont.Mulish(
//                           //       fontSize: 14,
//                           //       color: Colors.black87,
//                           //     ),
//                           //   )
//                           // else if (numberMatch)
//                           //   Text(
//                           //     simState.isLoading
//                           //         ? "SIM matched with this mobile. Verifying with server..."
//                           //         : "SIM matched with this mobile.",
//                           //     style: GoogleFont.Mulish(
//                           //       fontSize: 14,
//                           //       color: Colors.green.shade700,
//                           //     ),
//                           //   )
//                           // else if (!numberMatch && loaded)
//                           //   Text(
//                           //     anySimHasNumber
//                           //         ? "This mobile number is not available in this device. Please verify using OTP."
//                           //         : "Your device is not exposing SIM numbers. Please verify using OTP.",
//                           //     style: const TextStyle(
//                           //       color: Colors.red,
//                           //       fontSize: 16,
//                           //       fontWeight: FontWeight.w600,
//                           //     ),
//                           //   ),
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
//
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
//
//                     const SizedBox(height: 25),
//
//                     // Buttons
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
//
//                           const SizedBox(width: 15),
//
//                           Expanded(
//                             child: InkWell(
//                               borderRadius: BorderRadius.circular(15),
//
//                               onTap: (!allowOtp || simState.isLoading)
//                                   ? null
//                                   : () async {
//                                       final ok = await _sendOtpIfNeeded();
//                                       if (!ok) return;
//
//                                       if (!mounted) return;
//                                       context.pushNamed(
//                                         AppRoutes.otp,
//                                         extra: widget.loginNumber,
//                                       );
//                                     },
//                               // onTap: (numberMatch || simState.isLoading)
//                               //     ? null
//                               //     : () {
//                               //         // Go to OTP screen with same mobile number
//                               //         context.pushNamed(
//                               //           AppRoutes.otp,
//                               //           extra: widget.loginNumber,
//                               //         );
//                               //       },
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   color: otpButtonColor,
//                                   borderRadius: BorderRadius.circular(15),
//                                 ),
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 22,
//                                 ),
//                                 child: Center(
//                                   child: Text(
//                                     'Verify by OTP',
//                                     style: GoogleFont.Mulish(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w800,
//                                       color: AppColor.white,
//                                     ),
//                                   ),
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
//
//             // Bottom decoration
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
//
//             // 🔄 API loading overlay (SIM verify)
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
//   /// SIM card widget (index: 0 => SIM1, 1 => SIM2)
//   Widget _simWidget(int index) {
//     // If login number does NOT match any SIM → always show "No SIM"
//     if (!numberMatch) {
//       return _buildEmptySimCard(index + 1);
//     }
//
//     final SimCard? sim = _simForUiSlot(index);
//
//     if (sim == null) {
//       return _buildEmptySimCard(index + 1);
//     }
//
//     final bool isMatched = matchedSlotIndex == index;
//
//     String operatorName = (sim.carrierName ?? sim.displayName ?? '').trim();
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
