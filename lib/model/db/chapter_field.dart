class ChapterField {
  static String tableName = 'chapter';

  final int? id;
  final String komikId;
  final String chapterId;
  final String title;

  static String idField = '_id';
  static String komikIdField = 'komik_id';
  static String chapterIdField = 'chapterId';
  static String titleField = 'chapterTitle';

  ChapterField(this.id, this.komikId, this.chapterId, this.title);

  Map<String, dynamic> toJson() => {
        idField: id,
        komikIdField: komikId,
        titleField: title,
        chapterIdField: chapterId,
      };

  static ChapterField fromJson(Map<String, dynamic> json) => ChapterField(
        json[idField],
        json[komikIdField],
        json[chapterIdField],
        json[titleField],
      );
}
