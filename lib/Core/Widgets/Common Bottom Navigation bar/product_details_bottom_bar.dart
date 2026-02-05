import 'package:flutter/material.dart';
import 'package:tringo_app/Core/Widgets/Common%20Bottom%20Navigation%20bar/search_screen_bottombar.dart';
import 'package:tringo_app/Core/Widgets/sortby_popup_screen.dart';
import '../../../Presentation/OnBoarding/Screens/Food Screen/food_details.dart';
import '../../../Presentation/OnBoarding/Screens/Food Screen/food_list.dart';
import '../../../Presentation/OnBoarding/Screens/Products/Screens/product_details.dart';
import '../../../Presentation/OnBoarding/Screens/Products/Screens/product_listing.dart';
import '../../../Presentation/OnBoarding/Screens/Search Screen/Screens/search_screen.dart';
import '../../../Presentation/OnBoarding/Screens/Services Screen/Screens/Service_details.dart';
import '../../../Presentation/OnBoarding/Screens/Services Screen/Screens/service_listing.dart';
import '../../../Presentation/OnBoarding/Screens/Shop Screen/Screens/shops_listing.dart';
import '../../../Presentation/OnBoarding/Screens/Home Screen/Screens/home_screen.dart';
import '../../Utility/app_Images.dart';
import '../../Utility/app_color.dart';
import '../../Utility/google_font.dart';
import '../filter_popup_screen.dart';

class ProductDetailsBottomBar extends StatefulWidget {
  final int initialIndex;
  const ProductDetailsBottomBar({super.key, this.initialIndex = 0});

  @override
  State<ProductDetailsBottomBar> createState() =>
      _ProductDetailsBottomBarState();
}

class _ProductDetailsBottomBarState extends State<ProductDetailsBottomBar> {
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
      // _ExploreScreenStub(), // 2
      ProductDetails(), // 3
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
      // case 2:
      //   _goTo(1);
      //   break; // Magic
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
        physics: const NeverScrollableScrollPhysics(), // tap-only nav
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
