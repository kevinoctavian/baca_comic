class ChapterReaded {
  static String tableName = 'chapter_readed';

  final int? id;
  final String komikId;
  final String chapterId;

  static String idField = '_id';
  static String komikIdField = 'komikId';
  static String chapterIdField = 'chaperid';

  ChapterReaded(this.id, this.komikId, this.chapterId);

  Map<String, dynamic> toJson() => {
        idField: id,
        komikIdField: komikId,
        chapterIdField: chapterId,
      };

  static ChapterReaded fromJson(Map<String, dynamic> json) => ChapterReaded(
        json[idField],
        json[komikIdField],
        json[chapterIdField],
      );

  @override
  String toString() {
    return '''
id: $id
komikId: $komikId
title: $chapterId
''';
  }
}
