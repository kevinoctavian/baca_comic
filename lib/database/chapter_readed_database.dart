import 'package:baca_komik/model/db/chapter_readed.dart';

import 'package:sqflite/sqflite.dart';

import 'database.dart';

class ChapterReadedDatabase {
  Future<int> insert(ChapterReaded chapterReaded) async {
    final db = await DatabaseManager.instance.database;

    final id = await db.insert(
      ChapterReaded.tableName,
      chapterReaded.toJson(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    print('success save chapter');

    return id;
  }

  Future<List<ChapterReaded>> get(String id) async {
    final db = await DatabaseManager.instance.database;

    final query = await db.rawQuery(
      '''
      SELECT * FROM ${ChapterReaded.tableName}
      WHERE ${ChapterReaded.komikIdField} = ?
      ''',
      [id],
    );

    // print(query);

    return List.generate(query.length, (i) => ChapterReaded.fromJson(query[i]));
  }

  Future<int> delete(int? id) async {
    final db = await DatabaseManager.instance.database;

    if (id == null) return 0;

    final deletedId = await db.delete(
      ChapterReaded.tableName,
      where: '${ChapterReaded.idField} = ?',
      whereArgs: [id],
    );

    return deletedId;
  }

  Future close() async {
    await DatabaseManager.instance.close();
  }
}
