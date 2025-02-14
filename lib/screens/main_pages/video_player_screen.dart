// // import 'dart:async';
// // import 'package:flutter/material.dart';
// // import '../../core/utils/constants/app_constants.dart';
// // import '../../core/utils/shared/second_appbar.dart';
// // import '../../services/video_service.dart';
// // import '../../services/api_service.dart';
// // import 'package:media_kit/media_kit.dart';
// // import 'package:media_kit_video/media_kit_video.dart';
// // import '../../widgets/placeholder_content.dart';
// // import '../material_vide_controls_theme_data.dart';
// // import 'dart:math';
// //
// // import '../quality_speed_selector.dart';
// //
// // class VideoPlayerScreen extends StatefulWidget {
// //   final String videoLink,
// //       lessonName,
// //       unitName,
// //       videoId,
// //       token,
// //       lessonId,
// //       courseId,
// //       encryptededData,
// //       studentId;
// //
// //   const VideoPlayerScreen({
// //     super.key,
// //     required this.videoLink,
// //     required this.lessonName,
// //     required this.encryptededData,
// //     required this.unitName,
// //     required this.videoId,
// //     required this.token,
// //     required this.lessonId,
// //     required this.courseId,
// //     required this.studentId,
// //   });
// //
// //   @override
// //   State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
// // }
// //
// // class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
// //   late final player = Player(); // Already present in your code
// //   late final controller = VideoController(player);
// //
// //   double currentSpeed = 1.0; // Current playback speed
// //   // Duration currentPosition = Duration.zero; // Tracks current playback position
// //   List<Map<String, String>> qualityOptions =
// //       []; // Holds available quality options
// //   String currentQuality = ''; // Current quality URL
// //   List<VideoTrack> videoTracks = [];
// //   VideoTrack? selectedVideoTrack;
// //   //---------------------------------------------------------------------------
// //   double _effectivePlayedTime = 0.0;
// //
// //   bool _isLoading = true;
// //   bool _isAuthorized = false;
// //   late Timer _backgroundTimer;
// //   int _lastMinutedebugPrintged = 0;
// //   bool isFullScreen = false;
// //   bool _needsApiUpdate = false;
// //   double _videoTotalDurationSeconds = 0.0;
// //   late Timer _apiTimer;
// //   Duration? totalDuration; // Variable to store total video duration
// //   late StreamSubscription<Duration>
// //       positionSubscription; // Subscription to track position
// //
// //   final VideoService _videoService = VideoService();
// //   final ApiService _apiService = ApiService(baseUrl: AppConstants.baseUrl);
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _backgroundTimer =
// //         Timer.periodic(const Duration(seconds: 1), _backgroundTimerTick);
// //
// //     // Set up the timer to send data to API every minute
// //     _apiTimer = Timer.periodic(Duration(minutes: Random().nextInt(6)), (_) {
// //       _sendVideoDataToApi();
// //     });
// //     _authorizeUser();
// //     // _trackPosition();
// //   }
// //
// //   // void _trackPosition() {
// //   //   positionSubscription = player.stream.position.listen((position) {
// //   //     currentPosition = position;
// //   //   });
// //   // }
// //   //
// //   // void _initializeVideoPlayer() async {
// //   //   // await _fetchQualityLinks(widget.videoLink);
// //   //   // if (qualityOptions.isNotEmpty) {
// //   //   //   setState(() {
// //   //   //     currentQuality = qualityOptions[0]['url']!;
// //   //   //   });
// //   //     _playVideo(widget.videoLink);
// //   // }
// //
// //   void _backgroundTimerTick(Timer timer) {
// //     if (player.state.playing) {
// //       _effectivePlayedTime += currentSpeed;
// //
// //       if (_effectivePlayedTime ~/ 60 > _lastMinutedebugPrintged) {
// //         _lastMinutedebugPrintged = _effectivePlayedTime ~/ 60;
// //         debugPrint(
// //             "Effective video play time: $_lastMinutedebugPrintged minute(s).");
// //         _needsApiUpdate = true;
// //
// //         // _videoService.updateWatchTime(widget.videoId, 60 * currentSpeed);
// //       }
// //     }
// //   }
// //
// //   // Future<void> _fetchQualityLinks(String hlsUrl) async {
// //   //   try {
// //   //     final response = await http.get(Uri.parse(hlsUrl));
// //   //     if (response.statusCode == 200) {
// //   //       final lines = const LineSplitter().convert(response.body);
// //   //       final fetchedQualityOptions = <Map<String, String>>[];
// //   //
// //   //       for (int i = 0; i < lines.length; i++) {
// //   //         if (lines[i].startsWith('#EXT-X-STREAM-INF')) {
// //   //           final qualityInfo = lines[i];
// //   //           if (i + 1 < lines.length && !lines[i + 1].startsWith('#')) {
// //   //             final qualityUrl = lines[i + 1];
// //   //             fetchedQualityOptions.add({
// //   //               'info': qualityInfo.substring(qualityInfo.length - 3),
// //   //               'url': Uri.parse(hlsUrl).resolve(qualityUrl).toString(),
// //   //             });
// //   //           }
// //   //         }
// //   //       }
// //   //
// //   //       setState(() {
// //   //         qualityOptions = fetchedQualityOptions;
// //   //       });
// //   //     } else {
// //   //       if (kDebugMode) {
// //   //         print('Failed to fetch playlist: HTTP ${response.statusCode}');
// //   //       }
// //   //     }
// //   //   } catch (e) {
// //   //     if (kDebugMode) {
// //   //       debugPrint('Error: $e');
// //   //     }
// //   //   }
// //   // }
// //
// //   void _playVideo(String url) async {
// //     // debugPrint('Playing video at currentPosition: $currentPosition');
// //     // Duration startPosition = currentPosition; // Save the current position
// //
// //     // Open the new video URL but do not play it immediately
// //     await player.open(Media(url), play: false).then((_) {
// //       // Fetch available tracks after media is loaded.
// //       videoTracks = player.state.tracks.video;
// //       // audioTracks = player.state.tracks.audio;
// //       // subtitleTracks = player.state.tracks.subtitle;
// //
// //       // Automatically set the first available track or a default track.
// //       selectedVideoTrack = videoTracks.isNotEmpty ? videoTracks[0] : null;
// //       // selectedAudioTrack = audioTracks.isNotEmpty ? audioTracks[0] : null;
// //       // selectedSubtitleTrack = subtitleTracks.isNotEmpty ? subtitleTracks[0] : null;
// //
// //       setState(() {});
// //     });
// //     _isLoading = false;
// //     // Wait for the player to indicate readiness (loaded media)
// //     // StreamSubscription? readySubscription;
// //     // readySubscription = player.stream.duration.listen((duration) async {
// //     //   if (duration != Duration.zero) {
// //     //     // Once the media is ready, seek to the desired position
// //     //     await player.seek(startPosition);
// //     //
// //     //     // Start playback only after seeking
// //     //     await player.play();
// //     //
// //     //     // Cancel the subscription to avoid redundant calls
// //     //     readySubscription?.cancel();
// //     //   }
// //     // });
// //
// //     // Track the video duration for other logic
// //     player.stream.duration.listen((duration) {
// //       _videoTotalDurationSeconds = duration.inSeconds.toDouble();
// //       setState(() {
// //         if (totalDuration?.inMinutes != 0) {
// //           _videoService.addOrUpdateVideo(
// //             videoId: widget.videoId,
// //             totalTimeInSeconds: duration.inSeconds.toDouble(),
// //             encryptedData: widget.encryptededData,
// //             lessonName: widget.lessonName,
// //             unitName: widget.unitName,
// //           );
// //         }
// //       });
// //     });
// //
// //     // Update the playback speed if needed
// //     player.stream.rate.listen((rate) {
// //       setState(() {
// //         currentSpeed = rate;
// //       });
// //     });
// //   }
// //
// //   Future<void> _sendVideoDataToApi() async {
// //     if (!_needsApiUpdate) return;
// //     final response = await _apiService.postRequest(
// //       endpoint: 'view/views-progress',
// //       authToken: widget.token,
// //       data: {
// //         'lesson_id': widget.lessonId,
// //         'time_second': "${(_lastMinutedebugPrintged * 60).toInt()}",
// //         'duration_second': "${(_videoTotalDurationSeconds).toInt()}",
// //       },
// //     );
// //
// //     if (response != null && response.statusCode == 200) {
// //       _needsApiUpdate = false;
// //       debugPrint("Data successfully sent to API.: ${{
// //         'total_time': _videoTotalDurationSeconds,
// //         'watched_time': _lastMinutedebugPrintged * 60,
// //       }}");
// //     } else {
// //       debugPrint("Failed to send data to API.");
// //     }
// //   }
// //
// //   void _changePlaybackSpeed(double speed) {
// //     setState(() {
// //       currentSpeed = speed;
// //     });
// //     player.setRate(speed); // Adjust player speed
// //   }
// //
// //   Future<void> _authorizeUser() async {
// //     final response = await _apiService.auth(
// //         endpoint: 'dashboard/app/app-validation-data',
// //         authToken: widget.token,
// //         courseId: widget.courseId,
// //         lessonId: widget.lessonId);
// //
// //     if (response != null && response.statusCode == 200) {
// //       setState(() {
// //         _isAuthorized = true;
// //         _playVideo(widget.videoLink);
// //       });
// //     } else {
// //       setState(() {
// //         _isAuthorized = false;
// //         _isLoading = false;
// //       });
// //     }
// //   }
// //
// //   @override
// //   void dispose() {
// //     _debugPrintDatabaseRecordsOnClose();
// //     player.stop();
// //     player.dispose();
// //     //
// //     _backgroundTimer.cancel();
// //     _apiTimer.cancel(); // Stop the API timer when disposing
// //     positionSubscription.cancel();
// //     super.dispose();
// //   }
// //
// //   void _setVideoTrack(VideoTrack track) {
// //     player.setVideoTrack(track);
// //     setState(() {
// //       selectedVideoTrack = track;
// //     });
// //   }
// //
// //   Future<void> _debugPrintDatabaseRecordsOnClose() async {
// //     final allVideos = await _videoService.getAllVideos();
// //     for (var video in allVideos) {
// //       debugPrint(
// //           "[Closing App] READ FROM DB || Video_id: ${video.videoId}, Total Time: ${video.totalTime} minute(s), Watched Time: ${video.watchTime} minute(s), unit: ${video.unitName}, lesson: ${video.lessonName}, encryptedData: ${video.encryptedData}");
// //     }
// //
// //     // Send final data before closing
// //     _needsApiUpdate = true;
// //     await _sendVideoDataToApi();
// //   }
// //
// //   void _showQualityBanner(BuildContext context) {
// //     showDialog(
// //       context: context,
// //       barrierDismissible: true,
// //       builder: (BuildContext context) {
// //         return QualitySpeedSelector(
// //           videoTracks: videoTracks, // video tracks
// //           selectedVideoTrack: selectedVideoTrack, //current vid track
// //           onQualityChanged: (VideoTrack newQuality) {
// //             // setState(() {
// //             //   currentQuality = newQuality;
// //             // });
// //             // _playVideo(newQuality);
// //             _setVideoTrack(newQuality);
// //           },
// //           currentSpeed: currentSpeed,
// //           onSpeedChanged: (double newSpeed) {
// //             _changePlaybackSpeed(newSpeed);
// //           },
// //           isFullScreen: isFullScreen,
// //         );
// //       },
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Directionality(
// //       textDirection: AppConstants.textDirection,
// //       child: Scaffold(
// //         appBar: SecondAppBar(
// //           text: widget.lessonName != '' ? widget.lessonName : 'Player',
// //         ),
// //         body: widget.videoLink.isEmpty
// //             ? const PlaceholderContent(
// //                 message: 'افتح الفيديو من منصة المستر وهيشتغل هنا ^_^ ...',
// //                 imagePath: 'assets/icon/video_placeholder.png',
// //               )
// //             : _isLoading
// //                 ? const Center(
// //                     child: CircularProgressIndicator(),
// //                   )
// //                 : _isAuthorized
// //                     ? Center(
// //                         child: MaterialVideoControlsTheme(
// //                           normal: buildVideoControlsTheme(
// //                             onSettingsPressed: () =>
// //                                 _showQualityBanner(context),
// //                           ),
// //                           fullscreen: buildVideoControlsTheme(
// //                             onSettingsPressed: () =>
// //                                 _showQualityBanner(context),
// //                           ),
// //                           child: SafeArea(
// //                             child: Scaffold(
// //                               body: Video(
// //                                 controller: controller,
// //                                 wakelock: true,
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       )
// //                     : const PlaceholderContent(
// //                         message: 'برجاء التأكد ان الاشتراك مظبوط هنا ^_* ...',
// //                         imagePath: 'assets/icon/unauthorized.png',
// //                       ),
// //       ),
// //     );
// //   }
// // }
//
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:media_kit/media_kit.dart';
// import 'package:media_kit_video/media_kit_video.dart';
// import '../../core/utils/constants/app_colors.dart';
// import '../../core/utils/constants/app_constants.dart';
// import '../../core/utils/shared/second_appbar.dart';
// import '../../services/api_service.dart';
// import '../../services/video_service.dart';
// import '../../widgets/placeholder_content.dart';
// import '../material_vide_controls_theme_data.dart';
//
//
// class VideoPlayerScreen extends StatefulWidget {
//   final String videoLink;
//   final String lessonName;
//   final String unitName;
//   final String videoId;
//   final String token;
//   final String lessonId;
//   final String courseId;
//   final String encryptededData;
//   final String studentId;
//
//   const VideoPlayerScreen({
//     super.key,
//     required this.videoLink,
//     required this.lessonName,
//     required this.encryptededData,
//     required this.unitName,
//     required this.videoId,
//     required this.token,
//     required this.lessonId,
//     required this.courseId,
//     required this.studentId,
//   });
//
//   @override
//   State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
// }
//
// class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
//   late final Player player;
//   late final VideoController controller;
//   late final VideoService _videoService;
//   late final ApiService _apiService;
//
//   List<VideoTrack> videoTracks = [];
//   VideoTrack? selectedVideoTrack;
//   double currentSpeed = 1.0;
//   bool isFullScreen = false;
//   bool _isLoading = true;
//   bool _isAuthorized = false;
//   double _effectivePlayedTime = 0.0;
//   double _videoTotalDuration = 0.0;
//   int _lastMinuteLogged = 0;
//   bool _needsApiUpdate = false;
//   Timer? _progressTimer;
//   Timer? _apiUpdateTimer;
//
//   @override
//   void initState() {
//     super.initState();
//     player = Player();
//     controller = VideoController(player);
//     _videoService = VideoService();
//     _apiService = ApiService(baseUrl: AppConstants.baseUrl);
//     _authorizeAndInitialize();
//   }
//
//   Future<void> _authorizeAndInitialize() async {
//     try {
//       final response = await _apiService.auth(
//         endpoint: 'dashboard/app/app-validation-data',
//         authToken: widget.token,
//         courseId: widget.courseId,
//         lessonId: widget.lessonId,
//       );
//
//       if (response != null && response.statusCode == 200) {
//         setState(() => _isAuthorized = true);
//         await _initializePlayer();
//         _setupTracking();
//       } else {
//         setState(() {
//           _isAuthorized = false;
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       debugPrint('Authorization error: $e');
//       setState(() {
//         _isAuthorized = false;
//         _isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _initializePlayer() async {
//     try {
//       await player.open(Media(widget.videoLink), play: true);
//
//       // Track listeners
//       player.stream.tracks.listen((tracks) {
//         setState(() {
//           videoTracks = tracks.video;
//           if (videoTracks.isNotEmpty && selectedVideoTrack == null) {
//             selectedVideoTrack = videoTracks[0];
//           }
//         });
//       });
//
//       // Duration listener
//       player.stream.duration.listen((duration) {
//         _videoTotalDuration = duration.inSeconds.toDouble();
//         _videoService.addOrUpdateVideo(
//           videoId: widget.videoId,
//           totalTimeInSeconds: _videoTotalDuration,
//           encryptedData: widget.encryptededData,
//           lessonName: widget.lessonName,
//           unitName: widget.unitName,
//         );
//       });
//
//       // Playback speed listener
//       player.stream.rate.listen((speed) {
//         setState(() => currentSpeed = speed);
//       });
//
//       setState(() => _isLoading = false);
//     } catch (e) {
//       debugPrint('Player initialization error: $e');
//       setState(() => _isLoading = false);
//     }
//   }
//
//   void _setupTracking() {
//     // Track progress every second
//     _progressTimer = Timer.periodic(
//       const Duration(seconds: 1),
//           (timer) {
//         if (player.state.playing) {
//           _effectivePlayedTime += currentSpeed;
//           if (_effectivePlayedTime ~/ 60 > _lastMinuteLogged) {
//             _lastMinuteLogged = _effectivePlayedTime ~/ 60;
//             _needsApiUpdate = true;
//           }
//         }
//       },
//     );
//
//     // Send updates to API periodically
//     _apiUpdateTimer = Timer.periodic(
//       const Duration(minutes: 1),
//           (_) => _sendProgressToApi(),
//     );
//   }
//
//   Future<void> _sendProgressToApi() async {
//     if (!_needsApiUpdate) return;
//
//     try {
//       final response = await _apiService.postRequest(
//         endpoint: 'view/views-progress',
//         authToken: widget.token,
//         data: {
//           'lesson_id': widget.lessonId,
//           'time_second': "${(_lastMinuteLogged * 60).toInt()}",
//           'duration_second': "${_videoTotalDuration.toInt()}",
//         },
//       );
//
//       if (response != null && response.statusCode == 200) {
//         _needsApiUpdate = false;
//       }
//     } catch (e) {
//       debugPrint('Error sending progress to API: $e');
//     }
//   }
//
//   void _setVideoTrack(VideoTrack track) {
//     player.setVideoTrack(track);
//     setState(() => selectedVideoTrack = track);
//   }
//
//   void _changePlaybackSpeed(double speed) {
//     player.setRate(speed);
//     setState(() => currentSpeed = speed);
//   }
//
//   void _showQualitySpeedSelector() {
//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (context) => Dialog(
//         backgroundColor: Colors.transparent,
//         child: Material(
//           color: Colors.black.withOpacity(0.9),
//           borderRadius: BorderRadius.circular(12),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Quality Selection
//                 const Text(
//                   'Video Quality',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Wrap(
//                   spacing: 8,
//                   runSpacing: 8,
//                   children: videoTracks.map((track) {
//                     final isSelected = track == selectedVideoTrack;
//                     return GestureDetector(
//                       onTap: () {
//                         _setVideoTrack(track);
//                         Navigator.pop(context);
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 8,
//                         ),
//                         decoration: BoxDecoration(
//                           color: isSelected ? AppColors.turquoise : Colors.transparent,
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(color: Colors.white),
//                         ),
//                         child: Text(
//                           _getQualityLabel(track),
//                           style: TextStyle(
//                             color: isSelected ? Colors.black : Colors.white,
//                           ),
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//
//                 // Speed Selection
//                 const SizedBox(height: 24),
//                 const Text(
//                   'Playback Speed',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Wrap(
//                   spacing: 8,
//                   runSpacing: 8,
//                   children: [0.5, 1.0, 1.5, 2.0].map((speed) {
//                     final isSelected = speed == currentSpeed;
//                     return GestureDetector(
//                       onTap: () {
//                         _changePlaybackSpeed(speed);
//                         Navigator.pop(context);
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 8,
//                         ),
//                         decoration: BoxDecoration(
//                           color: isSelected ? AppColors.turquoise : Colors.transparent,
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(color: Colors.white),
//                         ),
//                         child: Text(
//                           '${speed}x',
//                           style: TextStyle(
//                             color: isSelected ? Colors.black : Colors.white,
//                           ),
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   String _getQualityLabel(VideoTrack track) {
//     final width = track.w ?? 0;
//     if (width >= 3840) return '4K';
//     if (width >= 1920) return '1080p';
//     if (width >= 1280) return '720p';
//     if (width >= 854) return '480p';
//     if (width >= 640) return '360p';
//     return '${track.h}p';
//   }
//
//   @override
//   void dispose() {
//     _progressTimer?.cancel();
//     _apiUpdateTimer?.cancel();
//     _sendProgressToApi(); // Final progress update
//     player.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (widget.videoLink.isEmpty) {
//       return const PlaceholderContent(
//         message: 'افتح الفيديو من منصة المستر وهيشتغل هنا ^_^ ...',
//         imagePath: 'assets/icon/video_placeholder.png',
//       );
//     }
//
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     if (!_isAuthorized) {
//       return const PlaceholderContent(
//         message: 'برجاء التأكد ان الاشتراك مظبوط هنا ^_* ...',
//         imagePath: 'assets/icon/unauthorized.png',
//       );
//     }
//
//     return Directionality(
//       textDirection: AppConstants.textDirection,
//       child: Scaffold(
//         appBar: SecondAppBar(text: widget.lessonName),
//         body: Center(
//           child: MaterialVideoControlsTheme(
//             normal: buildVideoControlsTheme(
//               onSettingsPressed: _showQualitySpeedSelector,
//             ),
//             fullscreen: buildVideoControlsTheme(
//               onSettingsPressed: _showQualitySpeedSelector,
//             ),
//             child: Video(
//               controller: controller,
//               wakelock: true,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../core/utils/constants/app_colors.dart';
import '../../core/utils/constants/app_constants.dart';
import '../../core/utils/shared/second_appbar.dart';
import '../../services/api_service.dart';
import '../../services/video_service.dart';
import '../../widgets/placeholder_content.dart';
import '../material_vide_controls_theme_data.dart';
import '../../core/utils/shared/base_url_singlton.dart';

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
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final Player player;
  late final VideoController controller;
  late final VideoService _videoService;
  late final ApiService _apiService;

  List<VideoTrack> videoTracks = [];
  VideoTrack? selectedVideoTrack;
  double currentSpeed = 1.0;
  bool isFullScreen = false;
  bool _isLoading = true;
  bool _isAuthorized = false;
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
      final response = await _apiService.auth(
        endpoint: 'dashboard/app/app-validation-data',
        authToken: widget.token,
        courseId: widget.courseId,
        lessonId: widget.lessonId,
      );

      if (response != null && response.statusCode == 200) {
        setState(() => _isAuthorized = true);
        await _initializePlayer();
        _setupTracking();
      } else {
        setState(() {
          _isAuthorized = false;
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

  Future<void> _initializePlayer() async {
    try {
      await player.open(Media(widget.videoLink), play: true);

      player.stream.tracks.listen((tracks) {
        setState(() {
          videoTracks = tracks.video;
          if (validVideoTracks.isNotEmpty && selectedVideoTrack == null) {
            selectedVideoTrack = validVideoTracks[0];
          }
        });
      });

      player.stream.duration.listen((duration) {
        _videoTotalDuration = duration.inSeconds.toDouble();
        if (_videoTotalDuration > 0) {
          _videoService.addOrUpdateVideo(
              videoId: widget.videoId,
              totalTimeInSeconds: _videoTotalDuration,
              encryptedData: widget.encryptededData,
              lessonName: widget.lessonName,
              unitName: widget.unitName,
              platformName: widget.platformName);
        }
      });

      player.stream.rate.listen((speed) {
        setState(() => currentSpeed = speed);
      });

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Player initialization error: $e');
      setState(() => _isLoading = false);
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

    _apiUpdateTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _sendProgressToApi(),
    );
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
        },
      );

      if (response != null && response.statusCode == 200) {
        _needsApiUpdate = false;
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
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAuthorized) {
      return Scaffold(
        appBar: SecondAppBar(text: 'Player'),
        body: const PlaceholderContent(
          message: 'انتهت مشاهدات الكورس الرجاء اعادة الإشتراك ^_* ...',
          imagePath: 'assets/icon/unauthorized.png',
        ),
      );
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
              const Center(
                child: CircularProgressIndicator(
                  color: AppColors.turquoise,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
