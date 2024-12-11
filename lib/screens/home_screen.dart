import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../screens/main_pages/courses_screen.dart';
import '../../../screens/main_pages/video_list_screen.dart';
import '../../../screens/main_pages/video_player_screen.dart';
import '../core/utils/constants/app_constants.dart';
import '../managers/cubit/navigation_cubit.dart';
import '../widgets/body/bottom_navigation_bar_widget.dart';

class HomeScreen extends StatelessWidget {
  final List<Widget>? tabs;

  const HomeScreen({super.key, this.tabs});

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
      ),
      VideoListScreen(),
    ];

    final List<Widget> activeTabs = tabs ?? defaultTabs;

    return ResponsiveBreakpoints.builder(
      child: Scaffold(
        body: BlocBuilder<NavigationCubit, int>(
          builder: (BuildContext context, int state) {
            return IndexedStack(
              index: state,
              children: activeTabs,
            ); // Lazy load tabs for performance
          },
        ),
        bottomNavigationBar: const BottomNavigationBarWidget(),
      ),
      breakpoints: AppConstants.breakpoints,
    );
  }
}
