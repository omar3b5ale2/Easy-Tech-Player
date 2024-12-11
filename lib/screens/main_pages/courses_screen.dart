import 'package:flutter/material.dart';
import '../../core/utils/constants/app_constants.dart';
import '../../core/utils/shared/second_appbar.dart';
import '../../widgets/body/list_of_courses.dart';
import '../../widgets/placeholder_content.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  bool hasBaseUrl = false;

  @override
  void initState() {
    super.initState();
    checkBaseUrl();
  }

  Future<void> checkBaseUrl() async {
    setState(() {
      hasBaseUrl = AppConstants.baseUrl.isNotEmpty &&
          AppConstants.baseUrl != ' '; // Check for default value
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppConstants.textDirection,
      child: Scaffold(
        appBar: SecondAppBar(
          text: AppConstants.appName,
        ),
        body: hasBaseUrl
            ? const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: ListOfCourses(),
              )
            : const PlaceholderContent(
                message:
                    'افتح الدرس من منصة المدرس و هتشوف كل الكورسات هنا ^_^ ...',
                imagePath: 'assets/icon/home_placeholder.png',
              ),
      ),
    );
  }
}
