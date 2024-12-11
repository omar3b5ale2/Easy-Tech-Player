import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/utils/constants/app_constants.dart';
import '../../widgets/marquee_widget.dart';

class PlaceholderContent extends StatelessWidget {
  final String message;
  final String imagePath;

  const PlaceholderContent({
    super.key,
    required this.message,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    // Determine image size based on breakpoint
    final breakpoint = ResponsiveBreakpoints.of(context).breakpoint.name;
    double imageSize;

    if (breakpoint == "MOBILE") {
      imageSize = 175.0;
    } else if (breakpoint == "TABLET") {
      imageSize = 225.0;
    } else if (breakpoint == "DESKTOP") {
      imageSize = 325.0;
    } else {
      imageSize = 200.0; // Default size
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.all(AppConstants.appPadding),
          child: SizedBox(
            height: 50, // Height for the marquee banner
            child: MarqueeWidget(text: message),
          ),
        ),
        Expanded(
          child: Center(
            child: Image.asset(
              imagePath,
              height: imageSize,
              width: imageSize,
            ),
          ),
        ),
      ],
    );
  }
}
