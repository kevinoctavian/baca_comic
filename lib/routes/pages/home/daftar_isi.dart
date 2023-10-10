import 'package:baca_komik/color_constant.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import 'package:baca_komik/widgets/komik_container_1.dart';
import 'package:baca_komik/api/komikcast_scraping.dart';

class DaftarIsiPage extends StatefulWidget {
  const DaftarIsiPage({super.key});
  @override
  State<DaftarIsiPage> createState() => _DaftarIsiPageState();
}

class _DaftarIsiPageState extends State<DaftarIsiPage> {
  final KomikcastScraping _komikcastScraping = KomikcastScraping();
  late ScrollController _scrollController;

  int _currentPage = 1;
  bool _isLoading = true;
  bool _showNextButton = true;
  final List<ListUpdateFormat> _popularKomik = [];

  //Search Option Data field
  List<GenresEnum?> _genresList = [];
  StatusEnum _status = StatusEnum.all;
  SortByEnum _sortByEnum = SortByEnum.titleasc;
  ComicType _comicType = ComicType.all;

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

  void _getPopulerKomik(int page, [bool isChangeOption = false]) async {
    if (isChangeOption) {
      setState(() {
        _isLoading = true;
        _showNextButton = true;
        _popularKomik.clear();
      });
    }

    var komikPopular = await _komikcastScraping.searchByOption(
        SearchOption(
          _genresList,
          sortby: _sortByEnum,
          status: _status,
          type: _comicType,
        ),
        page);

    setState(() {
      _currentPage = page;
      _showNextButton = komikPopular.isNotEmpty;
      _isLoading = false;

      _popularKomik.addAll(komikPopular);
    });
  }

  void _onConfirm(List<GenresEnum?> genres) {
    setState(() {
      _genresList = genres;
    });
  }

  void _onDropdownChange(Object? obj) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          children: [
            GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 45,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                Container(
                  color: Color(color1[1]),
                  child: MultiSelectBottomSheetField<GenresEnum?>(
                    listType: MultiSelectListType.CHIP,
                    colorator: (p0) => Color(color1[0]).withAlpha(100),
                    decoration: const BoxDecoration(),
                    buttonText: Text(
                      'Select ${_genresList.isNotEmpty ? _genresList.length : ''} Genres',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    title: const Text('Genres',
                        style: TextStyle(color: Colors.white)),
                    onConfirm: _onConfirm,
                    items: GenresEnum.values
                        .map(
                          (e) => MultiSelectItem<GenresEnum?>(
                            e,
                            SearchOption.fixGenre(e),
                          ),
                        )
                        .toList(),
                    initialValue: _genresList,
                    isDismissible: true,
                    chipDisplay: MultiSelectChipDisplay.none(),
                    cancelText: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black),
                    ),
                    confirmText: const Text(
                      'Confirm Genres',
                      style: TextStyle(color: Colors.black),
                    ),
                    backgroundColor: Color(color1[2]),
                  ),
                ),
                Container(
                  color: Color(color1[1]),
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: DropdownButton(
                    value: _comicType,
                    icon: Icon(
                      Icons.arrow_downward,
                      size: 25,
                      color: Color(color1[0]),
                    ),
                    isExpanded: true,
                    items: ComicType.values
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            onTap: () => _comicType = e,
                            child: Text(SearchOption.capitalize(e.name)),
                          ),
                        )
                        .toList(),
                    onChanged: _onDropdownChange,
                  ),
                ),
                Container(
                  color: Color(color1[1]),
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: DropdownButton(
                    value: _status,
                    icon: Icon(
                      Icons.arrow_downward,
                      size: 25,
                      color: Color(color1[0]),
                    ),
                    isExpanded: true,
                    items: StatusEnum.values
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            onTap: () => _status = e,
                            child: Text(SearchOption.capitalize(e.name)),
                          ),
                        )
                        .toList(),
                    onChanged: _onDropdownChange,
                  ),
                ),
                Container(
                  color: Color(color1[1]),
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: DropdownButton(
                    value: _sortByEnum,
                    icon: Icon(
                      Icons.arrow_downward,
                      size: 25,
                      color: Color(color1[0]),
                    ),
                    isExpanded: true,
                    items: SortByEnum.values
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            onTap: () => _sortByEnum = e,
                            child: Text(SearchOption.fixSortBy(e)),
                          ),
                        )
                        .toList(),
                    onChanged: _onDropdownChange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    _currentPage = 1;
                    _getPopulerKomik(_currentPage, true);
                  },
                  child: Text(
                    'Update List',
                    style: TextStyle(
                      color: Color(color1[0]),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _genresList = [];
                      _status = StatusEnum.all;
                      _sortByEnum = SortByEnum.titleasc;
                      _comicType = ComicType.all;
                    });
                  },
                  child: Text(
                    'Reset Option',
                    style: TextStyle(
                      color: Color(color1[0]),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
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
            if (_showNextButton)
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
