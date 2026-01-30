import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/wallet/Screens/qr_scan_screen.dart';

import '../../../../../Core/Utility/app_Images.dart';
import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/app_loader.dart';
import '../../../../../Core/Utility/google_font.dart';
import '../../../../../Core/Widgets/common_container.dart';
import '../../Home Screen/Screens/home_screen.dart';
import '../Controller/wallet_notifier.dart';
import '../Model/review_history_response.dart';
import 'enter_review.dart';

class ReviewAndEarn extends ConsumerStatefulWidget {
  const ReviewAndEarn({super.key});

  @override
  ConsumerState<ReviewAndEarn> createState() => _ReviewAndEarnState();
}

class _ReviewAndEarnState extends ConsumerState<ReviewAndEarn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    // ✅ API Call
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(walletNotifier.notifier).reviewHistory();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _badgeColor(String badgeType) {
    final t = badgeType.trim().toUpperCase();
    if (t == "RECEIVED") return AppColor.infoTeal;
    return AppColor.darkGrey;
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletNotifier);

    final resp = walletState.reviewHistoryResponse;
    final data = resp?.data;

    final totalReviewReward = data?.totalReviewRewardTcoin ?? 0;
    final sections = data?.sections ?? const <ReviewSection>[];

    if (walletState.isLoading) {
      return Scaffold(
        body: Center(child: ThreeDotsLoader(dotColor: AppColor.black)),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
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
                      'Earn by Review',
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

              // ✅ HEADER
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppImages.walletBCImage),
                  ),
                  gradient: LinearGradient(
                    colors: [AppColor.white, AppColor.surfaceAqua],
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
                            AppImages.earnByReview,
                            height: 53,
                            width: 68,
                          ),
                          const SizedBox(width: 15),

                          // ✅ TOTAL from API
                          ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                colors: [
                                  AppColor.tealBlue,
                                  AppColor.tealGreen,
                                  AppColor.successGreen,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds);
                            },
                            child: Text(
                              "$totalReviewReward",
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
                      'Total Review Reward',
                      style: GoogleFont.Mulish(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColor.darkBlue,
                      ),
                    ),

                    const SizedBox(height: 25),
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

                    // ✅ SCAN QR CARD
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {},
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColor.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: AppColor.white,
                                  width: 1.5,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 20,
                                      right: 20,
                                      top: 8,
                                      bottom: 11,
                                    ),
                                    child: Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EnterReview(),
                                              ),
                                            );
                                          },
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Scan Shop’s QR',
                                                style: GoogleFont.Mulish(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColor.darkBlue,
                                                ),
                                              ),
                                              Text(
                                                'Review the shop & Get Earnings',
                                                style: GoogleFont.Mulish(
                                                  fontSize: 12,
                                                  color: AppColor.darkGrey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 30),
                                        InkWell(
                                          onTap: () async {
                                            final result =
                                                await Navigator.push<String>(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        const QrScanScreen(
                                                          title:
                                                              'Scan QR for Review',
                                                        ),
                                                  ),
                                                );

                                            if (!context.mounted) return;
                                            if (result == null ||
                                                result.trim().isEmpty)
                                              return;

                                            // ✅ parse QR
                                            final payload =
                                                QrScanPayload.fromScanValue(
                                                  result,
                                                );

                                            final shopId =
                                                (payload.shopId ?? '').trim();

                                            if (shopId.isEmpty) {
                                              // shopId இல்லாத QR -> review screen open ஆக முடியாது
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Invalid QR: ShopId missing",
                                                  ),
                                                ),
                                              );
                                              return;
                                            }

                                            // ✅ Auto navigate to EnterReview with shopId
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    EnterReview(shopId: shopId),
                                              ),
                                            );
                                          },

                                          // onTap: () {
                                          //   Navigator.push(
                                          //     context,
                                          //     MaterialPageRoute(
                                          //       builder: (context) =>
                                          //           QrScanScreen(
                                          //             title:
                                          //                 'Scan QR for Review',
                                          //           ),
                                          //     ),
                                          //   );
                                          // },
                                          child: Image.asset(
                                            AppImages.qRColor,
                                            height: 37,
                                            width: 34,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.black.withOpacity(0.02),
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.01),
                                          ],
                                          stops: const [0, 1, 1],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ✅ HISTORY TITLE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Text(
                      'History',
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

              const SizedBox(height: 15),

              // ✅ LOADING
              if (walletState.isLoading) ...[
                const SizedBox(height: 40),
                ThreeDotsLoader(),
                const SizedBox(height: 40),
              ]
              // ✅ EMPTY
              else if (sections.isEmpty) ...[
                const SizedBox(height: 40),
                Text(
                  "No review history found",
                  style: GoogleFont.Mulish(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColor.darkGrey,
                  ),
                ),
                const SizedBox(height: 40),
              ]
              // ✅ DATA LIST
              else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: sections.map((sec) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 18),
                          Text(
                            sec!.dayLabel, // ✅ Today / 23 Jan 2026
                            style: GoogleFont.Mulish(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColor.darkGrey,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // ✅ ITEMS list under this day
                          Column(
                            children: sec.items.map((item) {
                              final badgeColor = _badgeColor(item.badgeType);

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: CommonContainer.walletHistoryBox(
                                  upiTexts: false,
                                  containerColor: AppColor.coolWhite,
                                  mainText: item.title, // ✅ shop/user
                                  timeText: item.timeLabel,
                                  numberText: item.amountTcoin.toString(),
                                  endText: item.badgeLabel,
                                  numberTextColor: badgeColor,
                                  endTextColor: badgeColor,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
