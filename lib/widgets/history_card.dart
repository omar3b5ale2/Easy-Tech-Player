import 'package:flutter/material.dart';
import '../../models/video_data.dart';
import '../core/utils/constants/app_colors.dart'; // Import the VideoData model

class HistoryCard extends StatelessWidget {
  final VideoData video; // Video data to be passed to the card
  final Function onTap; // Callback when the card is tapped

  const HistoryCard({
    Key? key,
    required this.video,
    required this.onTap,
  }) : super(key: key);

  // Format time into HH:MM:SS
  String formatTime(double minutes) {
    final int totalSeconds = (minutes * 60).round();
    final int hours = totalSeconds ~/ 3600;
    final int remainingSeconds = totalSeconds % 3600;
    final int mins = remainingSeconds ~/ 60;
    final int secs = remainingSeconds % 60;

    return "${hours.toString().padLeft(2, '0')}:"
        "${mins.toString().padLeft(2, '0')}:"
        "${secs.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(), // Trigger the onTap callback when the card is tapped
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Video Icon
              const Icon(
                Icons.play_circle_fill,
                size: 48,
                color: AppColors.teal,
              ),
              const SizedBox(width: 16),
              // Video Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.lessonName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "الوحدة: ${video.unitName}",
                      style: const TextStyle(
                          fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "اجمالي الوقت: ${formatTime(video.totalTime)}",
                      style: const TextStyle(
                          fontSize: 16, color: AppColors.teal),
                    ),
                  ],
                ),
              ),
              // Action Icon (Arrow)
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
