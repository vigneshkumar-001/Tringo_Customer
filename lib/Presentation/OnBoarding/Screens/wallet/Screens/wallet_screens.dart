import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/wallet/Screens/qr_scan_screen.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/wallet/Screens/receive_screen.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/wallet/Screens/referral_screen.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/wallet/Screens/review_and_earn.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/wallet/Screens/send_screen.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/wallet/Screens/withdraw_screen.dart';

import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/app_loader.dart';
import '../../../../../Core/Utility/app_snackbar.dart';
import '../../../../../Core/Utility/google_font.dart';
import '../../../../../Core/Widgets/common_container.dart';
import '../../No Data Screen/Screen/no_data_screen.dart';
import '../Controller/wallet_notifier.dart';
import '../Model/wallet_history_response.dart';

class WalletScreens extends ConsumerStatefulWidget {
  const WalletScreens({super.key});

  @override
  ConsumerState<WalletScreens> createState() => _WalletScreensState();
}

class _WalletScreensState extends ConsumerState<WalletScreens>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  DateTime selectedDate = DateTime.now();
  int selectedTypeIndex = 0; // old selectedIndex instead use this
  String selectedDateMode = "Today"; // Today / Yesterday / Custom

  String selectedDay = 'Today';
  int selectedIndex = 0;

  // API types
  static const _types = ["ALL", "REWARDS", "SENT", "RECEIVED", "WITHDRAW"];

  String _fmt(DateTime d) => DateFormat('dd MMM yyyy').format(d);
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

  Map<String, int> _localCountsFromSections(List<Section> sections) {
    int all = 0, rewards = 0, sent = 0, received = 0, withdraw = 0;

    bool isReward(WalletHistoryItem it) {
      final title = _norm(it.title);
      final key = _norm(it.badgeType).isNotEmpty
          ? _norm(it.badgeType)
          : _norm(it.badgeLabel);

      if (key == "REWARD" || key == "REWARDS") return true;
      if (title.contains("BONUS") || title.contains("REWARD")) return true;
      if (title.contains("SIGNUP")) return true; // Signup Bonus
      return false;
    }

    bool isWithdraw(WalletHistoryItem it) {
      final title = _norm(it.title);
      final key = _norm(it.badgeType).isNotEmpty
          ? _norm(it.badgeType)
          : _norm(it.badgeLabel);

      if (key == "WITHDRAW" || key == "WITHDRAWAL") return true;
      if (key == "WAITING" && title.contains("WITHDRAW")) return true;
      if (title.contains("WITHDRAW")) return true;
      return false;
    }

    for (final sec in sections) {
      for (final it in sec.items) {
        all++;

        final key = _norm(it.badgeType).isNotEmpty
            ? _norm(it.badgeType)
            : _norm(it.badgeLabel);

        if (key == "SENT") sent++;
        if (key == "RECEIVED") received++;
        if (isWithdraw(it)) withdraw++;
        if (isReward(it)) rewards++;
      }
    }

    return {
      "ALL": all,
      "REWARDS": rewards,
      "SENT": sent,
      "RECEIVED": received,
      "WITHDRAW": withdraw,
    };
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ initial load only (keep as ALL or your selectedIndex)
      ref.read(walletNotifier.notifier).walletHistory(counts: _types[0]);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ✅ Client-side date filter (works even if backend doesn’t support date param)
  List<Section> _applyLocalDateFilter(List<Section> sections) {
    if (sections.isEmpty) return sections;

    if (selectedDay == "Today" || selectedDay == "Yesterday") {
      final wanted = selectedDay.trim().toLowerCase();
      return sections
          .where((s) => s.dayLabel.trim().toLowerCase() == wanted)
          .toList();
    }

    final target = _fmt(selectedDate); // "23 Jan 2026"
    final filtered = <Section>[];

    for (final sec in sections) {
      final items = sec.items
          .where((it) => it.dateLabel.trim() == target)
          .toList();
      if (items.isNotEmpty) {
        filtered.add(
          Section(dayKey: sec.dayKey, dayLabel: sec.dayLabel, items: items),
        );
      }
    }
    return filtered;
  }

  // ✅ NEW: Client-side type filter (chips filter)
  List<Section> _applyLocalTypeFilter(List<Section> sections) {
    if (sections.isEmpty) return sections;

    final type = _types[selectedIndex].toUpperCase();
    if (type == "ALL") return sections;

    bool matchItem(WalletHistoryItem it) {
      final bt = _norm(it.badgeType); // WAITING / SENT / RECEIVED
      final bl = _norm(it.badgeLabel); // Waiting / Sent / Received
      final title = _norm(it.title); // Withdraw Requested / Signup Bonus
      final key = bt.isNotEmpty ? bt : bl;

      // ✅ Sent
      if (type == "SENT") return key == "SENT";

      // ✅ Received (includes bonus)
      if (type == "RECEIVED") return key == "RECEIVED";

      // ✅ Withdraw:
      // Backend uses WAITING for withdraw requested, so treat WAITING + title as Withdraw
      if (type == "WITHDRAW") {
        if (key == "WITHDRAW" || key == "WITHDRAWAL") return true;
        if (key == "WAITING" && title.contains("WITHDRAW")) return true;
        if (title.contains("WITHDRAW")) return true; // extra safe
        return false;
      }

      // ✅ Rewards:
      // Backend gives "Signup Bonus" as reward but badgeType is RECEIVED
      if (type == "REWARDS") {
        if (key == "REWARD" || key == "REWARDS") return true;
        if (title.contains("BONUS") || title.contains("REWARD")) return true;
        if (title.contains("SIGNUP")) return true; // Signup Bonus
        return false;
      }

      return false;
    }

    final out = <Section>[];
    for (final sec in sections) {
      final items = sec.items.where(matchItem).toList();
      if (items.isNotEmpty) {
        out.add(
          Section(dayKey: sec.dayKey, dayLabel: sec.dayLabel, items: items),
        );
      }
    }
    return out;
  }

  Future<void> _openDateFilterSheet() async {
    final res = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColor.lightGray,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 12),
              _sheetItem('Today', () => Navigator.pop(context, 'Today')),
              _sheetItem(
                'Yesterday',
                () => Navigator.pop(context, 'Yesterday'),
              ),
              _sheetItem(
                'Custom Date',
                () => Navigator.pop(context, 'Custom Date'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (res == null) return;

    if (res == 'Today') {
      setState(() {
        selectedDay = 'Today';
        selectedDate = DateTime.now();

        selectedIndex = 0; // ✅ reset chips to ALL
      });
    } else if (res == 'Yesterday') {
      setState(() {
        selectedDay = 'Yesterday';
        selectedDate = DateTime.now().subtract(const Duration(days: 1));

        selectedIndex = 0; // ✅ reset chips to ALL
      });
    } else if (res == 'Custom Date') {
      final picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              dialogBackgroundColor: AppColor.white,
              colorScheme: ColorScheme.light(
                primary: AppColor.strongBlue,
                onPrimary: AppColor.iceBlue,
                onSurface: AppColor.black,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: AppColor.strongBlue,
                ),
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        setState(() {
          selectedDate = picked;
          selectedDay = _fmt(picked);

          selectedIndex = 0; // ✅ reset chips to ALL
        });
      }
    }
  }

  Widget _sheetItem(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        child: Row(
          children: [
            Text(
              title,
              style: GoogleFont.Mulish(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColor.black,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }

  String _segmentLabel({required String title, required int count}) =>
      "$count $title";

  int _selectedCount(Counts? c) {
    switch (selectedIndex) {
      case 0:
        return c?.all ?? 0;
      case 1:
        return c?.rewards ?? 0;
      case 2:
        return c?.sent ?? 0;
      case 3:
        return c?.received ?? 0; // ✅ RECEIVED COUNT
      case 4:
        return c?.withdraw ?? 0;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletNotifier);

    final resp = walletState.walletHistoryResponse;
    final data = resp?.data;

    final wallet = data?.wallet;
    final counts = data?.counts;

    final rawSections = data?.sections ?? const <Section>[];

    final dateFiltered = _applyLocalDateFilter(rawSections);
    final typeFiltered = _applyLocalTypeFilter(dateFiltered);

    final localCounts = _localCountsFromSections(dateFiltered);

    // ✅ counts-based final decision
    final selectedType = _types[selectedIndex];
    final selCount = localCounts[selectedType] ?? 0;
    final sections = (selCount == 0) ? <Section>[] : typeFiltered;

    if (walletState.error != null && walletState.error!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppSnackBar.info(context, walletState.error!);
      });
    }

    if (walletState.isLoading) {
      return Scaffold(
        body: Center(child: ThreeDotsLoader(dotColor: AppColor.black)),
      );
    }

    final segments = <String>[
      _segmentLabel(title: "All", count: localCounts["ALL"] ?? 0),
      _segmentLabel(title: "Rewards", count: localCounts["REWARDS"] ?? 0),
      _segmentLabel(title: "Sent", count: localCounts["SENT"] ?? 0),
      _segmentLabel(title: "Received", count: localCounts["RECEIVED"] ?? 0),
      _segmentLabel(title: "Withdraw", count: localCounts["WITHDRAW"] ?? 0),
    ];

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // ✅ refresh calls API (kept)
            await ref
                .read(walletNotifier.notifier)
                .walletHistory(counts: _types[0]);
          },
          child: ListView(
            padding: EdgeInsets.zero,
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
                      'Wallet',
                      style: GoogleFont.Mulish(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColor.mildBlack,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // HEADER CARD
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppImages.walletBCImage),
                  ),
                  gradient: LinearGradient(
                    colors: [AppColor.white, AppColor.veryLightMintGreen],
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
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 115),
                      child: Row(
                        children: [
                          Image.asset(AppImages.wallet, height: 55, width: 62),
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
                              (wallet?.tcoinBalance ?? 0).toString(),
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
                      'TCoin Wallet Balance',
                      style: GoogleFont.Mulish(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColor.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(left: 135),
                      child: Row(
                        children: [
                          Text(
                            wallet?.uid ?? "—",
                            style: GoogleFont.Mulish(
                              fontSize: 13,
                              color: AppColor.darkBlue,
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              final uid = (wallet?.uid ?? "").trim();
                              if (uid.isEmpty) return;

                              await Clipboard.setData(ClipboardData(text: uid));

                              if (!mounted) return;
                              AppSnackBar.success(context, "UID copied: $uid");
                            },
                            child: Image.asset(AppImages.uID, height: 14),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

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

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 58,
                        vertical: 25,
                      ),
                      child: Row(
                        children: [
                          CommonContainer.walletSendBox(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => SendScreen()),
                              );
                            },
                            text: 'Send',
                            image: AppImages.sendArrow,
                          ),
                          const SizedBox(width: 20),
                          CommonContainer.walletSendBox(
                            onTap: () {
                              final myUid = (wallet?.uid ?? "").trim();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ReceiveScreen(toUid: myUid, amount: "0"),
                                ),
                              );
                            },
                            text: 'Receive',
                            image: AppImages.receiveArrow,
                          ),
                          const SizedBox(width: 20),
                          CommonContainer.walletSendBox(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      QrScanScreen(title: 'Scan QR Code'),
                                ),
                              );
                            },
                            text: 'Scan QR',
                            image: AppImages.smallScanQR,
                          ),
                          const SizedBox(width: 20),
                          CommonContainer.walletSendBox(
                            imageHeight: 30,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => WithdrawScreen(),
                                ),
                              );
                            },
                            text: 'Withdraw',
                            image: AppImages.withdraw,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 31),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ReferralScreen()),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColor.surfaceBlue,
                          borderRadius: BorderRadius.circular(15),
                          border: Border(
                            left: BorderSide(color: AppColor.blue, width: 2),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 40,
                            bottom: 25,
                            top: 25,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                AppImages.referFriends,
                                height: 64,
                                width: 75,
                              ),
                              const SizedBox(height: 15),
                              Text(
                                'Refer Friends',
                                style: GoogleFont.Mulish(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Text(
                                    'Let’s Start',
                                    style: GoogleFont.Mulish(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColor.linkBlue,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Image.asset(
                                    AppImages.rightSideArrow,
                                    height: 13,
                                    color: AppColor.linkBlue,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ReviewAndEarn()),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColor.lightMint,
                          borderRadius: BorderRadius.circular(15),
                          border: Border(
                            right: BorderSide(
                              color: AppColor.positiveGreen,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 25,
                            bottom: 25,
                            top: 25,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                AppImages.earnByReview,
                                height: 64,
                                width: 83,
                              ),
                              const SizedBox(height: 15),
                              Text(
                                'Earn by Review',
                                style: GoogleFont.Mulish(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Text(
                                    'Know More',
                                    style: GoogleFont.Mulish(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColor.positiveGreen,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Image.asset(
                                    AppImages.rightSideArrow,
                                    height: 13,
                                    color: AppColor.positiveGreen,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // History header
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
                    GestureDetector(
                      onTap: _openDateFilterSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.8,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.textWhite,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [Image.asset(AppImages.filter, height: 16)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              // ✅ Segment chips (CLICK -> local filter only)
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(segments.length, (index) {
                    final isSelected = selectedIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedIndex = index); // ✅ no API call
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 7),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.grey,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          segments[index],
                          style: GoogleFont.Mulish(
                            color: isSelected ? AppColor.darkBlue : Colors.grey,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 20),

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
                            numberText: "${item.amountSign}${item.amountTcoin}",
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
}

///old///
// class _WalletScreensState extends ConsumerState<WalletScreens>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//
//   DateTime selectedDate = DateTime.now();
//   String selectedDay = 'Today';
//   String _fmt(DateTime d) => DateFormat('dd MMM yyyy').format(d);
//
//   int selectedIndex = 0;
//
//   final List<String> segments = [
//     '50 All',
//     '6 Rewards',
//     '10 Sent',
//     '10 Received',
//   ];
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
//   Future<void> _openDateFilterSheet() async {
//     final res = await showModalBottomSheet<String>(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: false,
//       builder: (_) {
//         return Container(
//           padding: EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: AppColor.white,
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 44,
//                 height: 5,
//                 decoration: BoxDecoration(
//                   color: AppColor.lightGray,
//                   borderRadius: BorderRadius.circular(999),
//                 ),
//               ),
//               SizedBox(height: 12),
//
//               _sheetItem('Today', () => Navigator.pop(context, 'Today')),
//               _sheetItem(
//                 'Yesterday',
//                 () => Navigator.pop(context, 'Yesterday'),
//               ),
//               _sheetItem(
//                 'Custom Date',
//                 () => Navigator.pop(context, 'Custom Date'),
//               ),
//
//               SizedBox(height: 8),
//             ],
//           ),
//         );
//       },
//     );
//
//     if (res == null) return;
//
//     if (res == 'Today') {
//       setState(() {
//         selectedDay = 'Today';
//         selectedDate = DateTime.now();
//       });
//     } else if (res == 'Yesterday') {
//       setState(() {
//         selectedDay = 'Yesterday';
//         selectedDate = DateTime.now().subtract(const Duration(days: 1));
//       });
//     } else if (res == 'Custom Date') {
//       final picked = await showDatePicker(
//         context: context,
//         initialDate: selectedDate,
//         firstDate: DateTime(2000),
//         lastDate: DateTime(2100),
//         builder: (context, child) {
//           return Theme(
//             data: Theme.of(context).copyWith(
//               dialogBackgroundColor: AppColor.white,
//               colorScheme: ColorScheme.light(
//                 primary: AppColor.strongBlue,
//                 onPrimary: AppColor.iceBlue,
//                 onSurface: AppColor.black,
//               ),
//               textButtonTheme: TextButtonThemeData(
//                 style: TextButton.styleFrom(
//                   foregroundColor: AppColor.strongBlue,
//                 ),
//               ),
//             ),
//             child: child!,
//           );
//         },
//       );
//
//       if (picked != null) {
//         setState(() {
//           selectedDate = picked;
//           selectedDay = _fmt(picked);
//         });
//       }
//     }
//   }
//
//   Widget _sheetItem(String title, VoidCallback onTap) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(14),
//       child: Padding(
//         padding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
//         child: Row(
//           children: [
//             Text(
//               title,
//               style: GoogleFont.Mulish(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w700,
//                 color: AppColor.black,
//               ),
//             ),
//             Spacer(),
//             Icon(Icons.chevron_right, size: 20),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
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
//                       'Wallet',
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
//                     colors: [AppColor.white, AppColor.veryLightMintGreen],
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
//                           Image.asset(AppImages.wallet, height: 55, width: 62),
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
//                               '150',
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
//                       'TCoin Wallet Balance',
//                       style: GoogleFont.Mulish(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w700,
//                         color: AppColor.darkBlue,
//                       ),
//                     ),
//                     SizedBox(height: 5),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 149),
//                       child: Row(
//                         children: [
//                           Text(
//                             'UID886UI38',
//                             style: GoogleFont.Mulish(
//                               fontSize: 13,
//                               color: AppColor.darkBlue,
//                             ),
//                           ),
//                           SizedBox(width: 6),
//                           Image.asset(AppImages.uID, height: 14),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: 30),
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
//                     SizedBox(height: 0),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 58,
//                         vertical: 25,
//                       ),
//                       child: Row(
//                         children: [
//                           CommonContainer.walletSendBox(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => SendScreen(),
//                                 ),
//                               );
//                             },
//                             text: 'Send',
//                             image: AppImages.sendArrow,
//                           ),
//                           SizedBox(width: 20),
//                           CommonContainer.walletSendBox(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => ReceiveScreen(),
//                                 ),
//                               );
//                             },
//                             text: 'Receive',
//                             image: AppImages.receiveArrow,
//                           ),
//                           SizedBox(width: 20),
//                           CommonContainer.walletSendBox(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) =>
//                                       QrScanScreen(title: 'Scan QR Code'),
//                                 ),
//                               );
//                             },
//                             text: 'Scan QR',
//                             image: AppImages.smallScanQR,
//                           ),
//                           SizedBox(width: 20),
//                           CommonContainer.walletSendBox(
//                             imageHeight: 30,
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => WithdrawScreen(),
//                                 ),
//                               );
//                             },
//                             text: 'Withdraw',
//                             image: AppImages.withdraw,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 31),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 15),
//                 child: Row(
//                   children: [
//                     InkWell(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => ReferralScreen(),
//                           ),
//                         );
//                       },
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: AppColor.surfaceBlue,
//                           borderRadius: BorderRadius.circular(15),
//                           border: Border(
//                             left: BorderSide(color: AppColor.blue, width: 2),
//                           ),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.only(
//                             left: 20,
//                             right: 40,
//                             bottom: 25,
//                             top: 25,
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Image.asset(
//                                 AppImages.referFriends,
//                                 height: 64,
//                                 width: 75,
//                               ),
//                               SizedBox(height: 15),
//                               Text(
//                                 'Refer Friends',
//                                 style: GoogleFont.Mulish(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w700,
//                                   color: AppColor.darkBlue,
//                                 ),
//                               ),
//                               SizedBox(height: 3),
//                               Row(
//                                 children: [
//                                   Text(
//                                     'Let’s Start',
//                                     style: GoogleFont.Mulish(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w700,
//                                       color: AppColor.linkBlue,
//                                     ),
//                                   ),
//                                   SizedBox(width: 8),
//                                   Image.asset(
//                                     AppImages.rightSideArrow,
//                                     height: 13,
//                                     color: AppColor.linkBlue,
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 20),
//                     InkWell(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => ReviewAndEarn(),
//                           ),
//                         );
//                       },
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: AppColor.lightMint,
//                           borderRadius: BorderRadius.circular(15),
//                           border: Border(
//                             right: BorderSide(
//                               color: AppColor.positiveGreen,
//                               width: 2,
//                             ),
//                           ),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.only(
//                             left: 20,
//                             right: 25,
//                             bottom: 25,
//                             top: 25,
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Image.asset(
//                                 AppImages.earnByReview,
//                                 height: 64,
//                                 width: 83,
//                               ),
//                               SizedBox(height: 15),
//                               Text(
//                                 'Earn by Review',
//                                 style: GoogleFont.Mulish(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w700,
//                                   color: AppColor.darkBlue,
//                                 ),
//                               ),
//                               SizedBox(height: 3),
//                               Row(
//                                 children: [
//                                   Text(
//                                     'Know More',
//                                     style: GoogleFont.Mulish(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w700,
//                                       color: AppColor.positiveGreen,
//                                     ),
//                                   ),
//                                   SizedBox(width: 8),
//                                   Image.asset(
//                                     AppImages.rightSideArrow,
//                                     height: 13,
//                                     color: AppColor.positiveGreen,
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 26),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 15),
//                 child: Row(
//                   children: [
//                     Text(
//                       'History',
//                       style: GoogleFont.Mulish(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 28,
//                         color: AppColor.darkBlue,
//                       ),
//                     ),
//                     Spacer(),
//                     GestureDetector(
//                       onTap: _openDateFilterSheet,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12.8,
//                           vertical: 8,
//                         ),
//                         decoration: BoxDecoration(
//                           color: AppColor.textWhite,
//                           borderRadius: BorderRadius.circular(25),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             // Text(
//                             //   selectedDay,
//                             //   style: GoogleFont.Mulish(
//                             //     fontSize: 12,
//                             //     fontWeight: FontWeight.w600,
//                             //     color: AppColor.black,
//                             //   ),
//                             // ),
//                             // SizedBox(width: 5),
//                             Image.asset(AppImages.filter, height: 16),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 26),
//               SingleChildScrollView(
//                 padding: EdgeInsets.symmetric(horizontal: 15),
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   children: List.generate(segments.length, (index) {
//                     bool isSelected = selectedIndex == index;
//
//                     return GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           selectedIndex = index;
//                         });
//                       },
//                       child: Container(
//                         margin: EdgeInsets.only(right: 7),
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 28,
//                           vertical: 6,
//                         ),
//                         decoration: BoxDecoration(
//                           color: isSelected ? Colors.white : Colors.transparent,
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(
//                             color: isSelected ? Colors.black : Colors.grey,
//                             width: 1.5,
//                           ),
//                         ),
//                         child: Text(
//                           segments[index],
//                           style: GoogleFont.Mulish(
//                             color: isSelected ? AppColor.darkBlue : Colors.grey,
//                             fontWeight: isSelected
//                                 ? FontWeight.w800
//                                 : FontWeight.w500,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),
//                     );
//                   }),
//                 ),
//               ),
//               SizedBox(height: 20),
//               Text(
//                 selectedDay,
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
//                       containerColor: AppColor.lightGreenBg,
//                       mainText: 'Abdul kalam',
//
//                       timeText: '10.40Pm',
//                       numberText: '30',
//                       endText: 'Received',
//                       numberTextColor: AppColor.green,
//                       endTextColor: AppColor.green,
//                     ),
//                     SizedBox(height: 10),
//                     CommonContainer.walletHistoryBox(
//                       upiTexts: false,
//                       containerColor: AppColor.pinkSurface,
//                       mainText: 'Stalin',
//                       timeText: '10.40Pm',
//                       numberText: '15',
//                       endText: 'Send',
//                       numberTextColor: AppColor.lightRed,
//                       endTextColor: AppColor.lightRed,
//                     ),
//                     SizedBox(height: 20),
//                     Text(
//                       selectedDay,
//                       style: GoogleFont.Mulish(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w700,
//                         color: AppColor.darkGrey,
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                     CommonContainer.walletHistoryBox(
//                       upiTexts: true,
//                       containerColor: AppColor.lightBlueGray,
//                       mainText: 'Withdraw Requested',
//                       upiText: '4587458788@Upi',
//                       timeText: '10.40Pm',
//                       numberText: '₹12',
//                       endText: 'Waiting',
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
// }
