import 'dart:async';
import 'dart:convert';

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

  // ✅ for navigation after success
  String? _pendingToUid;
  String? _pendingAmount;

  // ✅ manual listener subscription
  ProviderSubscription<WalletState>? _sendSub;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    // ✅ FIX: initState -> use listenManual (NOT ref.listen)
    _sendSub = ref.listenManual<WalletState>(walletNotifier, (prev, next) {
      final wasSending = prev?.isMsgSendingLoading == true;
      final doneSending = wasSending && next.isMsgSendingLoading == false;
      if (!doneSending) return;

      // ✅ if error
      final err = next.error;
      if (err != null && err.trim().isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) AppSnackBar.error(context, err);
        });
        return;
      }

      // ✅ if success
      final ok = next.sendTcoinData?.success == true;
      if (ok) {
        final toUid = _pendingToUid ?? _messageController.text.trim();
        final amt = _pendingAmount ?? _amountController.text.trim();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          _amountController.clear();

          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //     builder: (_) => ReceiveScreen(toUid: toUid, amount: amt),
          //   ),
          // );
        });
      }
    });

    // ✅ prefill from QR / deeplink
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final pre = (widget.initialToUid ?? '').trim();
      if (pre.isEmpty) return;

      _messageController.text = pre;
      _messageController.selection = TextSelection.fromPosition(
        TextPosition(offset: _messageController.text.length),
      );

      setState(() => _isFetchingName = true);
      await ref
          .read(walletNotifier.notifier)
          .fetchUidPersonName(pre, load: false);

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

    _isUidEmpty = _messageController.text.trim().isEmpty;

    _messageController.addListener(() {
      final uid = _messageController.text.trim();
      final emptyNow = uid.isEmpty;

      if (emptyNow != _isUidEmpty) setState(() => _isUidEmpty = emptyNow);

      if (uid.isEmpty) {
        if (_receiverName.isNotEmpty || _isFetchingName) {
          setState(() {
            _receiverName = "";
            _isFetchingName = false;
          });
        }
        return;
      }

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
    _sendSub?.close(); // ✅ IMPORTANT
    _controller.dispose();
    _messageController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _sendNow() async {
    final uid = _messageController.text.trim();
    final amount = _amountController.text.trim();

    if (uid.isEmpty) return AppSnackBar.error(context, "Please enter UID");
    if (amount.isEmpty)
      return AppSnackBar.error(context, "Please enter amount");

    final n = num.tryParse(amount);
    if (n == null || n <= 0)
      return AppSnackBar.error(context, "Enter valid amount");

    final myUid =
        (ref.read(walletNotifier).walletHistoryResponse?.data.wallet.uid ?? "")
            .trim();

    if (myUid.isNotEmpty && uid.toUpperCase() == myUid.toUpperCase()) {
      return AppSnackBar.error(context, "CANNOT_SEND_TO_SELF");
    }

    final data = await ref
        .read(walletNotifier.notifier)
        .uIDSendApi(toUid: uid, tcoin: amount);

    if (!mounted) return;

    if (data == null) {
      final err = ref.read(walletNotifier).sendError ?? "Send failed";
      AppSnackBar.error(context, err);
      return;
    }

    // ✅ success -> navigate
    AppSnackBar.success(
      context,
      "Sent successfully. Balance: ${data.fromBalance}",
    );

    _amountController.clear();

    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => ReceiveScreen(toUid: uid, amount: amount),
    //   ),
    // );
  }

  String? _extractUidFromQr(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return null;

    // Case 1: plain UID (example: "U12345" / "abc123")
    final plainUidOk = RegExp(r'^[A-Za-z0-9_-]{3,64}$');
    if (plainUidOk.hasMatch(v) && !v.contains('://')) return v;

    // Case 2: url / deepLink like: hoppr://qr?toUid=XXX  or  ...?uid=XXX
    final uri = Uri.tryParse(v);
    if (uri != null) {
      final qp = uri.queryParameters;

      // direct params
      final direct = (qp['toUid'] ?? qp['uid'] ?? qp['u'])?.trim();
      if (direct != null && direct.isNotEmpty) return direct;

      // Case 3: payload=BASE64URL_JSON  (your earlier flow)
      final payload = qp['payload']?.trim();
      if (payload != null && payload.isNotEmpty) {
        try {
          final normalized = base64Url.normalize(payload);
          final decoded = utf8.decode(base64Url.decode(normalized));
          final map = json.decode(decoded);
          if (map is Map) {
            final puid = (map['toUid'] ?? map['uid'])?.toString().trim();
            if (puid != null && puid.isNotEmpty) return puid;
          }
        } catch (_) {}
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletNotifier);

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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 115),
                      child: Row(
                        children: [
                          Image.asset(AppImages.wallet, height: 55, width: 62),
                          const SizedBox(width: 15),
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                AppColor.brandBlue,
                                AppColor.accentCyan,
                                AppColor.successGreen,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: Text(
                              widget.tCoinBalance.toString(),
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
                            widget.uid,
                            style: GoogleFont.Mulish(
                              fontSize: 13,
                              color: AppColor.darkBlue,
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              final uid = widget.uid.trim();
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

                    TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
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
                              final uid = _extractUidFromQr(result);

                              if (uid == null) {
                                if (!mounted) return;
                                AppSnackBar.error(
                                  context,
                                  "Invalid QR (UID not found)",
                                );
                                return;
                              }

                              _messageController.text = uid;
                              _messageController.selection =
                                  TextSelection.fromPosition(
                                    TextPosition(
                                      offset: _messageController.text.length,
                                    ),
                                  );
                            }

                            // if (result != null && result.isNotEmpty) {
                            //   _messageController.text = result;
                            //   _messageController.selection =
                            //       TextSelection.fromPosition(
                            //         TextPosition(
                            //           offset: _messageController.text.length,
                            //         ),
                            //       );
                            // }
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

                    if (_isUidEmpty)
                      Text(
                        'Waiting to fetch person name',
                        style: GoogleFont.Mulish(
                          fontSize: 14,
                          color: AppColor.darkGrey,
                        ),
                      )
                    else if (_isFetchingName)
                      Text(
                        'Fetching name...',
                        style: GoogleFont.Mulish(
                          fontSize: 14,
                          color: AppColor.darkGrey,
                        ),
                      )
                    else
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
                            _receiverName,
                            style: GoogleFont.Mulish(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColor.blue,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 25),

                    Text(
                      'Amount',
                      style: GoogleFont.Mulish(
                        fontSize: 14,
                        color: AppColor.mildBlack,
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
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
                      onTap: walletState.isMsgSendingLoading ? null : _sendNow,
                      text: walletState.isMsgSendingLoading
                          ? ThreeDotsLoader()
                          : const Text('Send Now'),
                      imagePath: walletState.isMsgSendingLoading
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

// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:tringo_app/Presentation/OnBoarding/Screens/wallet/Screens/qr_scan_screen.dart';
// import 'package:tringo_app/Presentation/OnBoarding/Screens/wallet/Screens/receive_screen.dart';
//
// import '../../../../../Core/Utility/app_Images.dart';
// import '../../../../../Core/Utility/app_color.dart';
// import '../../../../../Core/Utility/app_loader.dart';
// import '../../../../../Core/Utility/app_snackbar.dart';
// import '../../../../../Core/Utility/google_font.dart';
// import '../../../../../Core/Widgets/common_container.dart';
// import '../Controller/wallet_notifier.dart';
//
// class SendScreen extends ConsumerStatefulWidget {
//   final String uid;
//   final String tCoinBalance;
//   final String? initialToUid;
//
//   const SendScreen({
//     super.key,
//     required this.uid,
//     required this.tCoinBalance,
//     this.initialToUid,
//   });
//
//   @override
//   ConsumerState<SendScreen> createState() => _SendScreenState();
// }
//
// class _SendScreenState extends ConsumerState<SendScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//
//   final TextEditingController _messageController =
//       TextEditingController(); // UID
//   final TextEditingController _amountController = TextEditingController();
//
//   Timer? _uidDebounce;
//
//   bool _isUidEmpty = true;
//   bool _isFetchingName = false;
//
//   String _receiverName = "";
//
//
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(vsync: this);
//
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       final pre = (widget.initialToUid ?? '').trim();
//       if (pre.isEmpty) return;
//
//       _messageController.text = pre;
//       _messageController.selection = TextSelection.fromPosition(
//         TextPosition(offset: _messageController.text.length),
//       );
//
//       // optional: immediately fetch name (no need wait debounce)
//       setState(() => _isFetchingName = true);
//       await ref
//           .read(walletNotifier.notifier)
//           .fetchUidPersonName(pre, load: false);
//
//       if (!mounted) return;
//       final res = ref.read(walletNotifier).uidNameResponse;
//       final dn = res?.data.displayName;
//
//       setState(() {
//         _receiverName = (dn != null && dn.trim().isNotEmpty)
//             ? dn.trim()
//             : "Unknown";
//         _isFetchingName = false;
//       });
//     });
//
//     _isUidEmpty = _messageController.text.trim().isEmpty;
//
//     _messageController.addListener(() {
//       final uid = _messageController.text.trim();
//       final emptyNow = uid.isEmpty;
//
//       if (emptyNow != _isUidEmpty) {
//         setState(() => _isUidEmpty = emptyNow);
//       }
//
//       // ✅ if cleared, reset name
//       if (uid.isEmpty) {
//         if (_receiverName.isNotEmpty || _isFetchingName) {
//           setState(() {
//             _receiverName = "";
//             _isFetchingName = false;
//           });
//         }
//         return;
//       }
//
//       // ✅ debounce typing
//       _uidDebounce?.cancel();
//       _uidDebounce = Timer(const Duration(milliseconds: 500), () async {
//         if (!mounted) return;
//
//         setState(() => _isFetchingName = true);
//
//         await ref
//             .read(walletNotifier.notifier)
//             .fetchUidPersonName(uid, load: false);
//
//         if (!mounted) return;
//
//         final res = ref.read(walletNotifier).uidNameResponse;
//         final dn = res?.data.displayName;
//
//         setState(() {
//           _receiverName = (dn != null && dn.trim().isNotEmpty)
//               ? dn.trim()
//               : "Unknown";
//           _isFetchingName = false;
//         });
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     _uidDebounce?.cancel();
//     _controller.dispose();
//     _messageController.dispose();
//     _amountController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _sendNow() async {
//     final uid = _messageController.text.trim();
//     final amount = _amountController.text.trim();
//
//     if (uid.isEmpty) {
//       AppSnackBar.error(context, "Please enter UID");
//       return;
//     }
//     if (amount.isEmpty) {
//       AppSnackBar.error(context, "Please enter amount");
//       return;
//     }
//
//     final n = num.tryParse(amount);
//     if (n == null || n <= 0) {
//       AppSnackBar.error(context, "Enter valid amount");
//       return;
//     }
//
//     // ✅ FROM UID (your own)
//     final myUid =
//         (ref.read(walletNotifier).walletHistoryResponse?.data.wallet.uid ?? "")
//             .trim();
//
//     // ✅ prevent self-transfer
//     if (myUid.isNotEmpty && uid.toUpperCase() == myUid.toUpperCase()) {
//       AppSnackBar.error(context, "CANNOT_SEND_TO_SELF");
//       return;
//     }
//
//     // ✅ call API
//     await ref
//         .read(walletNotifier.notifier)
//         .uIDSendApi(toUid: uid, tcoin: amount);
//
//     if (!mounted) return;
//
//     final st = ref.read(walletNotifier);
//
//     // ✅ show API error message
//     if (st.error != null && st.error!.trim().isNotEmpty) {
//       AppSnackBar.error(context, st.error!);
//       return;
//     }
//
//     final res = st.sendTcoinData;
//
//     if (res != null && res.success == true) {
//       AppSnackBar.success(
//         context,
//         "Sent successfully. Balance: ${res.fromBalance}",
//       );
//
//       final sentUid = uid;
//       final sentAmount = amount;
//
//       _amountController.clear();
//
//       // ✅ Navigate to ReceiveScreen with UID + Amount
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => ReceiveScreen(toUid: sentUid, amount: sentAmount),
//         ),
//       );
//     } else {
//       AppSnackBar.error(context, "Send failed");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final walletState = ref.watch(walletNotifier);
//
//     if (walletState.isLoading && walletState.walletHistoryResponse == null) {
//       return Scaffold(
//         body: Center(child: ThreeDotsLoader(dotColor: AppColor.black)),
//       );
//     }
//
//     final resp = walletState.walletHistoryResponse;
//     final wallet = resp?.data.wallet;
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
//               // TOP BAR
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
//
//               const SizedBox(height: 41),
//
//               // HEADER CARD (wallet balance)
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
//                           Image.asset(AppImages.wallet, height: 55, width: 62),
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
//                               (widget.tCoinBalance ?? 0).toString(),
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
//                       'TCoin Wallet Balance',
//                       style: GoogleFont.Mulish(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w700,
//                         color: AppColor.darkBlue,
//                       ),
//                     ),
//                     const SizedBox(height: 5),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 149),
//                       child: Row(
//                         children: [
//                           Text(
//                             widget.uid ?? "—",
//                             style: GoogleFont.Mulish(
//                               fontSize: 13,
//                               color: AppColor.darkBlue,
//                             ),
//                           ),
//                           const SizedBox(width: 6),
//                           InkWell(
//                             borderRadius: BorderRadius.circular(12),
//                             onTap: () async {
//                               final uid = (widget.uid ?? "").trim();
//                               if (uid.isEmpty) return;
//
//                               await Clipboard.setData(ClipboardData(text: uid));
//
//                               if (!mounted) return;
//                               AppSnackBar.success(context, "UID copied: $uid");
//                             },
//                             child: Image.asset(AppImages.uID, height: 14),
//                           ),
//                           // Image.asset(AppImages.uID, height: 14),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 25),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 32),
//
//               // FORM
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
//                     const SizedBox(height: 10),
//
//                     // UID FIELD
//                     TextField(
//                       controller: _messageController,
//                       decoration: InputDecoration(
//                         hintText: "",
//                         filled: true,
//                         fillColor: Colors.grey[200],
//                         suffixIcon: InkWell(
//                           onTap: () async {
//                             final result = await Navigator.push<String>(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) =>
//                                     const QrScanScreen(title: 'Scan QR Code'),
//                               ),
//                             );
//
//                             if (result != null && result.isNotEmpty) {
//                               _messageController.text = result;
//
//                               // Optional: move cursor to end
//                               _messageController.selection =
//                                   TextSelection.fromPosition(
//                                     TextPosition(
//                                       offset: _messageController.text.length,
//                                     ),
//                                   );
//                             }
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
//
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 10),
//
//                     if (_isUidEmpty) ...[
//                       Text(
//                         'Waiting to fetch person name',
//                         style: GoogleFont.Mulish(
//                           fontSize: 14,
//                           color: AppColor.darkGrey,
//                         ),
//                       ),
//                     ] else if (_isFetchingName) ...[
//                       Text(
//                         'Fetching name...',
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
//                             _receiverName.isEmpty ? "" : _receiverName,
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
//                     const SizedBox(height: 25),
//
//                     Text(
//                       'Amount',
//                       style: GoogleFont.Mulish(
//                         fontSize: 14,
//                         color: AppColor.mildBlack,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//
//                     // AMOUNT FIELD
//                     TextField(
//                       controller: _amountController,
//                       keyboardType: TextInputType.number,
//                       decoration: InputDecoration(
//                         hintText: "",
//                         filled: true,
//                         fillColor: Colors.grey[200],
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 25),
//
//                     CommonContainer.button(
//                       buttonColor: AppColor.darkBlue,
//                       onTap: walletState.isMsgSendingLoading ? null : _sendNow,
//                       text: walletState.isMsgSendingLoading
//                           ? ThreeDotsLoader()
//                           : const Text('Send Now'),
//                       imagePath: walletState.isMsgSendingLoading
//                           ? null
//                           : AppImages.rightSideArrow,
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
