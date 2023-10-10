import 'package:baca_komik/api/notification_call.dart';
import 'package:baca_komik/color_constant.dart';
import 'package:baca_komik/routes/baca_komik_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Color(color1[0]),
  ));

  await BacaKomikNotificationManager.instance.initNotifitcation();

  runApp(BacaKomikApp());
}
