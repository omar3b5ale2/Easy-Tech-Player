import 'package:flutter/material.dart';

import '../core/utils/constants/app_colors.dart';
import '../core/utils/constants/app_constants.dart';

class QualitySpeedSelector extends StatelessWidget {
  final List<Map<String, String>> qualityOptions;
  final String currentQuality;
  final void Function(String) onQualityChanged;
  final double currentSpeed;
  final void Function(double) onSpeedChanged;
  final bool isFullScreen;

  const QualitySpeedSelector({
    super.key,
    required this.qualityOptions,
    required this.currentQuality,
    required this.onQualityChanged,
    required this.currentSpeed,
    required this.onSpeedChanged,
    this.isFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppConstants.textDirection,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Material(
          color: Colors.black.withOpacity(AppConstants.materialColorOpacity),
          borderRadius: BorderRadius.circular(AppConstants.appCircularRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.appPadding),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Video Quality Control Section
                  const Padding(
                    padding: EdgeInsets.only(bottom: AppConstants.appPadding),
                    child: Text(
                      'اختار جودة الفيديو',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textColor,
                      ),
                    ),
                  ),
                  ExpansionTile(
                    title: const Text(
                      'الجودة',
                      style: TextStyle(
                        color: AppConstants.textColor,
                      ),
                    ),
                    iconColor: AppConstants.iconColor,
                    collapsedIconColor: AppConstants.iconColor,
                    children: [
                      SingleChildScrollView(
                        scrollDirection:
                            isFullScreen ? Axis.horizontal : Axis.vertical,
                        child: isFullScreen
                            ? Row(
                                children: qualityOptions.map((quality) {
                                  final isSelected =
                                      quality['url'] == currentQuality;
                                  return GestureDetector(
                                    onTap: () {
                                      onQualityChanged(quality['url']!);
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: AppConstants.appPaddingSymmetricV,
                                        horizontal: AppConstants.appPaddingSymmetricH,
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal:AppConstants.appMarginSymmetricH),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.turquoise
                                                .withOpacity(AppConstants.materialColorOpacity)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.appCircularRadius),
                                      ),
                                      child: Text(
                                        quality['info']!,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              )
                            : Column(
                                children: qualityOptions.map((quality) {
                                  final isSelected =
                                      quality['url'] == currentQuality;
                                  return GestureDetector(
                                    onTap: () {
                                      onQualityChanged(quality['url']!);
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: AppConstants.appPaddingSymmetricV,
                                        horizontal: AppConstants.appPaddingSymmetricH,
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.turquoise.withOpacity(0.8)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      child: Text(
                                        quality['info']!,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  // Playback Speed Control Section
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'اختار سرعة الفيديو',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textColor,
                      ),
                    ),
                  ),
                  ExpansionTile(
                    title: const Text(
                      'السرعة',
                      style: TextStyle(
                        color: AppConstants.textColor,
                      ),
                    ),
                    iconColor: AppConstants.iconColor,
                    collapsedIconColor: AppConstants.iconColor,
                    children: [
                      SingleChildScrollView(
                        scrollDirection:
                            isFullScreen ? Axis.horizontal : Axis.vertical,
                        child: isFullScreen
                            ? Row(
                                children: [0.5, 1.0, 1.5, 2.0].map((speed) {
                                  return GestureDetector(
                                    onTap: () {
                                      onSpeedChanged(speed);
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical:   AppConstants.appPaddingSymmetricV,
                                        horizontal: AppConstants.appPaddingSymmetricH,
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: AppConstants.appMarginSymmetricH),
                                      decoration: BoxDecoration(
                                        color: currentSpeed == speed
                                            ? AppColors.turquoise.withOpacity(AppConstants.materialColorOpacity)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(AppConstants.appCircularRadius),
                                      ),
                                      child: Text(
                                        '${speed}x',
                                        style: TextStyle(
                                          color: currentSpeed == speed
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              )
                            : Column(
                                children: [0.5, 1.0, 1.5, 2.0].map((speed) {
                                  return GestureDetector(
                                    onTap: () {
                                      onSpeedChanged(speed);
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical:   AppConstants.appPaddingSymmetricV,
                                        horizontal: AppConstants.appPaddingSymmetricH,
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: AppConstants.appMarginSymmetricH),
                                      decoration: BoxDecoration(
                                        color: currentSpeed == speed
                                            ? AppColors.turquoise.withOpacity(AppConstants.materialColorOpacity)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(AppConstants.appCircularRadius),
                                      ),
                                      child: Text(
                                        '${speed}x',
                                        style: TextStyle(
                                          color: currentSpeed == speed
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}