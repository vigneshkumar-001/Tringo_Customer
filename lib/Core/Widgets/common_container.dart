import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Utility/app_color.dart';

import '../Utility/google_font.dart';

Set<int> selectedIndexes = {};

class CommonContainer {
  static rightSideArrowButton({VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.black,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 14),
          child: Image.asset(AppImages.rightSideArrow, height: 15),
        ),
      ),
    );
  }

  static foodOBox({
    required String offRate,
    required String oldRate,
    required String image,
    required String foodName,
    required String rating,
    required String hotelName,
    required String distance,
    required String QtyList,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 245.79,
        width: 150.5,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.whiteSmoke, width: 1.9),
          color: AppColor.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColor.lightRed,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: Column(
                  children: [
                    Text(
                      offRate, // ← use param
                      style: GoogleFont.Mulish(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: AppColor.white,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColor.lowLightWhite,
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(14),
                          bottomLeft: Radius.circular(14),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 3,
                        horizontal: 40,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            oldRate, // ← use param
                            style: GoogleFont.Mulish(
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                              color: Colors.black,
                            ),
                          ),
                          Transform.rotate(
                            angle: -0.3,
                            child: Container(
                              height: 2,
                              width: 35,
                              color: AppColor.lightRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Image.asset(image, height: 72.29, width: 114.5),
            const SizedBox(height: 5),

            // Title
            Row(
              children: [
                Flexible(
                  child: Text(
                    foodName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFont.Mulish(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColor.lightBlueCont,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColor.green,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Text(
                        rating,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFont.Mulish(
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          color: AppColor.white,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Image.asset(AppImages.starImage, height: 7),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    hotelName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFont.Mulish(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColor.lightGray2,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),

            Expanded(
              child: Row(
                children: [
                  Image.asset(
                    AppImages.locationImage,
                    height: 10,
                    color: AppColor.lightGray2,
                  ),
                  SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      distance,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFont.Mulish(
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        color: AppColor.lightGray3,
                      ),
                    ),
                  ),
                  SizedBox(width: 35),
                  Text(
                    QtyList,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFont.Mulish(
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      color: AppColor.darkBlue,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'Qty',
                    style: GoogleFont.Mulish(
                      fontSize: 11,
                      color: AppColor.lightGray3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static shopImageContainer({
    required String shopName,
    required String location,
    required String km,
    required String ratingStar,
    required String ratingCount,
    required String time,
    required String Images,
    bool verify = false,
    VoidCallback? onTap,
    String? heroTag,
  }) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: heroTag != null
                ? Hero(
                    tag: heroTag,
                    child: Image.asset(
                      Images,
                      height: 183,
                      width: 257,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    Images,
                    height: 183,
                    width: 257,
                    fit: BoxFit.cover,
                  ),
          ),
          Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColor.black.withOpacity(0.01),
                    AppColor.black.withOpacity(0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 70, right: 15, left: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (verify)
                      Padding(
                        padding: const EdgeInsets.only(right: 140.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColor.blueGradient1,
                                AppColor.blueGradient2,
                                AppColor.blueGradient3,
                              ],
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(AppImages.verifyTick, height: 14),
                                const SizedBox(width: 4),
                                Text(
                                  'Trusted',
                                  style: GoogleFont.Mulish(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 10,
                                    color: AppColor.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            shopName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFont.Mulish(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColor.textWhite,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Image.asset(AppImages.locationImage, height: 10),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFont.Mulish(
                              fontWeight: FontWeight.bold,
                              fontSize: 8,
                              color: AppColor.textLowWhite,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          km,
                          style: GoogleFont.Mulish(
                            fontWeight: FontWeight.bold,
                            fontSize: 8,
                            color: AppColor.textLowWhite,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        /* Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.green,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize:
                                MainAxisSize.min, // 👈 stops expanding too much
                            children: [
                              Text(
                                ratingStar,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFont.Mulish(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                  color: AppColor.white,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Image.asset(AppImages.starImage, height: 7),
                              const SizedBox(width: 5),
                              Container(
                                width: 1.5,
                                height: 11,
                                decoration: BoxDecoration(
                                  color: AppColor.white.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                ratingCount,
                                style: GoogleFont.Mulish(
                                  fontSize: 8,
                                  color: AppColor.white,
                                ),
                              ),
                            ],
                          ),
                        ),*/
                        CommonContainer.greenStarRating(
                          ratingCount: ratingCount,
                          ratingStar: ratingStar,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Max',
                          style: GoogleFont.Mulish(
                            fontSize: 9,
                            color: AppColor.lightGray2,
                          ),
                        ),
                        Text(
                          time,
                          style: GoogleFont.Mulish(
                            fontSize: 9,
                            color: AppColor.lightGray2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget categoryChip(
    String text, {
    bool isSelected = false,
    required VoidCallback onTap,
    Color? ContainerColor,
    Color? BorderColor,
    Color? TextColor,
    bool rightSideArrow = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(25),
      onTap: onTap, // ✅ whole chip tappable
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
        decoration: BoxDecoration(
          color: ContainerColor!,
          // isSelected ? AppColor.iceBlue : Colors.transparent,
          border: Border.all(
            color: BorderColor!,
            // isSelected ? AppColor.deepTeaBlue : AppColor.frostBlue,
            width: isSelected ? 2.5 : 1.5,
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Text(
              text,
              style: GoogleFont.Mulish(
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                fontSize: 14,
                color: TextColor,
                // isSelected ? AppColor.darkBlue : AppColor.deepTeaBlue,
              ),
            ),
            SizedBox(width: 6),
            if (rightSideArrow)
              Image.asset(
                AppImages.rightArrow,
                height: 11,
                color: AppColor.lightGray2,
              ),
          ],
        ),
      ),
    );
  }

  static verifyTick() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.blueGradient1,
            AppColor.blueGradient2,
            AppColor.blueGradient3,
          ],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(AppImages.verifyTick, height: 14),
            SizedBox(width: 4),
            Text(
              'Trusted',
              style: GoogleFont.Mulish(
                fontWeight: FontWeight.w900,
                fontSize: 10,
                color: AppColor.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static callNowButton({
    VoidCallback? callOnTap,
    VoidCallback? orderOnTap,
    VoidCallback? mapOnTap,
    VoidCallback? messageOnTap,
    VoidCallback? whatsAppOnTap,
    VoidCallback? fireOnTap,

    bool messageContainer = false,
    bool mapBox = false,
    bool fullEnquiry = false,
    bool whatsAppIcon = false,
    bool MessageIcon = false,
    bool FireIcon = false,
    bool order = false,

    // 🔹 NEW: message loading flag
    bool messageLoading = false,

    EdgeInsetsGeometry? callNowPadding,
    EdgeInsetsGeometry? mapBoxPadding,
    EdgeInsetsGeometry? iconContainerPadding,

    double? callIconSize,
    double? callTextSize,
    double? mapIconSize,
    double? mapTextSize,
    double? messagesIconSize,
    double? whatsAppIconSize,
    double? fireIconSize,

    Color? callImageColor,
    String? fireTooltip,
    String? mapImage,
    String? mapText,
    String? callImage,
    String? callText,
    String? orderText,
    String? orderImage,
  }) {
    // ---- Set SAFE DEFAULTS ----
    final safeCallImage = callImage ?? AppImages.callImage;
    final safeCallText = callText ?? "Call";

    final safeOrderImage = orderImage ?? AppImages.orderImage;
    final safeOrderText = orderText ?? "Order";

    final safeMapImage = mapImage ?? AppImages.locationImage;
    final safeMapText = mapText ?? "Map";

    return Row(
      children: [
        if (order)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: orderOnTap,
              child: Container(
                padding:
                    callNowPadding ??
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColor.blueGradient1,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Image.asset(safeOrderImage, height: callIconSize ?? 16),
                    const SizedBox(width: 7),
                    Text(
                      safeOrderText,
                      style: GoogleFont.Mulish(
                        fontWeight: FontWeight.bold,
                        fontSize: callTextSize ?? 16,
                        color: AppColor.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // CALL BUTTON
        LayoutBuilder(
          builder: (context, constraints) {
            final bounded =
                constraints.hasBoundedWidth && constraints.maxWidth.isFinite;

            final callBtn = InkWell(
              onTap: callOnTap,
              child: Container(
                padding:
                    callNowPadding ??
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColor.blue,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      safeCallImage,
                      height: callIconSize ?? 16,
                      color: callImageColor,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      safeCallText,
                      style: GoogleFont.Mulish(
                        fontWeight: FontWeight.bold,
                        fontSize: callTextSize ?? 14,
                        color: AppColor.white,
                      ),
                    ),
                  ],
                ),
              ),
            );

            return bounded ? Expanded(child: callBtn) : callBtn;
          },
        ),
        if (fullEnquiry)
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: InkWell(
              onTap: messageLoading ? null : messageOnTap,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColor.blue, width: 1.5),
                ),
                child: Padding(
                  padding:
                      mapBoxPadding ??
                      const EdgeInsets.symmetric(horizontal: 17, vertical: 5),
                  // 🔹 FIX: give inner content a fixed width/height
                  child: SizedBox(
                    height: 24, // same height for both states
                    width: 130, // adjust to match your current button width
                    child: messageLoading
                        ? const Center(
                            child: SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                safeMapImage,
                                height: mapIconSize ?? 21,
                                color: AppColor.blue,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                safeMapText,
                                style: GoogleFont.Mulish(
                                  fontWeight: FontWeight.bold,
                                  fontSize: mapTextSize ?? 16,
                                  color: AppColor.blue,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),

        if (mapBox)
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: InkWell(
              onTap: mapOnTap,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColor.blue, width: 1.5),
                ),
                child: Padding(
                  padding:
                      mapBoxPadding ??
                      const EdgeInsets.symmetric(horizontal: 17, vertical: 5),
                  child: Row(
                    children: [
                      Image.asset(
                        safeMapImage,
                        height: mapIconSize ?? 21,
                        color: AppColor.blue,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        safeMapText,
                        style: GoogleFont.Mulish(
                          fontWeight: FontWeight.bold,
                          fontSize: mapTextSize ?? 16,
                          color: AppColor.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        if (messageContainer && (MessageIcon || whatsAppIcon || FireIcon))
          const SizedBox(width: 9),

        if (messageContainer && (MessageIcon || whatsAppIcon || FireIcon))
          Container(
            padding:
                iconContainerPadding ??
                const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            decoration: BoxDecoration(
              color: AppColor.white2,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Wrap(
              spacing: 16,
              alignment: WrapAlignment.center,
              children: [
                if (MessageIcon)
                  GestureDetector(
                    onTap: messageLoading ? null : messageOnTap,
                    child: messageLoading
                        ? SizedBox(
                            height: messagesIconSize ?? 19,
                            width: messagesIconSize ?? 19,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Image.asset(
                            AppImages.messageImage,
                            height: messagesIconSize ?? 19,
                          ),
                  ),
                if (whatsAppIcon)
                  GestureDetector(
                    onTap: whatsAppOnTap,
                    child: Image.asset(
                      AppImages.whatsappImage,
                      height: whatsAppIconSize ?? 19,
                    ),
                  ),
                if (FireIcon)
                  Tooltip(
                    message: fireTooltip ?? 'Trending service',
                    child: GestureDetector(
                      onTap: fireOnTap,
                      child: Image.asset(
                        AppImages.fireImage,
                        height: fireIconSize ?? 19,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  /*
  static callNowButton({
    VoidCallback? callOnTap,
    VoidCallback? orderOnTap,
    VoidCallback? mapOnTap,
    VoidCallback? messageOnTap,
    VoidCallback? whatsAppOnTap,
    VoidCallback? fireOnTap,
    bool messageLoading = false,
    bool messageContainer = false,
    bool mapBox = false,
    bool whatsAppIcon = false,
    bool MessageIcon = false,
    bool FireIcon = false,
    bool order = false,

    EdgeInsetsGeometry? callNowPadding,
    EdgeInsetsGeometry? mapBoxPadding,
    EdgeInsetsGeometry? iconContainerPadding,

    double? callIconSize,
    double? callTextSize,
    double? mapIconSize,
    double? mapTextSize,
    double? messagesIconSize,
    double? whatsAppIconSize,
    double? fireIconSize,

    Color? callImageColor,

    String? mapImage,
    String? mapText,
    String? callImage,
    String? callText,
    String? orderText,
    String? orderImage,
  })
  {
    // ---- Set SAFE DEFAULTS ----
    final safeCallImage = callImage ?? AppImages.callImage;
    final safeCallText = callText ?? "Call";

    final safeOrderImage = orderImage ?? AppImages.orderImage;
    final safeOrderText = orderText ?? "Order";

    final safeMapImage = mapImage ?? AppImages.locationImage;
    final safeMapText = mapText ?? "Map";

    return Row(
      children: [
        if (order)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: orderOnTap,
              child: Container(
                padding:
                    callNowPadding ??
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColor.blueGradient1,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Image.asset(safeOrderImage, height: callIconSize ?? 16),
                    SizedBox(width: 7),
                    Text(
                      safeOrderText,
                      style: GoogleFont.Mulish(
                        fontWeight: FontWeight.bold,
                        fontSize: callTextSize ?? 16,
                        color: AppColor.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // CALL BUTTON SAFE VERSION
        LayoutBuilder(
          builder: (context, constraints) {
            final bounded =
                constraints.hasBoundedWidth && constraints.maxWidth.isFinite;

            final callBtn = InkWell(
              onTap: callOnTap,
              child: Container(
                padding:
                    callNowPadding ??
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColor.blue,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      safeCallImage,
                      height: callIconSize ?? 16,
                      color: callImageColor,
                    ),
                    SizedBox(width: 7),
                    Text(
                      safeCallText,
                      style: GoogleFont.Mulish(
                        fontWeight: FontWeight.bold,
                        fontSize: callTextSize ?? 14,
                        color: AppColor.white,
                      ),
                    ),
                  ],
                ),
              ),
            );

            return bounded ? Expanded(child: callBtn) : callBtn;
          },
        ),

        if (mapBox)
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: InkWell(
              onTap: mapOnTap,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColor.blue, width: 1.5),
                ),
                child: Padding(
                  padding:
                      mapBoxPadding ??
                      const EdgeInsets.symmetric(horizontal: 17, vertical: 5),
                  child: Row(
                    children: [
                      Image.asset(
                        safeMapImage,
                        height: mapIconSize ?? 21,
                        color: AppColor.blue,
                      ),
                      SizedBox(width: 5),
                      Text(
                        safeMapText,
                        style: GoogleFont.Mulish(
                          fontWeight: FontWeight.bold,
                          fontSize: mapTextSize ?? 16,
                          color: AppColor.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        if (messageContainer && (MessageIcon || whatsAppIcon || FireIcon))
          SizedBox(width: 9),

        if (messageContainer && (MessageIcon || whatsAppIcon || FireIcon))
          Container(
            padding:
                iconContainerPadding ??
                const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            decoration: BoxDecoration(
              color: AppColor.white2,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Wrap(
              spacing: 16,
              alignment: WrapAlignment.center,
              children: [
                if (MessageIcon)
                  GestureDetector(
                    onTap: messageOnTap,
                    child: Image.asset(
                      AppImages.messageImage,
                      height: messagesIconSize ?? 19,
                    ),
                  ),
                if (whatsAppIcon)
                  GestureDetector(
                    onTap: whatsAppOnTap,
                    child: Image.asset(
                      AppImages.whatsappImage,
                      height: whatsAppIconSize ?? 19,
                    ),
                  ),
                if (FireIcon)
                  GestureDetector(
                    onTap: fireOnTap,
                    child: Image.asset(
                      AppImages.fireImage,
                      height: fireIconSize ?? 19,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
*/

  // static callNowButton({
  //   VoidCallback? callOnTap,
  //   VoidCallback? orderOnTap,
  //   VoidCallback? mapOnTap,
  //   VoidCallback? messageOnTap,
  //   VoidCallback? whatsAppOnTap,
  //   VoidCallback? fireOnTap,
  //   bool messageContainer = false,
  //   bool mapBox = false,
  //   bool whatsAppIcon = false,
  //   bool MessageIcon = false,
  //   bool FireIcon = false,
  //   bool order = false,
  //
  //   // Custom paddings
  //   EdgeInsetsGeometry? callNowPadding,
  //   EdgeInsetsGeometry? mapBoxPadding,
  //   EdgeInsetsGeometry? iconContainerPadding,
  //
  //   // Custom sizes
  //   double? callIconSize,
  //   double? callTextSize,
  //   double? mapIconSize,
  //   double? mapTextSize,
  //   double? messagesIconSize,
  //   double? whatsAppIconSize,
  //   double? fireIconSize,
  //
  //   Color? callImageColor,
  //
  //   String? mapImage,
  //   String? mapText,
  //   String? callImage,
  //   String? callText,
  //   String? orderText,
  //   String? orderImage,
  // }) {
  //   return Row(
  //     children: [
  //       if (order)
  //         Padding(
  //           padding: const EdgeInsets.only(right: 8.0),
  //           child: InkWell(
  //             onTap: orderOnTap,
  //             child: Container(
  //               padding:
  //                   callNowPadding ??
  //                   const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
  //               decoration: BoxDecoration(
  //                 color: AppColor.blueGradient1,
  //                 borderRadius: BorderRadius.circular(15),
  //               ),
  //               child: Row(
  //                 children: [
  //                   Image.asset(orderImage!, height: callIconSize ?? 16),
  //                   const SizedBox(width: 7),
  //                   Text(
  //                     orderText!,
  //                     style: GoogleFont.Mulish(
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: callTextSize ?? 16,
  //                       color: AppColor.white,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //
  //       // ---- Call button (smart flexible) ----
  //       LayoutBuilder(
  //         builder: (context, constraints) {
  //           final bounded =
  //               constraints.hasBoundedWidth && constraints.maxWidth.isFinite;
  //
  //           final callBtn = InkWell(
  //             onTap: callOnTap,
  //             child: Container(
  //               padding:
  //                   callNowPadding ??
  //                   const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
  //               decoration: BoxDecoration(
  //                 color: AppColor.blue,
  //                 borderRadius: BorderRadius.circular(15),
  //               ),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.center, // nice centering
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Image.asset(
  //                     callImage!,
  //                     height: callIconSize ?? 16,
  //                     color: callImageColor,
  //                   ),
  //                     SizedBox(width: 7),
  //                   Text(
  //                     callText!,
  //                     style: GoogleFont.Mulish(
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: callTextSize ?? 14,
  //                       color: AppColor.white,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //
  //           // If width is bounded (typical page layout), behave like Expanded.
  //           // If unbounded (inside horizontal SingleChildScrollView), return intrinsic size.
  //           return bounded ? Expanded(child: callBtn) : callBtn;
  //         },
  //       ),
  //
  //       // ⬇️ make call button flexible so layout matches Figma on all screens
  //       /*   Expanded(
  //         child: InkWell(
  //           onTap: callOnTap,
  //           child: Container(
  //             padding: callNowPadding ?? const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
  //             decoration: BoxDecoration(
  //               color: AppColor.blue,
  //               borderRadius: BorderRadius.circular(15),
  //             ),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.center, // keep icon + text centered
  //               children: [
  //                 Image.asset(callImage!, height: callIconSize ?? 16, color: callImageColor),
  //                 const SizedBox(width: 7),
  //                 Text(
  //                   callText!,
  //                   style: GoogleFont.Mulish(
  //                     fontWeight: FontWeight.bold,
  //                     fontSize: callTextSize ?? 14,
  //                     color: AppColor.white,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),*/
  //       if (mapBox)
  //         Padding(
  //           padding: const EdgeInsets.only(left: 10),
  //           child: InkWell(
  //             borderRadius: BorderRadius.circular(14),
  //             onTap: mapOnTap,
  //             child: Container(
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(14),
  //                 border: Border.all(color: AppColor.blue, width: 1.5),
  //               ),
  //               child: Padding(
  //                 padding:
  //                     mapBoxPadding ??
  //                     const EdgeInsets.symmetric(horizontal: 17, vertical: 5),
  //                 child: Row(
  //                   children: [
  //                     Image.asset(
  //                       mapImage!,
  //                       height: mapIconSize ?? 21,
  //                       color: AppColor.blue,
  //                     ),
  //                     const SizedBox(width: 3),
  //                     Text(
  //                       mapText!,
  //                       style: GoogleFont.Mulish(
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: mapTextSize ?? 16,
  //                         color: AppColor.blue,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //
  //       // ⬇️ only add gap if the pill is going to show
  //       if (messageContainer && (MessageIcon || whatsAppIcon || FireIcon))
  //         const SizedBox(width: 9),
  //
  //       if (messageContainer && (MessageIcon || whatsAppIcon || FireIcon))
  //         Container(
  //           padding:
  //               iconContainerPadding ??
  //               const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
  //           decoration: BoxDecoration(
  //             color: AppColor.white2,
  //             borderRadius: BorderRadius.circular(16),
  //           ),
  //           // ⬇️ auto-size & auto-center the icons based on how many are visible
  //           child: Wrap(
  //             spacing: 16, // even spacing for 2+ icons
  //             alignment: WrapAlignment.center,
  //             crossAxisAlignment: WrapCrossAlignment.center,
  //             children: [
  //               if (MessageIcon)
  //                 GestureDetector(
  //                   onTap: messageOnTap,
  //                   child: Image.asset(
  //                     AppImages.messageImage,
  //                     height: messagesIconSize ?? 19,
  //                   ),
  //                 ),
  //               if (whatsAppIcon)
  //                 GestureDetector(
  //                   onTap: whatsAppOnTap,
  //                   child: Image.asset(
  //                     AppImages.whatsappImage,
  //                     height: whatsAppIconSize ?? 19,
  //                   ),
  //                 ),
  //               if (FireIcon)
  //                 GestureDetector(
  //                   onTap: fireOnTap,
  //                   child: Image.asset(
  //                     AppImages.fireImage,
  //                     height: fireIconSize ?? 19,
  //                   ),
  //                 ),
  //             ],
  //           ),
  //         ),
  //     ],
  //   );
  //
  //   /*return Row(
  //     children: [
  //       if (order)
  //         Padding(
  //           padding: const EdgeInsets.only(right: 8.0),
  //           child: InkWell(
  //             onTap: orderOnTap,
  //             child: Container(
  //               padding:
  //                   callNowPadding ??
  //                   EdgeInsets.symmetric(horizontal: 40, vertical: 8),
  //               decoration: BoxDecoration(
  //                 color: AppColor.blueGradient1,
  //                 borderRadius: BorderRadius.circular(15),
  //               ),
  //               child: Row(
  //                 children: [
  //                   Image.asset(
  //                     AppImages.orderImage,
  //                     height: callIconSize ?? 16,
  //                   ),
  //                   SizedBox(width: 7),
  //                   Text(
  //                     'Order Your’s',
  //                     style: GoogleFont.Mulish(
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: callTextSize ?? 16,
  //                       color: AppColor.white,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //
  //       InkWell(
  //         onTap: callOnTap,
  //         child: Container(
  //           padding:
  //               callNowPadding ??
  //               EdgeInsets.symmetric(horizontal: 40, vertical: 8),
  //           decoration: BoxDecoration(
  //             color: AppColor.blue,
  //             borderRadius: BorderRadius.circular(15),
  //           ),
  //           child: Row(
  //             children: [
  //               Image.asset(
  //                 callImage!,
  //                 height: callIconSize ?? 16,
  //                 color: callImageColor,
  //               ),
  //               SizedBox(width: 7),
  //               Text(
  //                 callText!,
  //                 style: GoogleFont.Mulish(
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: callTextSize ?? 14,
  //                   color: AppColor.white,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //
  //       if (mapBox)
  //         Padding(
  //           padding: const EdgeInsets.only(left: 10),
  //           child: InkWell(
  //             borderRadius: BorderRadius.circular(14),
  //             onTap: mapOnTap,
  //             child: Container(
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(14),
  //                 border: Border.all(color: AppColor.blue, width: 1.5),
  //               ),
  //               child: Padding(
  //                 padding:
  //                     mapBoxPadding ??
  //                     const EdgeInsets.symmetric(horizontal: 17, vertical: 5),
  //                 child: Row(
  //                   children: [
  //                     Image.asset(
  //                       mapImage!,
  //                       height: mapIconSize ?? 21,
  //                       color: AppColor.blue,
  //                     ),
  //                     SizedBox(width: 3),
  //                     Text(
  //                       mapText!,
  //                       style: GoogleFont.Mulish(
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: mapTextSize ?? 16,
  //                         color: AppColor.blue,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //
  //       SizedBox(width: 9),
  //
  //       if (messageContainer)
  //         // Action Icon Container (message, WhatsApp, fire)
  //         Container(
  //           padding:
  //               iconContainerPadding ??
  //               EdgeInsets.symmetric(horizontal: 25, vertical: 10),
  //           decoration: BoxDecoration(
  //             color: AppColor.white2,
  //             borderRadius: BorderRadius.circular(16),
  //           ),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.center, // center icons
  //             mainAxisSize: MainAxisSize.min, // shrink-wrap the row
  //             children: [
  //               if (MessageIcon)
  //                 GestureDetector(
  //                   onTap: messageOnTap,
  //                   child: Image.asset(
  //                     AppImages.messageImage,
  //                     height: messagesIconSize ?? 19,
  //                   ),
  //                 ),
  //
  //               if (whatsAppIcon)
  //                 Padding(
  //                   padding: const EdgeInsets.symmetric(horizontal: 16),
  //                   child: GestureDetector(
  //                     onTap: whatsAppOnTap,
  //                     child: Image.asset(
  //                       AppImages.whatsappImage,
  //                       height: whatsAppIconSize ?? 19,
  //                     ),
  //                   ),
  //                 ),
  //
  //               if (FireIcon)
  //                 GestureDetector(
  //                   onTap: fireOnTap,
  //                   child: Image.asset(
  //                     AppImages.fireImage,
  //                     height: fireIconSize ?? 19,
  //                   ),
  //                 ),
  //             ],
  //           ),
  //         ),
  //     ],
  //   );*/
  // }

  static servicesContainer({
    required String image,
    required String companyName,
    required String location,
    required String fieldName,
    required String ratingStar,
    required String ratingCount,
    required String time,
    String? heroTag,
    VoidCallback? onTap,
    VoidCallback? callTap,
    VoidCallback? messageOnTap,
    VoidCallback? whatsAppOnTap,
    VoidCallback? fireOnTap,
    String? fireTooltip,
    bool horizontalDivider = false,
    bool Verify = false,

    bool isMessageLoading = false,
  }) {
    Widget thumb = CachedNetworkImage(
      imageUrl: image,
      height: 100,
      width: 100,
      fit: BoxFit.cover,
      placeholder: (context, url) => const SizedBox(
        height: 50,
        width: 50,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (context, url, error) => const SizedBox(
        height: 100,
        width: 100,
        child: Icon(Icons.broken_image),
      ),
    );

    if (heroTag != null && heroTag.isNotEmpty) {
      thumb = Hero(tag: heroTag, child: thumb);
    }

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // ... your existing top content (image, name, rating, etc.)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Row(
                children: [
                  ClipRRect(
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.circular(12),
                    child: thumb,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (Verify)
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColor.blueGradient1,
                                  AppColor.blueGradient2,
                                  AppColor.blueGradient3,
                                ],
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(AppImages.verifyTick, height: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Trusted',
                                    style: GoogleFont.Mulish(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10,
                                      color: AppColor.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 9),
                        Text(
                          companyName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFont.Mulish(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppColor.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Image.asset(
                              AppImages.locationImage,
                              height: 10,
                              color: AppColor.lightGray2,
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFont.Mulish(
                                  fontSize: 12,
                                  color: AppColor.lightGray2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              fieldName,
                              style: GoogleFont.Mulish(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: AppColor.lightGray3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            CommonContainer.greenStarRating(
                              ratingStar: ratingStar,
                              ratingCount: ratingCount,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Opens Upto ',
                              style: GoogleFont.Mulish(
                                fontSize: 9,
                                color: AppColor.lightGray2,
                              ),
                            ),
                            Text(
                              time,
                              style: GoogleFont.Mulish(
                                fontSize: 9,
                                color: AppColor.lightGray2,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 CALL / MESSAGE / WHATSAPP ROW
            CommonContainer.callNowButton(
              callImage: AppImages.callImage,
              callIconSize: 16,
              callText: 'Call Now',
              MessageIcon: true,
              whatsAppIcon: true,
              FireIcon: true,
              fireOnTap: fireOnTap,
              fireTooltip: fireTooltip,
              whatsAppOnTap: whatsAppOnTap,
              messageOnTap: messageOnTap,

              callOnTap: callTap,
              messageContainer: true,
              // 🔹 pass loading flag
              messageLoading: isMessageLoading,
            ),
            const SizedBox(height: 20),
            if (horizontalDivider) CommonContainer.horizonalDivider(),
          ],
        ),
      ),
    );
  }

  /*
  static servicesContainer({
    required String image,
    required String companyName,
    required String location,
    required String fieldName,
    required String ratingStar,
    required String ratingCount,
    required String time,
    String? heroTag, // 👈 optional
    VoidCallback? onTap,
    VoidCallback? callTap,
    VoidCallback? messageOnTap,
    VoidCallback? whatsAppOnTap,
    bool horizontalDivider = false,
    bool Verify = false,
  })
  {
    // thumbnail
    // Widget thumb = Image.network(
    //   image,
    //   height: 100,
    //   width: 100,
    //   fit: BoxFit.cover,
    // );
    Widget thumb = CachedNetworkImage(
      imageUrl: image,
      height: 100,
      width: 100,
      fit: BoxFit.cover,
      placeholder: (context, url) => const SizedBox(
        height: 50,
        width: 50,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (context, url, error) => const SizedBox(
        height: 100,
        width: 100,
        child: Icon(Icons.broken_image),
      ),
    );

    // only wrap with Hero if a tag is provided
    if (heroTag != null && heroTag.isNotEmpty) {
      thumb = Hero(tag: heroTag, child: thumb);
    }

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Row(
                children: [
                  ClipRRect(
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.circular(12),
                    child: thumb, // 👈 uses hero ONLY when heroTag provided
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (Verify)
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColor.blueGradient1,
                                  AppColor.blueGradient2,
                                  AppColor.blueGradient3,
                                ],
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(AppImages.verifyTick, height: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Trusted',
                                    style: GoogleFont.Mulish(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10,
                                      color: AppColor.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 9),
                        Text(
                          companyName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFont.Mulish(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppColor.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Image.asset(
                              AppImages.locationImage,
                              height: 10,
                              color: AppColor.lightGray2,
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFont.Mulish(
                                  fontSize: 12,
                                  color: AppColor.lightGray2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              fieldName,
                              style: GoogleFont.Mulish(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: AppColor.lightGray3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            // Container(
                            //   padding: const EdgeInsets.symmetric(
                            //     horizontal: 8,
                            //     vertical: 4,
                            //   ),
                            //   decoration: BoxDecoration(
                            //     color: AppColor.green,
                            //     borderRadius: BorderRadius.circular(30),
                            //   ),
                            //   child: Row(
                            //     mainAxisSize: MainAxisSize.min,
                            //     children: [
                            //       Text(
                            //         ratingStar,
                            //         style: GoogleFont.Mulish(
                            //           fontWeight: FontWeight.bold,
                            //           fontSize: 14,
                            //           color: AppColor.white,
                            //         ),
                            //       ),
                            //       const SizedBox(width: 5),
                            //       Image.asset(AppImages.starImage, height: 9),
                            //       const SizedBox(width: 5),
                            //       Container(
                            //         width: 1.5,
                            //         height: 11,
                            //         decoration: BoxDecoration(
                            //           color: AppColor.white.withOpacity(0.2),
                            //           borderRadius: BorderRadius.circular(1),
                            //         ),
                            //       ),
                            //       const SizedBox(width: 5),
                            //       Text(
                            //         ratingCount,
                            //         style: GoogleFont.Mulish(
                            //           fontSize: 12,
                            //           color: AppColor.white,
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            CommonContainer.greenStarRating(
                              ratingStar: ratingStar,
                              ratingCount: ratingCount,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Opens Upto ',
                              style: GoogleFont.Mulish(
                                fontSize: 9,
                                color: AppColor.lightGray2,
                              ),
                            ),
                            Text(
                              time,
                              style: GoogleFont.Mulish(
                                fontSize: 9,
                                color: AppColor.lightGray2,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            CommonContainer.callNowButton(

              callImage: AppImages.callImage,
              callIconSize: 16,
              callText: 'Call Now',
              MessageIcon: true,
              whatsAppIcon: true,
              FireIcon: true,
              fireOnTap: () {},
              whatsAppOnTap: whatsAppOnTap,
              messageOnTap: messageOnTap,
              callOnTap: callTap,
              messageContainer: true,
            ),
            const SizedBox(height: 20),
            if (horizontalDivider) CommonContainer.horizonalDivider(),
          ],
        ),
      ),
    );
  }
*/

  static serviceDetails({
    VoidCallback? onTap,
    required String filedName,
    required String image,
    required String ratingStar,
    required String ratingCount,
    required String offAmound,
    double imageHeight = 150,
    double imageWidth = 130,
    bool horizontalDivider = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 130,
                    width: 130,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: image, // your network image URL
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 40, // reduce icon size
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12),
                      Text(
                        filedName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFont.Mulish(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppColor.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          /*      Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.green,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  ratingStar,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFont.Mulish(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AppColor.white,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Image.asset(AppImages.starImage, height: 9),
                                const SizedBox(width: 5),
                                Container(
                                  width: 1.5,
                                  height: 11,
                                  decoration: BoxDecoration(
                                    color: AppColor.white.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  ratingCount,
                                  style: GoogleFont.Mulish(
                                    fontSize: 12,
                                    color: AppColor.white,
                                  ),
                                ),
                              ],
                            ),
                          ),*/
                          CommonContainer.greenStarRating(
                            ratingStar: ratingStar,
                            ratingCount: ratingCount,
                          ),
                        ],
                      ),
                      SizedBox(height: 7),
                      Text(
                        'Starts at',
                        style: GoogleFont.Mulish(color: AppColor.lightGray3),
                      ),
                      Text(
                        offAmound,
                        style: GoogleFont.Mulish(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          color: AppColor.darkBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          if (horizontalDivider)
            Container(
              width: double.infinity,
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    AppColor.white.withOpacity(0.5),
                    AppColor.white3,
                    AppColor.white3,
                    AppColor.white3,
                    AppColor.white3,
                    AppColor.white3,
                    AppColor.white3,
                    AppColor.white.withOpacity(0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
        ],
      ),
    );
  }

  /* static servicesContainer({
    required String image,
    required String companyName,
    required String location,
    required String fieldName,
    required String ratingStar,
    required String ratingCount,
    required String time,
    VoidCallback? onTap,
    bool horizontalDivider = false,
    bool Verify = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Hero(
                      tag: 'shopImageHero',
                      child: Image.asset(
                        AppImages.imageContainer1,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // sample text block for the card (replace as needed)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (Verify)
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColor.blueGradient1,
                                  AppColor.blueGradient2,
                                  AppColor.blueGradient3,
                                ],
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(AppImages.verifyTick, height: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Trusted',
                                    style: GoogleFont.Mulish(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10,
                                      color: AppColor.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        SizedBox(height: 9),
                        Text(
                          // categoryTabs[selectedIndex]["label"],
                          companyName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFont.Mulish(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppColor.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Image.asset(
                              AppImages.locationImage,
                              height: 10,
                              color: AppColor.lightGray2,
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFont.Mulish(
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: AppColor.lightGray2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              fieldName,
                              style: GoogleFont.Mulish(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: AppColor.lightGray3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.green,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize
                                    .min, // 👈 stops expanding too much
                                children: [
                                  Text(
                                    ratingStar,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFont.Mulish(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColor.white,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Image.asset(AppImages.starImage, height: 9),
                                  const SizedBox(width: 5),
                                  Container(
                                    width: 1.5,
                                    height: 11,
                                    decoration: BoxDecoration(
                                      color: AppColor.white.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    ratingCount,
                                    style: GoogleFont.Mulish(
                                      fontSize: 12,
                                      color: AppColor.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Opens Upto ',
                              style: GoogleFont.Mulish(
                                fontSize: 9,
                                color: AppColor.lightGray2,
                              ),
                            ),
                            Text(
                              time,
                              style: GoogleFont.Mulish(
                                fontSize: 9,
                                color: AppColor.lightGray2,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            CommonContainer.callNowButton(
              fireOnTap: () {},
              whatsAppOnTap: () {},
              messageOnTap: () {},
              onTap: () {},
              messageContainer: true,
            ),
            SizedBox(height: 20),
            if (horizontalDivider)
              Container(
                width: double.infinity,
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      AppColor.white.withOpacity(0.5),
                      AppColor.white3,
                      AppColor.white3,
                      AppColor.white3,
                      AppColor.white3,
                      AppColor.white3,
                      AppColor.white3,
                      AppColor.white.withOpacity(0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        ),
      ),
    );
  }*/

  static leftSideArrow({VoidCallback? onTap, Color = AppColor.white}) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Color,
          border: Border.all(color: AppColor.white4),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: const EdgeInsets.all(11.5),
          child: Image.asset(AppImages.leftSideArrow, height: 13),
        ),
      ),
    );
  }

  static Widget foodList({
    required String image,
    required String foodName,
    required String ratingStar,
    required String ratingCount,
    required String offAmound,
    required String oldAmound,
    required String km,
    required String location,
    double imageHeight = 160,
    double imageWidth = 155,
    double fontSize = 16,
    FontWeight titleWeight = FontWeight.w800,
    bool Verify = false,
    bool doorDelivery = false,
    bool locations = false,
    bool weight = false,
    bool Ad = false,
    VoidCallback? onTap,
    bool horizontalDivider = false,

    // List<String> weightOptions = const ['300Gm', '500Gm'],
    int? selectedWeightIndex, // null = none selected
    ValueChanged<int>? onWeightChanged, // callback when tapped
  }) {
    // Apply filtering logic:
    // final List<String> filteredWeightOptions = [
    //   if (weightOptions.contains('1Kg')) '1Kg',
    //   ...weightOptions.where((w) => w.toLowerCase().endsWith('gm')).take(2),
    // ];

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Row(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 130,
                        width: 130,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: image, // your network image URL
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 40, // reduce icon size
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ClipRRect(
                    //   borderRadius: BorderRadius.circular(16),
                    //   child: Image.asset(
                    //     image,
                    //     height: imageHeight,
                    //     width: imageWidth,
                    //     fit: BoxFit.cover,
                    //   ),
                    // ),
                    if (Ad)
                      Positioned(
                        bottom: 10,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColor.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            child: Row(
                              children: [
                                Image.asset(AppImages.alertImage, height: 9),
                                SizedBox(width: 4),
                                Text(
                                  'AD',
                                  style: GoogleFont.Mulish(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: AppColor.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (Verify) CommonContainer.verifyTick(),
                          SizedBox(width: 5),
                          doorDelivery == true
                              ? CommonContainer.doorDelivery()
                              : SizedBox.shrink(),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        foodName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFont.Mulish(
                          fontWeight: titleWeight,
                          fontSize: fontSize,
                          color: AppColor.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          /* Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.green,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  ratingStar,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFont.Mulish(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AppColor.white,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Image.asset(AppImages.starImage, height: 9),
                                const SizedBox(width: 5),
                                Container(
                                  width: 1.5,
                                  height: 11,
                                  decoration: BoxDecoration(
                                    color: AppColor.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  ratingCount,
                                  style: GoogleFont.Mulish(
                                    fontSize: 12,
                                    color: AppColor.white,
                                  ),
                                ),
                              ],
                            ),
                          ),*/
                          CommonContainer.greenStarRating(
                            ratingStar: ratingStar,
                            ratingCount: ratingCount,
                          ),
                        ],
                      ),
                      SizedBox(height: 7),
                      Row(
                        children: [
                          Text(
                            offAmound,
                            style: GoogleFont.Mulish(
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                              color: AppColor.darkBlue,
                            ),
                          ),
                          SizedBox(width: 5),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                oldAmound,
                                style: GoogleFont.Mulish(
                                  fontSize: 12,
                                  color: AppColor.lightGray3,
                                ),
                              ),
                              Transform.rotate(
                                angle: -0.1,
                                child: Container(
                                  height: 1.5,
                                  width: 40,
                                  color: AppColor.lightGray3,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (locations)
                        Container(
                          decoration: BoxDecoration(
                            color: AppColor.white,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: AppColor.textWhite,
                              width: 1.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  AppImages.locationImage,
                                  height: 13,
                                  color: AppColor.blue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  km,
                                  style: GoogleFont.Mulish(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    color: AppColor.blue,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    location,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFont.Mulish(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                      color: AppColor.darkBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // if (weight)
                      //   Row(
                      //     crossAxisAlignment: CrossAxisAlignment.center,
                      //     children: [
                      //       Text(
                      //         'Weight',
                      //         style: GoogleFont.Mulish(
                      //           fontSize: 12,
                      //           color: AppColor.darkBlue,
                      //         ),
                      //       ),
                      //       const SizedBox(width: 10),
                      //       Expanded(
                      //         child: Wrap(
                      //           spacing: 10,
                      //           runSpacing: 8,
                      //           children: List.generate(
                      //             filteredWeightOptions.length,
                      //             (i) {
                      //               final bool isSelected =
                      //                   selectedWeightIndex == i;
                      //               return InkWell(
                      //                 borderRadius: BorderRadius.circular(50),
                      //                 onTap: () => onWeightChanged?.call(i),
                      //                 child: Container(
                      //                   decoration: BoxDecoration(
                      //                     color: isSelected
                      //                         ? AppColor.white
                      //                         : Colors.transparent,
                      //                     borderRadius: BorderRadius.circular(
                      //                       50,
                      //                     ),
                      //                     border: Border.all(
                      //                       color: isSelected
                      //                           ? AppColor.blue
                      //                           : AppColor.lightGray2,
                      //                       width: 1.5,
                      //                     ),
                      //                     boxShadow: isSelected
                      //                         ? [
                      //                             BoxShadow(
                      //                               color: AppColor.blue
                      //                                   .withOpacity(0.14),
                      //                               blurRadius: 10,
                      //                               offset: const Offset(0, 2),
                      //                             ),
                      //                           ]
                      //                         : null,
                      //                   ),
                      //                   padding: const EdgeInsets.symmetric(
                      //                     horizontal: 12,
                      //                     vertical: 6,
                      //                   ),
                      //                   child: Text(
                      //                     filteredWeightOptions[i],
                      //                     style: GoogleFont.Mulish(
                      //                       fontSize: 12,
                      //                       fontWeight: FontWeight.w800,
                      //                       color: isSelected
                      //                           ? AppColor.blue
                      //                           : AppColor.lightGray2,
                      //                     ),
                      //                   ),
                      //                 ),
                      //               );
                      //             },
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          if (horizontalDivider) CommonContainer.horizonalDivider(),
        ],
      ),
    );
  }

  static Widget similarFoods({
    required String image,
    required String foodName,
    required String ratingStar,
    required String ratingCount,
    required String offAmound,
    required String oldAmound,
    required String km,
    required String location,
    double imageHeight = 150,
    double imageWidth = 197,
    bool Verify = false,
    bool doorDelivery = false,
    bool Ad = false,
  }) {
    // BOUND THE CARD WIDTH → avoids "unbounded width" in horizontal List
    return SizedBox(
      width: imageWidth, // <- முக்கியம்
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl:
                  image,
                  height: 150,
                  width: 190,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(
                        height: 150,
                        width: 190,
                        color: Colors.grey
                            .withOpacity(0.2),
                      ),
                  errorWidget:
                      (context, url, error) =>
                  const Icon(
                    Icons.broken_image,
                  ),
                ),
              ),
              if (Ad)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColor.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Image.asset(AppImages.alertImage, height: 9),
                        const SizedBox(width: 4),
                        Text(
                          'AD',
                          style: GoogleFonts.mulish(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppColor.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              if (Verify) CommonContainer.verifyTick(),
              SizedBox(width: 5),
              if (doorDelivery) CommonContainer.doorDelivery(),
            ],
          ),
          SizedBox(height: 15),
          Text(
            foodName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.mulish(
              color: AppColor.darkBlue,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),

          CommonContainer.greenStarRating(
            ratingStar: ratingStar,
            ratingCount: ratingCount,
          ),

          const SizedBox(height: 7),
          Row(
            children: [
              Text(
                offAmound,
                style: GoogleFonts.mulish(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: AppColor.darkBlue,
                ),
              ),
              const SizedBox(width: 10),

              // ✅ simpler & safer: strikethrough text, no Transform
              Text(
                oldAmound,
                style: GoogleFonts.mulish(
                  fontSize: 14,
                  color: AppColor.lightGray3,
                  decoration: TextDecoration.lineThrough,
                  decorationThickness: 1.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          // location chip
          Container(
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: AppColor.textWhite, width: 1.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                Image.asset(
                  AppImages.locationImage,
                  height: 13,
                  color: AppColor.blue,
                ),
                const SizedBox(width: 4),
                Text(
                  km,
                  style: GoogleFonts.mulish(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: AppColor.blue,
                  ),
                ),
                const SizedBox(width: 10),

                // ❌ Expanded (horizontal scroller context-ல் பிரச்னை)
                // ✅ Constrain to available card width
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.mulish(
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      color: AppColor.darkBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget sortbyPopup({
    required String text1,
    String? text2, // optional
    String connector = ' to ', // e.g. use ' in ' for suggestions
    String? image, // optional trailing image
    VoidCallback? onTap, // optional
    bool horizontalDivider = false,
    Color? iconColor,
  }) {
    final hasSecond = (text2 != null && text2!.trim().isNotEmpty);
    final hasTrailing = (image != null || onTap != null);

    Widget? trailing;
    if (hasTrailing) {
      trailing = ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        child: InkWell(
          onTap: onTap, // null = no ripple
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: AppColor.textWhite,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
            child: image != null
                ? Image.asset(
                    image,
                    height: 3,
                    width: 12,
                    color: iconColor ?? AppColor.blue,
                  )
                : Image.asset(AppImages.rightArrow, height: 12),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: text1,
                        style: GoogleFont.Mulish(
                          fontSize: 16,
                          color: AppColor.darkBlue,
                        ),
                      ),
                      if (hasSecond)
                        TextSpan(
                          text: connector,
                          style: GoogleFont.Mulish(
                            fontSize: 16,
                            color: AppColor.lightGray2,
                          ),
                        ),
                      if (hasSecond)
                        TextSpan(
                          text: text2,
                          style: GoogleFont.Mulish(
                            fontSize: 16,
                            color: AppColor.darkBlue,
                          ),
                        ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailing != null) const SizedBox(width: 12),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 19),
          if (horizontalDivider)
            Container(
              width: double.infinity,
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    AppColor.white.withOpacity(0.5),
                    AppColor.white3,
                    AppColor.white3,
                    AppColor.white3,
                    AppColor.white3,
                    AppColor.white3,
                    AppColor.white3,
                    AppColor.white.withOpacity(0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
        ],
      ),
    );
  }

  static Widget gradientContainer({
    required String text,
    String? locationImage,
    String? iconImage,
    Color lIconColor = AppColor.darkBlue,
    Color dIconColor = AppColor.darkBlue,
    Color textColor = AppColor.darkBlue,
    FontWeight? fontWeight,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.lowLightBlue,
              AppColor.lowLightBlue.withOpacity(0.5),
              AppColor.white.withOpacity(0.3),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (locationImage != null)
              Image.asset(locationImage, height: 24, color: lIconColor),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: GoogleFont.Mulish(
                  color: textColor,
                  fontWeight: fontWeight,
                ),
              ),
            ),
            const SizedBox(width: 6),
            if (iconImage != null)
              Image.asset(iconImage, height: 11, color: dIconColor),
          ],
        ),
      ),
    );
  }

  // CommonContainer.glowAvatar (Figma-style)
  /*  static Widget glowAvatar({
    required String image,         // asset path
    double size = 80,
    double radius = 20,
    Color borderColor = const Color(0xFFFFA11A),
    double borderWidth = 2,
    double glowBlur = 25,
    double glowSpread = 2,
    String? heroTag,
    GestureTapCallback? onTap,
  }) {
    final content = Container(
      width: size,
      height: size,
      // OUTER GLOW only (no fill)
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.70),
            blurRadius: glowBlur,
            spreadRadius: glowSpread,
            offset: const Offset(0, 0),
          ),
          // optional softer halo
          BoxShadow(
            color: borderColor.withOpacity(0.25),
            blurRadius: glowBlur * 1.6,
            spreadRadius: glowSpread * 1.2,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // full-bleed image
            Image.asset(image, fit: BoxFit.cover),

            // TOP STROKE (thin border) – no background fill
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    border: Border.all(color: borderColor, width: borderWidth),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final tappable = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: content,
      ),
    );

    return heroTag == null ? tappable : Hero(tag: heroTag!, child: tappable);
  }*/

  /// Figma-accurate glow avatar that keeps the same *visual size* for ANY image.
  /// - Square box (size x size)
  /// - Center-crop (cover) so portrait/landscape fill evenly
  /// - Thin outside stroke (doesn't eat into the photo)
  /// - Soft outer glow
  // CommonContainer.glowAvatarUniversal (no Hero)
  static Widget glowAvatarUniversal({
    required ImageProvider
    image, // AssetImage / NetworkImage / FileImage / MemoryImage
    double size = 60,
    double radius = 20,
    Color borderColor = const Color(0xFFFFA11A),
    double borderWidth = 1.5,
    double glowBlur = 40,
    double glowSpread = 0,
    double glowOpacity = 0.60,
    GestureTapCallback? onTap,
  }) {
    final avatar = SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Glow behind
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withOpacity(glowOpacity),
                  blurRadius: glowBlur,
                  spreadRadius: glowSpread,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
          // Image (always square, center-cropped)
          ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Image(
              image: image,
              width: size,
              height: size,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              filterQuality: FilterQuality.high,
            ),
          ),
          // Thin outside stroke
          IgnorePointer(
            child: Container(
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius),
                  side: BorderSide(
                    color: borderColor,
                    width: borderWidth,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: avatar,
      ),
    );
  }

  static Widget profileList({
    required String label,
    required String iconPath,
    double iconHeight = 25,
    double iconWidth = 19,
    double circleSize = 50,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.brightGray,
                ),
                child: Center(
                  child: Image.asset(
                    iconPath,
                    height: iconHeight,
                    width: iconWidth,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.mulish(
                  fontSize: 16,
                  color: AppColor.darkBlue,
                ),
              ),
            ],
          ),
          Image.asset(
            AppImages.rightArrow,
            height: 14,
            color: AppColor.lightGray2,
          ),
        ],
      ),
    );
  }

  static doorDelivery() {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.textWhite,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          children: [
            Image.asset(AppImages.deliveryImage, height: 14),
            SizedBox(width: 5),
            Text(
              'Door Delivery',
              style: GoogleFont.Mulish(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: AppColor.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static shopPeopleView({
    required String Images,
    required String shopName,
    required String locationName,
    required String km,
    required String ratingStar,
    required String ratingCound,
    required String time,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),

        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.grey.withOpacity(0.15),
          //     blurRadius: 20,
          //     spreadRadius: 5,
          //     offset: const Offset(0, 5),
          //   ),
          // ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                Images,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              shopName,
              overflow: TextOverflow.ellipsis,
              style: GoogleFont.Mulish(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColor.darkBlue,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Image.asset(
                  AppImages.locationImage,
                  height: 10,
                  color: AppColor.lightGray2,
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    locationName,
                    style: GoogleFont.Mulish(
                      fontSize: 12,
                      color: AppColor.lightGray2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  km,
                  style: GoogleFont.Mulish(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColor.lightGray3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                // Container(
                //   padding: const EdgeInsets.symmetric(
                //     horizontal: 10,
                //     vertical: 3,
                //   ),
                //   decoration: BoxDecoration(
                //     color: AppColor.green,
                //     borderRadius: BorderRadius.circular(30),
                //   ),
                //   child: Row(
                //     mainAxisSize: MainAxisSize.min,
                //     children: [
                //       Text(
                //         ratingStar,
                //         style: GoogleFont.Mulish(
                //           fontWeight: FontWeight.bold,
                //           fontSize: 14,
                //           color: AppColor.white,
                //         ),
                //       ),
                //       const SizedBox(width: 5),
                //       Image.asset(AppImages.starImage, height: 9),
                //       const SizedBox(width: 5),
                //       Container(
                //         width: 1.5,
                //         height: 11,
                //         decoration: BoxDecoration(
                //           color: AppColor.white.withOpacity(0.4),
                //           borderRadius: BorderRadius.circular(1),
                //         ),
                //       ),
                //       const SizedBox(width: 5),
                //       Text(
                //         ratingCound,
                //         style: GoogleFont.Mulish(
                //           fontSize: 12,
                //           color: AppColor.white,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                CommonContainer.greenStarRating(
                  ratingCount: ratingCound,
                  ratingStar: ratingStar,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: 'Opens Upto ',
                      style: GoogleFont.Mulish(
                        fontSize: 10,
                        color: AppColor.lightGray2,
                      ),
                      children: [
                        TextSpan(
                          text: time,
                          style: GoogleFont.Mulish(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColor.lightGray2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static horizonalDivider() {
    return Container(
      width: double.infinity,
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            AppColor.white.withOpacity(0.5),
            AppColor.white3,
            AppColor.white3,
            AppColor.white3,
            AppColor.white3,
            AppColor.white3,
            AppColor.white3,
            AppColor.white.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  static Widget button({
    required GestureTapCallback? onTap,
    required Widget text,
    double? size = double.infinity,
    double? imgHeight = 24,
    double? imgWeight = 24,
    double? borderRadius = 18,
    Widget? loader,
    Color buttonColor = AppColor.blue,
    Color? foreGroundColor,
    Color? borderColor,
    Color? textColor = Colors.white,
    bool? isLoading,
    bool hasBorder = false,
    String? imagePath,
  }) {
    return SizedBox(
      width: size,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          foregroundColor: foreGroundColor,

          shape: hasBorder
              ? RoundedRectangleBorder(
                  side: BorderSide(color: Color(0xff3F5FF2)),
                  borderRadius: BorderRadius.circular(borderRadius!),
                )
              : RoundedRectangleBorder(
                  side: BorderSide(color: borderColor ?? Colors.transparent),

                  borderRadius: BorderRadius.circular(borderRadius!),
                ),
          elevation: 0,
          fixedSize: Size(150.w, 45.h),
          backgroundColor: buttonColor,
        ),
        child: isLoading == true
            ? loader
            // SizedBox(
            //         width: 20,
            //         height: 20,
            //         child: CircularProgressIndicator(
            //           strokeWidth: 2,
            //           valueColor: AlwaysStoppedAnimation<Color>(
            //             textColor ?? Colors.white,
            //           ),
            //         ),
            //       )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DefaultTextStyle(
                    style: TextStyle(
                      fontFamily: "Roboto-normal",
                      fontSize: 16.sp,
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                    child: text,
                  ),
                  if (imagePath != null) ...[
                    SizedBox(width: 15.w),
                    Image.asset(
                      imagePath,
                      height: imgHeight!.sp,
                      width: imgWeight!.sp,
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  static button2({
    BuildContext? context,
    VoidCallback? onTap,
    required String text,
    Widget? loader,
    double fontSize = 16,
    Color? textColor = Colors.white,
    bool isBorder = false,
    FontWeight fontWeight = FontWeight.w700,
    double? width = 200,
    double? height = 60,
    String? image,
    Color? backgroundColor,
  }) {
    return Center(
      child: SizedBox(
        width: width,
        height: height,
        child: Container(
          decoration: BoxDecoration(
            color:
            backgroundColor ??
                (isBorder ? AppColor.white : AppColor.skyBlue),
            border: isBorder
                ? Border.all(color: const Color(0xff3F5FF2), width: 2)
                : null,
            borderRadius: BorderRadius.circular(18),
          ),
          child: ElevatedButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all(EdgeInsets.zero),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              elevation: MaterialStateProperty.all(0),
              backgroundColor: MaterialStateProperty.all(Colors.transparent),
            ),
            onPressed: onTap,
            child: loader != null
                ? loader
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontFamily: "Roboto-normal",
                    fontSize: fontSize,
                    color: textColor,
                    fontWeight: fontWeight,
                  ),
                ),
                if (image != null) ...[
                  const SizedBox(width: 15),
                  Image.asset(image, height: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static reviewBox() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            bottom: BorderSide(color: AppColor.brightGray, width: 8),
            left: BorderSide(color: AppColor.brightGray, width: 2),
            right: BorderSide(color: AppColor.brightGray, width: 2),
            top: BorderSide(color: AppColor.brightGray, width: 2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Great People',
                    style: GoogleFont.Mulish(
                      fontSize: 16,
                      color: AppColor.darkBlue,
                    ),
                  ),
                  SizedBox(width: 9),
                  Image.asset(AppImages.dratImage, height: 8, width: 6),
                  SizedBox(width: 9),
                  Image.asset(
                    AppImages.starImage,
                    height: 12,
                    color: AppColor.green,
                  ),
                  SizedBox(width: 4),
                  Image.asset(
                    AppImages.starImage,
                    height: 12,
                    color: AppColor.green,
                  ),
                  SizedBox(width: 4),
                  Image.asset(
                    AppImages.starImage,
                    height: 12,
                    color: AppColor.green,
                  ),
                  SizedBox(width: 4),
                  Image.asset(
                    AppImages.starImage,
                    height: 12,
                    color: AppColor.green,
                  ),
                  SizedBox(width: 4),
                  Image.asset(
                    AppImages.starImage,
                    height: 12,
                    color: AppColor.borderGray,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '4',
                    style: GoogleFont.Mulish(
                      fontWeight: FontWeight.bold,
                      color: AppColor.green,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Text(
                'Praesent viverra volutpat lorem, eu convallis lacus maximus quis. Nam at lorem mi. In tempor commodo bibendum. Donec euismod urna pharetra justo finibus, eget volutpat justo dapibus. ',
                style: GoogleFont.Mulish(color: AppColor.lightGray3),
              ),
              SizedBox(height: 15),
              CommonContainer.horizonalDivider(),
              SizedBox(height: 15),
              Text(
                '1 Month Ago',
                style: GoogleFont.Mulish(color: AppColor.lightGray2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static smartConnectHistory({
    required String productName,
    required String shopCounting,
    required String productCounting,
    required String Showrooms,
    required String productCategories,
    required String time,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 5), // ✅ bottom shadow only
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ✅ Flexible column so text doesn't overflow
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFont.Mulish(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColor.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    shopCounting,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFont.Mulish(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColor.lightGray3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          Showrooms,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFont.Mulish(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: AppColor.blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Image.asset(
                        AppImages.rightArrow,
                        height: 9,
                        width: 11,
                        color: AppColor.darkBlue,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          productCategories,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFont.Mulish(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: AppColor.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Created on ',
                        style: GoogleFont.Mulish(
                          fontSize: 10,
                          color: AppColor.lightGray2,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          time,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFont.Mulish(
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            color: AppColor.lightGray2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: onTap,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColor.blue,
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 7,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      AppImages.messageImageWhite,
                      height: 16.92,
                      width: 16,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      productCounting,
                      style: GoogleFont.Mulish(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColor.white,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Image.asset(
                      AppImages.rightArrow,
                      height: 13,
                      color: AppColor.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static greenStarRating({String? ratingStar, String? ratingCount}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColor.green,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, // 👈 stops expanding too much
            children: [
              Text(
                ratingStar!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFont.Mulish(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: AppColor.white,
                ),
              ),
              SizedBox(width: 5),
              Image.asset(AppImages.starImage, height: 7),
              SizedBox(width: 5),
              Container(
                width: 1.5,
                height: 11,
                decoration: BoxDecoration(
                  color: AppColor.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              SizedBox(width: 5),
              Text(
                ratingCount!,
                style: GoogleFont.Mulish(fontSize: 12, color: AppColor.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget fillProfileContainer({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    double? iconHeight = 14,
    String? rightIcon,
    String? rightLabel,
    VoidCallback? onTap,
    bool readOnly = false,
    String? selectedImage,

    /// NEW → Add validator
    String? Function(String?)? validator,
  }) {
    final bool hasIcon = rightIcon != null && rightIcon.isNotEmpty;
    final bool hasLabel = rightLabel != null && rightLabel.isNotEmpty;
    final bool showRightSection = hasIcon || hasLabel;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.borderGray, width: 2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Expanded(
              child: selectedImage == null
                  ? IgnorePointer(
                      ignoring: onTap != null,
                      child: TextFormField(
                        controller: controller,
                        readOnly: readOnly || onTap != null,
                        keyboardType: keyboardType,
                        maxLength: maxLength,

                        // ************ IMPORTANT ************
                        validator: validator,
                        autovalidateMode: AutovalidateMode.onUserInteraction,

                        // ************************************
                        style: GoogleFont.Mulish(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          hintText: hint,
                          hintStyle: GoogleFont.Mulish(
                            fontWeight: FontWeight.w600,
                            color: AppColor.borderGray,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      height: 60,
                      alignment: Alignment.centerLeft,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(selectedImage),
                          width: 130,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
            ),

            if (showRightSection) ...[
              SizedBox(width: 10),

              if (hasIcon)
                Image.asset(
                  rightIcon!,
                  height: iconHeight,
                  color: AppColor.lightGray2,
                ),

              SizedBox(width: 18),

              Container(
                width: 2,
                height: 35,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColor.white.withOpacity(0),
                      AppColor.borderGray,
                      AppColor.white.withOpacity(0),
                    ],
                  ),
                ),
              ),

              SizedBox(width: 18),

              if (hasLabel)
                Text(
                  rightLabel!,
                  style: GoogleFont.Mulish(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColor.lightGray2,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
