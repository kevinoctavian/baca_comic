import 'package:baca_komik/color_constant.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import 'package:baca_komik/model/model.dart';

/// kontainer dengan data List Format Update
///
class KomikContainer1 extends StatelessWidget {
  final ListUpdateFormat _panel;

  const KomikContainer1(this._panel, {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        GoRouter.of(context).pushNamed('komik',
            pathParameters: {'id': _panel.id}, extra: _panel.title);
      },
      child: Container(
        width: 115,
        height: 245,
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color(color1[3]),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                if (_panel.image.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: _panel.image,
                      width: 110,
                      height: 140,
                      fit: BoxFit.fill,
                      progressIndicatorBuilder: (context, url, progress) =>
                          Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: Stack(
                          children: [
                            Image.asset(
                              'assets/images/placeholder.gif',
                              width: 110,
                              height: 140,
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
                  width: 110,
                  height: 140,
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
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _panel.title,
                      maxLines: 2,
                      textAlign: TextAlign.left,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.white70),
                      semanticsLabel: _panel.title,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _panel.totalChapter,
                      maxLines: 1,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
