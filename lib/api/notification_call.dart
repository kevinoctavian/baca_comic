import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BacaKomikNotificationManager {
  static BacaKomikNotificationManager instance =
      BacaKomikNotificationManager._init();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final AndroidNotificationDetails _androidNotificationDetails =
      const AndroidNotificationDetails(
    'baca-komik-notification',
    'Baca Komik Notification',
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
  );

  BacaKomikNotificationManager._init();

  Future<void> initNotifitcation() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponse,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  void show(int id, String title, String body) async {
    final NotificationDetails notificationDetails =
        NotificationDetails(android: _androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: 'normalNotification',
    );
  }

  void showProgress(int id, String title, String body, int progress) async {
    AndroidNotificationDetails androidDownloadNotificationDetails =
        AndroidNotificationDetails(
      'baca-komik-download-notification',
      'Baca Komik Download Notification',
      playSound: false,
      enableVibration: false,
      enableLights: false,
      importance: Importance.max,
      priority: Priority.max,
      maxProgress: 100,
      ongoing: progress != 100,
      showProgress: true,
      progress: progress,
      category: AndroidNotificationCategory.progress,
      actions: const [
        AndroidNotificationAction('cancel', 'Cancel', showsUserInterface: true),
      ],
    );

    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidDownloadNotificationDetails);

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: 'normalNotification',
    );
  }

  @pragma('vm:entry-point')
  static void onDidReceiveBackgroundNotificationResponse(
      NotificationResponse res) {
    print(
      '''
_onDidReceiveBackgroundNotificationResponse:
id: ${res.id},
actionId: ${res.actionId},
input: ${res.input},
payload: ${res.payload},
notificationResponseType: ${res.notificationResponseType}
''',
    );
  }

  @pragma('vm:entry-point')
  static void onDidReceiveNotificationResponse(NotificationResponse res) {
    print(
      '''
_onDidReceiveNotificationResponse:
id: ${res.id},
actionId: ${res.actionId},
input: ${res.input},
payload: ${res.payload},
notificationResponseType: ${res.notificationResponseType}
''',
    );
  }
}
