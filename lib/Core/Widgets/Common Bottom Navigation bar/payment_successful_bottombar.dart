import 'package:flutter/material.dart';
import 'package:tringo_app/Core/Widgets/Common%20Bottom%20Navigation%20bar/search_screen_bottombar.dart';
import 'package:tringo_app/Core/Widgets/sortby_popup_screen.dart';
import '../../../Presentation/OnBoarding/Screens/Food Screen/food_booking_success.dart';
import '../../../Presentation/OnBoarding/Screens/Food Screen/food_details.dart';
import '../../../Presentation/OnBoarding/Screens/Food Screen/food_list.dart';
import '../../../Presentation/OnBoarding/Screens/Products/product_listing.dart';
import '../../../Presentation/OnBoarding/Screens/Search Screen/search_screen.dart';
import '../../../Presentation/OnBoarding/Screens/Services Screen/Service_details.dart';
import '../../../Presentation/OnBoarding/Screens/Services Screen/service_listing.dart';
import '../../../Presentation/OnBoarding/Screens/Shop Screen/shops_listing.dart';
import '../../../Presentation/OnBoarding/Screens/Home Screen/home_screen.dart';
import '../../Utility/app_Images.dart';
import '../../Utility/app_color.dart';
import '../../Utility/google_font.dart';
import '../filter_popup_screen.dart';

class PaymentSuccessfulBottombar extends StatefulWidget {
  final int initialIndex;
  const PaymentSuccessfulBottombar({super.key, this.initialIndex = 0});

  @override
  State<PaymentSuccessfulBottombar> createState() =>
      _PaymentSuccessfulBottombarState();
}

class _PaymentSuccessfulBottombarState
    extends State<PaymentSuccessfulBottombar> {
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
      FoodBookingSuccess(), // 3
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
        _goTo(1);
        break; // Magic
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
                      padding: const EdgeInsets.all(10.5),
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
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(7.0),
                        child: Image.asset(
                          AppImages.searchImage,
                          height: 14,
                          color: AppColor.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColor.blue),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 7,
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              AppImages.downloadImage,
                              height: 20,
                              color: AppColor.blue,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Download Receipt',
                              style: GoogleFont.Mulish(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColor.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColor.darkBlue),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              AppImages.support,
                              height: 19,
                              color: AppColor.darkBlue,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Support',
                              style: GoogleFont.Mulish(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColor.darkBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: border, width: 1.2),
        ),
        child: child,
      ),
    );
  }

}
