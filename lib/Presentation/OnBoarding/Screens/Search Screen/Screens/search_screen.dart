import 'package:flutter/material.dart';
import 'package:tringo_app/Core/Const/app_logger.dart';
import 'package:flutter/services.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../Api/api_providers.dart';
import '../../../../../Core/Utility/app_Images.dart';
import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/google_font.dart';
import '../../../../../Core/Widgets/Common Bottom Navigation bar/buttom_navigatebar.dart';
import '../../../../../Core/Widgets/common_container.dart';
import '../../../../../Core/Widgets/current_location_widget.dart';
import '../../../../../Core/Widgets/smart_connect_prompt_dialog.dart';
import '../../Mobile No User/Screen/detail_mobile_no_user.dart';
import '../../Smart Connect/Screens/create_smart_connect.dart';
import '../Controller/search_notifier.dart';
import '../Model/search_suggestion_response.dart';

class AlphaNumericPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // If text contains ONLY digits → limit to 10
    if (RegExp(r'^\d+$').hasMatch(text)) {
      if (text.length > 10) {
        return oldValue; // block extra digits
      }
    }

    // Allow letters + mix freely
    return newValue;
  }
}

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    // Load the backend's dynamic default suggestions (empty query) on open.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(searchNotifierProvider.notifier).loadDefault();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isDigitsOnly(String s) => RegExp(r'^\d+$').hasMatch(s);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchNotifierProvider);
    final notifier = ref.read(searchNotifierProvider.notifier);

    final queryText = _controller.text.trim();
    final typing = queryText.isNotEmpty;

    final apiItems =
        state.searchSuggestionResponse?.data?.items ?? <SearchItem>[];
    final recentItems = state.recentItems;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==== HEADER ====
                Row(
                  children: [
                    CommonContainer.leftSideArrow(
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      'Search',
                      style: GoogleFont.Mulish(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColor.black,
                      ),
                    ),
                    const SizedBox(width: 60),
                    Expanded(
                      child: CurrentLocationWidget(
                        locationIcon: AppImages.locationImage,
                        dropDownIcon: AppImages.drapDownImage,
                        textStyle: GoogleFonts.mulish(
                          color: AppColor.darkBlue,
                          fontWeight: FontWeight.w600,
                        ),
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 17),

                // ==== SEARCH BOX ====
                Focus(
                  onFocusChange: (f) => setState(() => _isFocused = f),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColor.white,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: _isFocused ? AppColor.blue : AppColor.lightGray1,
                        width: 2.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Center(
                          child: Image.asset(AppImages.searchImage, height: 17),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            autofocus: true,
                            controller: _controller,
                            keyboardType: TextInputType.text,
                            inputFormatters: [AlphaNumericPhoneFormatter()],
                            onChanged: (value) {
                              setState(() {});
                              notifier.onQueryChanged(value);
                            },
                            onSubmitted: (value) {
                              final term = value.trim();
                              if (term.isEmpty) return;

                              // keep results; don’t clear immediately
                              // (If you want to clear, you can do it)
                            },
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              isCollapsed: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 10,
                              ),
                              hintText:
                                  'Search product, shop, service, mobile no',
                              border: InputBorder.none,
                              hintStyle: GoogleFont.Mulish(
                                color: AppColor.lightGray,
                                fontSize: 14,
                              ),
                              suffixIcon: _controller.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        _controller.clear();
                                        setState(() {});
                                        // Re-show the dynamic default suggestions.
                                        notifier.loadDefault();
                                      },
                                    )
                                  : null,
                            ),
                            style: GoogleFont.Mulish(
                              fontSize: 14,
                              color: AppColor.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // //  Helpful text: phone needs 10 digits
                // if (typing && isPhoneTyping && !isPhoneReady)
                //   Padding(
                //     padding: const EdgeInsets.only(left: 8),
                //     child: Text(
                //       'Enter 10-digit mobile number to get user details',
                //       style: GoogleFont.Mulish(
                //         color: AppColor.lightGray2,
                //         fontSize: 12,
                //       ),
                //     ),
                //   ),
                const SizedBox(height: 14),

                // ==== CONTENT AREA ====
                // Recent searches: shown only before the user starts typing.
                if (!typing) ...[
                  Text(
                    'Recent Searches',
                    style: GoogleFont.Mulish(color: AppColor.lightGray2),
                  ),
                  const SizedBox(height: 17),

                  if (recentItems.isEmpty)
                    Text(
                      'No recent searches',
                      style: GoogleFont.Mulish(color: AppColor.lightGray2),
                    )
                  else
                    for (final item in recentItems) ...[
                      CommonContainer.sortbyPopup(
                        text1: item.label,
                        text2: item.inLabel,
                        connector: ' in ',
                        image: AppImages.rightArrow,
                        iconColor: AppColor.blue,
                        horizontalDivider: true,
                        onTap: () {
                          _handleSuggestionTap(context, item);
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                  const SizedBox(height: 16),
                ],

                // Suggestions / results: dynamic defaults (empty query) when idle,
                // live matches when typing. Backed by the same search API.
                if (state.isLoading) ...[
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
                ] else if (apiItems.isNotEmpty) ...[
                  for (final item in apiItems) ...[
                    CommonContainer.sortbyPopup(
                      text1: item.label,
                      text2: item.inLabel,
                      connector: ' in ',
                      image: AppImages.rightArrow,
                      iconColor: AppColor.blue,
                      horizontalDivider: true,
                      onTap: () {
                        notifier.addRecentItem(item);
                        _handleSuggestionTap(context, item);
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ] else if (typing) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
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

  static const Set<String> _smartConnectEligibleTypes = {
    'PRODUCT_SHOP',
    'SERVICE_SHOP',
    'PRODUCT',
    'SERVICE',
  };

  void _handleSuggestionTap(BuildContext context, SearchItem item) {
    const mobileTypes = {'OWNER_SHOP', 'CUSTOMER', 'VENDOR', 'EMPLOYEE'};

    // 📞 Mobile number → detail screen
    if (mobileTypes.contains(item.type)) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailMobileNoUser(item: item)),
      );
      return;
    }

    final category = item.meta?.category;
    if (_smartConnectEligibleTypes.contains(item.type) &&
        category != null &&
        category.trim().isNotEmpty) {
      _maybeShowSmartConnectPrompt(context, item, category);
      return;
    }

    _navigateToDefaultDestination(context, item);
  }

  /// Checks how many nearby verified businesses exist in the same category
  /// before navigating. If any are found, asks the user whether to fan out a
  /// Smart Connect request; otherwise (no signal, no verified shops, or the
  /// lookup fails) it silently falls back to the normal results list — this
  /// prompt should never block or break the existing search flow.
  Future<void> _maybeShowSmartConnectPrompt(
    BuildContext context,
    SearchItem item,
    String category,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    int verifiedCount = 0;
    try {
      final api = ref.read(apiDataSourceProvider);
      final result = await api
          .getNearbyVerifiedShopsCount(category: category)
          .timeout(const Duration(seconds: 5));
      result.fold((_) => verifiedCount = 0, (count) => verifiedCount = count);
    } catch (e) {
      AppLogger.log.e('Nearby verified count lookup failed: $e');
      verifiedCount = 0;
    }

    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // close loading spinner

    if (verifiedCount <= 0) {
      _navigateToDefaultDestination(context, item);
      return;
    }

    final sendRequest = await showSmartConnectPromptDialog(
      context,
      verifiedCount: verifiedCount,
      categoryLabel: item.meta?.categoryLabel,
    );

    if (!context.mounted) return;

    if (sendRequest == true) {
      // `category` (the required param above) was already validated
      // non-null/non-empty by _handleSuggestionTap before this prompt was
      // ever shown - categoryDisplayText prefers the display-ready label
      // when present, so this is never empty and never the item's own
      // name/label (which is what the Product field was wrongly showing).
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CreateSmartConnect(
            title: item.meta?.categoryDisplayText ?? category,
            listingId: _resolveListingId(item),
            listingType: _resolveListingType(item),
            shopId: item.target.shopId ?? (_isShopType(item.type) ? item.id : null),
          ),
        ),
      );
    } else {
      _navigateToDefaultDestination(context, item);
    }
  }

  bool _isShopType(String type) => type == 'PRODUCT_SHOP' || type == 'SERVICE_SHOP';

  String? _resolveListingId(SearchItem item) {
    switch (item.type) {
      case 'PRODUCT':
        return item.target.productId ?? item.id;
      case 'SERVICE':
        return item.target.serviceId ?? item.id;
      case 'PRODUCT_SHOP':
      case 'SERVICE_SHOP':
        return item.id;
      default:
        return item.id;
    }
  }

  String? _resolveListingType(SearchItem item) {
    switch (item.type) {
      case 'PRODUCT':
        return 'PRODUCT';
      case 'SERVICE':
        return 'SERVICE';
      case 'PRODUCT_SHOP':
      case 'SERVICE_SHOP':
        return 'SHOP';
      default:
        return null;
    }
  }

  void _navigateToDefaultDestination(BuildContext context, SearchItem item) {
    if (item.type == 'PRODUCT_SHOP') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ButtomNavigatebar(initialIndex: 3, highlightId: item.id),
        ),
      );
    } else if (item.type == 'PRODUCT' || item.type == 'SERVICE') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ButtomNavigatebar(
            initialIndex: 6,
            tittle: item.label,
            kind: item.type,
            highlightId: item.id,
          ),
        ),
      );
      AppLogger.log.i('Navigating to product/service detail screen');
    } else if (item.type == 'SERVICE_SHOP') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ButtomNavigatebar(initialIndex: 4, highlightId: item.id),
        ),
      );
    }
  }
}
