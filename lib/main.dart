import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:media_kit/media_kit.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/config/router/app_routing.dart';
import 'core/utils/constants/app_constants.dart';
import 'core/utils/shared/base_url_singlton.dart';
import 'managers/cubit/appbar_cubit.dart';
import 'managers/cubit/navigation_cubit.dart';
import 'services/video_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  setupSingleton();
  // Initialize sqflite_ffi for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
  }

  await _debugPrintDatabaseRecords();
  // await AppConstants.initializeBaseUrl();

  runApp(const MyApp());
}

Future<void> _debugPrintDatabaseRecords() async {
  final videoService = VideoService();
  final allVideos = await videoService.getAllVideos();

  for (var video in allVideos) {
    debugPrint(
      "[DATABASE] Video ID: ${video.videoId}, Total Time: ${video.totalTime}, Watched: ${video.watchTime}, Lesson: ${video.lessonName}",
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid || Platform.isIOS) {
      _enableScreenProtections();
    }
    if (Platform.isWindows) {
      initDeepLinks();
    }
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();

    // Handle links
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      debugPrint('onAppLink: $uri');
      openAppLink(uri);
    });
  }

  void openAppLink(Uri uri) {
    final path = uri.fragment.isNotEmpty ? uri.fragment : '/';
    router.go(path);
  }

  @override
  void dispose() {
    if (Platform.isAndroid || Platform.isIOS) {
      _disableScreenProtections();
      _linkSubscription?.cancel();
    }
    super.dispose();
  }

  Future<void> _enableScreenProtections() async {
    await ScreenProtector.protectDataLeakageOn();
    await ScreenProtector.preventScreenshotOn();
  }

  Future<void> _disableScreenProtections() async {
    await ScreenProtector.protectDataLeakageOff();
    await ScreenProtector.preventScreenshotOff();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) =>
            AppBarCubit()..initAnimation(this as TickerProvider)),
        BlocProvider(create: (_) => NavigationCubit()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        builder: (context, child) => ResponsiveBreakpoints.builder(
          child: child!,
          breakpoints: AppConstants.breakpoints,
        ),
        theme: ThemeData(fontFamily: AppConstants.fontFamily),
      ),
    );
  }
}
