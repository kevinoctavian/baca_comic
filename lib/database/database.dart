import 'package:sqflite/sqflite.dart';

import '../model/db/chapter_field.dart';
import '../model/db/chapter_readed.dart';
import '../model/db/history_model.dart';

import 'chapter_readed_database.dart';
import 'history_database.dart';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart';

class DatabaseManager {
  static DatabaseManager instance = DatabaseManager._init();

  static Database? _database;

  Future<Database> get database async {
    if (_database == null) {
      _database = await _initDb();
      return _database!;
    }

    return _database!;
  }

  final ChapterReadedDatabase chapterReadedDatabase = ChapterReadedDatabase();
  final HistoryDatabase historyDatabase = HistoryDatabase();

  DatabaseManager._init();

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();

    return await openDatabase(join(dbPath, 'bacakomik.db'),
        version: 1, onCreate: _onCreate, onOpen: _onCreate);
  }

  Future<void> _onCreate(Database db, [int version = 1]) async {
    print('Create table history');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS ${ChapterField.tableName} (
      ${ChapterField.idField} INTEGER PRIMARY KEY AUTOINCREMENT, 
      ${ChapterField.komikIdField} TEXT NOT NULL, 
      ${ChapterField.titleField} TEXT NOT NULL, 
      ${ChapterField.chapterIdField} TEXT NOT NULL UNIQUE 
    )
    ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS ${History.tableName} (
      ${History.idField} INTEGER PRIMARY KEY AUTOINCREMENT, 
      ${History.komikIdField} TEXT NOT NULL UNIQUE, 
      ${History.titleField} TEXT NOT NULL, 
      ${History.imageField} TEXT NOT NULL, 
      ${History.lastChapterField} INTEGER NOT NULL, 
      FOREIGN KEY (${History.lastChapterField}) REFERENCES ${ChapterField.tableName}(${ChapterField.idField})
        ON DELETE CASCADE ON UPDATE CASCADE
    )
    ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS ${ChapterReaded.tableName} (
      ${ChapterReaded.idField} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${ChapterReaded.komikIdField} INTEGER NOT NULL,
      ${ChapterReaded.chapterIdField} TEXT NOT NULL UNIQUE,
      FOREIGN KEY (${ChapterReaded.komikIdField}) REFERENCES ${History.tableName}(${History.komikIdField})
        ON DELETE CASCADE ON UPDATE CASCADE
    )
    ''');
  }

  Future<void> close() async {
    var db = await instance.database;

    db.close();
    _database = null;
  }
}
