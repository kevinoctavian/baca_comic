import 'package:baca_komik/color_constant.dart';
import 'package:baca_komik/database/database.dart';
import 'package:baca_komik/model/db/chapter_readed.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import 'package:baca_komik/model/model.dart';

/// kontainer dengan data UtaFormat
///
class KomikContainer2 extends StatelessWidget {
  final UtaFormat _panel;

  const KomikContainer2(this._panel, {super.key});

  void _containerClick(BuildContext context) {
    GoRouter.of(context).pushNamed('komik',
        pathParameters: {'id': _panel.id}, extra: _panel.title);
  }

  void _chapterClick(BuildContext context, String id) {
    DatabaseManager.instance.chapterReadedDatabase.insert(
      ChapterReaded(
        null,
        _panel.id,
        id,
      ),
    );

    GoRouter.of(context)
        .pushNamed('chapter', pathParameters: {'id': id}, extra: _panel);
  }

  @override
  Widget build(BuildContext context) {
    //print('${_panel.title} ${_panel.isHot ? '(Hot)' : ''}');
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color(color1[3]),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _containerClick(context),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: _panel.image,
                    width: 100,
                    fit: BoxFit.fill,
                    progressIndicatorBuilder: (context, url, progress) =>
                        Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: Stack(
                        children: [
                          Image.asset(
                            'assets/images/placeholder.gif',
                            width: 100,
                            height: 143,
                            fit: BoxFit.fill,
                          ),
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(
                                color: Colors.purple,
                                backgroundColor: Colors.deepPurple,
                                value: progress.progress,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 100,
                  height: 143,
                  color: const Color.fromARGB(30, 0, 0, 0),
                ),
                Positioned(
                  bottom: 6,
                  right: 8,
                  child: Image.asset(
                    'assets/tipe-komik/${_panel.type.name}.jpg',
                    width: 30,
                  ),
                ),
                if (_panel.isHot)
                  Positioned(
                    top: 6,
                    left: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.0),
                        color: Colors.red[600],
                      ),
                      padding: const EdgeInsets.all(4.0),
                      child: const Text(
                        'Hot',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => _containerClick(context),
                  child: Text(
                    _panel.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                ...(_panel.updateChapter
                    .map(
                      (e) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            splashColor: Colors.black,
                            onTap: () => _chapterClick(context, e.id),
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              margin: const EdgeInsets.only(bottom: 8.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Color(color1[1]),
                              ),
                              child: Text(
                                e.chapter,
                                style: TextStyle(color: Color(color1[0])),
                              ),
                            ),
                          ),
                          Text(
                            e.updateAt,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    )
                    .toList())
              ],
            ),
          ),
        ],
      ),
    );
  }
}
