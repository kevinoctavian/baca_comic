import 'dart:convert';
import 'dart:async';
import 'package:baca_komik/color_constant.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import 'package:html/parser.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;

class _SearchData {
  final String thumbnail;
  final String permalink;
  final String title;
  final List<String> genres;

  _SearchData(this.thumbnail, this.permalink, this.title, this.genres);

  @override
  String toString() {
    return '''
thumbnail : $thumbnail
permalink : $permalink
title     : $title
genres    : $genres
''';
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool _isSearching = true;
  bool _isLoading = false;

  Timer? _timer;
  late TextEditingController _controller;
  late FocusNode _focus;

  final HtmlUnescape _htmlEscape = HtmlUnescape();

  String _lastVal = '';

  final List<_SearchData> _searchData = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() {
      if (_controller.text == '') return;

      if (_lastVal != _controller.text) {
        _lastVal = _controller.text;
        if (_timer != null) {
          _timer!.cancel();
        }

        _timer = Timer(const Duration(milliseconds: 750), _searchStart);
      }
    });

    _focus = FocusNode();
    _focus.addListener(() {
      print(_focus.hasFocus);
      setState(() {
        _isSearching = _focus.hasFocus;
      });
    });
    _focus.requestFocus();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.removeListener(() {});
    _controller.dispose();

    _focus.removeListener(() {});
    _focus.dispose();

    _timer?.cancel();
  }

  dynamic _searchStart() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      // _searchData.clear();
      _isLoading = true;
    });

    var headers = {
      'User':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36',
      'X-Requested-With': 'XMLHttpRequest',
      'Origin': 'https://komikcast.io',
      'Referer': 'https://komikcast.io/',
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    var request = http.Request(
        'POST', Uri.parse('https://komikcast.io/wp-admin/admin-ajax.php'));
    request.bodyFields = {
      'action': 'searchkomik_komikcast_redesign',
      'search': _controller.text,
      'orderby': 'relevance',
      'per_page': '45'
    };
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String data = await response.stream.bytesToString();
      List<dynamic> jsonData = json.decode(data);
      List<_SearchData> temp = [];
      for (var data in jsonData) {
        var imgData = parse(data['thumbnail']).getElementsByTagName('img');
        String img = '';
        List<String> genres = [];

        if (imgData.isNotEmpty) {
          img = imgData[0].attributes['src'] ?? '';
          //print(imgData[0].attributes['src']);
        }

        for (var genre in data['genres']) {
          genres.add(genre['name']);
        }

        _SearchData searchData =
            _SearchData(img, data['permalink'], data['title'], genres);

        // print(searchData.thumbnail);
        temp.add(searchData);
      }
      setState(() {
        _searchData.clear();
        _searchData.addAll(temp);
        _isLoading = false;
        //print(_searchData);
      });
    } else {
      print(response.reasonPhrase);
      setState(() {
        // _searchData.clear();
        _isLoading = false;
      });
    }
  }

  void _onSubmit(String value) {
    setState(() => _isSearching = false);
  }

  Widget _changeTitle() {
    TextField field = TextField(
      autocorrect: false,
      focusNode: _focus,
      controller: _controller,
      onSubmitted: _onSubmit,
      // onTapOutside: (e) => print('Tap ouside'),
      cursorColor: Colors.white,
      decoration: const InputDecoration(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
      ),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
    );

    return field;
  }

  String _clearLink(String link) {
    link = link.replaceAll(RegExp(r'(\/+$|\/+\s+)'), '');

    Uri url = Uri.parse(link);
    List<String> paths = url.path.split('/');

    return paths.last;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _changeTitle(),
        actions: [
          TextButton.icon(
            onPressed: () {
              if (_isSearching) {
                _controller.clear();
              } else {
                _focus.requestFocus();
              }
            },
            icon: Icon(
              !_isSearching ? Icons.search_outlined : Icons.search_off_outlined,
              color: !_isSearching ? Colors.white : Colors.red[300],
              size: 25,
            ),
            label: const Text(''),
            style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.transparent),
            ),
          ),
        ],
      ),
      body: Listener(
        onPointerDown: (pointerEvent) => _focus.unfocus(),
        child: SizedBox.expand(
          child: !_isLoading
              ? SingleChildScrollView(
                  // padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _searchData.length,
                        itemBuilder: (context, index) {
                          _SearchData data = _searchData[index];
                          return Container(
                            decoration: BoxDecoration(color: Color(color1[3])),
                            margin: const EdgeInsets.only(bottom: 5.0),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 5.0),
                            child: InkWell(
                              onTap: () {
                                GoRouter.of(context).pushNamed('komik',
                                    pathParameters: {
                                      'id': _clearLink(data.permalink)
                                    },
                                    extra: _htmlEscape.convert(data.title));
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      if (data.thumbnail.isNotEmpty)
                                        CachedNetworkImage(
                                          imageUrl: data.thumbnail,
                                          width: 110,
                                          height: 140,
                                          fit: BoxFit.fill,
                                        ),
                                      Container(
                                        width: 110,
                                        height: 140,
                                        color:
                                            const Color.fromARGB(30, 0, 0, 0),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _htmlEscape.convert(data.title),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Genre: ${data.genres.join(', ').replaceFirst(RegExp(r'($,)'), '')}',
                                          overflow: TextOverflow.fade,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white70,
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
                      // if (_searchData.isNotEmpty)
                      //   Container(
                      //     padding: const EdgeInsets.all(5.0),
                      //     decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(8.0),
                      //       color: Color(color1[1]),
                      //     ),
                      //     child: TextButton(
                      //       onPressed: () {},
                      //       child: Text(
                      //         'Liat Lebih Banyak',
                      //         style: TextStyle(
                      //           fontSize: 16,
                      //           fontWeight: FontWeight.w500,
                      //           color: Color(color1[0]),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // const SizedBox(height: 10.0),
                    ],
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ),
    );
  }
}
