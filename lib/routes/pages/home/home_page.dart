// import 'package:baca_komik/api/notification_call.dart';
import 'package:baca_komik/color_constant.dart';
import 'package:baca_komik/widgets/komik_container_1.dart';
import 'package:baca_komik/widgets/komik_container_2.dart';
import 'package:flutter/material.dart';

import 'package:baca_komik/api/komikcast_scraping.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final KomikcastScraping _komikcast = KomikcastScraping();
  KomikHomeModel? _mangaHome;

  final EdgeInsets _komikMargin = const EdgeInsets.only(bottom: 15);

  ScrollController? _scrollController;
  bool _showGoUpButton = false;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController?.addListener(() {
      if (_scrollController!.offset > 300.0 && !_showGoUpButton) {
        setState(() {
          _showGoUpButton = true;
        });
      } else if (_scrollController!.offset == 0.0 && _showGoUpButton) {
        setState(() {
          _showGoUpButton = false;
        });
      }
      //print(_scrollController!.offset);
    });

    _getHome();
  }

  @override
  void dispose() {
    super.dispose();

    _scrollController?.dispose();
  }

  void _getHome() async {
    _mangaHome = await _komikcast.home();
    setState(() {});
  }

  Widget _goUpButton() => AnimatedOpacity(
        opacity: _showGoUpButton ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        child: FloatingActionButton(
          backgroundColor: Color(color1[4]),
          onPressed: () => _scrollController?.animateTo(0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.bounceInOut),
          child: const Icon(Icons.keyboard_arrow_up_outlined, size: 35),
        ),
      );

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return SizedBox.expand(
      child: Stack(
        children: [
          Scrollbar(
            controller: _scrollController,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _createHotKomikWidget(size),
                  _createProjectUpdate(size),
                  _createRilisanTerbaru(size),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: _goUpButton(),
          ),
        ],
      ),
    );
  }

  Widget _createHotKomikWidget(Size size) {
    if (_mangaHome == null) return Container();
    return Container(
      height: 275,
      margin: _komikMargin,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Sedang Hot',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: _mangaHome!.hotKomik.length,
              itemBuilder: (context, index) =>
                  KomikContainer1(_mangaHome!.hotKomik[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _createProjectUpdate(Size size) {
    if (_mangaHome == null) return Container();
    return Container(
      margin: _komikMargin,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Project Update',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _mangaHome!.projectUpdates.length,
            itemBuilder: (context, index) =>
                KomikContainer2(_mangaHome!.projectUpdates[index]),
          ),
        ],
      ),
    );
  }

  Widget _createRilisanTerbaru(Size size) {
    if (_mangaHome == null) return Container();
    return Container(
      margin: _komikMargin,
      child: Column(
        children: [
          const Text(
            'Rilisan Terbaru',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _mangaHome!.rilisanBaru.length,
            addSemanticIndexes: true,
            itemBuilder: (context, index) =>
                KomikContainer2(_mangaHome!.rilisanBaru[index]),
          ),
        ],
      ),
    );
  }
}
