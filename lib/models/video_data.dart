// models/video_data.dart

class VideoData {
  final String videoId;
  final double totalTime;
  final double watchTime;
  final String unitName;
  final String lessonName;
  final String encryptedData;

  VideoData({
    required this.videoId,
    required this.totalTime,
    required this.watchTime,
    required this.unitName,
    required this.lessonName,
    required this.encryptedData,
  });

  factory VideoData.fromMap(Map<String, dynamic> map) {
    return VideoData(
      videoId: map['video_id'],
      totalTime: map['total_time'],
      watchTime: map['watch_time'],
      unitName: map['unit_name'],
      lessonName: map['lesson_name'],
      encryptedData: map['encrypted_data'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'video_id': videoId,
      'total_time': totalTime,
      'watch_time': watchTime,
      'unit_name': unitName,
      'lesson_name': lessonName,
      'encrypted_data': encryptedData,
    };
  }
}
