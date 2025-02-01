import 'package:flutter/material.dart';
import '../../../core/utils/constants/app_constants.dart';
import '../../../core/utils/shared/second_appbar.dart';
import '../../../models/platform_data_model.dart';
import 'list_of_courses.dart';

class PlatformCoursesScreen extends StatelessWidget {
  final PlatformData platform;

  const PlatformCoursesScreen({super.key, required this.platform});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppConstants.textDirection,
      child: Scaffold(
        appBar: SecondAppBar(
          text: platform.platformName,
          showReturnButton: true,
        ),
        body: ListOfCourses(platformBaseUrl: platform.platformBaseUrl,platformToken: platform.token,),
      ),
    );
  }
}