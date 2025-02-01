import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/constants/app_constants.dart';
import '../../core/utils/shared/second_appbar.dart';
import '../../models/platform_data_model.dart';
import '../../models/video_data.dart';
import '../../services/video_service.dart';
import '../../widgets/history_card.dart';
import '../../widgets/placeholder_content.dart';
import '../../widgets/platform_card.dart';

class VideoListScreen extends StatelessWidget {
  const VideoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final videoService = VideoService();

    return Directionality(
      textDirection: AppConstants.textDirection,
      child: Scaffold(
        appBar: SecondAppBar(text: 'History'),
        body: FutureBuilder<List<PlatformData>>(
          future: videoService.getAllPlatforms(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'حدث خطأ أثناء تحميل المنصات: ${snapshot.error}',
                  style: const TextStyle(fontSize: 18),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: PlaceholderContent(
                  message:
                  'لا توجد منصات مسجلة. يرجى إضافة منصة لعرض المحتوى.',
                  imagePath: 'assets/icon/history.png',
                ),
              );
            }

            final platforms = snapshot.data!;

            if (platforms.length == 1) {
              // If there's only one platform, show the videos directly
              return FutureBuilder<List<VideoData>>(
                future: videoService.getVideosByPlatform(platforms.first.platformName),
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
                        'لا توجد فيديوهات مسجلة لهذه المنصة.',
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
                          Uri.encodeComponent(video.encryptedData);
                          context.go('/video?data=$encodedData');
                        },
                      );
                    },
                  );
                },
              );
            } else {
              // If there are multiple platforms, show a list of platform cards
              return ListView.builder(
                itemCount: platforms.length,
                itemBuilder: (context, index) {
                  final platform = platforms[index];
                  return PlatformCard(
                    platform: platform,
                    onTap: () {
                      // Navigate to a new screen or show a dialog with platform-specific videos
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlatformVideosScreen(
                            platformName: platform.platformName,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

/// Screen to display videos for a specific platform
class PlatformVideosScreen extends StatelessWidget {
  final String platformName;

  const PlatformVideosScreen({super.key, required this.platformName});

  @override
  Widget build(BuildContext context) {
    final videoService = VideoService();

    return Directionality(
      textDirection: AppConstants.textDirection,
      child: Scaffold(
        appBar:
        SecondAppBar(
          text: 'Video History Of: $platformName',
          showReturnButton: true,
        ),
        body: FutureBuilder<List<VideoData>>(
          future: videoService.getVideosByPlatform(platformName),
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
                  message: 'لا توجد فيديوهات مسجلة لهذه المنصة.',
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
                    Uri.encodeComponent(video.encryptedData);
                    context.go('/video?data=$encodedData');
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