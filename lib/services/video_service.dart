import 'package:sqflite/sqflite.dart';
import '../models/platform_data_model.dart';
import 'database_helper.dart';
import '../models/video_data.dart'; // Assuming you have a VideoData model
import 'package:flutter/foundation.dart';

class VideoService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Methods for interacting with the 'videos' table
  Future<void> addOrUpdateVideo({
    required String videoId,
    required double totalTimeInSeconds,
    required String unitName,
    required String lessonName,
    required String encryptedData,
    required String platformName,
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
        'platform_name': platformName,
        'lesson_name': lessonName,
        'encrypted_data': encryptedData,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<VideoData>> getAllVideos() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('videos');
    return List.generate(maps.length, (i) {
      return VideoData.fromMap(maps[i]);
    });
  }

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

  // Methods for interacting with the 'platforms' table

  /// Adds or updates a platform in the 'platforms' table.
  Future<void> addOrUpdatePlatform({
    required String platformName,
    required String platformBaseUrl,
    required String token,
  }) async {
    final db = await _dbHelper.database;
    await db.insert(
      'platforms',
      {
        'platform_name': platformName,
        'platform_base_url': platformBaseUrl,
        'token': token
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Fetch videos by platform name
  Future<List<VideoData>> getVideosByPlatform(String platformName) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'videos',
      where: 'platform_name = ?',
      whereArgs: [platformName],
    );
    return List.generate(maps.length, (i) {
      return VideoData.fromMap(maps[i]);
    });
  }

  /// Retrieves all platforms from the 'platforms' table.
  Future<List<PlatformData>> getAllPlatforms() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('platforms');
    return List.generate(maps.length, (i) {
      return PlatformData.fromMap(maps[i]);
    });
  }

  /// Retrieves a platform by its name from the 'platforms' table.
  Future<PlatformData?> getPlatformByName(String platformName) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'platforms',
      where: 'platform_name = ?',
      whereArgs: [platformName],
    );

    if (maps.isNotEmpty) {
      return PlatformData.fromMap(maps.first);
    }
    return null;
  }
}
