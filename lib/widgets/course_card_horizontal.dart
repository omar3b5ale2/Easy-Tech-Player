import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/course_model.dart';

class CourseCardHorizontal extends StatelessWidget {
  final Course course;
  final String platformToken;

  const CourseCardHorizontal({
    super.key,
    required this.course,
    required this.platformToken,
  });

  @override
  Widget build(BuildContext context) {
    final breakpoint = ResponsiveBreakpoints.of(context).breakpoint;
    final isMobile = breakpoint.name == MOBILE;
    final isTablet =
        breakpoint.name == TABLET || breakpoint.name == "BIG-TABLET";
    final isDesktop = breakpoint.name == DESKTOP;
    final is4K = breakpoint.name == '4K';

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth =
            _calculateCardWidth(context, isMobile, isTablet, isDesktop, is4K);

        return Container(
          width: cardWidth,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          child: GestureDetector(
            onTap: () => _launchCourseUrl(course, context),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  // Add border
                  color: Colors.grey.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 12 / 19,
                  child: Image.network(
                    course.cover,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchCourseUrl(Course course, BuildContext context) async {
    try {
      final Uri url = Uri.parse('${course.link}?token=$platformToken');
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'Could not launch ${course.link}';
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Could not open course link'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  double _calculateCardWidth(BuildContext context, bool isMobile, bool isTablet,
      bool isDesktop, bool is4K) {
    final screenWidth = MediaQuery.of(context).size.width;
    double widthPercentage = isMobile
        ? 0.4
        : // 40% of screen width
        isTablet
            ? 0.3
            : // 30% of screen width
            isDesktop
                ? 0.2
                : // 20% of screen width
                0.15; // 15% for 4K

    double calculatedWidth = screenWidth * widthPercentage;

    // Add maximum width constraints
    if (isMobile) {
      return calculatedWidth.clamp(120, 160);
    } else if (isTablet) {
      return calculatedWidth.clamp(160, 200);
    } else if (isDesktop) {
      return calculatedWidth.clamp(200, 280);
    } else {
      return calculatedWidth.clamp(280, 320);
    }
  }
}
