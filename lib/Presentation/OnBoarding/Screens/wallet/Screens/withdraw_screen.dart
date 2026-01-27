import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../Core/Utility/app_Images.dart';
import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/app_loader.dart';
import '../../../../../Core/Utility/app_snackbar.dart';
import '../../../../../Core/Utility/google_font.dart';
import '../../../../../Core/Widgets/common_container.dart';
import '../Controller/wallet_notifier.dart';

class WithdrawScreen extends ConsumerStatefulWidget {
  const WithdrawScreen({super.key});

  @override
  ConsumerState<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends ConsumerState<WithdrawScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final TextEditingController _uPIIDController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(walletNotifier.notifier).walletHistory();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _uPIIDController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // ✅ extract number from "₹120" or "120"
  double _parseRateToNumber(String rateText) {
    final cleaned = rateText.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  Future<void> _raiseWithdraw({
    required String upi,
    required String tcoin,
  }) async {
    if (upi.isEmpty) {
      AppSnackBar.error(context, "Please enter UPI Id");
      return;
    }
    if (tcoin.isEmpty) {
      AppSnackBar.error(context, "Please enter amount");
      return;
    }

    final n = num.tryParse(tcoin);
    if (n == null || n <= 0) {
      AppSnackBar.error(context, "Enter valid amount");
      return;
    }

    await ref
        .read(walletNotifier.notifier)
        .uIDWithRawApi(upiId: upi, tcoin: tcoin);

    if (!mounted) return;

    final st = ref.read(walletNotifier);

    if (st.error != null && st.error!.trim().isNotEmpty) {
      AppSnackBar.error(context, st.error!);
      return;
    }

    final wr = st.withdrawRequestResponse;
    if (wr != null && wr.status == true && wr.data.success == true) {
      AppSnackBar.success(
        context,
        "Withdraw request raised ✅\nRequestId: ${wr.data.requestId}",
      );
      _amountController.clear();
    } else {
      AppSnackBar.error(context, "Withdraw failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletNotifier);

    final resp = walletState.walletHistoryResponse;
    final data = resp?.data;
    final wallet = data?.wallet;

    final typedTcoin = int.tryParse(_amountController.text.trim()) ?? 0;
    final rateText = (wallet?.rate ?? "").toString();

    final perTcoinRate = _parseRateToNumber(rateText);

    final calculatedInr = (typedTcoin > 0 && perTcoinRate > 0)
        ? (typedTcoin * perTcoinRate)
        : 0;

    final leftTcoinText = typedTcoin > 0 ? "$typedTcoin" : "";
    final rightRateText = typedTcoin > 0 ? "₹${calculatedInr.round()}" : "0";

    final btnText = typedTcoin <= 0
        ? "Withdraw Request"
        : "₹${calculatedInr.round()} Withdraw Request";

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
                      'Withdraw',
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
                      padding: const EdgeInsets.only(left: 149),
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
                    const SizedBox(height: 25),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ✅ FORM
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UPI Id',
                      style: GoogleFont.Mulish(
                        fontSize: 14,
                        color: AppColor.mildBlack,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _uPIIDController,
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

                    Text(
                      'TCoin',
                      style: GoogleFont.Mulish(
                        fontSize: 14,
                        color: AppColor.mildBlack,
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) {
                        setState(() {}); // ✅ live update row + button
                      },
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

                    const SizedBox(height: 15),

                    // ✅ DYNAMIC RATE ROW (your requested change)
                    Row(
                      children: [
                        Text(
                          '$leftTcoinText TCoin → ',
                          style: GoogleFont.Mulish(
                            fontSize: 14,
                            color: AppColor.darkGrey,
                          ),
                        ),
                        Text(
                          rightRateText,
                          style: GoogleFont.Mulish(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColor.blue,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // ✅ BUTTON also show same rate
                    CommonContainer.button(
                      buttonColor: AppColor.darkBlue,
                      onTap: walletState.isLoading
                          ? null
                          : () => _raiseWithdraw(
                              upi: _uPIIDController.text.trim(),
                              tcoin: _amountController.text.trim(),
                            ),
                      text: walletState.isLoading
                          ? ThreeDotsLoader()
                          : Text(btnText),
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

// class _WithdrawScreenState extends ConsumerState<WithdrawScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   final TextEditingController _uPIIDController = TextEditingController();
//   final TextEditingController _amountController = TextEditingController();
//
//   String _btnAmountText = "Withdraw Request";
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(vsync: this);
//
//     _amountController.addListener(() {
//       if (!mounted) return;
//       setState(() {
//         final v = _amountController.text.trim();
//         _btnAmountText = v.isEmpty
//             ? "Withdraw Request"
//             : "₹$v Withdraw Request";
//       });
//     });
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // keep if you need wallet balance in send screen
//       ref.read(walletNotifier.notifier).walletHistory();
//     });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     _uPIIDController.dispose();
//     _amountController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _raiseWithdraw() async {
//     final upi = _uPIIDController.text.trim();
//     final amount = _amountController.text.trim();
//
//     if (upi.isEmpty) {
//       AppSnackBar.error(context, "Please enter UPI Id");
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
//     await ref
//         .read(walletNotifier.notifier)
//         .uIDWithRawApi(upiId: upi, tcoin: amount);
//
//     if (!mounted) return;
//
//     final st = ref.read(walletNotifier);
//
//     // ✅ API error message show
//     if (st.error != null && st.error!.trim().isNotEmpty) {
//       AppSnackBar.error(context, st.error!);
//       return;
//     }
//
//     final wr = st.withdrawRequestResponse; // WithdrawRequestResponse?
//     if (wr != null && wr.status == true && wr.data.success == true) {
//       AppSnackBar.success(
//         context,
//         "Withdraw request raised ✅\nRequestId: ${wr.data.requestId}",
//       );
//
//       _amountController.clear();
//       // _uPIIDController.clear(); // optional
//     } else {
//       AppSnackBar.error(context, "Withdraw failed");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final walletState = ref.watch(walletNotifier);
//     final wr = walletState.withdrawRequestResponse;
//
//     final resp = walletState.walletHistoryResponse;
//     final wallet = resp?.data.wallet;
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
//                       'Withdraw',
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
//                           InkWell(
//                             borderRadius: BorderRadius.circular(12),
//                             onTap: () async {
//                               final uid = (wallet?.uid ?? "").trim();
//                               if (uid.isEmpty) return;
//
//                               await Clipboard.setData(ClipboardData(text: uid));
//
//                               if (!mounted) return;
//                               AppSnackBar.success(context, "UID copied: $uid");
//                             },
//                             child: Image.asset(AppImages.uID, height: 14),
//                           ),
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
//                       'UPI Id',
//                       style: GoogleFont.Mulish(
//                         fontSize: 14,
//                         color: AppColor.mildBlack,
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     TextField(
//                       controller: _uPIIDController,
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
//                       keyboardType:
//                           TextInputType.number, // mobile number keypad
//                       inputFormatters: [
//                         FilteringTextInputFormatter.digitsOnly, // ✅ only 0-9
//                       ],
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
//                     SizedBox(height: 15),
//
//                     Row(
//                       children: [
//                         Text(
//                           '15TCoin → ',
//                           style: GoogleFont.Mulish(
//                             fontSize: 14,
//                             color: AppColor.darkGrey,
//                           ),
//                         ),
//                         Text(
//                           '₹10',
//                           style: GoogleFont.Mulish(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w700,
//                             color: AppColor.blue,
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 25),
//
//                     CommonContainer.button(
//                       buttonColor: AppColor.darkBlue,
//                       onTap: walletState.isLoading ? null : _raiseWithdraw,
//                       text: walletState.isLoading
//                           ? ThreeDotsLoader()
//                           : Text(_btnAmountText),
//                       imagePath: walletState.isLoading
//                           ? null
//                           : AppImages.rightSideArrow,
//                     ),
//
//                     // CommonContainer.button(
//                     //   buttonColor: AppColor.darkBlue,
//                     //   onTap: () {
//                     //     // Navigator.push(
//                     //     //   context,
//                     //     //   MaterialPageRoute(
//                     //     //     builder: (context) => ReceiveScreen(),
//                     //     //   ),
//                     //     // );
//                     //   },
//                     //   text: Text('Raise Withdraw Request'),
//                     //   imagePath: AppImages.rightSideArrow,
//                     // ),
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
