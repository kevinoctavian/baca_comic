import 'package:baca_komik/color_constant.dart';
import 'package:baca_komik/widgets/komik_container_1.dart';
import 'package:flutter/material.dart';

import 'package:baca_komik/api/komikcast_scraping.dart';

class PopularPage extends StatefulWidget {
  const PopularPage({super.key});
  @override
  State<PopularPage> createState() => _PopularPageState();
}

class _PopularPageState extends State<PopularPage> {
  final KomikcastScraping _komikcastScraping = KomikcastScraping();
  late ScrollController _scrollController;

  int _currentPage = 1;
  bool _isLoading = true;
  final List<ListUpdateFormat> _popularKomik = [];

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _getPopulerKomik(_currentPage);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  void _getPopulerKomik(int page) async {
    var komikPopular = await _komikcastScraping.popular(page);

    setState(() {
      _currentPage = page;
      _isLoading = false;
      _popularKomik.addAll(komikPopular);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          children: [
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisExtent: 245,
                mainAxisSpacing: 10,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _popularKomik.length,
              itemBuilder: (context, index) {
                ListUpdateFormat updateFormat = _popularKomik[index];
                return KomikContainer1(
                  updateFormat,
                );
              },
            ),
            const SizedBox(height: 10.0),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: () {
                  if (_isLoading) return;
                  setState(() => _isLoading = true);

                  _getPopulerKomik(++_currentPage);
                },
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.indigoAccent,
                        semanticsLabel: 'label',
                        semanticsValue: 'value',
                        strokeWidth: 2,
                      )
                    : Text(
                        'Next Page',
                        style: TextStyle(
                          color: Color(color1[0]),
                        ),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
