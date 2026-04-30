import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../Core/Utility/app_Images.dart';
import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/google_font.dart';
import '../../../../../Core/Widgets/common_container.dart';
import 'create_smart_connect.dart';

// ✅ Provider
import '../Controller/smart_connect_notifier.dart';

// ✅ Model (import your model file where SmartConnectSearchItem exists)
import '../Model/smart_connect_search_response.dart';

class SmartConnectSearch extends ConsumerStatefulWidget {
  const SmartConnectSearch({super.key});

  @override
  ConsumerState<SmartConnectSearch> createState() => _SmartConnectSearchState();
}

class _SmartConnectSearchState extends ConsumerState<SmartConnectSearch> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  bool get typing => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
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
    _debounce = Timer(const Duration(milliseconds: 180), () async {
      final query = q.trim();
      if (query.isEmpty) return;

      await ref
          .read(smartConnectNotifierProvider.notifier)
          .fetchSmartConnectSearch(search: query);
    });

    setState(() {}); // refresh suffixIcon, typing state
  }

  // ✅ Navigate using full item (recommended)
  void _openSuggestionItem(SmartConnectSearchItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateSmartConnect(
          shopId: item.shopId,
          listingId: item.listingId,
          listingType: item.listingType,
          title: item.primaryText,
          // If you want, pass extra params in CreateSmartConnect:
          // listingId: item.listingId,
          // shopId: item.shopId,
          // listingType: item.listingType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(smartConnectNotifierProvider);

    // ✅ items list
    final items =
        state.smartConnectSearchResponse?.data.items ??
        <SmartConnectSearchItem>[];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    CommonContainer.leftSideArrow(
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      'Smart Connect Search',
                      style: GoogleFont.Mulish(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: AppColor.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // ✅ Search box
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
                          autofocus: true,
                          controller: _controller,
                          focusNode: _focusNode,
                          onChanged: _onChanged,
                          textAlignVertical: TextAlignVertical.center,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            isCollapsed: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                            hintText: '',
                            border: InputBorder.none,
                            hintStyle: GoogleFont.Mulish(
                              color: AppColor.lightGray,
                              fontSize: 12,
                            ),
                            suffixIcon: _controller.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _controller.clear();

                                      // Optional: Clear results by triggering empty search
                                      // or just refresh UI
                                      setState(() {});
                                    },
                                  )
                                : null,
                          ),
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

                const SizedBox(height: 24),

                // ✅ Suggestions from API
                if (typing) ...[
                  if (state.isSearchLoading)
                    Skeletonizer(
                      enabled: true,
                      child: Column(
                        children: List.generate(6, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: CommonContainer.sortbyPopup(
                              text1: 'Loading item $index',
                              text2: 'Type',
                              connector: ' in ',
                              image: AppImages.rightArrow,
                              iconColor: AppColor.blue,
                              horizontalDivider: true,
                              onTap: () {},
                            ),
                          );
                        }),
                      ),
                    ),

                  if (!state.isSearchLoading && state.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        state.error!,
                        style: GoogleFont.Mulish(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  if (!state.isSearchLoading && state.error == null) ...[
                    if (items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 4),
                        child: Text(
                          'No results',
                          style: GoogleFont.Mulish(
                            color: AppColor.lightGray2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      for (int i = 0; i < items.take(10).length; i++) ...[
                        _SuggestionRowItem(
                          item: items[i],
                          onTap: () => _openSuggestionItem(items[i]),
                        ),
                        if (i != items.take(10).length - 1)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: CommonContainer.horizonalDivider(),
                          ),
                      ],
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionRowItem extends StatelessWidget {
  const _SuggestionRowItem({
    super.key,
    required this.item,
    required this.onTap,
  });

  final SmartConnectSearchItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: item.primaryText,
                        style: GoogleFonts.mulish(
                          fontSize: 16,
                          color: AppColor.darkBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: " "),
                      TextSpan(
                        text: item.secondaryText, // "in Televisions"
                        style: GoogleFonts.mulish(
                          fontSize: 16,
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
              InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(17),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(17),
                    color: AppColor.textWhite,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColor.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../Core/Utility/app_Images.dart';
import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/google_font.dart';
import '../../../../../Core/Widgets/common_container.dart';
import 'create_smart_connect.dart';

class SmartConnectSearch extends ConsumerStatefulWidget {
  const SmartConnectSearch({super.key});

  @override
  ConsumerState<SmartConnectSearch> createState() => _SmartConnectSearchState();
}

class _SmartConnectSearchState extends ConsumerState<SmartConnectSearch> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  // 👉 Preset items exactly like the Figma
  static const List<_Suggest> _preset = [
    _Suggest('Iphone 11', 'Mobile'),
    _Suggest('Iphone Charger', 'Mobile Accessories'),
    _Suggest('Iphone Headset', 'Mobile Accessories'),
  ];

  List<_Suggest> _view = [];

  bool get typing => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
    // (Optional) prefill to mirror your screenshot

    _onChanged(_controller.text);
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
        _view = t.isEmpty
            ? []
            : _preset
                  .where((s) => s.title.toLowerCase().contains(t))
                  .take(3) // 👉 show the 3 rows like the Figma
                  .toList();
      });
    });
  }

  void _openSuggestion(_Suggest s) {
    // fallback in case something goes wrong
    Widget page = Center(child: Text('Page not found'));

    switch (s.title) {
      case 'Iphone 11':
        page = CreateSmartConnect(title: s.title);
        break;
      case 'Iphone Charger':
        page = AccessoryDetailPage(type: 'Charger');
        break;
      case 'Iphone Headset':
        page = AccessoryDetailPage(type: 'Headset');
        break;
      default:
        page = SearchResultsPage(query: s.title, category: s.category);
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    CommonContainer.leftSideArrow(
                      onTap: () => Navigator.pop(context),
                    ),
                    SizedBox(width: 15),
                    Text(
                      'Smart Connect Search',
                      style: GoogleFont.Mulish(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: AppColor.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25),

                // Search box
                AnimatedContainer(
                  duration: Duration(milliseconds: 150),
                  padding: EdgeInsets.symmetric(horizontal: 16),
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
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          autofocus: true,
                          controller: _controller,
                          focusNode: _focusNode,
                          onChanged: _onChanged,
                          textAlignVertical: TextAlignVertical.center,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            isCollapsed: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                            hintText: '',
                            border: InputBorder.none,
                            hintStyle: GoogleFont.Mulish(
                              color: AppColor.lightGray,
                              fontSize: 12,
                            ),
                            suffixIcon: _controller.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _controller.clear();
                                      _onChanged('');
                                      setState(() {});
                                    },
                                  )
                                : null,
                          ),
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

                SizedBox(height: 24),

                // Suggestions
                if (typing) ...[
                  for (int i = 0; i < _view.length; i++) ...[
                    _SuggestionRow(
                      item: _view[i],
                      onTap: () => _openSuggestion(_view[i]), // safe now
                    ),
                    if (i != _view.length - 1)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        child: CommonContainer.horizonalDivider(),
                      ),
                  ],
                  if (_view.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 4),
                      child: Text(
                        'No results',
                        style: GoogleFont.Mulish(color: AppColor.lightGray2),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({super.key, required this.item, required this.onTap});

  final _Suggest item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap, // whole row navigates
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              // title + "in <category>"
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: item.title,
                        style: GoogleFont.Mulish(
                          fontSize: 16,
                          color: AppColor.darkBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: ' in ',
                        style: GoogleFonts.mulish(
                          fontSize: 16,
                          color: AppColor.lightGray2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: item.category,
                        style: GoogleFonts.mulish(
                          fontSize: 16,
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
              SizedBox(width: 10),

              // arrow pill (also navigates)
              InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(17),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(17),
                    color: AppColor.textWhite,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColor.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Suggest {
  final String title;
  final String category; // "Mobile" / "Mobile Accessories"
  const _Suggest(this.title, this.category);
}

// ===== Example pages (replace with your real Screens) =====
class ProductDetailPage extends StatelessWidget {
  final String title;
  const ProductDetailPage({super.key, required this.title});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(child: Text('Product detail: $title')),
  );
}

class AccessoryDetailPage extends StatelessWidget {
  final String type;
  const AccessoryDetailPage({super.key, required this.type});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(type)),
    body: Center(child: Text('Accessory: $type')),
  );
}

class SearchResultsPage extends StatelessWidget {
  final String query;
  final String category;
  const SearchResultsPage({
    super.key,
    required this.query,
    required this.category,
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(query)),
    body: Center(child: Text('Results for $query in $category')),
  );
}
*/
