import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../screens/home_screen.dart';
import '../../../screens/main_pages/courses_screen.dart';
import '../../../screens/main_pages/video_list_screen.dart';
import '../../../screens/main_pages/video_player_screen.dart';
import '../../../services/encryption_service.dart';
import '../../../services/video_service.dart'; // Import the VideoService
import 'base_url_singlton.dart';
import 'package:uuid/uuid.dart';
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
    platformName: '',
    uniqueId: '',
      requestDelay: 1
  ),
  VideoListScreen(),
];

Widget handleDeepLink(
  BuildContext context,
  GoRouterState state, {
  String? invocationRoute,
}) {
  String deepLinkData = '';

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
    print(decryptedPayload);
    if (decryptedPayload != null) {
      // Extract base URL and token from the decrypted payload
      final baseUrl = 'https://${decryptedPayload['base_url']}';
      final token = decryptedPayload['token'];
      final platformName = decryptedPayload['platform_name']; // Use the host as the platform name
      // final platformName = 'الاسطوره'; // Use the host as the platform name

      // Update the singleton and AppConstants
      final sharedState = getIt<SharedState>();
      sharedState.baseUrl = baseUrl;
      print(
          '[DATA] |handleDeepLink| sharedState.baseUrl = ${sharedState.baseUrl}');

      String generateUniqueId() {
        const uuid = Uuid();
        return uuid.v4(); // Generates a random UUID (version 4)
      }
      // Insert or update the platform in the database
      final videoService = VideoService();
      videoService.addOrUpdatePlatform(
        platformName: platformName,
        platformBaseUrl: baseUrl,
        token: token,
      );
      print('decryptedPayload[request_delay]: ${decryptedPayload['request_delay']}');

      print('decryptedPayload[request_delay]: ${decryptedPayload['request_delay']}');
      print('decryptedPayload: ${decryptedPayload}');

      // Update tabs list dynamically with decrypted payload
      String uniqueId = generateUniqueId();
      print('uniqueId: $uniqueId');
      tabsList = [
        const CoursesScreen(),
        VideoPlayerScreen(
          key: ValueKey(decryptedPayload['video_id']),
          studentId: decryptedPayload['student_id'].toString(),
          courseId: decryptedPayload['course_id'].toString(),
          lessonId: decryptedPayload['lesson_id'].toString(),
          lessonName: decryptedPayload['lesson_name'],
          videoLink: decryptedPayload['video_url'],
          videoId: decryptedPayload['video_id'].toString(),
          unitName: decryptedPayload['unit_name'],
          token: decryptedPayload['token'],
          platformName: decryptedPayload['platform_name'],
          requestDelay: decryptedPayload['request_delay'],
          encryptededData: deepLinkData,
          uniqueId: uniqueId,
        ),
        const VideoListScreen(),
      ];
    }
  }

  return HomeScreen(
    tabs: tabsList,
    initialTab: isDeepLink ? 1 : 0, // Directly pass the initial tab
  );
}
