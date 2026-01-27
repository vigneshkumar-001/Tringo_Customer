import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../../Core/Utility/app_Images.dart';
import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/google_font.dart';
import '../../../../../Core/Widgets/common_container.dart';

class ReceiveScreen extends ConsumerStatefulWidget {
  final String toUid;
  final String amount;

  const ReceiveScreen({super.key, required this.toUid, required this.amount});

  @override
  ConsumerState<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends ConsumerState<ReceiveScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // ✅ QR format (you can change this)
  String get _qrData {
    // example format:
    // tringo://send?touid=xxx&amount=10
    final uid = widget.toUid.trim();
    final amt = widget.amount.trim();

    return "tringo://send?touid=$uid&amount=$amt";
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Copied: $text")));
  }

  @override
  Widget build(BuildContext context) {
    final uid = widget.toUid.trim();
    final amt = widget.amount.trim();

    return Scaffold(
      backgroundColor: AppColor.whiteSmoke,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CommonContainer.leftSideArrow(
                        Color: AppColor.whiteSmoke,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    Text(
                      'Receive TCoin',
                      style: GoogleFont.Mulish(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColor.mildBlack,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 43),

                Container(
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 35,
                      vertical: 45,
                    ),
                    child: Column(
                      children: [
                        // ✅ GENERATED QR CODE
                        QrImageView(
                          data: _qrData,
                          size: 210,
                          backgroundColor: Colors.white,
                        ),

                        const SizedBox(height: 20),

                        Text(
                          'Scan QR',
                          style: GoogleFont.Mulish(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColor.darkBlue,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          '( or )',
                          style: GoogleFont.Mulish(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColor.borderGray,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ✅ UID
                        Text(
                          'Send To UID',
                          style: GoogleFont.Mulish(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColor.blue,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              uid.isEmpty ? "—" : uid,
                              style: GoogleFont.Mulish(
                                fontSize: 13,
                                color: AppColor.darkBlue,
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => _copyText(uid),
                              child: Image.asset(AppImages.uIDBlue, height: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:tringo_app/Core/Utility/app_Images.dart';
//
// import '../../../../../Core/Utility/app_color.dart';
// import '../../../../../Core/Utility/google_font.dart';
// import '../../../../../Core/Widgets/common_container.dart';
//
// class ReceiveScreen extends ConsumerStatefulWidget {
//   const ReceiveScreen({super.key});
//
//   @override
//   ConsumerState<ReceiveScreen> createState() => _ReceiveScreenState();
// }
//
// class _ReceiveScreenState extends ConsumerState<ReceiveScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(vsync: this);
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColor.whiteSmoke,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
//             child: Column(
//               children: [
//                 Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: CommonContainer.leftSideArrow(
//                         Color: AppColor.whiteSmoke,
//                         onTap: () => Navigator.pop(context),
//                       ),
//                     ),
//                     Text(
//                       'Receive TCoin',
//                       style: GoogleFont.Mulish(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w700,
//                         color: AppColor.mildBlack,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 43),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: AppColor.white,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 57,vertical: 66),
//                     child: Column(
//                       children: [
//                         Image.asset(AppImages.qRCode, height: 200),
//                         SizedBox(height: 31),
//                         Text(
//                           'Scan QR',
//                           style: GoogleFont.Mulish(
//                             fontSize: 24,
//                             fontWeight: FontWeight.w700,
//                             color: AppColor.darkBlue,
//                           ),
//                         ),
//                         SizedBox(height: 11),
//                         Text(
//                           '( or )',
//                           style: GoogleFont.Mulish(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w700,
//                             color: AppColor.borderGray,
//                           ),
//                         ),
//                         SizedBox(height: 11),
//                         Text(
//                           'Use this UID',
//                           style: GoogleFont.Mulish(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w700,
//                             color: AppColor.blue,
//                           ),
//                         ),
//                         SizedBox(height: 11),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               'UID886UI38',
//                               style: GoogleFont.Mulish(
//                                 fontSize: 13,
//                                 color: AppColor.darkBlue,
//                               ),
//                             ),
//                             SizedBox(width: 6),
//                             Image.asset(AppImages.uIDBlue, height: 14),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
