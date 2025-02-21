import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

import '../core/utils/constants/app_colors.dart';

class MarqueeWidget extends StatelessWidget {
  final String text;
  final Color textColor; // New parameter for text color

  const MarqueeWidget({
    super.key,
    this.text = 'افتح الدرس من منصة المدرس و اختار الدرس و هو هيشغل الدرس هنا ... ^_^ || ودي الكورسات اللي على المنصه لو عايز تشوفها.', // Default text
    this.textColor = AppColors.teal, // Default color
  });

  @override
  Widget build(BuildContext context) {
    return Marquee(
      text: text,
      style: TextStyle(
        fontSize: 18,
        color: textColor, // Use the customizable color
        fontWeight: FontWeight.w600,
      ),
      scrollAxis: Axis.horizontal,
      blankSpace: 20.0,
      velocity: 50.0,
      showFadingOnlyWhenScrolling: true,
      fadingEdgeStartFraction: 0.1,
      fadingEdgeEndFraction: 0.1,
    );
  }
}