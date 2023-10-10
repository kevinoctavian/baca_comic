//import 'package:baca_komik/api/notification_call.dart';
// import 'package:baca_komik/color_constant.dart';
import 'package:baca_komik/routes/pages/home/daftar_isi.dart';
import 'package:baca_komik/routes/pages/home/history_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'keep_alive_page_wrapper.dart';

import 'home_page.dart';
import 'popular_page.dart';
import 'pengaturan_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  bool get wantKeepAlive => true;

  final List<String> _appBarName = [
    'Baca Komik', // Home Title
    'Populer', // popular Page title
    'Daftar Isi', // popular Page title
    'History', // popular Page title
    'Pengaturan', // popular Page title
  ];
  final List<Widget> _pages = const [
    HomePage(),
    PopularPage(),
    DaftarIsiPage(),
    HistoryPage(),
    PengaturanPage(),
  ];

  @override
  void initState() {
    _pageController = PageController(initialPage: _currentIndex);
    super.initState();

    //BacaKomikNotificationManager.instance.show(1,'testing', 'haha');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _appBarName.elementAt(_currentIndex),
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              GoRouter.of(context).pushNamed('search');
            },
            icon: const Center(
              child: Icon(
                Icons.search_rounded,
                color: Colors.white,
              ),
            ),
            label: const Text(''),
            style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.transparent),
            ),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Center(
              child: Icon(
                Icons.more_vert_rounded,
                color: Colors.white,
              ),
            ),
            label: const Text(''),
            style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.transparent),
            ),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (page) => setState(() => _currentIndex = page),
        itemCount: _pages.length,
        itemBuilder: (context, index) => KeepAlivePageWrapper(
          keepAlive: index != 3,
          child: _pages[index],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (value) => setState(() {
          value = value > _pages.length - 1 ? _pages.length - 1 : value;

          _currentIndex = value;
          _pageController.jumpToPage(value);
        }),
        type: BottomNavigationBarType.fixed,
        items: const <_BottomNavBar>[
          _BottomNavBar(
            icon: Icon(Icons.home),
            label: 'Home',
            tooltip: 'Home',
          ),
          _BottomNavBar(
            icon: Icon(Icons.star_rate),
            label: 'Populer',
            tooltip: 'Manga, Manhwa, Manhua Populer',
          ),
          _BottomNavBar(
            icon: Icon(Icons.list_alt),
            label: 'Daftar Isi',
            tooltip: 'Daftar Daftar isi Manga, Manhwa, Manhua',
          ),
          _BottomNavBar(
            icon: Icon(Icons.hourglass_empty),
            label: 'History',
            tooltip: 'History bacaan',
          ),
          _BottomNavBar(
            icon: Icon(Icons.settings_applications),
            label: 'Pengaturan',
            tooltip: 'Pengaturan Aplikasi',
          ),
        ],
      ),
    );
  }
}

class _BottomNavBar extends BottomNavigationBarItem {
  const _BottomNavBar({required super.icon, super.label, super.tooltip = ''})
      : super(backgroundColor: Colors.deepPurpleAccent);
}
