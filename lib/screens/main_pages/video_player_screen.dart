import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../core/utils/constants/app_colors.dart';
import '../../core/utils/constants/app_constants.dart';
import '../../core/utils/shared/second_appbar.dart';
import '../../services/api_service.dart';
import '../../services/video_service.dart';
import '../../widgets/marquee_widget.dart';
import '../../widgets/placeholder_content.dart';
import '../material_vide_controls_theme_data.dart';
import '../../core/utils/shared/base_url_singlton.dart';
import 'dart:math'; // Ensure this import is present at the top of the file
class VideoPlayerScreen extends StatefulWidget {
  final String videoLink;
  final String lessonName;
  final String unitName;
  final String videoId;
  final String token;
  final String lessonId;
  final String courseId;
  final String encryptededData;
  final String studentId;
  final String platformName;
  final String uniqueId;
  final int requestDelay;
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
    required this.platformName,
    required this.uniqueId,
    required this.requestDelay,

  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final Player player;
  late final VideoController controller;
  late final VideoService _videoService;
  late final ApiService _apiService;
  double _progress = 0.0;
  late Timer _timer;
  List<VideoTrack> videoTracks = [];
  VideoTrack? selectedVideoTrack;
  double currentSpeed = 1.0;
  bool isFullScreen = false;
  bool _isLoading = true;
  bool _isAuthorized = false;
  bool _isUpdate = false;
  bool _isChangingTrack = false;
  double _effectivePlayedTime = 0.0;
  double _videoTotalDuration = 0.0;
  int _lastMinuteLogged = 0;
  bool _needsApiUpdate = false;
  Timer? _progressTimer;
  Timer? _apiUpdateTimer;

  List<VideoTrack> get validVideoTracks {
    return videoTracks.where((track) {
      if (track.w == null || track.h == null) return false;
      if (track.w == 0 || track.h == 0) return false;
      if (track.codec == null || track.codec!.isEmpty) return false;
      return true;
    }).toList()
      ..sort((a, b) => (b.h ?? 0).compareTo(a.h ?? 0));
  }

  @override
  void initState() {
    super.initState();
    player = Player();
    controller = VideoController(player);
    _videoService = VideoService();
    final sharedState = getIt<SharedState>();
    _apiService = ApiService(baseUrl: sharedState.baseUrl);
    _authorizeAndInitialize();
  }

  Future<void> _authorizeAndInitialize() async {
    try {

      final sharedState = getIt<SharedState>();
      print('packageInfo version: ${sharedState.appVersion}');
      print('packageInfo build: ${sharedState.buildNumber}');
      print('courseId : ${widget.courseId}');
      print('lessonId : ${widget.lessonId}');

      final response = await _apiService.auth(
        endpoint: 'dashboard/app/app-validation-data',
        authToken: widget.token,
        courseId: widget.courseId,
        lessonId: widget.lessonId,
        app_version: sharedState.appVersion,
        build_number: sharedState.buildNumber,
      );

      if (response != null && response.statusCode == 200) {
        setState(() => _isAuthorized = true);
        await _initializePlayer();
        _startProgressBar();

      } else {
        print('Status Code Not 200: ${response?.body}');
        setState(() {
          _isAuthorized = false;
          _isUpdate = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Authorization error: $e');
      setState(() {
        _isAuthorized = false;
        _isLoading = false;
      });
    }
  }

  void _startProgressBar() {
    // Start a timer that updates the progress bar every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_progress < 1.0) {
          _progress += 1 / 29; // Increment progress to reach 100% in 29 seconds
        } else {
          _timer.cancel(); // Stop the timer once progress reaches 100%
        }
      });
    });
  }


  Future<void> _initializePlayer() async {
    try {
      // Open the media
      await player.open(Media(widget.videoLink), play: true);

      // Listen to tracks
      player.stream.tracks.listen((tracks) {
        setState(() {
          videoTracks = tracks.video;
          if (validVideoTracks.isNotEmpty && selectedVideoTrack == null) {
            selectedVideoTrack = validVideoTracks[0];
          }
        });
      });

      // Listen to duration
      player.stream.duration.listen((duration) {
        _videoTotalDuration = duration.inSeconds.toDouble();
        if (_videoTotalDuration > 0) {
          _videoService.addOrUpdateVideo(
            videoId: widget.videoId,
            totalTimeInSeconds: _videoTotalDuration,
            encryptedData: widget.encryptededData,
            lessonName: widget.lessonName,
            unitName: widget.unitName,
            platformName: widget.platformName,
          );
        }
      });

      // Listen to playback rate
      player.stream.rate.listen((speed) {
        setState(() => currentSpeed = speed);
      });

      // Track when the video starts playing and reaches 1 second
      bool hasStartedPlaying = false;
      player.stream.playing.listen((isPlaying) {
        if (isPlaying && !hasStartedPlaying) {
          _setupTracking();
          hasStartedPlaying = true;
          // Now start checking the position
          player.stream.position.listen((position) {
            if (position.inSeconds >= 1) {
              setState(() => _isLoading =
                  false); // Stop loading after 1 second of playback
            }
          });
        }
      });
    } catch (e) {
      debugPrint('Player initialization error: $e');
      setState(() => _isLoading = false); // Stop loading on error
    }
  }

  void _setupTracking() {
    _progressTimer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (player.state.playing) {
          _effectivePlayedTime += currentSpeed;
          if (_effectivePlayedTime ~/ 60 > _lastMinuteLogged) {
            _lastMinuteLogged = _effectivePlayedTime ~/ 60;
            _needsApiUpdate = true;
          }
        }
      },
    );

    // Schedule the first API update with a random delay
    _scheduleRandomApiUpdate();
  }

  void _scheduleRandomApiUpdate() {
    // int requestDelay = int.parse(widget.requestDelay);
    // // List of possible minute intervals: 1, 2, 3, 4, 5, 6
    // final minuteOptions = [requestDelay];
    // final random = Random();
    // final randomMinutes = minuteOptions[random.nextInt(minuteOptions.length)];
    final duration = Duration(minutes: widget.requestDelay);

    _apiUpdateTimer?.cancel();

    _apiUpdateTimer = Timer(duration, () async {
      await _sendProgressToApi();
      if (mounted) {
        _scheduleRandomApiUpdate();
      }
    });

    debugPrint('Next API update scheduled in ${widget.requestDelay} minutes');
  }

  Future<void> _sendProgressToApi() async {
    if (!_needsApiUpdate) return;

    try {
      final response = await _apiService.postRequest(
        endpoint: 'view/views-progress',
        authToken: widget.token,
        data: {
          'lesson_id': widget.lessonId,
          'time_second': "${(_lastMinuteLogged * 60).toInt()}",
          'duration_second': "${_videoTotalDuration.toInt()}",
          'session_id': widget.uniqueId
        },
      );

      if (response != null && response.statusCode == 200) {
        _needsApiUpdate = false;
        print("response: ${response.body}");
      }
    } catch (e) {
      debugPrint('Error sending progress to API: $e');
    }
  }

  Future<void> _setVideoTrack(VideoTrack track) async {
    if (_isChangingTrack) return;

    setState(() => _isChangingTrack = true);
    try {
      final currentPosition = player.state.position;
      await player.setVideoTrack(track);
      await player.seek(currentPosition);
      setState(() {
        selectedVideoTrack = track;
        _isChangingTrack = false;
      });
    } catch (e) {
      debugPrint('Error changing video track: $e');
      setState(() => _isChangingTrack = false);
    }
  }

  void _changePlaybackSpeed(double speed) {
    player.setRate(speed);
    setState(() => currentSpeed = speed);
  }

  String _getQualityLabel(VideoTrack track) {
    if (track.w == null || track.h == null) return 'Auto';

    final width = track.w!;
    final height = track.h!;

    String bitrateInfo = '';
    if (track.bitrate != null && track.bitrate! > 0) {
      final mbps = track.bitrate! / 1000000;
      bitrateInfo = ' (${mbps.toStringAsFixed(1)}Mbps)';
    }

    if (width >= 3840) return '4K$bitrateInfo';
    if (width >= 1920) return '1080p$bitrateInfo';
    if (width >= 1280) return '720p$bitrateInfo';
    if (width >= 854) return '480p$bitrateInfo';
    if (width >= 640) return '360p$bitrateInfo';
    return '${height}p$bitrateInfo';
  }

  void _showQualitySpeedSelector() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Material(
          color: Colors.black.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Video Quality',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (validVideoTracks.isEmpty)
                  const Text(
                    'No quality options available',
                    style: TextStyle(color: Colors.white),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: validVideoTracks.map((track) {
                      final isSelected = track == selectedVideoTrack;
                      return GestureDetector(
                        onTap: () {
                          _setVideoTrack(track);
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.turquoise
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white),
                          ),
                          child: Text(
                            _getQualityLabel(track),
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 24),
                const Text(
                  'Playback Speed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [0.5, 1.0, 1.5, 2.0].map((speed) {
                    final isSelected = speed == currentSpeed;
                    return GestureDetector(
                      onTap: () {
                        _changePlaybackSpeed(speed);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.turquoise
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white),
                        ),
                        child: Text(
                          '${speed}x',
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _apiUpdateTimer?.cancel();
    _timer.cancel();
    _sendProgressToApi();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videoLink.isEmpty) {
      return Scaffold(
        appBar: SecondAppBar(text: 'Player'),
        body: const PlaceholderContent(
          message: 'افتح الفيديو من منصة المستر وهيشتغل هنا ^_^ ...',
          imagePath: 'assets/icon/video_placeholder.png',
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        appBar: SecondAppBar(text: 'Player'),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min, // Center the content vertically
            children: [
              Lottie.asset(
                'assets/animation/dino.json', // Replace with your Lottie file path
                width: 200, // Adjust size as needed
                height: 200,
                fit: BoxFit.contain,
                repeat: true, // Loop the animation
              ),
              const SizedBox(height: 16), // Space between animation and text
              const Padding(
                padding: EdgeInsets.all(AppConstants.appPadding),
                child: SizedBox(
                  height: 50,
                  width: 250, // Height for the marquee banner
                  child: MarqueeWidget(
                      text: 'استنا الدرس هيبدأ دلوقتي',
                      textColor: AppColors.darkBlue),
                ),
              ),
              const SizedBox(
                  height: 16), // Space between animation and progress bar
          SizedBox(
            width: 250, // Adjust the width of the progress bar
            child: Container(
              height: 12, // Adjust the height to make it taller
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), // Adjust the radius for rounded corners
                color: Colors.grey[300], // Background color of the progress bar
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8), // Ensure the progress bar has rounded corners too
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.transparent, // Set to transparent so the container color shows
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkBlue), // Color of the progress bar
                ),
              ),
            ),
          ),

            ],
          ),
        ),
      );
    }

    if (!_isAuthorized) {
      if(_isUpdate){
        String message = '';
        // Initialize sqflite_ffi for desktop platforms
        if (Platform.isIOS) {
          message = 'اعمل Update للبرنامج من App Store';
        }
        else if(Platform.isAndroid){
          message = 'اعمل Update للبرنامج من Google Play';
        }
        else if(Platform.isWindows){
          message = 'اعمل Update للبرنامج من المنصة';
        }
        return Scaffold(
          appBar: SecondAppBar(text: 'Player'),
          body: PlaceholderContent(
            message: message,
            imagePath: 'assets/icon/update.png',
          ),
        );
      }
      else{
        return Scaffold(
          appBar: SecondAppBar(text: 'Player'),
          body: const PlaceholderContent(
            message: 'انتهت مشاهدات الكورس الرجاء اعادة الإشتراك ^_* ...',
            imagePath: 'assets/icon/unauthorized.png',
          ),
        );

      }

    }

    return Directionality(
      textDirection: AppConstants.textDirection,
      child: Scaffold(
        appBar: SecondAppBar(text: widget.lessonName),
        body: Stack(
          children: [
            Center(
              child: MaterialVideoControlsTheme(
                normal: buildVideoControlsTheme(
                  onSettingsPressed: _showQualitySpeedSelector,
                ),
                fullscreen: buildVideoControlsTheme(
                  onSettingsPressed: _showQualitySpeedSelector,
                ),
                child: Video(
                  controller: controller,
                  wakelock: true,
                ),
              ),
            ),
            if (_isChangingTrack)
              Center(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min, // Center the content vertically
                  children: [
                    Lottie.asset(
                      'assets/animation/dino.json', // Replace with your Lottie file path
                      width: 200, // Adjust size as needed
                      height: 200,
                      fit: BoxFit.contain,
                      repeat: true, // Loop the animation
                    ),
                    const SizedBox(
                        height: 16), // Space between animation and text
                    const Padding(
                      padding: EdgeInsets.all(AppConstants.appPadding),
                      child: SizedBox(
                        height: 50,
                        width: 300, // Height for the marquee banner
                        child: MarqueeWidget(
                            text: 'استنا الدرس هيبدأ دلوقتي',
                            textColor: AppColors.darkBlue),
                      ),
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
