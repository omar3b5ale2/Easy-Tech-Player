import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/shared/second_appbar.dart';
import '../../models/video_data.dart';
import '../../services/video_service.dart';
import '../../widgets/history_card.dart';
import '../../widgets/placeholder_content.dart';

class VideoListScreen extends StatelessWidget {
  const VideoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final videoService = VideoService();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: SecondAppBar(
          text: 'History'
        ),
        body: FutureBuilder<List<VideoData>>(
          future: videoService.getAllVideos(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'حدث خطأ أثناء تحميل الفيديوهات: ${snapshot.error}',
                  style: const TextStyle(fontSize: 18),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: PlaceholderContent(
                  message:
                      'هنا كل الدروس اللي شوفتها قبل كدة علشان توصلها بسرعة ^_^ ... ',
                  imagePath: 'assets/icon/history.png',
                ),
              );
            }

            final videos = snapshot.data!;

            return ListView.builder(
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                return HistoryCard(
                  video: video,
                  onTap: () {
                    final encodedData =
                        Uri.encodeComponent(video.encryptedData); // Encode data
                    context.go(
                      '/video?data=$encodedData', // Navigate to the video route
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
