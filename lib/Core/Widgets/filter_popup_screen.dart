import 'package:flutter/material.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Utility/app_color.dart';
import 'package:tringo_app/Core/Utility/common_textfield.dart';
import 'package:tringo_app/Core/Utility/google_font.dart';

class FilterPopupScreen extends StatefulWidget {
  const FilterPopupScreen({super.key});

  @override
  State<FilterPopupScreen> createState() => _FilterPopupScreenState();
}

class _FilterPopupScreenState extends State<FilterPopupScreen> {
  final TextEditingController _controller = TextEditingController();
  final DraggableScrollableController _drag = DraggableScrollableController();
  final FocusNode _searchFocus = FocusNode();
  bool _isFocused = false; // add this in your State

  void clearAllFilters(ScrollController sc) {
    setState(() {
      // selections
      selectedCategories.clear();
      surpriseOffer = null;
      selectedDistance = 'Up to 5Km'; // reset to your default label

      // search
      _controller.clear();
    });

    // hide keyboard
    _searchFocus.unfocus();

    // scroll content to top (optional)
    if (sc.hasClients) {
      sc.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }

    // snap sheet back to mid (optional)
    if (_drag.isAttached) {
      _drag.animateTo(
        0.6, // your initial snap
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void initState() {
    super.initState();

    // focus => grow the SHEET itself (top moves up)
    _searchFocus.addListener(() {
      if (_searchFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 80), () {
          if (_drag.isAttached) {
            _drag.animateTo(
              0.9,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        // optional: snap back to mid
        if (_drag.isAttached) {
          _drag.animateTo(
            0.7,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _drag.dispose();
    _searchFocus.dispose();
    _controller.dispose();
    super.dispose();
  }

  final List<String> allCategories = [
    'Sweets & Bakery',
    'Rice Traders',
    'Grocery',
    'Veg Restaurant',
    'Paint',
    'Fruit Juice',
    'Non-Veg Restaurant',
    'Textiles',
    'Automobile Spare Parts',
    'Fitness',
  ];

  final Set<String> selectedCategories = {'Sweets & Bakery'};
  String selectedDistance = 'Up to 5Km';
  String? surpriseOffer = 'Yes';

  void clearAll() {
    setState(() {
      selectedCategories.clear();
      surpriseOffer = null;
    });
  }

  void clearSurpriseOffer() {
    setState(() => surpriseOffer = null);
  }

  void clearCategories() {
    setState(() => selectedCategories.clear());
  }

  @override
  Widget build(BuildContext context) {
    final kb = MediaQuery.of(context).viewInsets.bottom;
    return DraggableScrollableSheet(
      controller: _drag,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.96,
      snap: true,
      snapSizes: const [0.6, 0.8, 0.96],
      builder: (BuildContext context, ScrollController scrollController) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.only(bottom: kb), // lift above keyboard
          child: Material(
            color: AppColor.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: SafeArea(
              top: false,
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Filter',
                            style: GoogleFont.Mulish(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColor.darkBlue,
                            ),
                          ),
                          Spacer(),
                          Text(
                            'Clear All',
                            style: GoogleFont.Mulish(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: AppColor.lightRed,
                            ),
                          ),
                          SizedBox(width: 15),
                          GestureDetector(
                            onTap: () => clearAllFilters(scrollController),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColor.lowLightRed,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 17,
                                  vertical: 10,
                                ),
                                child: Image.asset(
                                  AppImages.closeImage,
                                  height: 9,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      Text(
                        'Distance',
                        style: GoogleFont.Mulish(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 20),
                      Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Container(
                            height: 40,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColor.textWhite.withOpacity(0.1),
                                  AppColor.textWhite,
                                  AppColor.textWhite,
                                  AppColor.textWhite.withOpacity(0.1),
                                ],
                                begin: Alignment.topRight,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColor.black.withOpacity(0.1),
                                  blurRadius: 0,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 7,
                            left: 5,
                            child: Container(
                              height: 30,
                              width: 150,
                              decoration: BoxDecoration(
                                color: AppColor.blue,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  selectedDistance,
                                  style: GoogleFont.Mulish(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppColor.white,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            left: 135,
                            top: 11,
                            child: Container(
                              width: 10,
                              height: 22,
                              decoration: BoxDecoration(
                                color: AppColor.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Categories',
                            style: GoogleFont.Mulish(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: AppColor.darkBlue,
                            ),
                          ),
                          GestureDetector(
                            onTap: clearCategories,
                            child: Text(
                              'Clear All',
                              style: GoogleFont.Mulish(
                                color: AppColor.blue,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Focus(
                        onFocusChange: (hasFocus) {
                          setState(() => _isFocused = hasFocus);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 0,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.white,
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(
                              color: _isFocused
                                  ? AppColor.blue
                                  : AppColor.lightGray1, // 💙 Change color on focus
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Image.asset(AppImages.searchImage, height: 17),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  focusNode: _searchFocus,
                                  controller: _controller,
                                  onChanged: (_) => setState(() {}),
                                  textAlignVertical: TextAlignVertical
                                      .center, // 👈 CENTER VERTICAL ALIGN
                                  decoration: InputDecoration(
                                    isCollapsed:
                                        true, // 👈 Important for tight vertical fit
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 12, // 👈 Tune this as needed
                                      horizontal: 10,
                                    ),
                                    hintText: 'Search Categories',
                                    border: InputBorder.none,
                                    hintStyle: GoogleFont.Mulish(
                                      color: AppColor.lightGray,
                                      fontSize: 14,
                                    ),
                                    suffixIcon: _controller.text.isNotEmpty
                                        ? IconButton(
                                            icon: Icon(Icons.clear, size: 18),
                                            onPressed: () {
                                              _controller.clear();
                                              setState(() {});
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

                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: allCategories.map((category) {
                          final isSelected = selectedCategories.contains(
                            category,
                          );
                          return ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(category),
                                if (isSelected) SizedBox(width: 8),
                                if (isSelected)
                                  Icon(
                                    Icons.close,
                                    size: 16,
                                    color: AppColor.blue,
                                  ),
                              ],
                            ),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() {
                                if (isSelected) {
                                  selectedCategories.remove(category);
                                } else {
                                  selectedCategories.add(category);
                                }
                              });
                            },
                            selectedColor: AppColor.white,
                            backgroundColor: AppColor.white,
                            showCheckmark: false,
                            shape: StadiumBorder(
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.blue
                                    : AppColor.borderGray,
                              ),
                            ),
                            labelStyle: GoogleFont.Mulish(
                              color: isSelected
                                  ? AppColor.blue
                                  : AppColor.lightGray2,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Surprise Offers
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Surprise Offers',
                            style: GoogleFont.Mulish(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColor.darkBlue,
                            ),
                          ),
                          GestureDetector(
                            onTap: clearSurpriseOffer,
                            child: Text(
                              'Clear All',
                              style: GoogleFont.Mulish(
                                color: AppColor.blue,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          ChoiceChip(
                            showCheckmark: false,
                            label: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 45.0,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Yes'),
                                  if (surpriseOffer == 'Yes') ...[
                                    SizedBox(width: 10),
                                    Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            selected: surpriseOffer == 'Yes',
                            onSelected: (_) {
                              setState(() => surpriseOffer = 'Yes');
                            },
                            selectedColor: AppColor.white,
                            backgroundColor: AppColor.white,
                            shape: StadiumBorder(
                              side: BorderSide(
                                color: surpriseOffer == 'Yes'
                                    ? AppColor.blue
                                    : AppColor.borderGray,
                              ),
                            ),
                            labelStyle: GoogleFont.Mulish(
                              color: surpriseOffer == 'Yes'
                                  ? AppColor.blue
                                  : AppColor.lightGray2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          ChoiceChip(
                            showCheckmark: false,
                            label: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 45.0,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('No'),
                                  if (surpriseOffer == 'No') ...[
                                    SizedBox(width: 10),
                                    Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            selected: surpriseOffer == 'No',
                            onSelected: (_) {
                              setState(() => surpriseOffer = 'No');
                            },
                            selectedColor: AppColor.white,
                            backgroundColor: AppColor.white,
                            shape: StadiumBorder(
                              side: BorderSide(
                                color: surpriseOffer == 'No'
                                    ? AppColor.blue
                                    : AppColor.borderGray,
                              ),
                            ),
                            labelStyle: GoogleFont.Mulish(
                              color: surpriseOffer == 'No'
                                  ? AppColor.blue
                                  : AppColor.lightGray2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
