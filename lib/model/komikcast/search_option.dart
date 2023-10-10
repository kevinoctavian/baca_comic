import 'home_model.dart';

class SearchOption {
  final List<GenresEnum?> _genres;
  final StatusEnum status;
  final SortByEnum sortby;
  final ComicType type;

  SearchOption(this._genres,
      {this.sortby = SortByEnum.titleasc,
      this.type = ComicType.all,
      this.status = StatusEnum.all});

  String parse() {
    String query = '';

    for (var genre in _genres) {
      if (genre == null) continue;
      String gnr = fixGenre(genre);
      query += 'genre%5B%5D=$gnr&';
    }

    query += 'status=${status != StatusEnum.all ? status.name : ''}&';
    query += 'type=${type != ComicType.all ? type.name : ''}&';
    query += 'orderby=${sortby.name}';

    return '?$query';
  }

  static String fixGenre(GenresEnum genre) {
    if (genre == GenresEnum.fourKoma) return '4-koma';
    if (genre == GenresEnum.genderBender) return 'Gender-Bender';
    if (genre == GenresEnum.martialArts) return 'Martial-Arts';
    if (genre == GenresEnum.oneShot) return 'One-Shot';
    if (genre == GenresEnum.schoolLife) return 'School-Life';
    if (genre == GenresEnum.sciFi) return 'Sci-Fi';
    if (genre == GenresEnum.shoujoAi) return 'Shoujo-Ai';
    if (genre == GenresEnum.shounenAi) return 'Shounen-Ai';
    if (genre == GenresEnum.sliceofLife) return 'Slice-of-Life';
    if (genre == GenresEnum.superPower) return 'Super-Power';

    return capitalize(genre.name);
  }

  static String capitalize(String str) {
    return str[0].toUpperCase() + str.substring(1);
  }

  static String fixSortBy(SortByEnum sortByEnum) {
    if (sortByEnum == SortByEnum.titleasc) return 'A-Z';
    if (sortByEnum == SortByEnum.titledesc) return 'Z-A';

    return capitalize(sortByEnum.name);
  }
}

enum StatusEnum { all, ongoing, completed }

enum SortByEnum { titleasc, titledesc, update, popular }

enum GenresEnum {
  fourKoma,
  action,
  adventure,
  comedy,
  cooking,
  demons,
  drama,
  ecchi,
  fantasy,
  game,
  genderBender,
  gore,
  harem,
  historical,
  horror,
  isekai,
  josei,
  magic,
  martialArts,
  mature,
  mecha,
  medical,
  military,
  music,
  mystery,
  oneShot,
  police,
  psychological,
  reincarnation,
  romance,
  school,
  schoolLife,
  sciFi,
  seinen,
  shoujo,
  shoujoAi,
  shounen,
  shounenAi,
  sliceofLife,
  sports,
  superPower,
  supernatural,
  thriller,
  tragedy,
  vampire,
  webtoons,
  yuri,
}
