import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tringo_app/Core/Const/app_logger.dart';

import '../../../../../Core/Utility/app_Images.dart';
import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/google_font.dart';
import '../../../../../Core/Widgets/Common Bottom Navigation bar/buttom_navigatebar.dart';
import '../../../../../Core/Widgets/common_container.dart';
import '../../../../../Core/Widgets/current_location_widget.dart';
import '../../Products/Screens/product_listing.dart';
import '../../Services Screen/Screens/service_listing.dart';
import '../Controller/search_notifier.dart'; // 👈 your notifier import
import '../Model/search_suggestion_response.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchNotifierProvider);
    final notifier = ref.read(searchNotifierProvider.notifier);

    final query = _controller.text.trim();
    final typing = query.isNotEmpty;

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
                        onTap: () {
                          print('Change location tapped!');
                        },
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
                            onChanged: (value) {
                              setState(() {});
                              final q = value.trim();
                              if (q.isEmpty) {
                                notifier.searchSuggestion(searchWords: '');
                              } else {
                                notifier.searchSuggestion(searchWords: q);
                              }
                            },

                            onSubmitted: (value) {
                              final term = value.trim();
                              if (term.isEmpty) return;

                              _controller.clear();
                              setState(() {});
                              notifier.searchSuggestion(searchWords: '');
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
                                        notifier.searchSuggestion(
                                          searchWords: '',
                                        );
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

                const SizedBox(height: 24),

                // ==== CONTENT AREA ====
                if (!typing) ...[
                  // 👉 Text field empty → Recent Searches
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
                        text1: item.label, // e.g. Krishna sweets
                        text2: item.inLabel, // Shop / Product / Service
                        connector: ' in ',
                        image: AppImages.rightArrow,
                        iconColor: AppColor.blue,
                        horizontalDivider: true,
                        onTap: () {
                          // 🔹 Direct navigation from recent
                          _handleSuggestionTap(context, item);
                        },
                        // optional: if sortbyPopup supports secondary action, use remove here
                        // இல்லனா longPress use pannalaam (below example)
                      ),
                      const SizedBox(height: 8),
                    ],
                ] else if (state.isLoading) ...[
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
                ] else ...[
                  // 👉 Typing + NOT loading → show API suggestions
                  if (apiItems.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'No results',
                        style: GoogleFont.Mulish(color: AppColor.lightGray2),
                      ),
                    )
                  else
                    for (final item in apiItems) ...[
                      CommonContainer.sortbyPopup(
                        text1: item.label,
                        text2: item.inLabel,
                        connector: ' in ',
                        image: AppImages.rightArrow,
                        iconColor: AppColor.blue,
                        horizontalDivider: true,
                        onTap: () {
                          // 🔹 1) Add to recent
                          notifier.addRecentItem(item);

                          // 🔹 2) Optional: clear search & suggestions
                          _controller.clear();
                          setState(() {});
                          notifier.searchSuggestion(searchWords: '');

                          // 🔹 3) Navigate
                          _handleSuggestionTap(context, item);
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSuggestionTap(BuildContext context, SearchItem item) {
    if (item.type == 'PRODUCT_SHOP') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ButtomNavigatebar(initialIndex: 3,highlightId: item.id,)),
      );
    } else if (item.type == 'PRODUCT' || item.type == 'SERVICE') {
      AppLogger.log.i(item.id);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ButtomNavigatebar(initialIndex: 6, tittle: item.label,kind: item.type,highlightId: item.id,),
          // ShopsListing(),
        ),
      );
    } else if (item.type == 'SERVICE_SHOP') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ButtomNavigatebar(initialIndex: 4,highlightId: item.id,),
          // ServiceListing(),
        ),
      );
    }
  }
}

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// import '../../../../../Core/Utility/app_Images.dart';
// import '../../../../../Core/Utility/app_color.dart';
// import '../../../../../Core/Utility/google_font.dart';
// import '../../../../../Core/Widgets/Common Bottom Navigation bar/buttom_navigatebar.dart';
// import '../../../../../Core/Widgets/common_container.dart';
// import '../../../../../Core/Widgets/current_location_widget.dart';
// import '../../Products/Screens/product_listing.dart';
// import '../../Services Screen/Screens/service_listing.dart';
//
// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});
//
//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }
//
// class _SearchScreenState extends State<SearchScreen> {
//   final TextEditingController _controller = TextEditingController();
//   bool _isFocused = false; // add this in your State
//
//   // sample data
//   final _recent = <String>[
//     'Electrical Shop near me',
//     'Plumbers service',
//     'Vega Helmet',
//   ];
//
//   final _allSuggestions = <_Suggestion>[
//     _Suggestion('Fan Repair near me', 'Service'),
//     _Suggestion('Buy BLDC fan', 'Product'),
//     _Suggestion('Pedestal Fans', 'Product'),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     final query = _controller.text.trim();
//     final typing = query.isNotEmpty;
//     final filtered = typing
//         ? _allSuggestions
//               .where((s) => s.title.toLowerCase().contains(query.toLowerCase()))
//               .toList()
//         : const <_Suggestion>[];
//
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     CommonContainer.leftSideArrow(
//                       onTap: () {
//                         Navigator.pop(context);
//                       },
//                     ),
//                     SizedBox(width: 15),
//                     Text(
//                       'Search',
//                       style: GoogleFont.Mulish(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: AppColor.black,
//                       ),
//                     ),
//                     SizedBox(width: 60),
//                     Expanded(
//                       child: CurrentLocationWidget(
//                         locationIcon: AppImages.locationImage,
//                         dropDownIcon: AppImages.drapDownImage,
//                         textStyle: GoogleFonts.mulish(
//                           color: AppColor.darkBlue,
//                           fontWeight: FontWeight.w600,
//                         ),
//                         onTap: () {
//                           // Handle location change, e.g., open map picker or bottom sheet
//                           print('Change location tapped!');
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 17),
//                 Focus(
//                   onFocusChange: (f) => setState(() => _isFocused = f),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     decoration: BoxDecoration(
//                       color: AppColor.white,
//                       borderRadius: BorderRadius.circular(40),
//                       border: Border.all(
//                         color: _isFocused
//                             ? AppColor.blue
//                             : AppColor.lightGray1, // 💙 Change color on focus
//                         width: 2.5,
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 6,
//                           offset: Offset(0, 3),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       children: [
//                         Center(
//                           child: Image.asset(AppImages.searchImage, height: 17),
//                         ),
//                         SizedBox(width: 10),
//                         Expanded(
//                           child: TextField(
//                             controller: _controller,
//                             onChanged: (_) => setState(() {}),
//                             textAlignVertical: TextAlignVertical.center,
//                             decoration: InputDecoration(
//                               isCollapsed: true,
//                               contentPadding: EdgeInsets.symmetric(
//                                 vertical: 12,
//                                 horizontal: 10,
//                               ),
//                               hintText:
//                                   'Search product, shop, service, mobile no',
//                               border: InputBorder.none,
//                               hintStyle: GoogleFont.Mulish(
//                                 color: AppColor.lightGray,
//                                 fontSize: 14,
//                               ),
//                               suffixIcon: _controller.text.isNotEmpty
//                                   ? IconButton(
//                                       icon: Icon(Icons.clear, size: 18),
//                                       onPressed: () {
//                                         _controller.clear();
//                                         setState(() {});
//                                       },
//                                     )
//                                   : null,
//                             ),
//                             style: GoogleFont.Mulish(
//                               fontSize: 14,
//                               color: AppColor.black,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 24),
//                 // ===== CONTENT =====
//                 if (!typing) ...[
//                   Text(
//                     'Recent Searches',
//                     style: GoogleFont.Mulish(color: AppColor.lightGray2),
//                   ),
//                   SizedBox(height: 17),
//                   for (final text in _recent) ...[
//                     CommonContainer.sortbyPopup(
//                       text1: text,
//                       image: AppImages.closeImage, // small “x” pill
//                       iconColor: AppColor.darkBlue,
//                       horizontalDivider: true,
//                       onTap: () => setState(
//                         () => _recent.remove(text),
//                       ), // remove this recent
//                     ),
//                     const SizedBox(height: 8),
//                   ],
//                 ] else ...[
//                   // filtered suggestions
//                   for (final s in filtered) ...[
//                     CommonContainer.sortbyPopup(
//                       text1: s.title,
//                       text2: s.type, // “Service/Product”
//                       connector: ' in ', // shows “in Service”
//                       image: AppImages.rightArrow, // chevron pill
//                       iconColor: AppColor.blue,
//                       horizontalDivider: true,
//                       onTap: () {
//                         if (s.type == 'Product') {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) =>
//                                   ButtomNavigatebar(initialIndex: 6),
//                             ),
//                           );
//                         } else if (s.type == 'Service') {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => ServiceListing(title: s.title),
//                             ),
//                           );
//                         }
//                       },
//                     ),
//                     const SizedBox(height: 8),
//                   ],
//                   if (filtered.isEmpty)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 12),
//                       child: Text(
//                         'No results',
//                         style: GoogleFont.Mulish(color: AppColor.lightGray2),
//                       ),
//                     ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _Suggestion {
//   final String title;
//   final String type; // e.g. "Service" or "Product"
//   const _Suggestion(this.title, this.type);
// }
