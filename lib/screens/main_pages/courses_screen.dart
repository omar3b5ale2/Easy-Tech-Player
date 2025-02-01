import 'package:flutter/material.dart';
import '../../core/utils/constants/app_constants.dart';
import '../../core/utils/shared/second_appbar.dart';
import '../../models/platform_data_model.dart';
import '../../services/video_service.dart';
import '../../widgets/placeholder_content.dart';
import '../../widgets/platform_course_section.dart';
import '../../widgets/body/platform_courses_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final VideoService _videoService = VideoService();
  late Future<List<PlatformData>> _platformsFuture;

  @override
  void initState() {
    super.initState();
    _platformsFuture = _videoService.getAllPlatforms();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppConstants.textDirection,
      child: Scaffold(
        appBar: SecondAppBar(
          text: AppConstants.appName,
          showReturnButton: false,
        ),
        body: FutureBuilder<List<PlatformData>>(
          future: _platformsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'حدث خطأ أثناء تحميل المنصات: ${snapshot.error}',
                  style: const TextStyle(fontSize: 18),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const PlaceholderContent(
                message:
                    'افتح الدرس من منصة المدرس و هتشوف كل الكورسات هنا ^_^ ...',
                imagePath: 'assets/icon/home_placeholder.png',
              );
            }

            final platforms = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 2),
              itemCount: platforms.length,
              itemBuilder: (context, index) {
                final platform = platforms[index];
                return PlatformCourseSection(
                  platform: platform,
                  onShowMore: () =>
                      _navigateToPlatformCourses(context, platform),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _navigateToPlatformCourses(BuildContext context, PlatformData platform) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlatformCoursesScreen(
          platform: platform,
        ),
      ),
    );
  }
}
