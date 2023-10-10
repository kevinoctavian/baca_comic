import 'chapter_field.dart';

class History {
  final int? id;
  final String komikId;
  final String title;
  final String image;
  int? lastChapter;

  ChapterField chapterField;

  static String tableName = 'history';
  static String idField = '_id';
  static String komikIdField = 'komikId';
  static String titleField = 'title';
  static String imageField = 'image';
  static String lastChapterField = 'lastChapter';

  History(this.id, this.komikId, this.title, this.image, this.lastChapter,
      this.chapterField);

  Map<String, dynamic> toJson() => {
        idField: id,
        komikIdField: komikId,
        titleField: title,
        imageField: image,
        lastChapterField: lastChapter
      };

  static History fromJson(Map<String, dynamic> json) => History(
        json[idField],
        json[komikIdField],
        json[titleField],
        json[imageField],
        json[lastChapterField],
        ChapterField.fromJson(json),
      );

  @override
  String toString() {
    return '''
id: $id
komikId: $komikId
title: $title
image: $image
lastChapter: $lastChapter
chapterField.chapterId: ${chapterField.chapterId}
chapterField.chapterTitle: ${chapterField.title}
''';
  }
}
