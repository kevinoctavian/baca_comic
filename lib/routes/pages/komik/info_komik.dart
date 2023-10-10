import 'package:baca_komik/color_constant.dart';
import 'package:baca_komik/database/database.dart';
import 'package:baca_komik/model/db/chapter_readed.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:baca_komik/api/komikcast_scraping.dart';

class InfoKomik extends StatefulWidget {
  const InfoKomik(this.state, {super.key});

  final GoRouterState state;

  @override
  State<InfoKomik> createState() => _InfoKomikState();
}

class _InfoKomikState extends State<InfoKomik> {
  final KomikcastScraping _komikcast = KomikcastScraping();
  MangaInfo? _mangaInfo;

  String _title = '';
  bool _toggleImage = false;

  late ScrollController _scrollController;

  List<ChapterReaded> _chapterReaded = [];

  @override
  void initState() {
    super.initState();
    _title = widget.state.extra as String? ?? 'Unkown Title';
    _scrollController = ScrollController();

    _getInfo(widget.state.pathParameters['id'] ?? '');
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();

    DatabaseManager.instance.chapterReadedDatabase.close();
  }

  void _getInfo(String id) async {
    _mangaInfo = await _komikcast.mangaInfo(id);
    await _getChapterReaded();
    setState(() {});
  }

  void _toggleImageSize() => setState(() {
        _toggleImage = !_toggleImage;
      });

  Future _getChapterReaded() async {
    var chapters = await DatabaseManager.instance.chapterReadedDatabase
        .get(_mangaInfo!.id);

    setState(() {
      _chapterReaded = chapters;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: _mangaInfo != null
          ? Stack(
              children: [
                SizedBox(
                  width: size.width,
                  height: double.infinity,
                  child: Scrollbar(
                    controller: _scrollController,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_mangaInfo!.image.isNotEmpty)
                                GestureDetector(
                                  onTap: _toggleImageSize,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      _mangaInfo!.image,
                                      width: 120,
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  width: 120,
                                  height: 180,
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: const Center(
                                    child: Text(
                                      'No Image',
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.white),
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 2 / 1,
                                      ),
                                      itemCount: _mangaInfo!.info.length,
                                      itemBuilder: (context, index) => Text(
                                        _mangaInfo!.info[index]
                                            .replaceAll(': ', ':\n'),
                                        overflow: TextOverflow.fade,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _mangaInfo!.title
                                .replaceFirst(RegExp(r'(\s+$)'), ''),
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _mangaInfo!.altTitle
                                .replaceFirst(RegExp(r'(\s+$)'), ''),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white60,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.start,
                            spacing: 5,
                            runSpacing: 5,
                            children: _mangaInfo!.genres
                                .map(
                                  (e) => Container(
                                    padding: const EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.grey[700],
                                    ),
                                    child: Text(
                                      e,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Rating ${_mangaInfo!.rating}',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: size.width,
                            child: Text(
                              _mangaInfo!.sinopsis
                                  .replaceFirst(RegExp(r'(\s+$)'), ''),
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            height: 50,
                            child: Row(
                              children: [
                                _chapterShortcut(),
                                const SizedBox(width: 5),
                                _chapterShortcut(_mangaInfo!.chapters.length),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: size.width,
                              minHeight: 50,
                              maxHeight: 400,
                            ),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: ListView.builder(
                                itemCount: _mangaInfo!.chapters.length,
                                itemBuilder: (ctx, index) {
                                  UpdateChapter chp =
                                      _mangaInfo!.chapters[index];

                                  int chapterDBIndex =
                                      _chapterReaded.indexWhere(
                                    (el) => el.chapterId == chp.id,
                                  );

                                  return Row(
                                    children: [
                                      Checkbox(
                                        activeColor: Color(color1[0]),
                                        value: chapterDBIndex >= 0,
                                        onChanged: (checked) async {
                                          if (checked ?? false) {
                                            await DatabaseManager
                                                .instance.chapterReadedDatabase
                                                .insert(
                                              ChapterReaded(
                                                null,
                                                _mangaInfo!.id,
                                                chp.id,
                                              ),
                                            );
                                          } else {
                                            await DatabaseManager
                                                .instance.chapterReadedDatabase
                                                .delete(
                                              _chapterReaded[chapterDBIndex].id,
                                            );
                                          }

                                          setState(() {
                                            _getChapterReaded();
                                          });
                                        },
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () async {
                                            if (chapterDBIndex == -1) {
                                              setState(() {
                                                DatabaseManager.instance
                                                    .chapterReadedDatabase
                                                    .insert(
                                                  ChapterReaded(
                                                    null,
                                                    _mangaInfo!.id,
                                                    chp.id,
                                                  ),
                                                );
                                              });
                                            }

                                            await GoRouter.of(context)
                                                .pushNamed(
                                              'chapter',
                                              pathParameters: {'id': chp.id},
                                              extra: _mangaInfo,
                                            );
                                            setState(() {
                                              _getChapterReaded();
                                            });
                                          },
                                          child: SizedBox(
                                            height: 40,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  chp.chapter,
                                                  style: const TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white),
                                                ),
                                                Text(
                                                  chp.updateAt,
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white70),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_toggleImage && _mangaInfo!.image.isNotEmpty)
                  GestureDetector(
                    onTap: _toggleImageSize,
                    child: Container(
                      width: size.width,
                      height: size.height,
                      color: const Color.fromARGB(150, 0, 0, 0),
                      child: Center(
                        child: Image.network(
                          _mangaInfo!.image,
                          width: size.width * 0.80,
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget _chapterShortcut([int chpNumber = 1]) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Color(color1[3]),
        ),
        height: 75,
        child: InkWell(
          onTap: () async {
            await GoRouter.of(context).pushNamed(
              'chapter',
              pathParameters: {
                'id': _mangaInfo!.chapters.reversed.toList()[chpNumber - 1].id
              },
              extra: _mangaInfo,
            );

            setState(() {
              _getChapterReaded();
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _mangaInfo!.chapters.reversed
                      .toList()[chpNumber - 1]
                      .chapter
                      .replaceFirst('Ch.', "Chapter"),
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_right_sharp,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
