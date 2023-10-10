import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/pages.dart';
import 'package:baca_komik/color_constant.dart';

class BacaKomikApp extends StatelessWidget {
  BacaKomikApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('main widgets');
    return MaterialApp.router(
      theme: ThemeData(
        appBarTheme: AppBarTheme(backgroundColor: Color(color1[0])),
        scaffoldBackgroundColor: Color(color1[2]),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Color(color1[0]),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.shifting,
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            maximumSize: const MaterialStatePropertyAll(
                Size(double.infinity, double.infinity)),
            textStyle:
                const MaterialStatePropertyAll(TextStyle(color: Colors.white)),
            padding: const MaterialStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0)),
            backgroundColor: MaterialStatePropertyAll(Color(color1[1])),
          ),
        ),
      ),
      routerConfig: _router,
    );
  }

  final _router = GoRouter(
    // initialLocation: '/komik/heavenly-demon-instructor',
    // initialExtra: 'Heavenly Demon Instructor',
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (ctx, state) => const Home(),
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (ctx, state) => const SearchPage(),
      ),
      GoRoute(
        path: '/komik/:id',
        name: 'komik',
        builder: (ctx, state) => InfoKomik(state),
      ),
      GoRoute(
        path: '/chapter/:id',
        name: 'chapter',
        builder: (ctx, state) => BacaKomikWidget(state, ctx),
      ),
    ],
  );
}
