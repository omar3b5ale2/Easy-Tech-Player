import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../screens/main_pages/courses_screen.dart';
import '../../../screens/main_pages/video_list_screen.dart';
import '../../../screens/main_pages/video_player_screen.dart';
import '../core/utils/constants/app_constants.dart';
import '../managers/cubit/navigation_cubit.dart';
import '../widgets/body/bottom_navigation_bar_widget.dart';

class HomeScreen extends StatefulWidget {
  final List<Widget>? tabs;
  final int initialTab; // Add this parameter

  const HomeScreen({
    super.key,
    this.tabs,
    required this.initialTab, // Mark as required
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Set the initial tab when the HomeScreen is first created
    context.read<NavigationCubit>().changeTab(widget.initialTab);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> defaultTabs = const [
      CoursesScreen(),
      VideoPlayerScreen(
        videoLink: '',
        lessonName: '',
        encryptededData: '',
        unitName: '',
        videoId: '',
        token: '',
        lessonId: '',
        courseId: '',
        studentId: '',
        platformName: '',
        uniqueId: '',
      ),
      VideoListScreen(),
    ];

    final List<Widget> activeTabs = widget.tabs ?? defaultTabs;

    return ResponsiveBreakpoints.builder(
      child: Scaffold(
        body: BlocBuilder<NavigationCubit, int>(
          builder: (BuildContext context, int currentTab) {
            return IndexedStack(
              index: currentTab,
              children: activeTabs,
            );
          },
        ),
        bottomNavigationBar: const BottomNavigationBarWidget(),
      ),
      breakpoints: AppConstants.breakpoints,
    );
  }
}