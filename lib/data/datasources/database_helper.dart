import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Table names
  static const String userTable = 'users';
  static const String activityTable = 'activities';
  static const String journalTable = 'journals';

  // Singleton constructor
  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal() {
    // Initialize FFI for desktop platforms
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Initialize FFI
      sqfliteFfiInit();
      // Change the default factory
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'moveit.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE $userTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        xp INTEGER DEFAULT 0,
        level INTEGER DEFAULT 1,
        totalSportHours INTEGER DEFAULT 0
      )
    ''');

    // Create activities table
    await db.execute('''
      CREATE TABLE $activityTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        type TEXT NOT NULL,
        durationMinutes INTEGER NOT NULL,
        date TEXT NOT NULL,
        isCompleted INTEGER DEFAULT 0,
        userId INTEGER NOT NULL,
        FOREIGN KEY (userId) REFERENCES $userTable (id) ON DELETE CASCADE
      )
    ''');

    // Create journals table
    await db.execute('''
      CREATE TABLE $journalTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        activityId INTEGER NOT NULL,
        content TEXT NOT NULL,
        mood TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (activityId) REFERENCES $activityTable (id) ON DELETE CASCADE
      )
    ''');
  }

  // Generic insert method
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Generic update method
  Future<int> update(String table, Map<String, dynamic> data, String whereClause, List<dynamic> whereArgs) async {
    final db = await database;
    return await db.update(table, data, where: whereClause, whereArgs: whereArgs);
  }

  // Generic delete method
  Future<int> delete(String table, String whereClause, List<dynamic> whereArgs) async {
    final db = await database;
    return await db.delete(table, where: whereClause, whereArgs: whereArgs);
  }

  // Generic query method
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? whereClause,
    List<dynamic>? whereArgs,
    String? orderBy,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }

  // Generic raw query method
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }
}
