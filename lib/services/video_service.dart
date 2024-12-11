// video_service.dart
import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';
import '../models/video_data.dart';
import 'package:flutter/foundation.dart';

class VideoService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> addOrUpdateVideo({
    required String videoId,
    required double totalTimeInSeconds,
    required String unitName,
    required String lessonName,
    required String encryptedData,
  }) async {
    final db = await _dbHelper.database;
    final totalTimeInMinutes = totalTimeInSeconds / 60;
    if (kDebugMode) {
      print("saving: 'video_id'$videoId, 'total_time': $totalTimeInMinutes");
    }
    await db.insert(
      'videos',
      {
        'video_id': videoId,
        'total_time': totalTimeInMinutes,
        'watch_time': 0.0,
        'unit_name': unitName,
        'lesson_name': lessonName,
        'encrypted_data': encryptedData,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Future<void> updateWatchTime(
  //     String videoId, double watchTimeInSeconds) async {
  //   final db = await _dbHelper.database;
  //   final watchTimeInMinutes = watchTimeInSeconds / 60; // Convert to minutes
  //
  //   await db.rawUpdate(
  //     'UPDATE videos SET watch_time = watch_time + ? WHERE video_id = ?',
  //     [watchTimeInMinutes, videoId],
  //   );
  // }

  // Method to retrieve all videos

  Future<List<VideoData>> getAllVideos() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('videos');
    return List.generate(maps.length, (i) {
      return VideoData.fromMap(maps[i]);
    });
  }

  // Method to retrieve a single video by ID
  Future<VideoData?> getVideoById(String videoId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'videos',
      where: 'video_id = ?',
      whereArgs: [videoId],
    );

    if (maps.isNotEmpty) {
      return VideoData.fromMap(maps.first);
    }
    return null;
  }
}
