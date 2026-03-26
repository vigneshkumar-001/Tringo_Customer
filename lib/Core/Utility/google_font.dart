import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GoogleFont {
  static double _sp(double size) {
    try {
      return size.sp;
    } catch (_) {
      return size;
    }
  }

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
      fontSize: _sp(fontSize),
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
      fontSize: _sp(fontSize),
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static inter({double fontSize = 18, FontWeight? fontWeight, Color? color}) {
    return GoogleFonts.inter(
      fontSize: _sp(fontSize),
      fontWeight: fontWeight,
      color: color,
    );
  }
}
