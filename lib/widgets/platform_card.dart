import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart'; // Import ResponsiveFramework

import '../core/utils/constants/app_colors.dart';
import '../models/platform_data_model.dart';


class PlatformGrid extends StatelessWidget {
  final List<PlatformData> platforms;
  final Function(PlatformData) onPlatformTap;

  const PlatformGrid({
    super.key,
    required this.platforms,
    required this.onPlatformTap,
  });

  @override
  Widget build(BuildContext context) {
    final currentBreakpoint = ResponsiveBreakpoints.of(context).breakpoint.name;
    final crossAxisCount = _getCrossAxisCount(currentBreakpoint!);

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: platforms.length,
      itemBuilder: (context, index) {
        final platform = platforms[index];
        return PlatformCard(
          platform: platform,
          onTap: () => onPlatformTap(platform),
        );
      },
    );
  }

  int _getCrossAxisCount(String breakpoint) {
    switch (breakpoint) {
      case 'MOBILE':
        return 2;
      case 'TABLET':
        return 3;
      case 'DESKTOP':
        return 4;
      case '4K':
        return 6;
      default:
        return 3;
    }
  }
}

class PlatformCard extends StatelessWidget {
  final PlatformData platform;
  final VoidCallback onTap;

  const PlatformCard({
    super.key,
    required this.platform,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Get the current screen size using ResponsiveFramework
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    // Adjust card padding and font size based on screen size
    final cardPadding = isMobile
        ? const EdgeInsets.all(12)
        : isTablet
            ? const EdgeInsets.all(16)
            : const EdgeInsets.all(20);

    final iconSize = isMobile
        ? 24.0
        : isTablet
            ? 32.0
            : 40.0;
    final fontSize = isMobile
        ? 16.0
        : isTablet
            ? 18.0
            : 20.0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: cardPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.video_camera_back_outlined,
                size: iconSize,
                color: AppColors.darkBlue,
              ),
              const SizedBox(height: 8),
              Text(
                platform.platformName,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
