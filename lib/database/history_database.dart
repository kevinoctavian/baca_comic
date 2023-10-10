import 'package:baca_komik/database/database.dart';
import 'package:sqflite/sqflite.dart';

import 'package:baca_komik/model/db/chapter_field.dart';
import 'package:baca_komik/model/db/history_model.dart';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart';

class HistoryDatabase {
  Future<int> insert(History history, ChapterField chapterField) async {
    final db = await DatabaseManager.instance.database;

    // getting the chapterfield
    final chapterRow = await db.rawQuery(
      '''
      SELECT _id FROM ${ChapterField.tableName} 
      WHERE ${ChapterField.komikIdField} = ?
      ''',
      [history.komikId],
    );

    // ignore: non_constant_identifier_names
    int chapter_id = 0;
    if (chapterRow.isEmpty) {
      chapter_id =
          await db.insert(ChapterField.tableName, chapterField.toJson());
    } else {
      chapter_id = await db.update(
        ChapterField.tableName,
        {
          ChapterField.chapterIdField: chapterField.chapterId,
          ChapterField.titleField: chapterField.title,
        },
        where: '_id = ?',
        whereArgs: [chapterRow.first['_id']],
      );
    }

    if (chapter_id != 0) {
      history.lastChapter = chapter_id;

      var histry = await db.rawQuery(
        '''
        SELECT _id FROM ${History.tableName} 
        WHERE ${History.komikIdField} = ?
        ''',
        [history.komikId],
      );

      if (histry.isEmpty) {
        chapter_id = await db.insert(
          History.tableName,
          history.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } else {
        chapter_id = await db.update(
          History.tableName,
          {History.lastChapterField: history.lastChapter},
          where: '_id = ?',
          whereArgs: [history.komikId],
        );
      }
    }

    return chapter_id;
  }

  Future<List<History>> get() async {
    final db = await DatabaseManager.instance.database;

    String q = '''
      SELECT * FROM ${History.tableName}
      INNER JOIN ${ChapterField.tableName} 
      ON ${History.tableName}.${History.lastChapterField} = ${ChapterField.tableName}.${ChapterField.idField}
      ''';

    final query = await db.rawQuery(q);

    print(query);

    return List.generate(query.length, (i) => History.fromJson(query[i]));
  }

  Future close() async {
    await DatabaseManager.instance.close();
  }

  Future deleteDb() async {
    final dbPath = await getDatabasesPath();

    await deleteDatabase(join(dbPath, 'bacakomik.db'));
    close();
  }
}
