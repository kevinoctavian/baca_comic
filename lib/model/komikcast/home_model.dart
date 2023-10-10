enum ComicType { all, manga, manhwa, manhua }

class UpdateChapter {
  final String id;
  final String chapter;
  final String updateAt;

  UpdateChapter(this.id, this.chapter, this.updateAt);
}

class UtaFormat {
  final String id;
  final String image;
  final String idManga;
  final String title;

  final bool isHot;
  final ComicType type;
  final List<UpdateChapter> updateChapter;

  UtaFormat(this.id, this.image, this.idManga, this.title, this.isHot,
      this.type, this.updateChapter);

  @override
  String toString() {
    List<String> chap = updateChapter
        .map((e) => '${e.id}, ${e.chapter.trim()} ${e.updateAt}')
        .toList();

    return '''
id            : $id
image         : $image
idManga       : $idManga
title         : $title
isHot         : $isHot
type          : $type
updateChapter : $chap
''';
  }
}

class ListUpdateFormat {
  final String id;
  final String image;
  final String title;
  final String totalChapter;
  final ComicType type;
  final bool isComplete;

  ListUpdateFormat(this.id, this.image, this.title, this.totalChapter,
      this.type, this.isComplete);

  @override
  String toString() {
    return '''
id           : $id
title        : $title
image        : $image
type         : $type
totalChapter : $totalChapter
''';
  }
}

class KomikHomeModel {
  final List<ListUpdateFormat> hotKomik;
  final List<UtaFormat> projectUpdates;
  final List<UtaFormat> rilisanBaru;

  KomikHomeModel(this.hotKomik, this.projectUpdates, this.rilisanBaru);

  @override
  String toString() {
    return '''
hotKomik       : ${hotKomik[0]}
projectUpdates : ${projectUpdates[0]}
rilisanBaru    : ${rilisanBaru[0]}
''';
  }
}

class MangaInfo {
  final String id;
  final String title;
  final String altTitle;
  final String image;
  final String sinopsis;
  final double rating;

  final List<String> info;
  final List<String> genres;
  final List<UpdateChapter> chapters;

  MangaInfo(this.id, this.title, this.altTitle, this.image, this.sinopsis,
      this.rating, this.info, this.genres, this.chapters);

  @override
  String toString() {
    return '''
title        : $title
altTitle     : $altTitle
image        : $image
rating       : $rating
genres       : $genres
totalChapter : ${chapters.length}
info         : $info
sinopsis     : $sinopsis
''';
  }
}
