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

  runApp(const MyApp());
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

    // Initialize platform-specific features
    if (Platform.isAndroid || Platform.isIOS) {
      _enableScreenProtections();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        initDeepLinks(context);
      });
    } else if (Platform.isWindows) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        initDeepLinks(context);
      });
    }
  }

  Future<void> initDeepLinks(BuildContext context) async {
    _appLinks = AppLinks();

    // Handle initial deep link on cold start
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        openAppLink(initialUri, context);
      });
    }

    // Handle foreground deep links (app already open)
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      debugPrint('Foreground Deep Link Received: $uri');
      openAppLink(uri, context);
    });
  }

  void openAppLink(Uri uri, BuildContext context) {
    // Extract path from URI's path component
    final rawPath = uri.path;
    final path = rawPath.isNotEmpty ? rawPath : '/';
    // Normalize path to ensure it starts with '/'
    final normalizedPath = path.startsWith('/') ? path : '/$path';

    debugPrint('Navigating to: $normalizedPath');

    // Force navigation to the deep link path
    if (router.state!.uri.path != normalizedPath) {
      router.go(normalizedPath);
    }

    // Update the NavigationCubit to reflect the correct tab
    final navigationCubit = context.read<NavigationCubit>();
    if (normalizedPath == '/video') {
      navigationCubit.changeTab(1); // Navigate to Page 1 for deep links
    } else {
      navigationCubit.changeTab(0); // Navigate to Tab 0 for normal launches
    }
  }

  @override
  void dispose() {
    // Cleanup platform-specific features
    if (Platform.isAndroid || Platform.isIOS) {
      _disableScreenProtections();
    }
    _linkSubscription?.cancel();
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
          create: (_) => AppBarCubit()..initAnimation(this as TickerProvider),
        ),
        BlocProvider(
          create: (_) => NavigationCubit(),
          lazy: false, // Ensure immediate availability
        ),
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