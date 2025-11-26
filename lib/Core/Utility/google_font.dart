import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_color.dart';

class GoogleFont {
  static Mulish({
    double fontSize = 14,
    double? height = 1.5,
    FontWeight? fontWeight,
    letterSpacing,
    Color? color,
    Color? decorationColor,
    double? decorationThickness,
    TextDecoration? decoration,
    List<Shadow>? shadows,
     Paint? foreground,
  }) {
    return GoogleFonts.mulish(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationThickness: decorationThickness,
      shadows: shadows,
    );
  }

  static ibmPlexSans({
    double fontSize = 14,
    double? height = 1.5,
    FontWeight? fontWeight,
    letterSpacing,
    Color? color,
  }) {
    return GoogleFonts.ibmPlexSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static inter({double fontSize = 18, FontWeight? fontWeight, Color? color}) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}
