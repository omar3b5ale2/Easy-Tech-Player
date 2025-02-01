import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;
  static const int _databaseVersion = 2;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      final dbFactory = databaseFactoryFfi;
      final dbPath = await _getDatabasePath();
      return await dbFactory.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: _databaseVersion,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
        ),
      );
    } else {
      final dbPath = await getDatabasesPath();
      return await openDatabase(
        join(dbPath, 'video_app.db'),
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE videos(
        video_id TEXT PRIMARY KEY,
        total_time REAL,
        watch_time REAL,
        unit_name TEXT,
        lesson_name TEXT,
        platform_name TEXT,
        encrypted_data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE platforms(
        platform_name TEXT PRIMARY KEY,
        platform_base_url TEXT,
        token TEXT
      )
    ''');

    await _setDatabaseVersion(db, _databaseVersion);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Migrating database from v$oldVersion to v$newVersion');

    if (oldVersion < 2) {
      await _migrateV1ToV2(db);
    }
  }

  Future<void> _migrateV1ToV2(Database db) async {
    // Add platforms table
    if (!await _tableExists(db, 'platforms')) {
      await db.execute('''
        CREATE TABLE platforms(
          platform_name TEXT PRIMARY KEY,
          platform_base_url TEXT,
          token TEXT
        )
      ''');
    }

    // Add platform_name column if not exists
    if (!await _columnExists(db, 'videos', 'platform_name')) {
      await db.execute('ALTER TABLE videos ADD COLUMN platform_name TEXT');
    }

    await _setDatabaseVersion(db, 2);
  }

  Future<bool> _tableExists(Database db, String tableName) async {
    final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'"
    );
    return result.isNotEmpty;
  }

  Future<bool> _columnExists(Database db, String table, String column) async {
    final result = await db.rawQuery('PRAGMA table_info($table)');
    return result.any((row) => row['name'] == column);
  }

  Future<void> _setDatabaseVersion(Database db, int version) async {
    await db.execute('PRAGMA user_version = $version');
  }

  // Public methods for debugging
  Future<int> getCurrentVersion() async {
    final db = await database;
    final result = await db.rawQuery('PRAGMA user_version');
    print(result.first['user_version']);
    return result.first['user_version'] as int;
  }

  Future<Map<String, dynamic>> inspectSchema() async {
    final db = await database;
    final tables = await db.rawQuery('''
      SELECT name, sql 
      FROM sqlite_master 
      WHERE type='table' AND name NOT LIKE 'sqlite_%'
    ''');

    final schema = <String, dynamic>{};
    for (final table in tables) {
      final tableName = table['name'] as String;
      schema[tableName] = {
        'schema': table['sql'],
        'columns': await db.rawQuery('PRAGMA table_info($tableName)')
      };
    }
    return schema;
  }

  Future<String> _getDatabasePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return join(directory.path, 'video_app.db');
  }
}