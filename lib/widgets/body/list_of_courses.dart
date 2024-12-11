import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/utils/constants/app_colors.dart';
import '../../core/utils/constants/app_constants.dart';
import '../../models/course_model.dart';
import '../../services/api_service.dart';
import '../course_card_widget.dart';
import '../marquee_widget.dart';
import '../placeholder_content.dart';

class ListOfCourses extends StatefulWidget {
  const ListOfCourses({super.key});

  @override
  State<ListOfCourses> createState() => _ListOfCoursesState();
}

class _ListOfCoursesState extends State<ListOfCourses> {
  late Future<List<Course>> _coursesFuture;
  final ApiService apiService =
      ApiService(baseUrl: AppConstants.baseUrl); // Replace with your base URL

  Future<List<Course>> _fetchCourses() async {
    try {
      final data = await apiService.fetchCourses();
      return data.map((courseData) => Course.fromJson(courseData)).toList();
    } catch (error) {
      debugPrint('Error fetching courses: $error');
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    _coursesFuture = _fetchCourses();
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.darkBlue,
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: const Text(
              'مش هنقدر نفتح لك الدرس من هنا دلوقتي ممكن تفتحه من المنصة',
              style: AppConstants.dialogTextStyle,
              textDirection: TextDirection.rtl,
            ),
          ),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.teal, // Border color
                      width: 2.0, // Border width
                    ),
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                    color: Colors.white, // Background color
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4), // Shadow color
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3), // Shadow position
                      ),
                    ],
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'تمام',
                      style: AppConstants.dialogTextStyle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentBreakpoint = ResponsiveBreakpoints.of(context).breakpoint.name;
    print(currentBreakpoint);
    print(MediaQuery.of(context).size.width);

    return FutureBuilder<List<Course>>(
      future: _coursesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('حدث خطأ أثناء تحميل الدورات'),
          );
        } else if (snapshot.data == null || snapshot.data!.isEmpty) {
          return const PlaceholderContent(
            message: 'مفيش كورسات حاليا انتظرنا قريب اوي ^_^ ...',
            imagePath: 'assets/icon/video_placeholder.png',
          );
        }

        final courses = snapshot.data!;
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.all(AppConstants.appPadding),
              child: SizedBox(
                height: 50, // Height for the banner
                child: const MarqueeWidget(),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: currentBreakpoint == 'MOBILE'
                      ? 1
                      : currentBreakpoint == 'TABLET'
                          ? 2
                          : currentBreakpoint == 'BIG-TABLET'
                              ? 3
                              : currentBreakpoint == 'DESKTOP'
                                  ? 4
                                  : 6,
                  // Two items per row
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: currentBreakpoint == 'MOBILE'
                      ? 1.2
                      : 1, // Square aspect ratio
                ),
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return GestureDetector(
                    onTap: () async {
                      if (course.link.isNotEmpty ) {
                        try {

                          final Uri url = Uri.parse('${course.link}?token=${AppConstants.token}');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url,
                                mode: LaunchMode.externalApplication);
                          } else {
                            throw 'لا يمكن فتح الرابط: ${course.link}';
                          }
                        } catch (e) {
                          debugPrint('Error launching URL: $e');
                          _showDialog(context);
                        }
                      } else {
                        _showDialog(context);
                      }
                    },
                    child: CourseCard(
                      name: course.name,
                      link: course.link,
                      lessonsCount: course.lessonsCount,
                      free: course.free,
                      cover: course.cover,
                      description: course.description,
                      isGrid:
                          true, // Pass true if grid-specific layout is required
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
