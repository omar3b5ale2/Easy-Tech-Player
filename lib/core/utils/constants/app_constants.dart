import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_colors.dart';

class AppConstants {
  static String appName =
      'Easy Player';
  static String kWindowsScheme = 'easyplayer';

  static List<Breakpoint> breakpoints = [
    const Breakpoint(start: 0, end: 590, name: MOBILE),
    const Breakpoint(start: 591, end: 930, name: TABLET),
    const Breakpoint(start: 931, end: 1200, name: "BIG-TABLET"),
    const Breakpoint(start: 1201, end: 1920, name: DESKTOP),
    const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
  ];

  // Styles
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
  static const double appMarginSymmetricH = 4.0;
  static const double appPaddingSymmetricH = 16.0;
  static const double appPaddingSymmetricV = 12.0;
  static const double appBarElevation = 3.0;
  static const double appCircularRadius = 8.0;

  // Colors
  static const Color textColor = Color(0xffffffff);
  static const Color textColor2 = Color(0xff000000);
  static const Color appBarBkColor = Color(0xffffffff);
  static const Color iconColor = Color(0xffffffff);
  static const Color shadowColor = Colors.black38;

  // Material
  static const double materialColorOpacity = 0.8;

  // API
  static const String apiKey =
      'Api-Key 0FWs33Nw.eCWDhANZ2Wet5bfmCpEK3nvES7cTTxTt';
  static String baseUrl = 'https://manasa.easytech-sotfware.com'; // Default value
  static String token = ' '; // Default value

  static const String endPoint = 'course/course-list';
  static const String endPointAuth = 'dashboard/app/app-validation-data';

  // Fonts
  static const String fontFamily = 'Cairo';

  // Text Directions
  static const TextDirection textDirection = TextDirection.rtl;
  static const TextAlign textAlign = TextAlign.center;
  // Initialize Base URL
  // static Future<void> initializeBaseUrl() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   baseUrl = prefs.getString('base_url') ?? baseUrl;
  //   if (kDebugMode) {
  //     print('cached base url: $baseUrl');
  //   }
  // }
  //
  // // Set Base URL
  // static Future<void> setBaseUrl(String url) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('base_url', url);
  //
  //   baseUrl = url;
  // }
  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);

    token = token;
  }
  // Get the appName from SharedPreferences or return the default value
  static Future<void> initializeAppName() async {
    final prefs = await SharedPreferences.getInstance();
    appName = prefs.getString('app_name') ?? appName;
    if (kDebugMode) {
      print('cached app name: $appName');
    }
  }

  // Set the appName and store it in SharedPreferences
  static Future<void> setAppName(String newAppName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_name', newAppName);

    appName = newAppName;
  }
}
