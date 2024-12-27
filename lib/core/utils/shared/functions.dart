import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../managers/cubit/navigation_cubit.dart';
import '../../../screens/home_screen.dart';
import '../../../screens/main_pages/courses_screen.dart';
import '../../../screens/main_pages/video_list_screen.dart';
import '../../../screens/main_pages/video_player_screen.dart';
import '../../../services/encryption_service.dart';
import '../constants/app_constants.dart';

// Initialize the list of tabs (lazy-loaded when required).
List<Widget> tabsList = const [
  CoursesScreen(),
  VideoPlayerScreen(
    studentId: '',
    courseId: '',
    lessonId: '',
    lessonName: '',
    videoLink: '',
    videoId: '',
    unitName: '',
    token: '',
    encryptededData: '',
  ),
  VideoListScreen(),
];

Widget handleDeepLink(
  BuildContext context,
  GoRouterState state, {
  String? invocationRoute,
}) {
  String deepLinkData = '';
  // AppConstants.setAppName('7amada');

  if (Platform.isWindows) {
    deepLinkData = state.pathParameters['data'] ?? '';
  } else {
    deepLinkData = state.uri.queryParameters['data'] ?? '';
  }

  final isDeepLink = deepLinkData.isNotEmpty;

  // Print '12345' if invocationRoute is 'video'
  if (invocationRoute == 'video') {
    final decodedData = Uri.decodeComponent(deepLinkData);
    deepLinkData = decodedData;
  }

  if (isDeepLink) {
    final encryptionService = EncryptionService();
    final decryptedPayload =
        encryptionService.decryptAndExtractData(deepLinkData);

    if (decryptedPayload != null) {
      // final baseUrl = decryptedPayload[AppConstants.baseUrl];
      final token = decryptedPayload['token'];
      // if (baseUrl != null && baseUrl.isNotEmpty) {
      //   SharedPreferences.getInstance().then((prefs) {
      //     prefs.setString('base_url', baseUrl); // Cache the base_url
      //   });
      //   AppConstants.setBaseUrl(baseUrl);

        SharedPreferences.getInstance().then((prefs) {
          prefs.setString('token', token); // Cache the base_url
        });
        AppConstants.setToken(token);
      }

      // Update tabs list dynamically with decrypted payload
      tabsList = [
        const CoursesScreen(),
        VideoPlayerScreen(
          key: ValueKey(decryptedPayload!['video_id']),
          studentId: decryptedPayload['student_id'].toString(),
          courseId: decryptedPayload['course_id'].toString(),
          lessonId: decryptedPayload['lesson_id'].toString(),
          lessonName: decryptedPayload['lesson_name'],
          videoLink: decryptedPayload['video_url'],
          videoId: decryptedPayload['video_id'].toString(),
          unitName: decryptedPayload['unit_name'],
          token: decryptedPayload['token'],
          encryptededData: deepLinkData,
        ),
        const VideoListScreen(),
      ];
    }
  return BlocProvider(
    create: (_) => NavigationCubit()..changeTab(isDeepLink ? 1 : 0),
    // Focus on Video Player if deep linked
    child: HomeScreen(tabs: tabsList),
  );

}


