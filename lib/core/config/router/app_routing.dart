import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../screens/splash_screen.dart';
import '../../utils/shared/functions.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

// Configure GoRouter
final router = GoRouter(
  navigatorKey: _navigatorKey,
  initialLocation: '/splash',
  routes: [
    // Splash Screen
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => handleDeepLink(context, state),
    ),
    // Main App Route
    GoRoute(
      path: '/link/:data',
      builder: (context, state) => handleDeepLink(context, state),
    ),

    // Video Deep Link Route
    GoRoute(
      path: '/video',
      builder: (context, state) => handleDeepLink(context, state),
    ),
  ],

  // Error Handling
  // Error Handling
  errorBuilder: (context, state) => const Scaffold(
    body: Center(
      child: Text('404 - Page not found'),
    ),
  ),
);
