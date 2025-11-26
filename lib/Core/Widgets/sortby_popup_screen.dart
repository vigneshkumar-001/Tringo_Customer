import 'package:flutter/material.dart';
import 'package:tringo_app/Core/Widgets/common_container.dart';
import '../Utility/app_Images.dart';
import '../Utility/app_color.dart';
import '../Utility/google_font.dart';

class SortbyPopupScreen extends StatelessWidget {
  const SortbyPopupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const topRadius = Radius.circular(20);
    final kb = MediaQuery.of(context).viewInsets.bottom;
    return SizedBox.expand(
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.96,
        expand: false, // <-- important: don’t force to fill
        builder: (context, scrollController) {
          return ClipRRect(
            clipBehavior: Clip.antiAlias,
            borderRadius: const BorderRadius.vertical(top: topRadius),
            child: Material(
              color: AppColor.white,
              child: SafeArea(
                top: false,
                child: ListView(
                  controller: scrollController, // <-- wire the controller
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 25,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
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
                        const Spacer(),
                        Text(
                          'Clear All',
                          style: GoogleFont.Mulish(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: AppColor.lightRed,
                          ),
                        ),
                        const SizedBox(width: 15),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColor.lowLightRed,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 17,
                              vertical: 10,
                            ),
                            child: Image.asset(AppImages.closeImage, height: 9),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    CommonContainer.sortbyPopup(
                      image: AppImages.rightArrow,
                      iconColor: AppColor.blue,
                      text1: 'Near',
                      text2: 'Distance',
                      onTap: () {},
                      horizontalDivider: true,
                    ),
                    const SizedBox(height: 19),

                    CommonContainer.sortbyPopup(
                      image: AppImages.rightArrow,
                      iconColor: AppColor.blue,
                      text1: 'Distance',
                      text2: 'Near',
                      onTap: () {},
                      horizontalDivider: true,
                    ),
                    const SizedBox(height: 19),

                    CommonContainer.sortbyPopup(
                      image: AppImages.rightArrow,
                      iconColor: AppColor.blue,
                      text1: 'Surprise Offer',
                      text2: 'App Offer',
                      onTap: () {},
                      horizontalDivider: true,
                    ),
                    const SizedBox(height: 19),

                    CommonContainer.sortbyPopup(
                      image: AppImages.rightArrow,
                      iconColor: AppColor.blue,
                      text1: 'App Offer',
                      text2: 'Surprise Offer',
                      onTap: () {},
                      horizontalDivider: true,
                    ),
                    const SizedBox(height: 19),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
