// import 'package:flutter/material.dart';
// import 'dart:async';
//
// import '../../screens/home_screen.dart';
//
// class SplashBody extends StatefulWidget {
//   const SplashBody({super.key});
//
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashBody>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Initialize animation controller
//     _animationController = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     );
//
//     // Create fade-in animation
//     _fadeAnimation =
//         Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
//
//     // Start animation
//     _animationController.forward();
//
//     Timer(const Duration(seconds: 3), () {
//       Navigator.of(context)
//           .pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
//     });
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: FadeTransition(
//           opacity: _fadeAnimation,
//           child: Image.asset(
//             'assets/logo.png',
//             width: 150,
//             height: 150,
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:responsive_framework/responsive_framework.dart';

import '../../core/utils/constants/app_constants.dart';


class SplashBody extends StatefulWidget {
  const SplashBody({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Create fade-in animation
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    // Start animation
    _animationController.forward();

    Timer(const Duration(seconds: 3), () {
      GoRouter.of(context).go('/');
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ResponsiveBreakpoints.builder(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: Image.asset(
                  'assets/icon/logo.png',
                  width: ResponsiveValue<double>(
                    context,
                    defaultValue: 150,
                    conditionalValues: [
                      Condition.largerThan(name: TABLET, value: 200),
                      Condition.largerThan(name: DESKTOP, value: 250),
                    ],
                  ).value,
                  height: ResponsiveValue<double>(
                    context,
                    defaultValue: 150,
                    conditionalValues: [
                      Condition.largerThan(name: TABLET, value: 200),
                      Condition.largerThan(name: DESKTOP, value: 250),
                    ],
                  ).value,
                ),
              ),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Image.asset(
                  'assets/icon/text.png',
                  width: ResponsiveValue<double>(
                    context,
                    defaultValue: 150,
                    conditionalValues: [
                      Condition.largerThan(name: TABLET, value: 200),
                      Condition.largerThan(name: DESKTOP, value: 250),
                    ],
                  ).value,
                  height: ResponsiveValue<double>(
                    context,
                    defaultValue: 150,
                    conditionalValues: [
                      Condition.largerThan(name: TABLET, value: 200),
                      Condition.largerThan(name: DESKTOP, value: 250),
                    ],
                  ).value,
                ),
              ),
            ],
          ),
        ),
        breakpoints:  AppConstants.breakpoints,
      ),
    );
  }
}
