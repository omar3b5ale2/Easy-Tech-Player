import 'package:easy_player_app/core/utils/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../models/course_model.dart';
import '../../models/platform_data_model.dart';
import '../../services/api_service.dart';
import 'course_card_horizontal.dart';

class PlatformCourseSection extends StatefulWidget {
  final PlatformData platform;
  final VoidCallback onShowMore;

  const PlatformCourseSection({
    super.key,
    required this.platform,
    required this.onShowMore,
  });

  @override
  State<PlatformCourseSection> createState() => _PlatformCourseSectionState();
}

class _PlatformCourseSectionState extends State<PlatformCourseSection> {
  late Future<List<Course>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    _coursesFuture = _fetchCourses();
  }

  Future<List<Course>> _fetchCourses() async {
    try {
      final apiService = ApiService(baseUrl: widget.platform.platformBaseUrl);
      final data = await apiService.fetchCourses(baseUrl: widget.platform.platformBaseUrl);
      return data.map((course) => Course.fromJson(course)).toList();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Error fetching courses: $error');
      }
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final breakpoint = ResponsiveBreakpoints.of(context).breakpoint;
    final isMobile = breakpoint.name == MOBILE;
    final isTablet = breakpoint.name == TABLET || breakpoint.name == "BIG-TABLET";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: isMobile ? 8 : 12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.platform.platformName,
                style: TextStyle(
                  fontSize: isMobile ? 18 : isTablet ? 20 : 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: widget.onShowMore,
                child: Text(
                  'Show More',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    color: AppColors.darkBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
        FutureBuilder<List<Course>>(
          future: _coursesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: isMobile ? 180 : 240,
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            final courses = snapshot.data ?? [];
            if (courses.isEmpty) return const SizedBox.shrink();

            return SizedBox(
              height: isMobile ? 200 : isTablet ? 240 : 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24,
                ),
                itemCount: _getItemCount(courses.length, breakpoint),
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: isMobile ? 12 : 16,
                    ),
                    child: CourseCardHorizontal(course: course,platformToken: widget.platform.token,),
                  );
                },
              ),
            );
          },
        ),
        Divider(
          height: isMobile ? 32 : 40,
          thickness: 0.5,
          indent: 24,
          endIndent: 24,
        ),
      ],
    );
  }

  int _getItemCount(int courseCount, Breakpoint breakpoint) {
    final maxItems = breakpoint.name == MOBILE ? 5
        : breakpoint.name == TABLET ? 6
        : breakpoint.name == "BIG-TABLET" ? 7
        : 7;
    return courseCount > maxItems ? maxItems : courseCount;
  }
}