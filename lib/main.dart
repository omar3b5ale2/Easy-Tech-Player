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
import 'managers/cubit/appbar_cubit.dart';
import 'managers/cubit/navigation_cubit.dart';
import 'core/utils/shared/base_url_singlton.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await setupSingleton();

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
        initDeepLinks();
      });
    } else if (Platform.isWindows) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        initDeepLinks();
      });
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