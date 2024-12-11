import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Use sqflite_ffi for desktop platforms
      sqfliteFfiInit();
      final dbFactory = databaseFactoryFfi;
      final dbPath = await _getDatabasePath();
      return await dbFactory.openDatabase(dbPath, options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE videos(
              video_id TEXT PRIMARY KEY,
              total_time REAL,
              watch_time REAL,
              unit_name TEXT,
              lesson_name TEXT,
              encrypted_data TEXT
            )
          ''');
        },
      ));
    } else {
      // Use sqflite for mobile platforms
      final dbPath = await getDatabasesPath();
      return await openDatabase(
        join(dbPath, 'video_app.db'),
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE videos(
              video_id TEXT PRIMARY KEY,
              total_time REAL,
              watch_time REAL,
              unit_name TEXT,
              lesson_name TEXT,
              encrypted_data TEXT
            )
          ''');
        },
      );
    }
  }

  Future<String> _getDatabasePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return join(directory.path, 'video_app.db');
  }
}
