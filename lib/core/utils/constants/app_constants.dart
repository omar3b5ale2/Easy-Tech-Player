import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'app_colors.dart';

class AppConstants {
  static String appName = 'Easy Player';

  static List<Breakpoint> breakpoints = [
    const Breakpoint(start: 0, end: 590, name: MOBILE),
    const Breakpoint(start: 591, end: 985, name: TABLET),
    const Breakpoint(start: 986, end: 1301, name: "BIG-TABLET"),
    const Breakpoint(start: 1302, end: 1938, name: DESKTOP),
    const Breakpoint(start: 1939, end: double.infinity, name: '4K'),
  ];

  static const titleTextStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.lightAqua,
  );
  static const dialogTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
    color: AppColors.turquoise,
    fontFamily: fontFamily,
    fontSize: 18.0,
  );

  // Layout
  static const double appPadding = 16.0;
  static const double appBarElevation = 3.0;

  static const Color shadowColor = Colors.black38;

  // Material

  // API
  static const String apiKey =
      'Api-Key 0FWs33Nw.eCWDhANZ2Wet5bfmCpEK3nvES7cTTxTt';

  static const String endPoint = 'course/course-list';

  // Fonts
  static const String fontFamily = 'Cairo';

  // Text Directions
  static const TextDirection textDirection = TextDirection.ltr;
}
