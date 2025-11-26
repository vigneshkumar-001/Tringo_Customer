// import 'package:flutter/material.dart';
//
// import '../../../../Core/Utility/app_Images.dart';
// import '../../../../Core/Utility/app_color.dart';
// import '../../../../Core/Utility/google_font.dart';
// import '../OTP Screen/otp_screen.dart';
//
// class MobileNumberVerify extends StatefulWidget {
//   const MobileNumberVerify({super.key});
//
//   @override
//   State<MobileNumberVerify> createState() => _MobileNumberVerifyState();
// }
//
// class _MobileNumberVerifyState extends State<MobileNumberVerify> {
//
//   @override
//   Widget build(BuildContext context) {
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
//                                 'Please Wait Verifying',
//                                 style: GoogleFont.Mulish(
//                                   fontWeight: FontWeight.w800,
//                                   fontSize: 24,
//                                   color: AppColor.darkBlue,
//                                 ),
//                               ),
//                               SizedBox(width: 5),
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
//                     SizedBox(height: 35),
//
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
//                                 children: [
//                                   Stack(
//                                     children: [
//                                       Image.asset(
//                                         AppImages.simImage,
//                                         height: 150,
//                                         width: 140,
//                                       ),
//                                       Positioned(
//                                         child: Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                             horizontal: 52,
//                                             vertical: 40,
//                                           ),
//                                           child: Column(
//                                             children: [
//                                               Text(
//                                                 'Sim',
//                                                 style: GoogleFont.Mulish(
//                                                   fontSize: 17,
//                                                   color: AppColor.darkBlue,
//                                                 ),
//                                               ),
//                                               Text(
//                                                 '1',
//                                                 style: GoogleFont.Mulish(
//                                                   fontWeight: FontWeight.w700,
//                                                   fontSize: 25,
//                                                   color: AppColor.blue,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//
//                                   Stack(
//                                     children: [
//                                       Image.asset(
//                                         AppImages.simImage,
//                                         height: 150,
//                                         width: 140,
//                                       ),
//                                       Positioned(
//                                         child: Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                             horizontal: 52,
//                                             vertical: 40,
//                                           ),
//                                           child: Column(
//                                             children: [
//                                               Text(
//                                                 'Sim',
//                                                 style: GoogleFont.Mulish(
//                                                   fontSize: 17,
//                                                   color: AppColor.darkBlue,
//                                                 ),
//                                               ),
//                                               Text(
//                                                 '2',
//                                                 style: GoogleFont.Mulish(
//                                                   fontWeight: FontWeight.w700,
//                                                   fontSize: 25,
//                                                   color: AppColor.blue,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
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
//                       child: Row(
//                         children: [
//                           InkWell(
//                             borderRadius: BorderRadius.circular(15),
//                             onTap: () {
//                               Navigator.maybePop(context);
//                             },
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: AppColor.textWhite,
//                                 borderRadius: BorderRadius.circular(15),
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 34,
//                                   vertical: 22,
//                                 ),
//                                 child: Text(
//                                   'Back',
//                                   style: GoogleFont.Mulish(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w800,
//                                     color: AppColor.darkBlue,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//
//                           SizedBox(width: 15),
//
//                           InkWell(
//                             borderRadius: BorderRadius.circular(15),
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => OtpScreen(),
//                                 ),
//                               );
//                             },
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: AppColor.blue,
//                                 borderRadius: BorderRadius.circular(15),
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 40,
//                                   vertical: 22,
//                                 ),
//                                 child: Text(
//                                   'Verify by OTP',
//                                   style: GoogleFont.Mulish(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w800,
//                                     color: AppColor.white,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
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
///new///
///
// import 'package:flutter/material.dart';
// import 'package:mobile_number/mobile_number.dart';
//
// import '../../../../Core/Utility/app_Images.dart';
// import '../../../../Core/Utility/app_color.dart';
// import '../../../../Core/Utility/google_font.dart';
// import '../OTP Screen/otp_screen.dart';
// import '../Privacy Policy/privacy_policy.dart';
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
//   List<String> deviceSimNumbers = [];
//   bool numberMatch = false;
//   bool loaded = false;
//   List<SimCard> sims = [];
//   int? matchedSimIndex;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadSimInfo();
//   }
//
//   String _normalizeNumber(String number) {
//     // Digits mattum vachu, +, -, space, etc remove pannrom
//     var n = number.replaceAll(RegExp(r'\D'), '');
//
//     // India case: end la irukkura last 10 digits thaaan important
//     if (n.length > 10) {
//       n = n.substring(n.length - 10); // e.g. 919876543210 -> 9876543210
//     }
//
//     return n;
//   }
//
//   Future<void> _loadSimInfo() async {
//     try {
//       if (!await MobileNumber.hasPhonePermission) {
//         await MobileNumber.requestPhonePermission;
//       }
//
//       sims = await (MobileNumber.getSimCards ?? []);
//
//       // 🔍 DEBUG PRINT — THIS IS WHERE YOU ADD IT
//       for (var i = 0; i < sims.length; i++) {
//         final raw = (sims[i].number ?? '').trim();
//         final norm = _normalizeNumber(raw);
//         print('SIM ${i + 1} → RAW: $raw  |  NORMALIZED: $norm');
//       }
//
//       deviceSimNumbers = sims
//           .map((sim) => (sim.number ?? '').replaceAll(' ', '').trim())
//           .where((num) => num.isNotEmpty)
//           .toList();
//
//       final normalizedSimNumbers = deviceSimNumbers
//           .map(_normalizeNumber)
//           .toList();
//
//       final userNum = _normalizeNumber(widget.loginNumber);
//
//       matchedSimIndex = null;
//       for (var i = 0; i < normalizedSimNumbers.length; i++) {
//         if (normalizedSimNumbers[i] == userNum) {
//           matchedSimIndex = i;
//           break;
//         }
//       }
//
//       numberMatch = matchedSimIndex != null;
//       loaded = true;
//       setState(() {});
//
//       if (numberMatch) {
//         Future.delayed(const Duration(seconds: 1), () {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => PrivacyPolicy()),
//           );
//         });
//       }
//     } catch (e) {
//       print(e);
//       loaded = true;
//       setState(() {});
//     }
//   }
//
//   ///old///
//   // Future<void> _loadSimInfo() async {
//   //   try {
//   //     // 🔐 Permission check
//   //     if (!await MobileNumber.hasPhonePermission) {
//   //       // Just await the call – don't assign to a variable
//   //       await MobileNumber.requestPhonePermission;
//   //       // or, if your plugin uses a method: await MobileNumber.requestPhonePermission();
//   //     }
//   //
//   //     // 📲 Read SIM info
//   //     List<SimCard> sims = await MobileNumber.getSimCards ?? [];
//   //
//   //     // Raw numbers (for debug)
//   //     deviceSimNumbers = sims
//   //         .map((sim) => (sim.number ?? '').replaceAll(' ', '').trim())
//   //         .where((num) => num.isNotEmpty)
//   //         .toList();
//   //
//   //     // 🔍 Normalize SIM numbers
//   //     final normalizedSimNumbers =
//   //     deviceSimNumbers.map(_normalizeNumber).toList();
//   //
//   //     // User number normalize
//   //     final userNum = _normalizeNumber(widget.loginNumber);
//   //
//   //     print('RAW SIM NUMBERS: $deviceSimNumbers');
//   //     print('NORMALIZED SIM NUMBERS: $normalizedSimNumbers');
//   //     print('USER NUMBER: $userNum');
//   //
//   //     //  Compare
//   //     numberMatch = normalizedSimNumbers.contains(userNum);
//   //
//   //     loaded = true;
//   //     setState(() {});
//   //
//   //     /// AUTO NAVIGATE if number matches
//   //     if (numberMatch) {
//   //       Future.delayed(const Duration(seconds: 1), () {
//   //         Navigator.pushReplacement(
//   //           context,
//   //           MaterialPageRoute(builder: (_) => PrivacyPolicy()),
//   //         );
//   //       });
//   //     }
//   //   } catch (e) {
//   //     print(e);
//   //     loaded = true;
//   //     setState(() {});
//   //   }
//   // }
//
//   @override
//   Widget build(BuildContext context) {
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
//                     Padding(
//                       padding: const EdgeInsets.only(left: 35, top: 50),
//                       child: Image.asset(AppImages.logo, height: 88, width: 85),
//                     ),
//
//                     const SizedBox(height: 60),
//
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
//                     /// SIM Display (UI only)
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
//                                 children: [
//                                   _simWidget("Sim 1"),
//                                   _simWidget("Sim 2"),
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
//                     /// ❗If number does NOT match → show red message
//                     if (loaded && !numberMatch)
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 35),
//                         child: Text(
//                           "This mobile number is not available in this device. Please verify using OTP.",
//                           style: TextStyle(
//                             color: Colors.red,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//
//                     const SizedBox(height: 25),
//
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 35),
//                       child: Row(
//                         children: [
//                           InkWell(
//                             borderRadius: BorderRadius.circular(15),
//                             onTap: () => Navigator.maybePop(context),
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
//                           InkWell(
//                             borderRadius: BorderRadius.circular(15),
//                             onTap: () {
//                               if (!numberMatch) {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (_) => OtpScreen(
//                                       mobileNumber: widget.loginNumber,
//                                     ),
//                                   ),
//                                 );
//                               }
//                             },
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: numberMatch
//                                     ? Colors.grey
//                                     : AppColor.blue,
//                                 borderRadius: BorderRadius.circular(15),
//                               ),
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 40,
//                                 vertical: 22,
//                               ),
//                               child: Text(
//                                 'Verify by OTP',
//                                 style: GoogleFont.Mulish(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w800,
//                                   color: AppColor.white,
//                                 ),
//                               ),
//                             ),
//                           ),
//
//                           // InkWell(
//                           //   borderRadius: BorderRadius.circular(15),
//                           //   onTap: () {
//                           //     if (!numberMatch) {
//                           //       Navigator.push(
//                           //         context,
//                           //         MaterialPageRoute(
//                           //           builder: (_) => OtpScreen(
//                           //             mobileNumber: widget.loginNumber,
//                           //           ),
//                           //         ),
//                           //       );
//                           //     }
//                           //   },
//                           //   child: Container(
//                           //     decoration: BoxDecoration(
//                           //       color: numberMatch
//                           //           ? Colors
//                           //                 .grey // disable OTP if match
//                           //           : AppColor.blue,
//                           //       borderRadius: BorderRadius.circular(15),
//                           //     ),
//                           //     padding: const EdgeInsets.symmetric(
//                           //       horizontal: 40,
//                           //       vertical: 22,
//                           //     ),
//                           //     child: Text(
//                           //       'Verify by OTP',
//                           //       style: GoogleFont.Mulish(
//                           //         fontSize: 16,
//                           //         fontWeight: FontWeight.w800,
//                           //         color: AppColor.white,
//                           //       ),
//                           //     ),
//                           //   ),
//                           // ),
//                         ],
//                       ),
//                     ),
//
//                     // const SizedBox(height: 50),
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
//   Widget _simWidget(String label) {
//     return Stack(
//       children: [
//         Image.asset(AppImages.simImage, height: 150, width: 140),
//         Positioned(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 52, vertical: 40),
//             child: Column(
//               children: [
//                 Text(
//                   'Sim',
//                   style: GoogleFont.Mulish(
//                     fontSize: 17,
//                     color: AppColor.darkBlue,
//                   ),
//                 ),
//                 Text(
//                   label.contains("1") ? '1' : '2',
//                   style: GoogleFont.Mulish(
//                     fontWeight: FontWeight.w700,
//                     fontSize: 25,
//                     color: AppColor.blue,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
///new///
// import 'package:flutter/material.dart';
// import 'package:mobile_number/mobile_number.dart';
//
// import '../../../../Core/Utility/app_Images.dart';
// import '../../../../Core/Utility/app_color.dart';
// import '../../../../Core/Utility/google_font.dart';
// import '../OTP Screen/otp_screen.dart';
// import '../Privacy Policy/privacy_policy.dart';
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
//   List<String> deviceSimNumbers = [];
//   bool numberMatch = false;
//   bool loaded = false;
//   List<SimCard> sims = [];
//   int? matchedSimIndex; // 0 = SIM1, 1 = SIM2, null = no match
//
//   @override
//   void initState() {
//     super.initState();
//     _loadSimInfo();
//   }
//
//   ///  Normalize to last 10 digits (India)
//   String _normalizeNumber(String number) {
//     var n = number.replaceAll(RegExp(r'\D'), '');
//     if (n.length > 10) {
//       n = n.substring(n.length - 10);
//     }
//     return n;
//   }
//
//   Future<void> _loadSimInfo() async {
//     try {
//       // 🔐 Permission check
//       if (!await MobileNumber.hasPhonePermission) {
//         await MobileNumber.requestPhonePermission;
//       }
//
//       // 📲 Get SIM cards
//       sims = await (MobileNumber.getSimCards ?? []);
//
//       // Normalize login number
//       final userNum = _normalizeNumber(widget.loginNumber);
//
//       matchedSimIndex = null;
//
//       for (var i = 0; i < sims.length; i++) {
//         final simNumber = _normalizeNumber((sims[i].number ?? '').trim());
//         if (simNumber == userNum) {
//           matchedSimIndex = i;
//           break;
//         }
//       }
//
//       numberMatch = matchedSimIndex != null;
//       loaded = true;
//       setState(() {});
//
//       // Auto navigate if number found
//       if (numberMatch) {
//         Future.delayed(const Duration(seconds: 1), () {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => PrivacyPolicy()),
//           );
//         });
//       }
//     } catch (e) {
//       print(e);
//       loaded = true;
//       setState(() {});
//     }
//   }
//
//   // Future<void> _loadSimInfo() async {
//   //   try {
//   //     // 🔐 Permission check
//   //     if (!await MobileNumber.hasPhonePermission) {
//   //       await MobileNumber.requestPhonePermission;
//   //     }
//   //
//   //     // 📲 Read SIM info into state variable
//   //     sims = await (MobileNumber.getSimCards ?? []);
//   //
//   //     // 🔍 Debug (optional)
//   //     for (var i = 0; i < sims.length; i++) {
//   //       final raw = (sims[i].number ?? '').trim();
//   //       final norm = _normalizeNumber(raw);
//   //       print('SIM ${i + 1} → RAW: $raw  |  NORMALIZED: $norm');
//   //     }
//   //
//   //     // Raw numbers list
//   //     deviceSimNumbers = sims
//   //         .map((sim) => (sim.number ?? '').replaceAll(' ', '').trim())
//   //         .where((num) => num.isNotEmpty)
//   //         .toList();
//   //
//   //     // Normalize SIM numbers
//   //     final normalizedSimNumbers = deviceSimNumbers
//   //         .map(_normalizeNumber)
//   //         .toList();
//   //
//   //     // Normalize login number
//   //     final userNum = _normalizeNumber(widget.loginNumber);
//   //
//   //     print('LOGIN RAW: ${widget.loginNumber} | NORMALIZED: $userNum');
//   //
//   //     // 🧠 Find which SIM matches
//   //     matchedSimIndex = null;
//   //     for (var i = 0; i < normalizedSimNumbers.length; i++) {
//   //       if (normalizedSimNumbers[i] == userNum) {
//   //         matchedSimIndex = i; // 0 or 1
//   //         break;
//   //       }
//   //     }
//   //
//   //     numberMatch = matchedSimIndex != null;
//   //     loaded = true;
//   //     setState(() {});
//   //
//   //     // ✅ Auto navigate if number found in one of the SIMs
//   //     if (numberMatch) {
//   //       Future.delayed(const Duration(seconds: 1), () {
//   //         Navigator.pushReplacement(
//   //           context,
//   //           MaterialPageRoute(builder: (_) => PrivacyPolicy()),
//   //         );
//   //       });
//   //     }
//   //   } catch (e) {
//   //     print(e);
//   //     loaded = true;
//   //     setState(() {});
//   //   }
//   // }
//
//   @override
//   Widget build(BuildContext context) {
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
//                     // 🔹 Logo
//                     Padding(
//                       padding: const EdgeInsets.only(left: 35, top: 50),
//                       child: Image.asset(AppImages.logo, height: 88, width: 85),
//                     ),
//
//                     const SizedBox(height: 60),
//
//                     // 🔹 Title
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
//                     /// 🔹 SIM Display
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
//                     /// ❗ Number NOT in this device → only show this error (as you asked)
//                     if (loaded && !numberMatch)
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 35),
//                         child: Text(
//                           "This mobile number is not available in this device. Please verify using OTP.",
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
//                     /// 🔹 Buttons
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 35),
//                       child: Row(
//                         children: [
//                           InkWell(
//                             borderRadius: BorderRadius.circular(15),
//                             onTap: () => Navigator.maybePop(context),
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
//                           // OTP button – disabled if match found
//                           InkWell(
//                             borderRadius: BorderRadius.circular(15),
//                             onTap: () {
//                               if (!numberMatch) {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (_) => OtpScreen(
//                                       mobileNumber: widget.loginNumber,
//                                     ),
//                                   ),
//                                 );
//                               }
//                             },
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: numberMatch
//                                     ? Colors.grey
//                                     : AppColor.blue,
//                                 borderRadius: BorderRadius.circular(15),
//                               ),
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 40,
//                                 vertical: 22,
//                               ),
//                               child: Text(
//                                 'Verify by OTP',
//                                 style: GoogleFont.Mulish(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w800,
//                                   color: AppColor.white,
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
//   /// 🔹 SIM Card Widget
//   /// index: 0 = SIM 1, 1 = SIM 2
//   Widget _simWidget(int index) {
//     // Physical SIM irukka-nu check
//     final bool hasPhysicalSim =
//         sims.length > index && ((sims[index].number ?? '').trim().isNotEmpty);
//
//     final SimCard? sim = hasPhysicalSim ? sims[index] : null;
//
//     final bool isMatched = matchedSimIndex == index;
//     final bool noLoginMatch = matchedSimIndex == null;
//
//     final bool showAsNoSim = noLoginMatch || !hasPhysicalSim;
//
//     String operatorName = '';
//     String maskedNumber = '';
//
//     if (!showAsNoSim && sim != null) {
//       operatorName = (sim.carrierName ?? sim.displayName ?? '').trim();
//
//       final rawNumber = (sim.number ?? '').trim();
//       final normalizedNumber = rawNumber.isNotEmpty
//           ? _normalizeNumber(rawNumber)
//           : '';
//
//       if (normalizedNumber.length >= 4) {
//         maskedNumber =
//             '•••• ${normalizedNumber.substring(normalizedNumber.length - 3)}';
//       }
//     }
//
//     return Opacity(
//       opacity: 1.0,
//       child: Stack(
//         children: [
//           // SIM card background – no fixed width
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
//
//           // Text content
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
//                     showAsNoSim
//                         ? 'No SIM'
//                         : (operatorName.isNotEmpty ? operatorName : 'Unknown'),
//                     textAlign: TextAlign.center,
//                     style: GoogleFont.Mulish(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       color: isMatched ? AppColor.blue : AppColor.darkBlue,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   if (!showAsNoSim && maskedNumber.isNotEmpty)
//                     Text(
//                       maskedNumber,
//                       style: GoogleFont.Mulish(
//                         fontSize: 13,
//                         color: Colors.black87,
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
// }

///new1//////
///new2///

// import 'package:flutter/material.dart';
// import 'package:mobile_number/mobile_number.dart';
//
// import '../../../../Core/Utility/app_Images.dart';
// import '../../../../Core/Utility/app_color.dart';
// import '../../../../Core/Utility/google_font.dart';
// import '../OTP Screen/otp_screen.dart';
// import '../Privacy Policy/privacy_policy.dart';
//
// import 'package:flutter/material.dart';
// import 'package:mobile_number/mobile_number.dart';
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
//   List<String> deviceSimNumbers = [];
//   bool numberMatch = false;
//   bool loaded = false;
//   List<SimCard> sims = [];
//   int? matchedSimIndex; // 0 = SIM1, 1 = SIM2, null = no match
//   bool anySimHasNumber = false;
//
//   @override
//   void initState() {
//     super.initState();
//     loadSimInfo();
//   }
//
//   ///  Normalize to last 10 digits (India)
//   // String _normalizeNumber(String number) {
//   //   // Remove all non-digits
//   //   var n = number.replaceAll(RegExp(r'\D'), '');
//   //   // If length > 10, keep only last 10 digits
//   //   if (n.length > 10) {
//   //     n = n.substring(n.length - 10);
//   //   }
//   //   return n;
//   // }
//
//   String _normalizeNumber(String num) {
//     var n = num.replaceAll(RegExp(r'\D'), '');
//     if (n.length > 10) {
//       n = n.substring(n.length - 10);
//     }
//     return n;
//   }
//
//   Future<void> loadSimInfo() async {
//     try {
//       // Request Permission
//       if (!await MobileNumber.hasPhonePermission) {
//         await MobileNumber.requestPhonePermission;
//       }
//
//       // Fetch SIM cards (SIM1, SIM2…)
//       final simCards = await MobileNumber.getSimCards;
//
//       sims = simCards ?? [];
//       matchedSimIndex = null;
//
//       bool localAnySimHasNumber = false;
//
//       // Normalize login number
//       final loginNorm = _normalizeNumber(widget.loginNumber);
//
//       debugPrint("=== LOGIN NUMBER ===");
//       debugPrint("RAW: ${widget.loginNumber}");
//       debugPrint("NORMALIZED: $loginNorm");
//
//       debugPrint("\n=== DEVICE SIM INFO ===");
//
//       for (int i = 0; i < sims.length; i++) {
//         final sim = sims[i];
//
//         final raw = (sim.number ?? '').trim();
//         final norm = _normalizeNumber(raw);
//
//         final carrier = (sim.carrierName ?? sim.displayName ?? "").trim();
//         final hasCarrier = carrier.isNotEmpty;
//
//         debugPrint("""
// -------------------------
// SIM ${i + 1}
// Carrier: $carrier
// RAW Number: $raw
// Normalized: $norm
// Slot Index: ${sim.slotIndex}
// -------------------------
// """);
//
//         // If SIM reports a number, remember that at least 1 SIM has a readable number
//         if (norm.isNotEmpty) {
//           localAnySimHasNumber = true;
//
//           // Match check
//           if (norm == loginNorm) {
//             matchedSimIndex = i;
//             debugPrint("✅ MATCH FOUND → SIM ${i + 1}");
//           }
//         }
//       }
//
//       setState(() {
//         anySimHasNumber = localAnySimHasNumber;
//         numberMatch = matchedSimIndex != null;
//         loaded = true;
//       });
//
//       // Auto navigation if match found
//       if (numberMatch) {
//         Future.delayed(const Duration(milliseconds: 800), () {
//           if (!mounted) return;
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => PrivacyPolicy()),
//           );
//         });
//       }
//     } catch (e, st) {
//       debugPrint("❌ SIM Load Error: $e");
//       debugPrint("$st");
//       setState(() => loaded = true);
//     }
//   }
//
//   // Future<void> _loadSimInfo() async {
//   //   try {
//   //     // 🔐 Permission check
//   //     if (!await MobileNumber.hasPhonePermission) {
//   //       await MobileNumber.requestPhonePermission;
//   //     }
//   //
//   //     // 📲 Get SIM cards
//   //     final List<SimCard>? simCards = await MobileNumber.getSimCards;
//   //     sims = simCards ?? [];
//   //
//   //     // 🔍 Debug + check if any SIM has number
//   //     bool localAnySimHasNumber = false;
//   //
//   //     for (var i = 0; i < sims.length; i++) {
//   //       final raw = (sims[i].number ?? '').trim();
//   //       final norm = _normalizeNumber(raw);
//   //
//   //       if (norm.isNotEmpty) {
//   //         localAnySimHasNumber = true;
//   //       }
//   //
//   //       debugPrint('SIM ${i + 1} → RAW: "$raw" | NORMALIZED: "$norm"');
//   //     }
//   //
//   //     // 🔢 Normalize login number
//   //     final userNum = _normalizeNumber(widget.loginNumber);
//   //     debugPrint('LOGIN RAW: "${widget.loginNumber}" | NORMALIZED: "$userNum"');
//   //
//   //     matchedSimIndex = null;
//   //
//   //     // 🔁 Check all sims (SIM1, SIM2…)
//   //     // This logic ensures that if the number is found in EITHER SIM 1 (i=0) or SIM 2 (i=1), it matches.
//   //     for (var i = 0; i < sims.length; i++) {
//   //       final simRaw = (sims[i].number ?? '').trim();
//   //       final simNorm = _normalizeNumber(simRaw);
//   //
//   //       if (simNorm.isEmpty) continue;
//   //
//   //       if (simNorm == userNum) {
//   //         matchedSimIndex = i; // 0 = SIM1, 1 = SIM2
//   //         debugPrint('✅ MATCH FOUND in SIM ${i + 1}');
//   //         break;
//   //       }
//   //     }
//   //
//   //     setState(() {
//   //       numberMatch = matchedSimIndex != null;
//   //       loaded = true;
//   //       anySimHasNumber =
//   //           localAnySimHasNumber; // store if any sim number was readable
//   //     });
//   //
//   //     // ✅ Auto navigate if matched in any SIM
//   //     if (numberMatch) {
//   //       Future.delayed(const Duration(seconds: 1), () {
//   //         if (!mounted) return;
//   //         Navigator.pushReplacement(
//   //           context,
//   //           MaterialPageRoute(builder: (_) => PrivacyPolicy()),
//   //         );
//   //       });
//   //     }
//   //   } catch (e, st) {
//   //     debugPrint('SIM LOAD ERROR: $e');
//   //     debugPrint('$st');
//   //     setState(() {
//   //       loaded = true;
//   //     });
//   //   }
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     // Determine button color
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
//                     // 🔹 Logo
//                     Padding(
//                       padding: const EdgeInsets.only(left: 35, top: 50),
//                       child: Image.asset(AppImages.logo, height: 88, width: 85),
//                     ),
//
//                     const SizedBox(height: 60),
//
//                     // 🔹 Title
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
//                     /// 🔹 SIM Display
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
//                     /// ❗ Error Message
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
//                     /// 🔹 Buttons
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 35),
//                       child: Row(
//                         children: [
//                           // Back Button
//                           InkWell(
//                             borderRadius: BorderRadius.circular(15),
//                             onTap: () => Navigator.maybePop(context),
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
//                           // OTP button – disabled if match found
//                           Expanded(
//                             child: InkWell(
//                               borderRadius: BorderRadius.circular(15),
//                               onTap: numberMatch
//                                   ? null // Disable if match found
//                                   : () {
//                                       if (!numberMatch) {
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (_) => OtpScreen(
//                                               mobileNumber: widget.loginNumber,
//                                             ),
//                                           ),
//                                         );
//                                       }
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
//   /// 🔹 SIM Card Widget
//   /// index: 0 = SIM 1, 1 = SIM 2
//   Widget _simWidget(int index) {
//     // If this SIM slot itself doesn't exist (e.g., SIM3)
//     if (sims.length <= index) {
//       return _buildEmptySimCard(index + 1);
//     }
//
//     final sim = sims[index];
//     final bool isMatched = matchedSimIndex == index;
//
//     // Operator name (Jio / Airtel / etc…)
//     String operatorName = (sim.carrierName ?? sim.displayName ?? '').trim();
//     final bool hasOperatorName = operatorName.isNotEmpty;
//
//     // Masked number
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
//     // Show 'No SIM' if neither operator nor number is present.
//     if (!hasSimCard) operatorName = 'No SIM';
//
//     return Opacity(
//       // Keep opacity high if SIM is detected (even if number is hidden)
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
//                   // If number is read and masked: show it
//                   if (maskedNumber.isNotEmpty)
//                     Text(
//                       maskedNumber,
//                       style: GoogleFont.Mulish(
//                         fontSize: 13,
//                         color: Colors.black87,
//                       ),
//                     )
//                   // If SIM is detected (has carrier name) but number is empty: show 'Number Hidden'
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
//   /// Empty SIM card UI when slot itself doesn't exist
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

///new3///
//// last code
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:mobile_number/mobile_number.dart';
//
// import '../../../../Core/Utility/app_Images.dart';
// import '../../../../Core/Utility/app_color.dart';
// import '../../../../Core/Utility/google_font.dart';
// import '../OTP Screen/otp_screen.dart';
// import '../Privacy Policy/privacy_policy.dart';
// // your other imports...
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
//   bool numberMatch = false; // true => skip OTP
//   bool loaded = false;
//
//   List<SimCard> sims = []; // all SIMs from plugin
//   int? matchedSlotIndex; // 0 => SIM1 card, 1 => SIM2 card
//   bool anySimHasNumber = false; // at least one SIM exposed a phone number
//
//   @override
//   void initState() {
//     super.initState();
//     loadSimInfo();
//   }
//
//   /// Normalize to last 10 digits (India)
//   String _normalizeNumber(String num) {
//     var n = num.replaceAll(RegExp(r'\D'), '');
//     if (n.length > 10) {
//       n = n.substring(n.length - 10);
//     }
//     return n;
//   }
//
//   /// Convert plugin's slotIndex + list index → UI index (0 = SIM1 card, 1 = SIM2 card)
//   int _uiIndexFromSlot(int? slotIndex, int listIndex) {
//     // If plugin doesn't give slotIndex, fallback to list position
//     if (slotIndex == null) {
//       return listIndex.clamp(0, 1);
//     }
//
//     // Most devices: 0 = SIM1, 1 = SIM2
//     if (slotIndex == 0 || slotIndex == 1) {
//       return slotIndex;
//     }
//
//     // Some devices: 1 = SIM1, 2 = SIM2
//     if (slotIndex == 1) return 0;
//     if (slotIndex == 2) return 1;
//
//     // Any other weird value: force into 0 or 1
//     if (slotIndex <= 0) return 0;
//     return 1;
//   }
//
//   /// uiIndex: 0 -> SIM 1 (left), 1 -> SIM 2 (right)
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
//       // Permission
//       if (!await MobileNumber.hasPhonePermission) {
//         await MobileNumber.requestPhonePermission;
//       }
//
//       // Get SIM list
//       final simCards = await MobileNumber.getSimCards;
//       sims = simCards ?? [];
//       matchedSlotIndex = null;
//
//       bool localAnySimHasNumber = false;
//
//       // Normalize login number
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
//           // ✅ MAIN LOGIC: if login number is in ANY SIM (SIM1 or SIM2)
//           if (norm == loginNorm) {
//             matchedSlotIndex = uiIndex; // highlight that SIM card
//             debugPrint("✅ MATCH FOUND → uiIndex = $matchedSlotIndex");
//           }
//         } else {
//           debugPrint(
//             "❗ SIM uiIndex=$uiIndex has NO readable number (Number Hidden)",
//           );
//         }
//       }
//
//       setState(() {
//         anySimHasNumber = localAnySimHasNumber;
//         numberMatch = matchedSlotIndex != null; // TRUE if any SIM matched
//         loaded = true;
//       });
//
//       // ✅ If SIM1 or SIM2 matched => skip OTP, go next screen
//       if (numberMatch) {
//         Future.delayed(const Duration(milliseconds: 800), () {
//           if (!mounted) return;
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => PrivacyPolicy()),
//           );
//         });
//       }
//     } catch (e, st) {
//       debugPrint("❌ SIM Load Error: $e");
//       debugPrint("$st");
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
//                                   Expanded(
//                                     child: Center(child: _simWidget(0)),
//                                   ), // SIM1
//                                   const SizedBox(width: 8),
//                                   Expanded(
//                                     child: Center(child: _simWidget(1)),
//                                   ), // SIM2
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
//                             onTap: () => Navigator.maybePop(context),
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
//                                   ? null // OTP disabled if SIM1/SIM2 matched
//                                   : () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (_) => OtpScreen(
//                                             mobileNumber: widget.loginNumber,
//                                           ),
//                                         ),
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
// lib/Presentation/OnBoarding/Screens/Login Screen/mobile_number_verify.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_number/mobile_number.dart';

import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Utility/app_color.dart';
import 'package:tringo_app/Core/Utility/google_font.dart';

import '../../../../Core/app_go_routes.dart';

class MobileNumberVerify extends StatefulWidget {
  final String loginNumber;
  const MobileNumberVerify({super.key, required this.loginNumber});

  @override
  State<MobileNumberVerify> createState() => _MobileNumberVerifyState();
}

class _MobileNumberVerifyState extends State<MobileNumberVerify> {
  bool numberMatch = false; // true => skip OTP
  bool loaded = false;

  List<SimCard> sims = [];
  int? matchedSlotIndex;
  bool anySimHasNumber = false;

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
    if (slotIndex == null) {
      return listIndex.clamp(0, 1);
    }

    if (slotIndex == 0 || slotIndex == 1) {
      return slotIndex;
    }

    if (slotIndex == 1) return 0;
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
      if (!await MobileNumber.hasPhonePermission) {
        await MobileNumber.requestPhonePermission;
        if (!await MobileNumber.hasPhonePermission) {
          if (!mounted) return;
          setState(() {
            loaded = true;
            anySimHasNumber = false;
            numberMatch = false;
          });
          return;
        }
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
            debugPrint("✅ MATCH FOUND → uiIndex = $matchedSlotIndex");
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

      // If SIM matches → skip OTP and go to PrivacyPolicy
      if (numberMatch) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (!mounted) return;
          context.go(AppGoRoutes.privacyPolicyPath);
        });
      }
    } catch (e, st) {
      debugPrint("❌ SIM Load Error: $e");
      debugPrint("$st");
      if (!mounted) return;
      setState(() => loaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final otpButtonColor = numberMatch ? Colors.grey.shade400 : AppColor.blue;

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
                    // Logo
                    Padding(
                      padding: const EdgeInsets.only(left: 35, top: 50),
                      child: Image.asset(AppImages.logo, height: 88, width: 85),
                    ),

                    const SizedBox(height: 60),

                    // Title
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

                    // SIM cards
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

                    const SizedBox(height: 30),

                    // Error message if no match
                    if (loaded && !numberMatch)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 35),
                        child: Text(
                          anySimHasNumber
                              ? "This mobile number is not available in this device. Please verify using OTP."
                              : "Your device is not exposing SIM numbers. Please verify using OTP.",
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                    const SizedBox(height: 25),

                    // Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: Row(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () => context.pop(),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColor.textWhite,
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
                              onTap: numberMatch
                                  ? null
                                  : () {
                                      // Go to OTP screen with same mobile number
                                      context.pushNamed(
                                        AppGoRoutes.otp,
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
                                  child: Text(
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
          ],
        ),
      ),
    );
  }

  /// SIM card widget (index: 0 => SIM1, 1 => SIM2)
  Widget _simWidget(int index) {
    final SimCard? sim = _simForUiSlot(index);

    if (sim == null) {
      return _buildEmptySimCard(index + 1);
    }

    final bool isMatched = matchedSlotIndex == index;

    String operatorName = (sim.carrierName ?? sim.displayName ?? '').trim();
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
                      color: isMatched ? AppColor.blue : AppColor.darkBlue,
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

///old///
// class MobileNumberVerify extends StatefulWidget {
//   final String loginNumber;
//   const MobileNumberVerify({super.key, required this.loginNumber});
//
//   @override
//   State<MobileNumberVerify> createState() => _MobileNumberVerifyState();
// }
//
// class _MobileNumberVerifyState extends State<MobileNumberVerify> {
//   List<String> deviceSimNumbers = [];
//   bool numberMatch = false;
//   bool loaded = false;
//   List<SimCard> sims = [];
//   int? matchedSimIndex; // 0 = SIM1, 1 = SIM2, null = no match
//   bool anySimHasNumber = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadSimInfo();
//   }
//
//   /// ✅ Normalize to last 10 digits (India)
//   String _normalizeNumber(String number) {
//     if (number.isEmpty) return '';
//
//     // Remove all non-digits
//     var n = number.replaceAll(RegExp(r'[^\d]'), '');
//
//     // Remove leading 0 or 91 if present
//     if (n.startsWith('91') && n.length > 10) {
//       n = n.substring(2);
//     } else if (n.startsWith('0') && n.length > 10) {
//       n = n.substring(1);
//     }
//
//     // If length > 10, keep only last 10 digits
//     if (n.length > 10) {
//       n = n.substring(n.length - 10);
//     }
//
//     return n;
//   }
//
//   Future<void> _loadSimInfo() async {
//     try {
//       // 🔐 Permission check
//       if (!await MobileNumber.hasPhonePermission) {
//         await MobileNumber.requestPhonePermission;
//       }
//
//       // 📲 Get SIM cards - FIXED: Proper await syntax
//       final List<SimCard>? simCards = await MobileNumber.getSimCards;
//       sims = simCards ?? [];
//
//       // 🔍 Debug + check if any SIM has number
//       bool localAnySimHasNumber = false;
//
//       // Normalize login number first
//       final userNum = _normalizeNumber(widget.loginNumber);
//       debugPrint('LOGIN RAW: "${widget.loginNumber}" | NORMALIZED: "$userNum"');
//
//       // Check all SIMs and log details
//       for (var i = 0; i < sims.length; i++) {
//         final raw = (sims[i].number ?? '').trim();
//         final norm = _normalizeNumber(raw);
//
//         debugPrint('SIM ${i + 1} → RAW: "$raw"  |  NORMALIZED: "$norm"');
//
//         if (norm.isNotEmpty) {
//           localAnySimHasNumber = true;
//         }
//       }
//
//       matchedSimIndex = null;
//
//       // 🔁 Check all sims (SIM1, SIM2…) for match
//       for (var i = 0; i < sims.length; i++) {
//         final simRaw = (sims[i].number ?? '').trim();
//         final simNorm = _normalizeNumber(simRaw);
//
//         if (simNorm.isEmpty) continue;
//
//         debugPrint('Comparing: SIM$i "$simNorm" == USER "$userNum"');
//
//         if (simNorm == userNum) {
//           matchedSimIndex = i; // 0 = SIM1, 1 = SIM2
//           debugPrint('✅ MATCH FOUND in SIM ${i + 1}');
//           break;
//         }
//       }
//
//       setState(() {
//         numberMatch = matchedSimIndex != null;
//         loaded = true;
//         anySimHasNumber = localAnySimHasNumber;
//       });
//
//       // ✅ Auto navigate if matched in any SIM
//       if (numberMatch) {
//         debugPrint('🔄 Auto-navigating to PrivacyPolicy screen');
//         Future.delayed(const Duration(seconds: 1), () {
//           if (mounted) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (_) => PrivacyPolicy()),
//             );
//           }
//         });
//       } else {
//         debugPrint('❌ No SIM match found');
//       }
//     } catch (e, st) {
//       debugPrint('SIM LOAD ERROR: $e');
//       debugPrint('$st');
//       setState(() {
//         loaded = true;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
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
//                     // 🔹 Logo
//                     Padding(
//                       padding: const EdgeInsets.only(left: 35, top: 50),
//                       child: Image.asset(AppImages.logo, height: 88, width: 85),
//                     ),
//
//                     const SizedBox(height: 60),
//
//                     // 🔹 Title
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
//                     /// 🔹 SIM Display
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
//                                 MainAxisAlignment.spaceBetween,
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
//                     /// ❗ Number NOT in this device
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
//                     /// 🔹 Buttons
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 35),
//                       child: Row(
//                         children: [
//                           InkWell(
//                             borderRadius: BorderRadius.circular(15),
//                             onTap: () => Navigator.maybePop(context),
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
//                           // OTP button – disabled if match found
//                           InkWell(
//                             borderRadius: BorderRadius.circular(15),
//                             onTap: () {
//                               if (!numberMatch) {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (_) => OtpScreen(
//                                       mobileNumber: widget.loginNumber,
//                                     ),
//                                   ),
//                                 );
//                               }
//                             },
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: numberMatch
//                                     ? Colors.grey
//                                     : AppColor.blue,
//                                 borderRadius: BorderRadius.circular(15),
//                               ),
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 40,
//                                 vertical: 22,
//                               ),
//                               child: Text(
//                                 'Verify by OTP',
//                                 style: GoogleFont.Mulish(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w800,
//                                   color: AppColor.white,
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
//   /// 🔹 SIM Card Widget
//   /// index: 0 = SIM 1, 1 = SIM 2
//   Widget _simWidget(int index) {
//     // If this SIM slot itself doesn't exist
//     if (sims.length <= index) {
//       return _buildEmptySimCard(index + 1);
//     }
//
//     final sim = sims[index];
//     final bool isMatched = matchedSimIndex == index;
//
//     // Operator name (Jio / Airtel / etc…)
//     String operatorName =
//     (sim.carrierName ?? sim.displayName ?? '').trim();
//     if (operatorName.isEmpty) operatorName = 'Unknown';
//
//     // Masked number
//     final rawNumber = (sim.number ?? '').trim();
//     final normalizedNumber =
//     rawNumber.isNotEmpty ? _normalizeNumber(rawNumber) : '';
//     String maskedNumber = '';
//
//     if (normalizedNumber.length >= 4) {
//       maskedNumber =
//       '•••• ${normalizedNumber.substring(normalizedNumber.length - 4)}';
//     }
//
//     final bool hasAnyInfo =
//         operatorName != 'Unknown' || normalizedNumber.isNotEmpty;
//
//     return Opacity(
//       opacity: hasAnyInfo ? 1.0 : 0.4,
//       child: Stack(
//         children: [
//           ColorFiltered(
//             colorFilter: isMatched
//                 ? const ColorFilter.mode(
//                 Colors.transparent, BlendMode.srcOver)
//                 : ColorFilter.mode(
//               Colors.grey.withOpacity(0.4),
//               BlendMode.srcATop,
//             ),
//             child: Image.asset(
//               AppImages.simImage,
//               height: 150,
//               fit: BoxFit.contain,
//             ),
//           ),
//           Positioned.fill(
//             child: Padding(
//               padding:
//               const EdgeInsets.symmetric(horizontal: 24, vertical: 35),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Text(
//                     'SIM ${index + 1}',
//                     style: GoogleFont.Mulish(
//                       fontSize: 16,
//                       fontWeight:
//                       isMatched ? FontWeight.w800 : FontWeight.w600,
//                       color: AppColor.darkBlue,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     hasAnyInfo ? operatorName : 'No SIM',
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
//   /// Empty SIM card UI when slot itself doesn't exist
//   Widget _buildEmptySimCard(int simIndex) {
//     return Opacity(
//       opacity: 0.4,
//       child: Stack(
//         children: [
//           Image.asset(
//             AppImages.simImage,
//             height: 150,
//             fit: BoxFit.contain,
//           ),
//           Positioned.fill(
//             child: Padding(
//               padding:
//               const EdgeInsets.symmetric(horizontal: 24, vertical: 35),
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
