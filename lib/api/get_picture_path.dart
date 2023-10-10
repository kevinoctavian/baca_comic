import 'dart:io';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

Future<Directory?> getPicturePath() async {
  final status = await getReadWritePermission();
  const platform = MethodChannel('com.vinindie.apps.baca_komik');

  try {
    if (status) {
      final String? picturesDirectory =
          await platform.invokeMethod('getPictureDirectoryPath');
      return Directory(picturesDirectory!);
    }
  } on PlatformException catch (e) {
    print('failed To get Picture directory: ${e.message}');
  }
  return null;
}

Future<Directory?> getDocumentPath() async {
  final status = await getReadWritePermission();
  const platform = MethodChannel('com.vinindie.apps.baca_komik');

  try {
    if (status) {
      final String? picturesDirectory =
          await platform.invokeMethod('getDocumentDirectoryPath');
      return Directory(picturesDirectory!);
    }
  } on PlatformException catch (e) {
    print('failed To get Picture directory: ${e.message}');
  }
  return null;
}

Future<bool> getReadWritePermission() async {
  final PermissionStatus status = await Permission.storage.request();
  return status.isGranted;
}
