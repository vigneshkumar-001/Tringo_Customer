// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:mobile_number/mobile_number.dart';
// import 'package:mobile_number/sim_card.dart';
//
// import 'package:tringo_app/Core/Utility/app_Images.dart';
// import 'package:tringo_app/Core/Utility/app_color.dart';
// import 'package:tringo_app/Core/Utility/google_font.dart';
//
// import '../../../../Core/app_go_routes.dart';
//
// class MobileNumberVerify extends StatefulWidget {
//   final String loginNumber;
//   const MobileNumberVerify({super.key, required this.loginNumber});
//
//   @override
//   State<MobileNumberVerify> createState() => _MobileNumberVerifyState();
// }
//
// class _MobileNumberVerifyState extends State<MobileNumberVerify> {
//   bool numberMatch = false; // true => SIM in this device matches login
//   bool loaded = false;
//
//   List<SimCard> sims = [];
//   int? matchedSlotIndex; // uiIndex (0 = SIM1 card, 1 = SIM2 card)
//   bool anySimHasNumber = false;
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
//   /// Map device slot index to UI slot (0 = SIM1, 1 = SIM2)
//   int _uiIndexFromSlot(int? slotIndex, int listIndex) {
//     if (slotIndex == null) {
//       return listIndex.clamp(0, 1);
//     }
//
//     // Many devices use 0 / 1
//     if (slotIndex == 0) return 0;
//     if (slotIndex == 1) return 1;
//
//     // Some devices use 1 / 2 for slots
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
//   Future<void> loadSimInfo() async {
//     try {
//       if (!await MobileNumber.hasPhonePermission) {
//         await MobileNumber.requestPhonePermission;
//         if (!await MobileNumber.hasPhonePermission) {
//           if (!mounted) return;
//           setState(() {
//             loaded = true;
//             anySimHasNumber = false;
//             numberMatch = false;
//           });
//           return;
//         }
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
//             debugPrint("✅ MATCH FOUND → uiIndex = $matchedSlotIndex");
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
//         numberMatch =
//             matchedSlotIndex != null; // true only if SIM1/SIM2 matched
//         loaded = true;
//       });
//
//       // If SIM matches → skip OTP and go to PrivacyPolicy
//       if (numberMatch) {
//         Future.delayed(const Duration(milliseconds: 800), () {
//           if (!mounted) return;
//           context.go(AppRoutes.privacyPolicyPath);
//         });
//       }
//     } catch (e, st) {
//       debugPrint("❌ SIM Load Error: $e");
//       debugPrint("$st");
//       if (!mounted) return;
//       setState(() => loaded = true);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final otpButtonColor = numberMatch ? Colors.grey.shade400 : AppColor.blue;
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
//
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
//                     const SizedBox(height: 30),
//
//                     // Error message if no match
//                     if (loaded && !numberMatch)
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 35),
//                         child: Text(
//                           anySimHasNumber
//                               ? "This mobile number is not available in this device. Please verify using OTP."
//                               : "Your device is not exposing SIM numbers. Please verify using OTP.",
//                           style: const TextStyle(
//                             color: Colors.red,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
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
//                             onTap: () => context.pop(),
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: AppColor.textWhite,
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
//                               onTap: numberMatch
//                                   ? null
//                                   : () {
//                                       // Go to OTP screen with same mobile number
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
//
//   /// SIM card widget (index: 0 => SIM1, 1 => SIM2)
//   Widget _simWidget(int index) {
//     // 🔴 IMPORTANT:
//     // If login number does NOT match any SIM in this device,
//     // show "No SIM" for both SIM1 and SIM2 cards.
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
//                       color: isMatched ? AppColor.blue : AppColor.darkBlue,
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
