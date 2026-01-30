import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/wallet/Screens/qr_scan_screen.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/wallet/Screens/receive_screen.dart';

import '../../../../../Core/Utility/app_Images.dart';
import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/app_loader.dart';
import '../../../../../Core/Utility/app_snackbar.dart';
import '../../../../../Core/Utility/google_font.dart';
import '../../../../../Core/Widgets/common_container.dart';
import '../Controller/wallet_notifier.dart';

class SendScreen extends ConsumerStatefulWidget {
  final String uid;
  final String tCoinBalance;
  final String? initialToUid;

  const SendScreen({
    super.key,
    required this.uid,
    required this.tCoinBalance,
    this.initialToUid,
  });

  @override
  ConsumerState<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends ConsumerState<SendScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final TextEditingController _messageController =
      TextEditingController(); // UID
  final TextEditingController _amountController = TextEditingController();

  Timer? _uidDebounce;

  bool _isUidEmpty = true;
  bool _isFetchingName = false;

  String _receiverName = "";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final pre = (widget.initialToUid ?? '').trim();
      if (pre.isEmpty) return;

      _messageController.text = pre;
      _messageController.selection = TextSelection.fromPosition(
        TextPosition(offset: _messageController.text.length),
      );

      // optional: immediately fetch name (no need wait debounce)
      setState(() => _isFetchingName = true);
      await ref.read(walletNotifier.notifier).fetchUidPersonName(pre, load: false);

      if (!mounted) return;
      final res = ref.read(walletNotifier).uidNameResponse;
      final dn = res?.data.displayName;

      setState(() {
        _receiverName =
        (dn != null && dn.trim().isNotEmpty) ? dn.trim() : "Unknown";
        _isFetchingName = false;
      });
    });

    _isUidEmpty = _messageController.text.trim().isEmpty;

    _messageController.addListener(() {
      final uid = _messageController.text.trim();
      final emptyNow = uid.isEmpty;

      if (emptyNow != _isUidEmpty) {
        setState(() => _isUidEmpty = emptyNow);
      }

      // ✅ if cleared, reset name
      if (uid.isEmpty) {
        if (_receiverName.isNotEmpty || _isFetchingName) {
          setState(() {
            _receiverName = "";
            _isFetchingName = false;
          });
        }
        return;
      }

      // ✅ debounce typing
      _uidDebounce?.cancel();
      _uidDebounce = Timer(const Duration(milliseconds: 500), () async {
        if (!mounted) return;

        setState(() => _isFetchingName = true);

        await ref
            .read(walletNotifier.notifier)
            .fetchUidPersonName(uid, load: false);

        if (!mounted) return;

        final res = ref.read(walletNotifier).uidNameResponse;
        final dn = res?.data.displayName;

        setState(() {
          _receiverName = (dn != null && dn.trim().isNotEmpty)
              ? dn.trim()
              : "Unknown";
          _isFetchingName = false;
        });
      });
    });
  }

  @override
  void dispose() {
    _uidDebounce?.cancel();
    _controller.dispose();
    _messageController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _sendNow() async {
    final uid = _messageController.text.trim();
    final amount = _amountController.text.trim();

    if (uid.isEmpty) {
      AppSnackBar.error(context, "Please enter UID");
      return;
    }
    if (amount.isEmpty) {
      AppSnackBar.error(context, "Please enter amount");
      return;
    }

    final n = num.tryParse(amount);
    if (n == null || n <= 0) {
      AppSnackBar.error(context, "Enter valid amount");
      return;
    }

    // ✅ FROM UID (your own)
    final myUid =
        (ref.read(walletNotifier).walletHistoryResponse?.data.wallet.uid ?? "")
            .trim();

    // ✅ prevent self-transfer
    if (myUid.isNotEmpty && uid.toUpperCase() == myUid.toUpperCase()) {
      AppSnackBar.error(context, "CANNOT_SEND_TO_SELF");
      return;
    }

    // ✅ call API
    await ref
        .read(walletNotifier.notifier)
        .uIDSendApi(toUid: uid, tcoin: amount);

    if (!mounted) return;

    final st = ref.read(walletNotifier);

    // ✅ show API error message
    if (st.error != null && st.error!.trim().isNotEmpty) {
      AppSnackBar.error(context, st.error!);
      return;
    }

    final res = st.sendTcoinData;

    if (res != null && res.success == true) {
      AppSnackBar.success(
        context,
        "Sent successfully. Balance: ${res.fromBalance}",
      );

      final sentUid = uid;
      final sentAmount = amount;

      _amountController.clear();

      // ✅ Navigate to ReceiveScreen with UID + Amount
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReceiveScreen(toUid: sentUid, amount: sentAmount),
        ),
      );
    } else {
      AppSnackBar.error(context, "Send failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletNotifier);

    final resp = walletState.walletHistoryResponse;
    final wallet = resp?.data.wallet;

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
                      'Send',
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

              // HEADER CARD (wallet balance)
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
                              (widget.tCoinBalance ?? 0).toString(),
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
                      padding: const EdgeInsets.only(left: 149),
                      child: Row(
                        children: [
                          Text(
                            widget.uid ?? "—",
                            style: GoogleFont.Mulish(
                              fontSize: 13,
                              color: AppColor.darkBlue,
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              final uid = (widget.uid ?? "").trim();
                              if (uid.isEmpty) return;

                              await Clipboard.setData(ClipboardData(text: uid));

                              if (!mounted) return;
                              AppSnackBar.success(context, "UID copied: $uid");
                            },
                            child: Image.asset(AppImages.uID, height: 14),
                          ),
                          // Image.asset(AppImages.uID, height: 14),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // FORM
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter UID',
                      style: GoogleFont.Mulish(
                        fontSize: 14,
                        color: AppColor.mildBlack,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // UID FIELD
                    TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "",
                        filled: true,
                        fillColor: Colors.grey[200],
                        suffixIcon: InkWell(
                          onTap: () async {
                            final result = await Navigator.push<String>(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const QrScanScreen(title: 'Scan QR Code'),
                              ),
                            );

                            if (result != null && result.isNotEmpty) {
                              _messageController.text = result;

                              // Optional: move cursor to end
                              _messageController.selection =
                                  TextSelection.fromPosition(
                                    TextPosition(
                                      offset: _messageController.text.length,
                                    ),
                                  );
                            }
                          },
                          borderRadius: BorderRadius.circular(15),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            child: Image.asset(
                              AppImages.smallScanQRBlack,
                              width: 27,
                              color: AppColor.darkBlue,
                            ),
                          ),
                        ),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    if (_isUidEmpty) ...[
                      Text(
                        'Waiting to fetch person name',
                        style: GoogleFont.Mulish(
                          fontSize: 14,
                          color: AppColor.darkGrey,
                        ),
                      ),
                    ] else if (_isFetchingName) ...[
                      Text(
                        'Fetching name...',
                        style: GoogleFont.Mulish(
                          fontSize: 14,
                          color: AppColor.darkGrey,
                        ),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Text(
                            'To ',
                            style: GoogleFont.Mulish(
                              fontSize: 14,
                              color: AppColor.darkGrey,
                            ),
                          ),
                          Text(
                            _receiverName.isEmpty ? "" : _receiverName,
                            style: GoogleFont.Mulish(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColor.blue,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 25),

                    Text(
                      'Amount',
                      style: GoogleFont.Mulish(
                        fontSize: 14,
                        color: AppColor.mildBlack,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // AMOUNT FIELD
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "",
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    CommonContainer.button(
                      buttonColor: AppColor.darkBlue,
                      onTap: _sendNow,
                      // onTap: () {
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(builder: (_) => ReceiveScreen()),
                      //   );
                      // },
                      text: walletState.isLoading
                          ? ThreeDotsLoader()
                          : Text('Send Now'),
                      imagePath: walletState.isLoading
                          ? null
                          : AppImages.rightSideArrow,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class _SendScreenState extends ConsumerState<SendScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   final TextEditingController _messageController = TextEditingController();
//   final TextEditingController _amountController = TextEditingController();
//
//   bool _isUidEmpty = true;
//   String _receiverName = "Ashok"; // later API fetch name set pannalam
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(vsync: this);
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // ✅ initial load only (keep as ALL or your selectedIndex)
//       ref.read(walletNotifier.notifier).walletHistory();
//     });
//
//     _isUidEmpty = _messageController.text.trim().isEmpty;
//
//     _messageController.addListener(() {
//       final emptyNow = _messageController.text.trim().isEmpty;
//       if (emptyNow != _isUidEmpty) {
//         setState(() => _isUidEmpty = emptyNow);
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     _messageController.dispose();
//     _amountController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final walletState = ref.watch(walletNotifier);
//     final fetchUidPersonName = ref.watch(walletNotifier);
//     final name = walletState.uidNameResponse;
//     final resp = walletState.walletHistoryResponse;
//     final data = resp?.data;
//     final wallet = data?.wallet;
//
//     if (walletState.isLoading) {
//       return Scaffold(
//         body: Center(child: ThreeDotsLoader(dotColor: AppColor.black)),
//       );
//     }
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
//                       'Send',
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
//                               (wallet?.tcoinBalance ?? 0).toString(),
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
//                             wallet?.uid ?? "—",
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
//                     SizedBox(height: 25),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 32),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 15),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Enter UID',
//                       style: GoogleFont.Mulish(
//                         fontSize: 14,
//                         color: AppColor.mildBlack,
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     TextField(
//                       controller: _messageController,
//                       decoration: InputDecoration(
//                         hintText: "",
//                         filled: true,
//                         fillColor: Colors.grey[200],
//                         suffixIcon: InkWell(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) =>
//                                     QrScanScreen(title: 'Scan QR Code'),
//                               ),
//                             );
//                           },
//                           borderRadius: BorderRadius.circular(15),
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 25),
//                             child: Image.asset(
//                               AppImages.smallScanQRBlack,
//                               width: 27,
//                               color: AppColor.darkBlue,
//                             ),
//                           ),
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 10),
//
//                     if (_isUidEmpty) ...[
//                       Text(
//                         'Waiting to fetch person name',
//                         style: GoogleFont.Mulish(
//                           fontSize: 14,
//                           color: AppColor.darkGrey,
//                         ),
//                       ),
//                     ] else ...[
//                       Row(
//                         children: [
//                           Text(
//                             'To ',
//                             style: GoogleFont.Mulish(
//                               fontSize: 14,
//                               color: AppColor.darkGrey,
//                             ),
//                           ),
//                           Text(
//                             _receiverName,
//                             style: GoogleFont.Mulish(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w700,
//                               color: AppColor.blue,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//
//                     SizedBox(height: 25),
//                     Text(
//                       'Amount',
//                       style: GoogleFont.Mulish(
//                         fontSize: 14,
//                         color: AppColor.mildBlack,
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     TextField(
//                       controller: _amountController,
//                       decoration: InputDecoration(
//                         hintText: "",
//                         filled: true,
//                         fillColor: Colors.grey[200],
//
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 25),
//                     CommonContainer.button(
//                       buttonColor: AppColor.darkBlue,
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => ReceiveScreen(),
//                           ),
//                         );
//                       },
//                       text: Text('Send Now'),
//                       imagePath: AppImages.rightSideArrow,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
