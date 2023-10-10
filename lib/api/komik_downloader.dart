import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:baca_komik/model/model.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pdf_widgets;

import 'package:baca_komik/api/get_picture_path.dart';
import 'package:baca_komik/api/notification_call.dart';

class DownloaderData {
  final SendPort port;
  final List<String> urls;
  final MangaInfo? mangaInfo;
  final String komikChapter;
  final bool usePdfOutput;
  final Directory? path;

  DownloaderData(this.port, this.urls, this.mangaInfo, this.komikChapter,
      this.usePdfOutput, this.path);
}

class KomikDownloader {
  BuildContext ctx;
  MangaInfo? mangaInfo;
  String komikChapter;

  KomikDownloader(this.ctx, {required this.komikChapter, this.mangaInfo});

  Future<void> spawnThread(List<String> urls, bool usePdfOutput) async {
    final permission = await getReadWritePermission();

    if (!permission) return;

    print('Start Isolate');

    Directory? path;
    if (usePdfOutput) {
      path = await getDocumentPath();
    } else {
      path = await getPicturePath();
    }

    ReceivePort port = ReceivePort();
    port.listen((msg) {
      // msg data [bool, String, String, int]
      bool isProgress = msg[0] as bool;
      String title = msg[1] as String;
      String body = msg[2] as String;

      if (isProgress) {
        int data = msg[3] as int;
        BacaKomikNotificationManager.instance
            .showProgress(0, title, body, data);
      } else {
        BacaKomikNotificationManager.instance.show(0, title, body);
      }
    });

    await Isolate.spawn(
      downloadKomik,
      DownloaderData(
        port.sendPort,
        urls,
        mangaInfo,
        komikChapter,
        usePdfOutput,
        path,
      ),
    );
  }

  @pragma('vm:entry-point')
  static Future<void> downloadKomik(DownloaderData message) async {
    final usePdfOutput = message.usePdfOutput;
    final port = message.port;
    final komikChapter = message.komikChapter;
    final mangaInfo = message.mangaInfo;
    final urls = message.urls;
    final path = message.path;

    port.send([false, 'Komik Downloader', 'Sedang memulai Download']);

    if (path == null) {
      port.send([
        false,
        'Komik Downloader',
        'Gagal mendownload, mohon aktifkan mengakses file pada pengaturan'
      ]);
      return;
    }

    var bacaKomikDir = Directory(
      '${path.path}/BacaManga',
    );
    if (!bacaKomikDir.existsSync()) bacaKomikDir.createSync();
    var bacaKomikDirTitle = Directory(
      '${bacaKomikDir.path}/${clearTitle(mangaInfo?.title ?? '')}',
    );
    if (!bacaKomikDirTitle.existsSync()) bacaKomikDirTitle.createSync();
    var bacaKomikDirTitleChap = Directory(
      '${bacaKomikDirTitle.path}/${komikChapter.replaceAll('Ch.', 'Chapter').replaceFirst('.', ' part ')}',
    );
    if (!bacaKomikDirTitleChap.existsSync()) {
      bacaKomikDirTitleChap.createSync();
    }

    pdf_widgets.Document? docPdf;

    if (usePdfOutput) {
      docPdf = pdf_widgets.Document(
        author: mangaInfo?.title,
        producer: 'Baca Komik By Kevin',
        creator: mangaInfo?.info.join(' '),
        keywords: mangaInfo?.genres.join(' '),
      );
    }

    for (int i = 0; i < urls.length; i++) {
      // print(
      //     '${bacaKomikDirTitle.path}/${_komikChapter?.chapter}/${i + 1}.${urls[i].split('.').last}');
      http.Response res = await http.get(Uri.parse(urls[i]));

      if (res.statusCode == 200) {
        if (usePdfOutput && docPdf != null) {
          final image = pdf_widgets.MemoryImage(res.bodyBytes);

          docPdf.addPage(
            pdf_widgets.Page(
              build: (context) {
                return pdf_widgets.Image(image);
              },
            ),
            index: i,
          );
        } else {
          File file = File(
              '${bacaKomikDirTitleChap.path}/${i + 1}.${urls[i].split('.').last}');
          if (!file.existsSync()) file.createSync();

          await file.writeAsBytes(res.bodyBytes);
        }

        print('${mangaInfo?.title} panel ${i + 1} done.');
        port.send([
          true,
          'Komik Downloader',
          'Mengunduh ${i + 1} / ${urls.length} panel',
          ((i / urls.length) * 100.0).toInt(),
        ]);
      } else {
        print('Download Error with code: ${res.statusCode}');
      }
    }

    print('total page:${docPdf?.document.pdfPageList.pages.length}');

    port.send([false, 'Komik Downloader', 'Sedang mengcek file...']);

    if (!usePdfOutput) {
      port.send([
        false,
        'Komik Downloader Selesai',
        'Hasil unduh tersimpan di ${bacaKomikDirTitleChap.path}'
      ]);
      return;
    }

    if (usePdfOutput &&
        docPdf != null &&
        docPdf.document.pdfPageList.pages.isNotEmpty) {
      final file = File(
        '${bacaKomikDirTitleChap.path}/${clearTitle(mangaInfo?.title ?? '')}.pdf',
      );

      if (!file.existsSync()) file.createSync();

      await file.writeAsBytes(await docPdf.save());

      port.send([
        false,
        'Komik Downloader Selesai',
        'Hasil unduh tersimpan di ${bacaKomikDirTitleChap.path}'
      ]);
      return;
    } else {
      port.send(
          [false, 'Komik Downloader Gagal', 'Unduh gagal coba lagi nanti']);
    }
  }

  static String clearTitle(String title) {
    return title
        .replaceAll(RegExp(r"(\\|\/|:|\*|\?|\||<|>|\0)"), '')
        .replaceAll('"', '')
        .replaceAll("'", '')
        .replaceAll('&', 'and');
  }
}
