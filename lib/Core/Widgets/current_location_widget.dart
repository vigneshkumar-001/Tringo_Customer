import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Controller/location_notifier.dart';
import '../Utility/app_color.dart';

class CurrentLocationWidget extends ConsumerWidget {
  final VoidCallback? onTap;
  final String? locationIcon;
  final String? dropDownIcon;
  final TextStyle? textStyle;
  final Color? iconColor;

  const CurrentLocationWidget({
    super.key,
    this.onTap,
    this.locationIcon,
    this.dropDownIcon,
    this.textStyle,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationNotifierProvider);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 13),
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            const locationIconW = 18.0;
            const dropDownIconW = 11.0;
            const gapW = 6.0;

            final showLocationIcon = locationIcon != null;
            final showDropDownIcon = dropDownIcon != null;
            final available = constraints.maxWidth;

            final showLocationGap =
                showLocationIcon &&
                (!available.isFinite || available >= (locationIconW + gapW + 4));

            final fixedLeading = showLocationIcon
                ? (locationIconW + (showLocationGap ? gapW : 0))
                : 0.0;
            final fixedTrailing = showDropDownIcon ? (gapW + dropDownIconW) : 0.0;

            final canShowDropDown =
                showDropDownIcon &&
                (!available.isFinite || available >= (fixedLeading + fixedTrailing));

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showLocationIcon)
                  Image.asset(
                    locationIcon!,
                    height: locationIconW,
                    color: iconColor ?? AppColor.blue,
                  ),
                if (showLocationGap) const SizedBox(width: gapW),
                Flexible(
                  child: Text(
                    locationState.isLoading
                        ? 'Fetching location...'
                        : (locationState.address ?? 'Unknown location'),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style:
                        textStyle ??
                        GoogleFonts.mulish(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                if (canShowDropDown) const SizedBox(width: gapW),
                if (canShowDropDown)
                  Image.asset(
                    dropDownIcon!,
                    height: dropDownIconW,
                    color: AppColor.darkBlue,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
