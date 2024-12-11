import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/utils/constants/app_constants.dart';
import '../../core/utils/shared/second_appbar.dart';
import '../../services/video_service.dart';
import '../../services/api_service.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:http/http.dart' as http;
import '../../widgets/placeholder_content.dart';
import '../material_vide_controls_theme_data.dart';
import 'dart:math';

import '../quality_speed_selector.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoLink,
      lessonName,
      unitName,
      videoId,
      token,
      lessonId,
      courseId,
      encryptededData,
      studentId;

  const VideoPlayerScreen({
    super.key,
    required this.videoLink,
    required this.lessonName,
    required this.encryptededData,
    required this.unitName,
    required this.videoId,
    required this.token,
    required this.lessonId,
    required this.courseId,
    required this.studentId,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final player = Player(); // Already present in your code
  late final controller = VideoController(player);

  double currentSpeed = 1.0; // Current playback speed
  Duration currentPosition = Duration.zero; // Tracks current playback position
  List<Map<String, String>> qualityOptions =
      []; // Holds available quality options
  String currentQuality = ''; // Current quality URL
  //---------------------------------------------------------------------------
  double _effectivePlayedTime = 0.0;

  bool _isLoading = true;
  bool _isAuthorized = false;
  late Timer _backgroundTimer;
  int _lastMinutedebugPrintged = 0;
  bool isFullScreen = false;
  bool _needsApiUpdate = false;
  double _videoTotalDurationSeconds = 0.0;
  late Timer _apiTimer;
  Duration? totalDuration; // Variable to store total video duration
  late StreamSubscription<Duration>
      positionSubscription; // Subscription to track position

  final VideoService _videoService = VideoService();
  final ApiService _apiService = ApiService(baseUrl: AppConstants.baseUrl);

  @override
  void initState() {
    super.initState();
    _backgroundTimer =
        Timer.periodic(const Duration(seconds: 1), _backgroundTimerTick);

    // Set up the timer to send data to API every minute
    _apiTimer =
        Timer.periodic(Duration(minutes: Random().nextInt(6)), (_) {
          _sendVideoDataToApi();
        });
    _authorizeUser();
    _trackPosition();
  }

  void _trackPosition() {
    positionSubscription = player.stream.position.listen((position) {
      currentPosition = position;
    });
  }

  void _initializeVideoPlayer() async {
    await _fetchQualityLinks(widget.videoLink);
    if (qualityOptions.isNotEmpty) {
      setState(() {
        currentQuality = qualityOptions[0]['url']!;
      });
      _playVideo(currentQuality);
    }
  }

  void _backgroundTimerTick(Timer timer) {
    if (player.state.playing) {
      _effectivePlayedTime += currentSpeed;

      if (_effectivePlayedTime ~/ 60 > _lastMinutedebugPrintged) {
        _lastMinutedebugPrintged = _effectivePlayedTime ~/ 60;
        debugPrint(
            "Effective video play time: $_lastMinutedebugPrintged minute(s).");
        _needsApiUpdate = true;

        // _videoService.updateWatchTime(widget.videoId, 60 * currentSpeed);
      }
    }
  }

  Future<void> _fetchQualityLinks(String hlsUrl) async {
    try {
      final response = await http.get(Uri.parse(hlsUrl));
      if (response.statusCode == 200) {
        final lines = const LineSplitter().convert(response.body);
        final fetchedQualityOptions = <Map<String, String>>[];

        for (int i = 0; i < lines.length; i++) {
          if (lines[i].startsWith('#EXT-X-STREAM-INF')) {
            final qualityInfo = lines[i];
            if (i + 1 < lines.length && !lines[i + 1].startsWith('#')) {
              final qualityUrl = lines[i + 1];
              fetchedQualityOptions.add({
                'info': qualityInfo.substring(qualityInfo.length - 3),
                'url': Uri.parse(hlsUrl).resolve(qualityUrl).toString(),
              });
            }
          }
        }

        setState(() {
          qualityOptions = fetchedQualityOptions;
        });
      } else {
        debugPrint('Failed to fetch playlist: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _playVideo(String url) async {
    debugPrint('Playing video at currentPosition: $currentPosition');
    Duration startPosition = currentPosition; // Save the current position

    // Open the new video URL but do not play it immediately
    await player.open(Media(url), play: false);
    _isLoading = false;
    // Wait for the player to indicate readiness (loaded media)
    StreamSubscription? readySubscription;
    readySubscription = player.stream.duration.listen((duration) async {
      if (duration != Duration.zero) {
        // Once the media is ready, seek to the desired position
        await player.seek(startPosition);

        // Start playback only after seeking
        await player.play();

        // Cancel the subscription to avoid redundant calls
        readySubscription?.cancel();
      }
    });

    // Track the video duration for other logic
    player.stream.duration.listen((duration) {
      _videoTotalDurationSeconds = duration.inSeconds.toDouble();
      setState(() {
        if (totalDuration?.inMinutes != 0) {
          _videoService.addOrUpdateVideo(
            videoId: widget.videoId,
            totalTimeInSeconds: duration.inSeconds.toDouble(),
            encryptedData: widget.encryptededData,
            lessonName: widget.lessonName,
            unitName: widget.unitName,
          );
        }
      });
    });

    // Update the playback speed if needed
    player.stream.rate.listen((rate) {
      setState(() {
        currentSpeed = rate;
      });
    });
  }

  Future<void> _sendVideoDataToApi() async {
    if (!_needsApiUpdate) return;
    final response = await _apiService.postRequest(
      endpoint: 'view/views-progress',
      authToken: widget.token,
      data: {
        'lesson_id': widget.lessonId,
        'time_second': "${(_lastMinutedebugPrintged * 60).toInt()}",
        'duration_second': "${(_videoTotalDurationSeconds).toInt()}",
      },
    );

    if (response != null && response.statusCode == 200) {
      _needsApiUpdate = false;
      debugPrint("Data successfully sent to API.: ${{
        'total_time': _videoTotalDurationSeconds,
        'watched_time': _lastMinutedebugPrintged * 60,
      }}");
    } else {
      debugPrint("Failed to send data to API.");
    }
  }

  void _changePlaybackSpeed(double speed) {
    setState(() {
      currentSpeed = speed;
    });
    player.setRate(speed); // Adjust player speed
  }

  Future<void> _authorizeUser() async {
    final response = await _apiService.auth(
        endpoint: 'dashboard/app/app-validation-data',
        authToken: widget.token,
        courseId: widget.courseId,
        lessonId: widget.lessonId);

    if (response != null && response.statusCode == 200) {
      setState(() {
        _isAuthorized = true;
        _initializeVideoPlayer();
      });
    } else {
      setState(() {
        _isAuthorized = false;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _debugPrintDatabaseRecordsOnClose();
    player.stop();
    player.dispose();
    //
    _backgroundTimer.cancel();
    _apiTimer.cancel(); // Stop the API timer when disposing
    positionSubscription.cancel();
    super.dispose();
  }

  Future<void> _debugPrintDatabaseRecordsOnClose() async {
    final allVideos = await _videoService.getAllVideos();
    for (var video in allVideos) {
      debugPrint(
          "[Closing App] READ FROM DB || Video_id: ${video.videoId}, Total Time: ${video.totalTime} minute(s), Watched Time: ${video.watchTime} minute(s), unit: ${video.unitName}, lesson: ${video.lessonName}, encryptedData: ${video.encryptedData}");
    }

    // Send final data before closing
    _needsApiUpdate = true;
    await _sendVideoDataToApi();
  }

  void _showQualityBanner(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return QualitySpeedSelector(
          qualityOptions: qualityOptions,
          currentQuality: currentQuality,
          onQualityChanged: (String newQuality) {
            setState(() {
              currentQuality = newQuality;
            });
            _playVideo(newQuality);
          },
          currentSpeed: currentSpeed,
          onSpeedChanged: (double newSpeed) {
            _changePlaybackSpeed(newSpeed);
          },
          isFullScreen: isFullScreen,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppConstants.textDirection,
      child: Scaffold(
        appBar: SecondAppBar(
          text: widget.lessonName != '' ? widget.lessonName : 'Player',
        ),
        body: widget.videoLink.isEmpty
            ? const PlaceholderContent(
                message: 'افتح الفيديو من منصة المستر وهيشتغل هنا ^_^ ...',
                imagePath: 'assets/icon/video_placeholder.png',
              )
            : _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _isAuthorized
                    ? Center(
                        child: MaterialVideoControlsTheme(
                          normal: buildVideoControlsTheme(
                            onSettingsPressed: () =>
                                _showQualityBanner(context),
                          ),
                          fullscreen: buildVideoControlsTheme(
                            onSettingsPressed: () =>
                                _showQualityBanner(context),
                          ),
                          child: SafeArea(
                            child: Scaffold(
                              body: Video(
                                controller: controller,
                                wakelock: true,
                              ),
                            ),
                          ),
                        ),
                      )
                    : const PlaceholderContent(
                        message: 'برجاء التأكد ان الاشتراك مظبوط هنا ^_* ...',
                        imagePath: 'assets/icon/unauthorized.png',
                      ),
      ),
    );
  }
}
