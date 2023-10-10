import 'package:flutter/material.dart';

import 'package:baca_komik/color_constant.dart';

class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});
  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  final List<int> _mycolor = [
    ...color1,
    ...color2,
    ...color3,
    ...color4,
    ...color5,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5, mainAxisSpacing: 10),
        itemCount: _mycolor.length,
        itemBuilder: (context, index) {
          return Container(
            color: Color(_mycolor[index]),
          );
        },
      ),
    );
  }
}
