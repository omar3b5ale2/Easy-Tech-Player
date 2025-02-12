import 'dart:io'; // Import the Platform class
import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';

MaterialVideoControlsThemeData buildVideoControlsTheme({
  required VoidCallback onSettingsPressed,
  Duration controlsHoverDuration = const Duration(seconds: 2, milliseconds: 500),
  Color seekBarPositionColor = Colors.yellow,
  Color seekBarBufferColor = const Color(0xFFFFF176), // Light yellow
  Color seekBarColor = const Color(0xFFFFF9C4), // Lighter yellow
  Color seekBarThumbColor = const Color(0xFFFFD54F), // Darker yellow
  bool seekGesture = true,
  bool seekOnDoubleTap = true,
  bool speedUpOnLongPress = false,
}) {
  return MaterialVideoControlsThemeData(
    controlsHoverDuration: controlsHoverDuration,
    padding: const EdgeInsets.only(bottom: 16),
    topButtonBar: [
      const Spacer(),
      MaterialCustomButton(
        onPressed: onSettingsPressed,
        icon: const Icon(Icons.settings),
      ),
    ],
    bottomButtonBar: [
      const MaterialDesktopPositionIndicator(),
      const MaterialDesktopVolumeButton(),
      const Spacer(),
      const MaterialFullscreenButton(),
    ],
    seekBarPositionColor: seekBarPositionColor,
    seekBarBufferColor: seekBarBufferColor,
    seekBarColor: seekBarColor,
    seekBarThumbColor: seekBarThumbColor,
    seekGesture: seekGesture,
    seekOnDoubleTap: seekOnDoubleTap,
    speedUpOnLongPress: speedUpOnLongPress,
  );
}