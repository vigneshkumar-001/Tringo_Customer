import 'package:flutter/material.dart';
import 'package:tringo_app/Core/Widgets/Common%20Bottom%20Navigation%20bar/search_screen_bottombar.dart';
import 'package:tringo_app/Core/Widgets/sortby_popup_screen.dart';
import '../../../Presentation/OnBoarding/Screens/Food Screen/food_list.dart';
import '../../../Presentation/OnBoarding/Screens/Products/Screens/product_listing.dart';
import '../../../Presentation/OnBoarding/Screens/Search Screen/search_screen.dart';
import '../../../Presentation/OnBoarding/Screens/Services Screen/Screens/service_listing.dart';
import '../../../Presentation/OnBoarding/Screens/Shop Screen/Screens/shops_listing.dart';
import '../../../Presentation/OnBoarding/Screens/Home Screen/Screens/home_screen.dart';
import '../../Utility/app_Images.dart';
import '../../Utility/app_color.dart';
import '../../Utility/google_font.dart';
import '../filter_popup_screen.dart';

class ButtomNavigatebar extends StatefulWidget {
  final int initialIndex;
  const ButtomNavigatebar({super.key, this.initialIndex = 0});

  @override
  State<ButtomNavigatebar> createState() => _ButtomNavigatebarState();
}

class _ButtomNavigatebarState extends State<ButtomNavigatebar> {
  late int _selectedIndex;
  int _filterCount = 2;

  late final PageController _pageController;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _selectedIndex);

    // replace stubs with your real pages if you have them
    _pages = [
      HomeScreen(), // 0
      SearchScreen(), // 1
      _ExploreScreenStub(), // 2
      ShopsListing(), // 3
      ServiceListing(), // 4
      FoodList(), // 5
      ProductListing(), // 6
    ];
  }

  void _goTo(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      isScrollControlled: true, // needed for tall sheet + keyboard
      backgroundColor: Colors.transparent,
      context: context,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FilterPopupScreen(),
    );
  }

  void _openSortSheet() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SortbyPopupScreen(),
    );
  }

  /*
  void _pushCategory(String name) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HomeScreen(), // add this param to your page
      ),

    );
  }
*/
  void _pushCategory(String name) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => HomeScreen()),
      (route) => false, // remove everything below
    );
  }

  void openSearchShell(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => const SearchScreenBottombar(initialIndex: 1),
      ),
    );
  }

  // map taps from the bar
  void _onBarTap(int i) {
    // if (index == _selectedIndex) return;
    switch (i) {
      case 0:
        _pushCategory('Home');
        break; // Home
      case 1:
        openSearchShell(context);
        break; // Search
      case 2:
        _goTo(2);
        break; // Magic
      case 3:
        _openFilterSheet();
        break;
      case 4:
        _openSortSheet();
        break;
      case 5:
        _goTo(3);
        break;
      case 6:
        _goTo(4);
        break;
      case 7:
        _pushCategory('Bakery');
        break;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(), // tap-only nav
        children: _pages,
      ),
      bottomNavigationBar: FigmaBottomNavBar(
        selectedIndex: _selectedIndex,
        filterCount: _filterCount,
        onChanged: _onBarTap,
        onClearFilters: () => setState(() => _filterCount = 0),
      ),
    );
  }
}

class _ExploreScreenStub extends StatelessWidget {
  const _ExploreScreenStub();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Explore Screen', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}

/// ------------------- BOTTOM BAR (Figma-style) -----------------------------------

class FigmaBottomNavBar extends StatelessWidget {
  const FigmaBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
    this.filterCount = 0,
    this.onClearFilters,
  });

  final int selectedIndex;
  final int filterCount;
  final VoidCallback? onClearFilters;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppColor.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 16,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // HOME round button (image)
                  InkWell(
                    onTap: () => onChanged(0),

                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      decoration: BoxDecoration(
                        color: selectedIndex == 0
                            ? AppColor.iceBlue.withOpacity(0.35)
                            : AppColor.white,
                        border: Border.all(
                          color: selectedIndex == 0
                              ? AppColor.darkBlue
                              : AppColor.darkBlue,
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.all(8.5),
                      child: Image.asset(AppImages.homeImage, height: 19),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // SEARCH pill (black)
                  _pill(
                    context,
                    onTap: () => onChanged(1),
                    bg: Colors.black,
                    border: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            AppImages.searchImage,
                            height: 14,
                            color: AppColor.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Search',
                            style: GoogleFont.Mulish(
                              fontSize: 14,
                              color: AppColor.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),

                  // SPARKLE gradient circle
                  _gradientCircle(
                    size: 40,
                    onTap: () => onChanged(2),
                    child: Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 10),

                  // FILTER pill (with count)
                  _pill(
                    context,
                    onTap: () => onChanged(3),
                    bg: AppColor.white,
                    border: AppColor.borderGray,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'Filter',
                            style: GoogleFont.Mulish(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppColor.lightGray2,
                            ),
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: Colors.black54,
                        ),
                        if (filterCount > 0) ...[
                          SizedBox(width: 8),
                          _countChip(
                            context,
                            value: '$filterCount',
                            onClear: onClearFilters,
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: 10),

                  // SORT pill
                  _pill(
                    context,
                    onTap: () => onChanged(4),
                    bg: AppColor.white,
                    border: AppColor.borderGray,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Sort By',
                          style: GoogleFont.Mulish(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColor.lightGray2,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 4),

                  // CATEGORY pills -> send index 5..7 back up
                  _pill(
                    context,
                    onTap: () => onChanged(5),
                    bg: AppColor.white,
                    border: AppColor.borderGray,
                    child: _ChipLabel('Restaurants'),
                  ),
                  SizedBox(width: 4),
                  _pill(
                    context,
                    onTap: () => onChanged(6),
                    bg: AppColor.white,
                    border: AppColor.borderGray,
                    child: _ChipLabel('Textiles'),
                  ),
                  SizedBox(width: 4),
                  _pill(
                    context,
                    onTap: () => onChanged(7),
                    bg: AppColor.white,
                    border: AppColor.borderGray,
                    child: _ChipLabel('Bakery'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- helpers ----------

  static Widget _pill(
    BuildContext context, {
    required Widget child,
    required VoidCallback onTap,
    required Color bg,
    required Color border,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: border, width: 1.2),
        ),
        child: child,
      ),
    );
  }

  static Widget _gradientCircle({
    required double size,
    required Widget child,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        height: size,
        width: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size / 2),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF7A00), // orange
              Color(0xFFFF2D55), // pink
              Color(0xFF7A5CFF), // purple
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  static Widget _countChip(
    BuildContext context, {
    required String value,
    VoidCallback? onClear,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF2D9CFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFont.Mulish(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          if (onClear != null)
            GestureDetector(
              onTap: onClear,
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
        ],
      ),
    );
  }
}

class _ChipLabel extends StatelessWidget {
  final String text;
  const _ChipLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: Text(
      text,
      style: GoogleFont.Mulish(
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: AppColor.lightGray2,
      ),
    ),
  );
}
