import 'package:baca_komik/color_constant.dart';
import 'package:baca_komik/database/database.dart';
import 'package:baca_komik/model/db/chapter_field.dart';
import 'package:baca_komik/model/db/chapter_readed.dart';
import 'package:baca_komik/model/db/history_model.dart';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import 'package:baca_komik/api/komikcast_scraping.dart';
import 'package:baca_komik/api/komik_downloader.dart';

class BacaKomikWidget extends StatefulWidget {
  const BacaKomikWidget(this.state, this.ctx, {super.key});

  final BuildContext ctx;
  final GoRouterState state;

  @override
  State<BacaKomikWidget> createState() => _BacaKomikWidgetState();
}

class _BacaKomikWidgetState extends State<BacaKomikWidget> {
  final KomikcastScraping _komikcast = KomikcastScraping();
  final ScrollController _scrollController = ScrollController();
  KomikDownloader? _komikDownloader;

  MangaInfo? _mangaInfo;
  String _mangaId = '';
  UpdateChapter? _komikChapter;
  int currentKomikId = 0;
  bool _isChanged = false;
  final List<String> _mangas = [];

  @override
  void initState() {
    super.initState();

    if (widget.state.extra! is UtaFormat) {
      _getKomikInfo((widget.state.extra! as UtaFormat).id);
    } else if (widget.state.extra! is MangaInfo) {
      _mangaInfo = widget.state.extra! as MangaInfo;
      _setKomik(widget.state.pathParameters['id']!);
      _getKomikImage();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  Future<void> _getKomikImage() async {
    var mangas = await _komikcast.mangaRead(_mangaId);

    await _setHistoryDb();

    setState(() {
      _mangas.clear();
      _mangas.addAll(mangas);
      _isChanged = false;

      _komikDownloader = KomikDownloader(widget.ctx,
          komikChapter: _komikChapter!.chapter, mangaInfo: _mangaInfo);
    });
  }

  void _getKomikInfo(String id) async {
    var komikInfo = await _komikcast.mangaInfo(id);

    _mangaInfo = komikInfo;
    _setKomik(widget.state.pathParameters['id']!);
    await _getKomikImage();
  }

  void _setKomik(String id, [UpdateChapter? chapObj]) {
    for (int i = 0; i < _mangaInfo!.chapters.length; i++) {
      if (id == _mangaInfo!.chapters[i].id) {
        currentKomikId = i;
      }
    }

    _mangaId = id;
    if (chapObj == null) {
      _komikChapter = _mangaInfo!.chapters[currentKomikId];
      return;
    }
    _komikChapter = chapObj;
  }

  Future<void> _setHistoryDb() async {
    var history = History(
      null,
      _mangaInfo!.id,
      _mangaInfo!.title,
      _mangaInfo!.image,
      0,
      ChapterField(null, '', '', ''),
    );

    await DatabaseManager.instance.historyDatabase.insert(
      history,
      ChapterField(
        null,
        history.komikId,
        _komikChapter?.id ?? '',
        _komikChapter?.chapter ?? '',
      ),
    );

    print('done save history');

    await DatabaseManager.instance.chapterReadedDatabase.insert(
      ChapterReaded(
        null,
        _mangaInfo!.id,
        _komikChapter!.id,
      ),
    );

    print('done save ChapterReaded');
  }

  // Future<Size> _getImageSize(Uint8List imageData) async {
  //   final imageProvider = MemoryImage(imageData);
  //   final completer = Completer<ImageInfo>();
  //   final imageStream = imageProvider.resolve(ImageConfiguration.empty);
  //   imageStream.addListener(ImageStreamListener(
  //     (image, synchronousCall) {
  //       completer.complete(image);
  //     },
  //   ));
  //   final imageInfo = await completer.future;

  //   return Size(
  //       imageInfo.image.width.toDouble(), imageInfo.image.height.toDouble());
  // }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _mangaInfo?.title ?? 'Baca Komik by Kevin',
        ),
      ),
      body: SizedBox.expand(
        child: Scrollbar(
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                if (_mangaInfo != null && _komikChapter != null)
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                      child: Text(
                        '${_mangaInfo!.title} (${_komikChapter!.chapter.replaceAll('Ch.', 'Chapter')})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  height: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Color(color1[1]),
                        ),
                        child: _createDropDown(),
                      ),
                      Container(
                        child: TextButton(
                          // onPressed: () {},
                          onPressed: () =>
                              _komikDownloader?.spawnThread(_mangas, true),
                          child: Text(
                            'download komik',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(color1[0]),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _crateNextPrefBtn(),
                const SizedBox(height: 15),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _mangas.length,
                  itemBuilder: (context, index) {
                    return CachedNetworkImage(
                      imageUrl: _mangas[index],
                      fit: BoxFit.contain,
                      progressIndicatorBuilder: (context, url, progress) =>
                          Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: Stack(
                          children: [
                            Image.asset('assets/images/placeholder.gif'),
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(
                                  color: Colors.purple,
                                  backgroundColor: Colors.white,
                                  value: progress.progress,
                                  strokeWidth: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      errorWidget: (context, url, error) => SizedBox(
                        width: size.width,
                        height: 100,
                        child: const SizedBox.expand(
                          child: Center(
                            child: Text('Image Error'),
                          ),
                        ),
                      ),
                      fadeInCurve: Curves.elasticIn,
                      fadeInDuration: const Duration(milliseconds: 750),
                    );
                  },
                ),
                const SizedBox(height: 25),
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Color(color1[1]),
                  ),
                  child: _createDropDown(),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: _crateNextPrefBtn(),
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _crateNextPrefBtn() {
    if (_mangaInfo == null) return Container();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            if (currentKomikId < _mangaInfo!.chapters.length - 1 &&
                !_isChanged) {
              _isChanged = true;
              _komikChapter = _mangaInfo!.chapters[++currentKomikId];
              _mangaId = _komikChapter?.id ?? _mangaId;
              _getKomikImage();
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.bounceInOut,
              );

              // DatabaseManager.instance.chapterReadedDatabase.insert(
              //   ChapterReaded(
              //     null,
              //     _mangaInfo!.id,
              //     _mangaId,
              //   ),
              // );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: currentKomikId >= _mangaInfo!.chapters.length - 1
                  ? Color(color1[0])
                  : Color(color1[1]),
            ),
            child: Text(
              'Prev Chapter',
              style: TextStyle(
                  color: currentKomikId >= _mangaInfo!.chapters.length - 1
                      ? Colors.white
                      : Color(color1[0]),
                  fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 15),
        InkWell(
          onTap: () {
            if (currentKomikId > 0 && !_isChanged) {
              _isChanged = true;
              _komikChapter = _mangaInfo!.chapters[--currentKomikId];
              _mangaId = _komikChapter?.id ?? _mangaId;
              _getKomikImage();
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.bounceInOut,
              );
              // DatabaseManager.instance.chapterReadedDatabase.insert(
              //   ChapterReaded(
              //     null,
              //     _mangaInfo!.id,
              //     _mangaId,
              //   ),
              // );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: currentKomikId == 0 ? Color(color1[0]) : Color(color1[1]),
            ),
            child: Text(
              'Next Chapter',
              style: TextStyle(
                  color: currentKomikId == 0 ? Colors.white : Color(color1[0]),
                  fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _createDropDown() {
    return DropdownButton(
      dropdownColor: Color(color1[3]),
      hint: Text(
        _komikChapter?.chapter ?? 'Loading...',
        style: TextStyle(
          fontSize: 16,
          color: Color(color1[0]),
        ),
      ),
      borderRadius: BorderRadius.circular(8),
      underline: Container(
        decoration:
            BoxDecoration(border: Border.all(color: Colors.transparent)),
      ),
      items: _mangaInfo?.chapters
              .map(
                (e) => DropdownMenuItem<UpdateChapter>(
                  enabled: e.id != _komikChapter!.id,
                  value: e,
                  onTap: () => _komikChapter = e,
                  child: Text(
                    e.chapter,
                    style: TextStyle(
                        color: e.id != _komikChapter!.id
                            ? Colors.white
                            : Colors.grey),
                  ),
                ),
              )
              .toList() ??
          [],
      onChanged: (obj) {
        _setKomik(
          _komikChapter?.id ?? _mangaId,
          _komikChapter,
        );
        _getKomikImage();
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.bounceInOut,
        );
      },
    );
  }
}
