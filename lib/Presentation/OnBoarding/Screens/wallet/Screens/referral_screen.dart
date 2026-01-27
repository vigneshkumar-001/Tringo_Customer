import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../Core/Utility/app_Images.dart';
import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/app_loader.dart';
import '../../../../../Core/Utility/app_snackbar.dart';
import '../../../../../Core/Utility/google_font.dart';
import '../../../../../Core/Widgets/common_container.dart';
import '../Controller/wallet_notifier.dart';
import '../Model/referral_history_response.dart';

class ReferralScreen extends ConsumerStatefulWidget {
  const ReferralScreen({super.key});

  @override
  ConsumerState<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends ConsumerState<ReferralScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  bool _isAndroidLeft = true;
  void _toggle() => setState(() => _isAndroidLeft = !_isAndroidLeft);

  // ✅ fallback values (API fail ஆனாலும் crash ஆகாததுக்கு)
  String _referralCode = "—";
  String _shareText = "";
  String _shareLink = "";
  int _totalReward = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // ✅ API CALL
      await ref.read(walletNotifier.notifier).referralHistory();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _shareTextFunc(String text) async {
    try {
      final box = context.findRenderObject() as RenderBox?;
      await Share.share(
        text,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Share failed")));
      }
    }
  }

  Future<void> _shareReferralCodeOnly() async {
    final msg = "Use my referral code $_referralCode to join Tringo.";
    await _shareTextFunc(msg);
  }

  Future<void> _shareFullReferralText() async {
    final msg = _shareText.isNotEmpty
        ? _shareText
        : "Use my referral code $_referralCode to join Tringo.\n$_shareLink";
    await _shareTextFunc(msg);
  }

  // ✅ badge color helper (Received/Sent etc.)
  String _norm(String v) => v.trim().toUpperCase();

  Color _badgeColorSmart({
    required String badgeType,
    required String badgeLabel,
  }) {
    final t = _norm(badgeType);
    final l = _norm(badgeLabel);
    final key = t.isNotEmpty ? t : l;

    if (key == "RECEIVED" || key == "SUCCESS") return AppColor.green;
    if (key == "SENT" || key == "REJECTED") return AppColor.lightRed;
    if (key == "WAITING" || key == "PENDING") return AppColor.blue;
    if (key == "REWARD" || key == "REWARDS") return AppColor.positiveGreen;

    return AppColor.darkGrey;
  }

  Color _rowBgSmart({required String badgeType, required String badgeLabel}) {
    final t = _norm(badgeType);
    final l = _norm(badgeLabel);
    final key = t.isNotEmpty ? t : l;

    if (key == "RECEIVED" || key == "SUCCESS") return AppColor.lightGreenBg;
    if (key == "SENT" || key == "REJECTED") return AppColor.pinkSurface;
    if (key == "WAITING" || key == "PENDING") return AppColor.lightBlueGray;
    if (key == "REWARD" || key == "REWARDS") return AppColor.lightMint;

    return AppColor.whiteSmoke;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(walletNotifier);

    // ✅ API DATA
    final resp = state.referralHistoryResponse;
    final data = resp?.data;

    final sections = data?.sections ?? const <ReferralSection>[];

    // ✅ update values for UI
    _referralCode = data?.referralCode ?? _referralCode;
    _shareText = data?.shareText ?? _shareText;
    _shareLink = data?.shareLink ?? _shareLink;
    _totalReward = data?.totalReferralRewardTcoin ?? _totalReward;

    if (state.error != null && state.error!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppSnackBar.info(context, state.error!);
      });
    }

    if (state.isLoading) {
      return Scaffold(
        body: Center(child: ThreeDotsLoader(dotColor: AppColor.black)),
      );
    }

    // Animated switch cards
    final leftChild = _isAndroidLeft
        ? _androidBigCard(key: const ValueKey("android_big"))
        : _iosBigCard(key: const ValueKey("ios_big"));

    final rightChild = _isAndroidLeft
        ? _iosSmallBtn(key: const ValueKey("ios_small"))
        : _androidSmallBtn(key: const ValueKey("android_small"));

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // TOP BAR
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 16,
                ),
                child: Stack(
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
                      'Refer Friend',
                      style: GoogleFont.Mulish(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColor.mildBlack,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 41),

              // HEADER CARD
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppImages.walletBCImage),
                  ),
                  gradient: LinearGradient(
                    colors: [AppColor.white, AppColor.surfaceBlue],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 115),
                      child: Row(
                        children: [
                          Image.asset(
                            AppImages.referFriends,
                            height: 55,
                            width: 62,
                          ),
                          const SizedBox(width: 15),
                          ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                colors: [
                                  AppColor.brandBlue,
                                  AppColor.accentCyan,
                                  AppColor.successGreen,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds);
                            },
                            child: Text(
                              _totalReward.toString(),
                              style: GoogleFont.Mulish(
                                fontSize: 42,
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Total Referral Reward',
                      style: GoogleFont.Mulish(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColor.darkBlue,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // DIVIDER
                    Container(
                      width: double.infinity,
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [
                            AppColor.white.withOpacity(0.5),
                            AppColor.white4.withOpacity(0.4),
                            AppColor.white4.withOpacity(0.4),
                            AppColor.white4.withOpacity(0.4),
                            AppColor.white4.withOpacity(0.4),
                            AppColor.white4.withOpacity(0.4),
                            AppColor.white4.withOpacity(0.4),
                            AppColor.white.withOpacity(0.5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ANDROID / IOS SWITCH AREA
                    Padding(
                      padding: const EdgeInsets.only(left: 40, right: 25),
                      child: Row(
                        children: [
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 420),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) {
                                final isIosBig =
                                    child.key == const ValueKey("ios_big");
                                final beginOffset = isIosBig
                                    ? const Offset(0.25, 0)
                                    : const Offset(-0.25, 0);
                                return ClipRect(
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: beginOffset,
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  ),
                                );
                              },
                              child: leftChild,
                            ),
                          ),
                          const SizedBox(width: 20),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 420),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (child, animation) {
                              final isAndroidSmall =
                                  child.key == const ValueKey("android_small");
                              final beginOffset = isAndroidSmall
                                  ? const Offset(-0.25, 0)
                                  : const Offset(0.25, 0);
                              return ClipRect(
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: beginOffset,
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                ),
                              );
                            },
                            child: rightChild,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // REFERRAL CODE + SHARE BTN
                    Padding(
                      padding: const EdgeInsets.only(left: 40.0, right: 25),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                await Clipboard.setData(
                                  ClipboardData(text: _referralCode),
                                );
                                if (!mounted) return;
                                AppSnackBar.success(
                                  context,
                                  "Referral code copied: $_referralCode",
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColor.white.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: AppColor.white,
                                    width: 1.5,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 20,
                                    right: 18,
                                    top: 8,
                                    bottom: 11,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Share Referral Code',
                                        style: GoogleFont.Mulish(
                                          fontSize: 12,
                                          color: AppColor.darkGrey,
                                        ),
                                      ),
                                      Text(
                                        _referralCode,
                                        style: GoogleFont.Mulish(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: AppColor.darkBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          InkWell(
                            onTap: _shareFullReferralText,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.black,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Image.asset(AppImages.share, height: 35),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // HISTORY TITLE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Text(
                      "History",
                      style: GoogleFont.Mulish(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: AppColor.darkBlue,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // EMPTY STATE
              if (sections.isEmpty) ...[
                const SizedBox(height: 25),
                Center(
                  child: Text(
                    "No history found",
                    style: GoogleFont.Mulish(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColor.darkGrey,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
              ] else ...[
                // LIST SECTIONS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final sec in sections) ...[
                        Center(
                          child: Text(
                            sec.dayLabel,
                            style: GoogleFont.Mulish(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColor.darkGrey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        for (final item in sec.items) ...[
                          CommonContainer.walletHistoryBox(
                            upiTexts: false,
                            containerColor: _rowBgSmart(
                              badgeType: item.badgeType,
                              badgeLabel: item.badgeLabel,
                            ),
                            mainText: item.title,
                            timeText: item.timeLabel,
                            numberText: "+${item.amountTcoin}",
                            endText: item.badgeLabel,
                            numberTextColor: _badgeColorSmart(
                              badgeType: item.badgeType,
                              badgeLabel: item.badgeLabel,
                            ),
                            endTextColor: _badgeColorSmart(
                              badgeType: item.badgeType,
                              badgeLabel: item.badgeLabel,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],

                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------
  // LEFT BIG CARD - Android
  // -------------------------
  Widget _androidBigCard({Key? key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColor.blue,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Image.asset(AppImages.playStore, height: 36),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(
                left: 16,
                right: 10,
                bottom: 7,
                top: 7,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Share Android App Link',
                    style: GoogleFont.Mulish(
                      color: AppColor.darkGrey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _shareLink.isEmpty ? "/ref..." : _shareLink,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFont.Mulish(
                            color: AppColor.blue,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: _shareFullReferralText,
                        child: Image.asset(
                          AppImages.share,
                          width: 25,
                          color: AppColor.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------
  // LEFT BIG CARD - iOS
  // -------------------------
  Widget _iosBigCard({Key? key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColor.yellow,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Image.asset(AppImages.iPhoneLogo, height: 36),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(
                left: 16,
                right: 10,
                bottom: 7,
                top: 7,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Share iOS App Link',
                    style: GoogleFont.Mulish(
                      color: AppColor.darkGrey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _shareLink.isEmpty ? "/ref..." : _shareLink,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFont.Mulish(
                            color: AppColor.blue,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: _shareFullReferralText,
                        child: Image.asset(
                          AppImages.share,
                          width: 25,
                          color: AppColor.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------
  // RIGHT SMALL BUTTON - iOS
  // -------------------------
  Widget _iosSmallBtn({Key? key}) {
    return InkWell(
      key: key,
      onTap: _toggle,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: AppColor.yellow,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Image.asset(AppImages.iPhoneLogo, height: 35),
      ),
    );
  }

  // -------------------------
  // RIGHT SMALL BUTTON - Android
  // -------------------------
  Widget _androidSmallBtn({Key? key}) {
    return InkWell(
      key: key,
      onTap: _toggle,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: AppColor.blue,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Image.asset(AppImages.playStore, height: 35),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:share_plus/share_plus.dart';
//
// import '../../../../../Core/Utility/app_Images.dart';
// import '../../../../../Core/Utility/app_color.dart';
// import '../../../../../Core/Utility/google_font.dart';
// import '../../../../../Core/Widgets/common_container.dart';
//
// class ReferralScreen extends ConsumerStatefulWidget {
//   const ReferralScreen({super.key});
//
//   @override
//   ConsumerState<ReferralScreen> createState() => _ReferralScreenState();
// }
//
// class _ReferralScreenState extends ConsumerState<ReferralScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//
//   bool _isAndroidLeft = true;
//
//   void _toggle() => setState(() => _isAndroidLeft = !_isAndroidLeft);
//
//   final String _referralCode = "525866";
//   final String _androidShareUrl =
//       "https://play.google.com/store/apps/details?id=com.yourapp&ref=525866";
//   final String _iosShareUrl =
//       "https://apps.apple.com/app/id0000000000?ref=525866";
//
//   Future<void> _shareText(String text) async {
//     try {
//       final box = context.findRenderObject() as RenderBox?;
//       await Share.share(
//         text,
//         sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
//       );
//     } catch (e) {
//       // optional: show snackbar
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("Share failed")));
//       }
//     }
//   }
//
//   Future<void> _shareAndroidLink() async {
//     final msg =
//         "Join using my referral code: $_referralCode\n\nAndroid App:\n$_androidShareUrl";
//     await _shareText(msg);
//   }
//
//   Future<void> _shareIosLink() async {
//     final msg =
//         "Join using my referral code: $_referralCode\n\niOS App:\n$_iosShareUrl";
//     await _shareText(msg);
//   }
//
//   Future<void> _shareReferralCodeOnly() async {
//     final msg = "My referral code: $_referralCode";
//     await _shareText(msg);
//   }
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
//     // Use different keys so AnimatedSwitcher knows it's a new child to animate.
//     final leftChild = _isAndroidLeft
//         ? _androidBigCard(key: const ValueKey("android_big"))
//         : _iosBigCard(key: const ValueKey("ios_big"));
//
//     final rightChild = _isAndroidLeft
//         ? _iosSmallBtn(key: const ValueKey("ios_small"))
//         : _androidSmallBtn(key: const ValueKey("android_small"));
//
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 15,
//                   vertical: 16,
//                 ),
//                 child: Stack(
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
//                       'Refer Friend',
//                       style: GoogleFont.Mulish(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w700,
//                         color: AppColor.mildBlack,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 41),
//               Container(
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage(AppImages.walletBCImage),
//                   ),
//                   gradient: LinearGradient(
//                     colors: [AppColor.white, AppColor.surfaceBlue],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                   ),
//                   borderRadius: const BorderRadius.only(
//                     bottomLeft: Radius.circular(25),
//                     bottomRight: Radius.circular(25),
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 115),
//                       child: Row(
//                         children: [
//                           Image.asset(
//                             AppImages.referFriends,
//                             height: 55,
//                             width: 62,
//                           ),
//                           const SizedBox(width: 15),
//                           ShaderMask(
//                             shaderCallback: (bounds) {
//                               return LinearGradient(
//                                 colors: [
//                                   AppColor.brandBlue,
//                                   AppColor.accentCyan,
//                                   AppColor.successGreen,
//                                 ],
//                                 begin: Alignment.centerLeft,
//                                 end: Alignment.bottomRight,
//                               ).createShader(bounds);
//                             },
//                             child: Text(
//                               '63',
//                               style: GoogleFont.Mulish(
//                                 fontSize: 42,
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w900,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 15),
//                     Text(
//                       'Total Referral Reward',
//                       style: GoogleFont.Mulish(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w700,
//                         color: AppColor.darkBlue,
//                       ),
//                     ),
//                     const SizedBox(height: 25),
//                     Container(
//                       width: double.infinity,
//                       height: 2,
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.centerRight,
//                           end: Alignment.centerLeft,
//                           colors: [
//                             AppColor.white.withOpacity(0.5),
//                             AppColor.white4.withOpacity(0.4),
//                             AppColor.white4.withOpacity(0.4),
//                             AppColor.white4.withOpacity(0.4),
//                             AppColor.white4.withOpacity(0.4),
//                             AppColor.white4.withOpacity(0.4),
//                             AppColor.white4.withOpacity(0.4),
//                             AppColor.white.withOpacity(0.5),
//                           ],
//                         ),
//                         borderRadius: BorderRadius.circular(1),
//                       ),
//                     ),
//                     const SizedBox(height: 25),
//
//                     Padding(
//                       padding: const EdgeInsets.only(left: 40, right: 25),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: AnimatedSwitcher(
//                               duration: const Duration(milliseconds: 420),
//                               switchInCurve: Curves.easeOutCubic,
//                               switchOutCurve: Curves.easeInCubic,
//                               transitionBuilder: (child, animation) {
//                                 final isIosBig =
//                                     child.key == const ValueKey("ios_big");
//                                 final beginOffset = isIosBig
//                                     ? const Offset(0.25, 0)
//                                     : const Offset(-0.25, 0);
//
//                                 return ClipRect(
//                                   child: SlideTransition(
//                                     position: Tween<Offset>(
//                                       begin: beginOffset,
//                                       end: Offset.zero,
//                                     ).animate(animation),
//                                     child: FadeTransition(
//                                       opacity: animation,
//                                       child: child,
//                                     ),
//                                   ),
//                                 );
//                               },
//                               child: leftChild,
//                             ),
//                           ),
//                           const SizedBox(width: 20),
//                           AnimatedSwitcher(
//                             duration: const Duration(milliseconds: 420),
//                             switchInCurve: Curves.easeOutCubic,
//                             switchOutCurve: Curves.easeInCubic,
//                             transitionBuilder: (child, animation) {
//                               final isAndroidSmall =
//                                   child.key == const ValueKey("android_small");
//                               final beginOffset = isAndroidSmall
//                                   ? const Offset(-0.25, 0)
//                                   : const Offset(0.25, 0);
//
//                               return ClipRect(
//                                 child: SlideTransition(
//                                   position: Tween<Offset>(
//                                     begin: beginOffset,
//                                     end: Offset.zero,
//                                   ).animate(animation),
//                                   child: FadeTransition(
//                                     opacity: animation,
//                                     child: child,
//                                   ),
//                                 ),
//                               );
//                             },
//                             child: rightChild,
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: 10),
//
//                     Padding(
//                       padding: const EdgeInsets.only(left: 40.0),
//                       child: Row(
//                         children: [
//                           InkWell(
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: AppColor.white.withOpacity(0.7),
//                                 borderRadius: BorderRadius.circular(15),
//                                 border: Border.all(
//                                   color: AppColor.white,
//                                   width: 1.5,
//                                 ),
//                               ),
//                               child: Stack(
//                                 children: [
//                                   Padding(
//                                     padding: const EdgeInsets.only(
//                                       left: 20,
//                                       right: 113,
//                                       top: 8,
//                                       bottom: 11,
//                                     ),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           'Share Referral Code',
//                                           style: GoogleFont.Mulish(
//                                             fontSize: 12,
//                                             color: AppColor.darkGrey,
//                                           ),
//                                         ),
//                                         Text(
//                                           _referralCode,
//                                           style: GoogleFont.Mulish(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w800,
//                                             color: AppColor.darkBlue,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   ClipRRect(
//                                     borderRadius: BorderRadius.circular(15),
//                                     child: Container(
//                                       decoration: BoxDecoration(
//                                         gradient: LinearGradient(
//                                           begin: Alignment.topLeft,
//                                           end: Alignment.bottomRight,
//                                           colors: [
//                                             Colors.black.withOpacity(0.02),
//                                             Colors.transparent,
//                                             Colors.black.withOpacity(0.01),
//                                           ],
//                                           stops: const [0, 1, 1],
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 20),
//                           InkWell(
//                             onTap:
//                                 _shareReferralCodeOnly, // ✅ Share button click
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 10,
//                                 vertical: 14,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: AppColor.black,
//                                 borderRadius: BorderRadius.circular(15),
//                               ),
//                               child: Image.asset(AppImages.share, height: 35),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: 25),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//               Text(
//                 'Today',
//                 style: GoogleFont.Mulish(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w700,
//                   color: AppColor.darkGrey,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 15),
//                 child: Column(
//                   children: [
//                     CommonContainer.walletHistoryBox(
//                       upiTexts: false,
//                       containerColor: AppColor.surfaceBlue,
//                       mainText: 'Abdul kalam',
//                       timeText: '10.40Pm',
//                       numberText: '30',
//                       endText: 'Received',
//                       numberTextColor: AppColor.blue,
//                       endTextColor: AppColor.blue,
//                     ),
//                     const SizedBox(height: 10),
//                     CommonContainer.walletHistoryBox(
//                       upiTexts: false,
//                       containerColor: AppColor.surfaceBlue,
//                       mainText: 'Stalin',
//                       timeText: '10.40Pm',
//                       numberText: '30',
//                       endText: 'Received',
//                       numberTextColor: AppColor.blue,
//                       endTextColor: AppColor.blue,
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 40),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // -------------------------
//   // LEFT BIG CARD - Android
//   // -------------------------
//   Widget _androidBigCard({Key? key}) {
//     return Container(
//       key: key,
//       padding: const EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: AppColor.blue,
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Row(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10),
//             child: Image.asset(AppImages.playStore, height: 36),
//           ),
//           Expanded(
//             child: Container(
//               padding: const EdgeInsets.only(
//                 left: 16,
//                 right: 10,
//                 bottom: 7,
//                 top: 7,
//               ),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'Share Android App Link',
//                     style: GoogleFont.Mulish(
//                       color: AppColor.darkGrey,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           '/refy/refu098kjfindfu38...',
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: GoogleFont.Mulish(
//                             color: AppColor.blue,
//                             fontSize: 15,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                       InkWell(
//                         onTap: _shareAndroidLink, // ✅ Share sheet open
//                         child: Padding(
//                           padding: const EdgeInsets.all(0),
//                           child: Image.asset(
//                             AppImages.share,
//                             width: 25,
//                             color: AppColor.blue,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // -------------------------
//   // LEFT BIG CARD - iOS
//   // -------------------------
//   Widget _iosBigCard({Key? key}) {
//     return Container(
//       key: key,
//       padding: const EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: AppColor.yellow,
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Row(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10),
//             child: Image.asset(AppImages.iPhoneLogo, height: 36),
//           ),
//           Expanded(
//             child: Container(
//               padding: const EdgeInsets.only(
//                 left: 16,
//                 right: 10,
//                 bottom: 7,
//                 top: 7,
//               ),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'Share iOS App Link',
//                     style: GoogleFont.Mulish(
//                       color: AppColor.darkGrey,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           '/refy/iosu098kjfindfu38...',
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: GoogleFont.Mulish(
//                             color: AppColor.blue,
//                             fontSize: 15,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                       InkWell(
//                         onTap: _shareIosLink, // ✅ Share sheet open
//                         child: Padding(
//                           padding: const EdgeInsets.all(0),
//                           child: Image.asset(
//                             AppImages.share,
//                             width: 25,
//                             color: AppColor.blue,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // -------------------------
//   // RIGHT SMALL BUTTON - iOS
//   // -------------------------
//   Widget _iosSmallBtn({Key? key}) {
//     return InkWell(
//       key: key,
//       onTap: _toggle,
//       borderRadius: BorderRadius.circular(15),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
//         decoration: BoxDecoration(
//           color: AppColor.yellow,
//           borderRadius: BorderRadius.circular(15),
//         ),
//         child: Image.asset(AppImages.iPhoneLogo, height: 35),
//       ),
//     );
//   }
//
//   // -------------------------
//   // RIGHT SMALL BUTTON - Android
//   // -------------------------
//   Widget _androidSmallBtn({Key? key}) {
//     return InkWell(
//       key: key,
//       onTap: _toggle,
//       borderRadius: BorderRadius.circular(15),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
//         decoration: BoxDecoration(
//           color: AppColor.blue,
//           borderRadius: BorderRadius.circular(15),
//         ),
//         child: Image.asset(AppImages.playStore, height: 35),
//       ),
//     );
//   }
// }

///old ////
// import 'package:flutter/material.dart';
// import 'package:share_plus/share_plus.dart';
//
// import '../../../../../Core/Utility/app_Images.dart';
// import '../../../../../Core/Utility/app_color.dart';
// import '../../../../../Core/Utility/google_font.dart';
// import '../../../../../Core/Widgets/common_container.dart';
//
// class ReferralScreen extends StatefulWidget {
//   const ReferralScreen({super.key});
//
//   @override
//   State<ReferralScreen> createState() => _ReferralScreenState();
// }
//
// class _ReferralScreenState extends State<ReferralScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//
//   bool _isAndroidLeft = true;
//
//   void _toggle() => setState(() => _isAndroidLeft = !_isAndroidLeft);
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
//     // Use different keys so AnimatedSwitcher knows it's a new child to animate.
//     final leftChild = _isAndroidLeft
//         ? _androidBigCard(key: const ValueKey("android_big"))
//         : _iosBigCard(key: const ValueKey("ios_big"));
//
//     final rightChild = _isAndroidLeft
//         ? _iosSmallBtn(key: const ValueKey("ios_small"))
//         : _androidSmallBtn(key: const ValueKey("android_small"));
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 15,
//                   vertical: 16,
//                 ),
//                 child: Stack(
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
//                       'Refer Friend',
//                       style: GoogleFont.Mulish(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w700,
//                         color: AppColor.mildBlack,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 41),
//               Container(
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage(AppImages.walletBCImage),
//                   ),
//                   gradient: LinearGradient(
//                     colors: [AppColor.white, AppColor.surfaceBlue],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                   ),
//                   borderRadius: BorderRadius.only(
//                     bottomLeft: Radius.circular(25),
//                     bottomRight: Radius.circular(25),
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 115),
//                       child: Row(
//                         children: [
//                           Image.asset(
//                             AppImages.referFriends,
//                             height: 55,
//                             width: 62,
//                           ),
//                           SizedBox(width: 15),
//                           ShaderMask(
//                             shaderCallback: (bounds) {
//                               return LinearGradient(
//                                 colors: [
//                                   AppColor.brandBlue,
//                                   AppColor.accentCyan,
//                                   AppColor.successGreen,
//                                 ],
//                                 begin: Alignment.centerLeft,
//                                 end: Alignment.bottomRight,
//                               ).createShader(bounds);
//                             },
//                             child: Text(
//                               '63',
//                               style: GoogleFont.Mulish(
//                                 fontSize: 42,
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w900,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: 15),
//                     Text(
//                       'Total Referral Reward',
//                       style: GoogleFont.Mulish(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w700,
//                         color: AppColor.darkBlue,
//                       ),
//                     ),
//
//                     SizedBox(height: 25),
//                     Container(
//                       width: double.infinity,
//                       height: 2,
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.centerRight,
//                           end: Alignment.centerLeft,
//                           colors: [
//                             AppColor.white.withOpacity(0.5),
//                             AppColor.white4.withOpacity(0.4),
//                             AppColor.white4.withOpacity(0.4),
//                             AppColor.white4.withOpacity(0.4),
//                             AppColor.white4.withOpacity(0.4),
//                             AppColor.white4.withOpacity(0.4),
//                             AppColor.white4.withOpacity(0.4),
//                             AppColor.white.withOpacity(0.5),
//                           ],
//                         ),
//                         borderRadius: BorderRadius.circular(1),
//                       ),
//                     ),
//                     SizedBox(height: 25),
//                     Padding(
//                       padding: EdgeInsets.only(left: 40, right: 25),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: AnimatedSwitcher(
//                               duration: const Duration(milliseconds: 420),
//                               switchInCurve: Curves.easeOutCubic,
//                               switchOutCurve: Curves.easeInCubic,
//                               transitionBuilder: (child, animation) {
//                                 // Slide direction depends on which side we are switching to
//                                 // If iOS is moving to left (from right), slide from right -> center.
//                                 // If Android is moving to left (from left), slide from left -> center.
//                                 final isIosBig =
//                                     child.key == const ValueKey("ios_big");
//                                 final beginOffset = isIosBig
//                                     ? const Offset(0.25, 0) // from right
//                                     : const Offset(-0.25, 0); // from left
//
//                                 return ClipRect(
//                                   child: SlideTransition(
//                                     position: Tween<Offset>(
//                                       begin: beginOffset,
//                                       end: Offset.zero,
//                                     ).animate(animation),
//                                     child: FadeTransition(
//                                       opacity: animation,
//                                       child: child,
//                                     ),
//                                   ),
//                                 );
//                               },
//                               child: leftChild,
//                             ),
//                           ),
//
//                           const SizedBox(width: 20),
//
//                           AnimatedSwitcher(
//                             duration: const Duration(milliseconds: 420),
//                             switchInCurve: Curves.easeOutCubic,
//                             switchOutCurve: Curves.easeInCubic,
//                             transitionBuilder: (child, animation) {
//                               // Right side swap: opposite direction
//                               final isAndroidSmall =
//                                   child.key == const ValueKey("android_small");
//                               final beginOffset = isAndroidSmall
//                                   ? const Offset(
//                                       -0.25,
//                                       0,
//                                     ) // from left to right slot
//                                   : const Offset(
//                                       0.25,
//                                       0,
//                                     ); // from right to right slot
//
//                               return ClipRect(
//                                 child: SlideTransition(
//                                   position: Tween<Offset>(
//                                     begin: beginOffset,
//                                     end: Offset.zero,
//                                   ).animate(animation),
//                                   child: FadeTransition(
//                                     opacity: animation,
//                                     child: child,
//                                   ),
//                                 ),
//                               );
//                             },
//                             child: rightChild,
//                           ),
//                         ],
//                       ),
//                       // Row(
//                       //   children: [
//                       //     Expanded(
//                       //       child: Container(
//                       //         padding: const EdgeInsets.all(4),
//                       //         decoration: BoxDecoration(
//                       //           color: AppColor.blue,
//                       //           borderRadius: BorderRadius.circular(15),
//                       //         ),
//                       //         child: Row(
//                       //           children: [
//                       //             Padding(
//                       //               padding: const EdgeInsets.symmetric(
//                       //                 horizontal: 10,
//                       //               ),
//                       //               child: Image.asset(
//                       //                 AppImages.playStore,
//                       //                 height: 36,
//                       //               ),
//                       //             ),
//                       //
//                       //             Expanded(
//                       //               child: Container(
//                       //                 padding: const EdgeInsets.only(
//                       //                   left: 16,
//                       //                   right: 10,
//                       //                   bottom: 7,
//                       //                   top: 7,
//                       //                 ),
//                       //                 decoration: BoxDecoration(
//                       //                   color: Colors.white,
//                       //                   borderRadius: BorderRadius.circular(15),
//                       //                 ),
//                       //                 child: Column(
//                       //                   crossAxisAlignment:
//                       //                       CrossAxisAlignment.start,
//                       //                   mainAxisSize: MainAxisSize.min,
//                       //                   children: [
//                       //                     Text(
//                       //                       'Share Android App Link',
//                       //                       style: GoogleFont.Mulish(
//                       //                         color: AppColor.darkGrey,
//                       //                         fontSize: 12,
//                       //                         fontWeight: FontWeight.w500,
//                       //                       ),
//                       //                     ),
//                       //                     Row(
//                       //                       children: [
//                       //                         Expanded(
//                       //                           child: Text(
//                       //                             '/refy/refu098kjfindfu38...',
//                       //                             maxLines: 1,
//                       //                             overflow:
//                       //                                 TextOverflow.ellipsis,
//                       //                             style: GoogleFont.Mulish(
//                       //                               color: AppColor.blue,
//                       //                               fontSize: 15,
//                       //                               fontWeight: FontWeight.w600,
//                       //                             ),
//                       //                           ),
//                       //                         ),
//                       //                         InkWell(
//                       //                           onTap: () {},
//                       //                           child: Padding(
//                       //                             padding: const EdgeInsets.all(
//                       //                               0,
//                       //                             ),
//                       //                             child: Image.asset(
//                       //                               AppImages.share,
//                       //                               width: 25,
//                       //                               color: AppColor.blue,
//                       //                             ),
//                       //                           ),
//                       //                         ),
//                       //                       ],
//                       //                     ),
//                       //                   ],
//                       //                 ),
//                       //               ),
//                       //             ),
//                       //           ],
//                       //         ),
//                       //       ),
//                       //     ),
//                       //
//                       //     SizedBox(width: 20),
//                       //     InkWell(
//                       //       onTap: () {},
//                       //       borderRadius: BorderRadius.circular(15),
//                       //       child: Container(
//                       //         padding: const EdgeInsets.symmetric(
//                       //           horizontal: 10,
//                       //           vertical: 14,
//                       //         ),
//                       //         decoration: BoxDecoration(
//                       //           color: AppColor.yellow,
//                       //           borderRadius: BorderRadius.circular(15),
//                       //         ),
//                       //         child: Image.asset(
//                       //           AppImages.iPhoneLogo,
//                       //           height: 35,
//                       //         ),
//                       //       ),
//                       //     ),
//                       //   ],
//                       // ),
//                     ),
//                     SizedBox(height: 10),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 40.0),
//                       child: Row(
//                         children: [
//                           InkWell(
//                             onTap: () {},
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: AppColor.white.withOpacity(0.7),
//                                 borderRadius: BorderRadius.circular(15),
//                                 border: Border.all(
//                                   color: AppColor.white,
//                                   width: 1.5,
//                                 ),
//                               ),
//                               child: Stack(
//                                 children: [
//                                   Padding(
//                                     padding: const EdgeInsets.only(
//                                       left: 20,
//                                       right: 113,
//                                       top: 8,
//                                       bottom: 11,
//                                     ),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           'Share Referral Code',
//                                           style: GoogleFont.Mulish(
//                                             fontSize: 12,
//                                             color: AppColor.darkGrey,
//                                           ),
//                                         ),
//                                         Text(
//                                           '525866',
//                                           style: GoogleFont.Mulish(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w800,
//                                             color: AppColor.darkBlue,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   ClipRRect(
//                                     borderRadius: BorderRadius.circular(15),
//                                     child: Container(
//                                       decoration: BoxDecoration(
//                                         gradient: LinearGradient(
//                                           begin: Alignment.topLeft,
//                                           end: Alignment.bottomRight,
//                                           colors: [
//                                             Colors.black.withOpacity(0.02),
//                                             Colors.transparent,
//                                             Colors.black.withOpacity(0.01),
//                                           ],
//                                           stops: [0, 1, 1],
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 20),
//                           InkWell(
//                             onTap: () {},
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 10,
//                                 vertical: 14,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: AppColor.black,
//                                 borderRadius: BorderRadius.circular(15),
//                               ),
//                               child: Image.asset(AppImages.share, height: 35),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: 25),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 20),
//               Text(
//                 'Today',
//                 style: GoogleFont.Mulish(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w700,
//                   color: AppColor.darkGrey,
//                 ),
//               ),
//               SizedBox(height: 10),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 15),
//                 child: Column(
//                   children: [
//                     CommonContainer.walletHistoryBox(
//                       upiTexts: false,
//                       containerColor: AppColor.surfaceBlue,
//                       mainText: 'Abdul kalam',
//
//                       timeText: '10.40Pm',
//                       numberText: '30',
//                       endText: 'Received',
//                       numberTextColor: AppColor.blue,
//                       endTextColor: AppColor.blue,
//                     ),
//                     SizedBox(height: 10),
//                     CommonContainer.walletHistoryBox(
//                       upiTexts: false,
//                       containerColor: AppColor.surfaceBlue,
//                       mainText: 'Stalin',
//                       timeText: '10.40Pm',
//                       numberText: '30',
//                       endText: 'Received',
//                       numberTextColor: AppColor.blue,
//                       endTextColor: AppColor.blue,
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 40),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _androidBigCard({Key? key}) {
//     return Container(
//       key: key,
//       padding: const EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: AppColor.blue,
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Row(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10),
//             child: Image.asset(AppImages.playStore, height: 36),
//           ),
//           Expanded(
//             child: Container(
//               padding: const EdgeInsets.only(
//                 left: 16,
//                 right: 10,
//                 bottom: 7,
//                 top: 7,
//               ),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'Share Android App Link',
//                     style: GoogleFont.Mulish(
//                       color: AppColor.darkGrey,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           '/refy/refu098kjfindfu38...',
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: GoogleFont.Mulish(
//                             color: AppColor.blue,
//                             fontSize: 15,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                       InkWell(
//                         onTap: () {},
//                         child: Padding(
//                           padding: const EdgeInsets.all(0),
//                           child: Image.asset(
//                             AppImages.share,
//                             width: 25,
//                             color: AppColor.blue,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // -------------------------
//   // LEFT BIG CARD - iOS
//   // (same style, different icon/title)
//   // -------------------------
//   Widget _iosBigCard({Key? key}) {
//     return Container(
//       key: key,
//       padding: const EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: AppColor.yellow,
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Row(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10),
//             child: Image.asset(AppImages.iPhoneLogo, height: 36),
//           ),
//           Expanded(
//             child: Container(
//               padding: const EdgeInsets.only(
//                 left: 16,
//                 right: 10,
//                 bottom: 7,
//                 top: 7,
//               ),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'Share iOS App Link',
//                     style: GoogleFont.Mulish(
//                       color: AppColor.darkGrey,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           '/refy/iosu098kjfindfu38...',
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: GoogleFont.Mulish(
//                             color: AppColor.blue,
//                             fontSize: 15,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                       InkWell(
//                         onTap: () {
//                           // share ios link
//                         },
//                         child: Padding(
//                           padding: const EdgeInsets.all(0),
//                           child: Image.asset(
//                             AppImages.share,
//                             width: 25,
//                             color: AppColor.blue,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // -------------------------
//   // RIGHT SMALL BUTTON - iOS
//   // -------------------------
//   Widget _iosSmallBtn({Key? key}) {
//     return InkWell(
//       key: key,
//       onTap: _toggle, // ✅ iPhone click -> move to left, Android goes right
//       borderRadius: BorderRadius.circular(15),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
//         decoration: BoxDecoration(
//           color: AppColor.yellow,
//           borderRadius: BorderRadius.circular(15),
//         ),
//         child: Image.asset(AppImages.iPhoneLogo, height: 35),
//       ),
//     );
//   }
//
//   // -------------------------
//   // RIGHT SMALL BUTTON - Android
//   // -------------------------
//   Widget _androidSmallBtn({Key? key}) {
//     return InkWell(
//       key: key,
//       onTap: _toggle, // ✅ PlayStore click -> move back to left
//       borderRadius: BorderRadius.circular(15),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
//         decoration: BoxDecoration(
//           color: AppColor.blue,
//           borderRadius: BorderRadius.circular(15),
//         ),
//         child: Image.asset(AppImages.playStore, height: 35),
//       ),
//     );
//   }
// }
