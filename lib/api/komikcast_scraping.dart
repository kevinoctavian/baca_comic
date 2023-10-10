import 'package:baca_komik/model/model.dart';
import 'package:html/dom.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

export 'package:baca_komik/model/model.dart';

class KomikcastScraping {
  final String baseUrl;

  KomikcastScraping({this.baseUrl = "https://komikcast.io/"});

  Future<String> _request(String path) async {
    var res = await http.get(Uri.parse("$baseUrl$path"));
    // print(_clearLink("$baseUrl$path"));
    // print("$baseUrl$path");
    return res.body;
  }

  String _clearLink(String link) {
    link = link.replaceAll(RegExp(r'(\/+$|\/+\s+)'), '');

    Uri url = Uri.parse(link);
    List<String> paths = url.path.split('/');

    return paths.last;
  }

  Future<KomikHomeModel> home() async {
    String body = await _request('');

    List<ListUpdateFormat> hotKomik = [];
    List<UtaFormat> projectUpdates = [];
    List<UtaFormat> rilisanBaru = [];

    if (body.isNotEmpty) {
      var $ = parse(body);
      var bixbox = $.getElementsByClassName("bixbox");

      var hotKomik_ = bixbox[0].getElementsByClassName('swiper-slide');
      var projectUpdate_ = bixbox[1].getElementsByClassName("uta");
      var rilisanBaru_ = bixbox[2].getElementsByClassName("uta");

      for (var hot in hotKomik_) {
        var a = hot.getElementsByTagName('a').last;
        var img = a.getElementsByTagName('img')[0];
        var chapter = a.getElementsByClassName('chapter')[0];

        var komicType =
            a.getElementsByClassName('type')[0].text.trim().toLowerCase();
        ComicType type = ComicType.manga;
        switch (komicType) {
          case 'manhua':
            type = ComicType.manhua;
            break;
          case 'manhwa':
            type = ComicType.manhwa;
            break;
        }

        ListUpdateFormat hotFormat = ListUpdateFormat(
            _clearLink(a.attributes['href'] ?? ''),
            img.attributes['src'] ?? '',
            a.attributes['title'] ?? '',
            chapter.text
                .replaceAll(RegExp(r'(\t|\s)'), '')
                .replaceFirst('Ch.', 'Ch. '),
            type,
            false);

        //print(hotFormat);
        hotKomik.add(hotFormat);
      }

      for (var rilisan in rilisanBaru_) {
        var uta = _utaScraping(rilisan);
        rilisanBaru.add(uta);
      }

      for (var update in projectUpdate_) {
        var uta = _utaScraping(update);
        projectUpdates.add(uta);
      }
    }

    return KomikHomeModel(hotKomik, projectUpdates, rilisanBaru);
  }

  Future<List<String>> mangaRead(String id) async {
    String body = await _request('chapter/$id/');

    List<String> manga = [];

    if (body.isNotEmpty) {
      var $ = parse(body);

      var mainReading = $.getElementsByClassName('main-reading-area');

      if (mainReading.isNotEmpty) {
        for (var img in mainReading[0].getElementsByTagName('img')) {
          manga.add(img.attributes['src'] ?? '');
        }
      }
    }

    return manga;
  }

  Future<MangaInfo> mangaInfo(String id) async {
    String body = await _request('komik/$id');

    String title = '';
    String altTitle = '';
    String image = '';
    String sinopsis = '';
    double rating = 0.0;

    List<String> info = [];
    List<String> genres = [];
    List<UpdateChapter> chapters = [];

    if (body.isNotEmpty) {
      var $ = parse(body);

      var komikInfo = $.getElementsByClassName('komik_info-body')[0];

      title = komikInfo
          .getElementsByTagName('h1')[0]
          .text
          .replaceFirst(RegExp(r'(\s+$)'), '');
      altTitle = komikInfo
          .getElementsByClassName('komik_info-content-native')[0]
          .text
          .replaceFirst(RegExp(r'(\s+$)'), '');

      var imgTag = komikInfo.getElementsByTagName('img');
      image = imgTag.isNotEmpty ? imgTag[0].attributes['src'] ?? '' : '';
      sinopsis = komikInfo
          .getElementsByClassName('komik_info-description-sinopsis')[0]
          .text
          .replaceAll(RegExp(r'(^\s+|\s+$)'), '');

      try {
        rating = double.parse(komikInfo
                .getElementsByClassName('data-rating')[0]
                .attributes['data-ratingkomik'] ??
            '0.0');
      } catch (e) {
        try {
          rating = double.parse(parse(komikInfo
                      .getElementsByClassName('data-rating')[0]
                      .attributes['data-ratingkomik'])
                  .body
                  ?.text ??
              '0.0');
        } catch (e) {
          rating = 0.0;
        }
      }

      for (var genre in komikInfo.getElementsByClassName('genre-item')) {
        genres.add(genre.text.trim());
      }

      for (var inf in komikInfo
          .getElementsByClassName('komik_info-content-meta')[0]
          .children) {
        info.add(inf.text.replaceAll(RegExp(r'(\:\s+)'), ': '));
      }

      var chapterInfo = $.getElementsByClassName('komik_info-body')[1];

      for (var chp in chapterInfo.getElementsByTagName('li')) {
        var a = chp.getElementsByTagName('a')[0];
        chapters.add(UpdateChapter(
            _clearLink(a.attributes['href'] ?? ''),
            a.text
                .replaceAll(RegExp(r'(\t|\s)'), '')
                .replaceFirst('Chapter', 'Ch. '),
            chp.getElementsByTagName('div')[0].text));
      }
    }

    return MangaInfo(
        id, title, altTitle, image, sinopsis, rating, info, genres, chapters);
  }

  Future<List<ListUpdateFormat>> projectUpdate(int page) async {
    String body =
        await _request('project-list/${page > 1 ? 'page/$page/' : ''}');

    List<ListUpdateFormat> list = [];

    if (body.isNotEmpty) {
      var $ = parse(body);

      var listUpds_ = $.getElementsByClassName('list-update_item');

      for (var upds in listUpds_) {
        var luf = _lufScraping(upds);

        list.add(luf);
      }
    }

    return list;
  }

  Future<List<ListUpdateFormat>> popular(int page) async {
    return searchByOption(SearchOption([], sortby: SortByEnum.popular), page);
  }

  Future<List<ListUpdateFormat>> search(String query, int page) async {
    String body = await _request('${page > 1 ? 'page/$page/' : ''}?s=$query');

    List<ListUpdateFormat> list = [];

    if (body.isNotEmpty) {
      var $ = parse(body);

      var listUpds_ = $.getElementsByClassName('list-update_item');

      for (var upds in listUpds_) {
        var luf = _lufScraping(upds);

        list.add(luf);
      }
    }

    return list;
  }

  Future<List<ListUpdateFormat>> searchByOption(
      SearchOption option, int page) async {
    String body = await _request(
        'daftar-komik/${page > 1 ? 'page/$page/' : ''}${option.parse()}');

    List<ListUpdateFormat> list = [];

    if (body.isNotEmpty) {
      var $ = parse(body);

      var listUpds_ = $.getElementsByClassName('list-update_item');

      for (var upds in listUpds_) {
        var luf = _lufScraping(upds);

        list.add(luf);
      }
    }

    return list;
  }

  UtaFormat _utaScraping(Element elm) {
    var imgu = elm.getElementsByClassName('imgu')[0];
    var luf = elm.getElementsByClassName('luf')[0];

    var image = imgu.getElementsByTagName('img')[0].attributes['src'] ?? '';
    var idManga = imgu.getElementsByTagName('a')[0].attributes['rel'] ?? '';
    var id = imgu.getElementsByTagName('a')[0].attributes['href'] ?? '';
    var title = luf.getElementsByTagName('h3')[0].text;

    ComicType type = ComicType.manga;
    switch (luf.getElementsByTagName('ul')[0].className.toLowerCase()) {
      case 'manhua':
        type = ComicType.manhua;
        break;
      case 'manhwa':
        type = ComicType.manhwa;
        break;
    }

    bool isHot = imgu.getElementsByClassName('hot').isNotEmpty;

    List<UpdateChapter> updateChapters = [];
    for (var chp in luf.getElementsByTagName('li')) {
      var a = chp.getElementsByTagName('a')[0];
      updateChapters.add(UpdateChapter(
          _clearLink(a.attributes['href'] ?? ''),
          a.text
              .replaceAll(RegExp(r'(\t|\s)'), '')
              .replaceFirst('Chapter', 'Ch. '),
          chp.getElementsByTagName('span')[0].text));
    }

    return UtaFormat(
        _clearLink(id), image, idManga, title, isHot, type, updateChapters);
  }

  ListUpdateFormat _lufScraping(Element elm) {
    var a = elm.getElementsByTagName('a')[0];
    var image = elm.getElementsByClassName('list-update_item-image')[0];
    var info = elm.getElementsByClassName('list-update_item-info')[0];

    var id = a.attributes['href'];
    var img = image.getElementsByTagName('img')[0].attributes['src'];
    var title = info.getElementsByTagName('h3')[0].text;
    var chapter = info
        .getElementsByClassName('chapter')[0]
        .text
        .replaceAll(RegExp(r'(\t|\s)'), '')
        .replaceFirst('Ch.', 'Ch. ');

    ComicType type = ComicType.manga;
    switch (image.getElementsByClassName('type')[0].text.trim().toLowerCase()) {
      case 'manhua':
        type = ComicType.manhua;
        break;
      case 'manhwa':
        type = ComicType.manhwa;
        break;
    }

    return ListUpdateFormat(
        _clearLink(id ?? ''), img ?? '', title, chapter, type, false);
  }
}
