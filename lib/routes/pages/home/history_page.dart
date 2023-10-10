import 'package:baca_komik/color_constant.dart';
import 'package:baca_komik/database/database.dart';
import 'package:baca_komik/database/history_database.dart';
import 'package:baca_komik/model/db/history_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryDatabase _historyDb = DatabaseManager.instance.historyDatabase;

  List<History> _history = [];

  @override
  void initState() {
    super.initState();

    getHistory();
  }

  @override
  void dispose() {
    super.dispose();
    _historyDb.close();
  }

  Future<void> getHistory() async {
    var history = await _historyDb.get();
    // print(history);
    setState(() {
      _history = history;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: RefreshIndicator(
            onRefresh: getHistory,
            child: Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10.0,
                    crossAxisSpacing: 10.0,
                    mainAxisExtent: 265,
                  ),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    History history = _history[index];
                    return Container(
                      padding: const EdgeInsets.all(10.0),
                      color: Color(color1[3]),
                      child: InkWell(
                        onTap: () {
                          GoRouter.of(context).pushNamed(
                            'komik',
                            pathParameters: {'id': history.komikId},
                            extra: history.title,
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: CachedNetworkImage(
                                imageUrl: history.image,
                                width: 100,
                                height: 130,
                                fit: BoxFit.fill,
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.black87,
                                  child: const Center(
                                    child: Text(
                                      'Image Error',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            Expanded(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    history.title,
                                    maxLines: 3,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Last Chapter: ${history.chapterField.title}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: getHistory,
                  child: Text(
                    'get History',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(color1[0]),
                    ),
                  ),
                ),
                // TextButton(
                //   onPressed: () async {
                //     var db = await _historyDb.database;

                //     db
                //         .rawQuery('SELECT * FROM history')
                //         .then((value) => print(value));
                //   },
                //   child: Text(
                //     'Test History',
                //     style: TextStyle(
                //       color: Color(color1[0]),
                //     ),
                //   ),
                // ),
                // TextButton(
                //   onPressed: () async {
                //     await _historyDb.close();
                //     print('closed');
                //   },
                //   child: Text(
                //     'Close',
                //     style: TextStyle(
                //       color: Color(color1[0]),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
