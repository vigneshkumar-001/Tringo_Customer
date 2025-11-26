import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Utility/app_color.dart';
import 'package:tringo_app/Core/Utility/google_font.dart';
import '../../../../Core/Widgets/common_container.dart';
import 'Smart_connect_search.dart';

class SmartConnectGuide extends StatefulWidget {
  const SmartConnectGuide({super.key});

  @override
  State<SmartConnectGuide> createState() => _SmartConnectGuideState();
}

class _SmartConnectGuideState extends State<SmartConnectGuide> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  // exactly two preset suggestions (for the UI you asked)
  static const List<_Suggest> _preset = [
    _Suggest('Atomberg Ceiling BLDC fan', 'fan'),
    _Suggest('Atomberg Pedestal BLDC fan', 'fan'),
  ];

  List<_Suggest> _view = []; // what we show under the box

  bool get typing => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {})); // to redraw focus border
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 180), () {
      final t = q.trim().toLowerCase();
      setState(() {
        // show ONLY these two items; filter by query like in your mock
        _view = t.isEmpty
            ? []
            : _preset
                  .where((s) => s.title.toLowerCase().contains(t))
                  .take(2)
                  .toList();
        // if you want to always show both when typing, use: _view = t.isEmpty ? [] : _preset;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.white,
                  AppColor.white,
                  AppColor.white,
                  AppColor.white,
                  AppColor.babyBlue.withOpacity(0.4),
                  AppColor.babyBlue,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonContainer.leftSideArrow(
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 19),
                  Center(
                    child: Image.asset(AppImages.aiGuideImage, height: 135),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Text(
                      'Smart Connect Guide',
                      style: GoogleFont.Mulish(
                        fontWeight: FontWeight.bold,
                        fontSize: 29,
                        color: AppColor.darkBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),

                  // mixed-weight info card
                  Container(
                    decoration: BoxDecoration(
                      color: AppColor.aliceBlue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(15),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.mulish(
                          fontSize: 14,
                          height: 1.5,
                          color: AppColor.charcoalBrown,
                        ),
                        children: const [
                          TextSpan(
                            text:
                                'Smart Connect instantly links customers with up to ',
                          ),
                          TextSpan(
                            text: '20 nearby shops',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text:
                                '. Shops can reply to a query in one message, and customers can directly interact with the shop for products they need.',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 27),
                  Text(
                    '1. Search Your Need & Click',
                    style: GoogleFont.Mulish(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColor.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ==== WHITE CARD with search box + 2 suggestions ====
                  Container(
                    decoration: BoxDecoration(
                      color: AppColor.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        // base soft drop shadow
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 3,
                          spreadRadius: 0.5,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // search box INSIDE the white container
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColor.white,
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(
                              color: _focusNode.hasFocus
                                  ? AppColor.blue
                                  : AppColor.lightGray1,
                              width: 2.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Image.asset(AppImages.searchImage, height: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  focusNode: _focusNode,
                                  onChanged: _onChanged,
                                  textAlignVertical: TextAlignVertical.center,
                                  decoration: InputDecoration(
                                    isCollapsed: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                      horizontal: 6,
                                    ),
                                    hintText: '',
                                    border: InputBorder.none,
                                    hintStyle: GoogleFont.Mulish(
                                      color: AppColor.lightGray,
                                      fontSize: 12,
                                    ),
                                    suffixIcon: _controller.text.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(
                                              Icons.clear,
                                              size: 18,
                                            ),
                                            onPressed: () {
                                              _controller.clear();
                                              _onChanged('');
                                              setState(() {});
                                            },
                                          )
                                        : null,
                                  ),
                                  // bold typed text like the mock
                                  style: GoogleFont.Mulish(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColor.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // suggestions: show ONLY when typing; exactly two rows with light "in fan"
                        if (typing) ...[
                          for (int i = 0; i < _view.length; i++) ...[
                            _SuggestionRow(item: _view[i]),
                            if (i != _view.length - 1)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: CommonContainer.horizonalDivider(),
                              ),
                          ],
                          if (_view.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 10,
                                bottom: 4,
                              ),
                              child: Text(
                                'No results',
                                style: GoogleFont.Mulish(
                                  color: AppColor.lightGray2,
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: 35),
                  Text(
                    '2. Get Reply from Shops within Minutes',
                    style: GoogleFont.Mulish(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColor.darkBlue,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    '3. Pick your favorite shop & Connect',
                    style: GoogleFont.Mulish(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColor.darkBlue,
                    ),
                  ),
                  SizedBox(height: 34),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SmartConnectSearch(),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColor.blue,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 15,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Explore Smart Connect',
                              style: GoogleFont.Mulish(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColor.white,
                              ),
                            ),
                            SizedBox(width: 10),
                            Image.asset(
                              AppImages.rightSideArrow,
                              height: 18,
                              color: AppColor.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 34),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({required this.item});
  final _Suggest item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // main text (dark) + " in fan" (light)
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: item.title,
                  style: GoogleFont.Mulish(
                    fontSize: 15,
                    color: AppColor.darkBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: ' in ',
                  style: GoogleFonts.mulish(
                    fontSize: 15,
                    color: AppColor.lightGray2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: item.category,
                  style: GoogleFonts.mulish(
                    fontSize: 15,
                    color: AppColor.lightGray2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 10),
        // chevron in soft blue pill (like your screenshot)
        InkWell(
          onTap: () {},
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 13, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              color: AppColor.textWhite,
              // gradient: LinearGradient(
              //   colors: [AppColor.aliceBlue, AppColor.blue.withOpacity(0.15)],
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              // ),
            ),
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColor.blue,
            ),
          ),
        ),
      ],
    );
  }
}

class _Suggest {
  final String title;
  final String category; // e.g., 'fan'
  const _Suggest(this.title, this.category);
}
