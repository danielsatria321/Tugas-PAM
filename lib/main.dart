import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'Pages/Login.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationService {
  static Future<void> initialize() async {
    //1. Inisialisasi Library
    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: 'learning_reminder_channel',
        channelName: 'Learning Reminder Notifications',
        channelDescription: 'Notification channel for learning reminders',
        defaultColor: Colors.green,
        ledColor: Colors.green,
        importance: NotificationImportance.High,
        channelShowBadge: true,
        onlyAlertOnce: true,
        playSound: true,
        criticalAlerts: true,
      ),
    ]);
    //2. Memeriksa dan Meminta Izin
    await AwesomeNotifications().isNotificationAllowed().then((
      isAllowed,
    ) async {
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    // Ketika ditekan
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onActionReceivedMethod,
      onNotificationCreatedMethod: _onNotificationCreatedMethod,
      onNotificationDisplayedMethod: _onNotificationDisplayedMethod,
    );

    await startLearningReminder();
  }

  static Future<void> startLearningReminder() async {
    await AwesomeNotifications().cancelAllSchedules();

    await _showLearningNotification();
    // 3. Membuat dan Menjadwal Notifikasi
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'learning_reminder_channel',
        title: 'Waktunya Belajar!',
        body: 'Ayo belajar lagi!! Jangan menyerah! ',
        payload: {'type': 'learning_reminder', 'action': 'study_time'},
        notificationLayout: NotificationLayout.Default,
        autoDismissible: false,
        showWhen: true,
        displayOnForeground: true,
        displayOnBackground: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'START_STUDY',
          label: 'Mulai Belajar',
          autoDismissible: true,
        ),
        NotificationActionButton(
          key: 'SNOOZE',
          label: 'Tunda 5 Menit',
          autoDismissible: true,
        ),
      ],
      schedule: NotificationInterval(
        interval: Duration(seconds: 60),
        preciseAlarm: true,
        repeats: true,
      ),
    );

    print('Notifikasi belajar dijadwalkan setiap 60 detik');
  }

  static Future<void> stopLearningReminder() async {
    await AwesomeNotifications().cancelAllSchedules();
    await AwesomeNotifications().cancelAll();
    print(' Notifikasi belajar dihentikan');
  }

  static Future<void> _showLearningNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'learning_reminder_channel',
        title: 'Quiz App Reminder',
        body: 'Ayo belajar lagi!! Tingkatkan pengetahuanmu! 🚀',
        payload: {
          'type': 'learning_reminder',
          'time': DateTime.now().toString(),
        },
        notificationLayout: NotificationLayout.Default,
        autoDismissible: false,
        showWhen: true,
      ),
    );
  }

  //Aksi saat tombolnya ditekan
  @pragma('vm:entry-point')
  static Future<void> _onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    print('Action received: ${receivedAction.buttonKeyPressed}');

    final String buttonKey = receivedAction.buttonKeyPressed;
    final Map<String, String?> payload = receivedAction.payload ?? {};

    if (buttonKey == 'START_STUDY') {
      _navigateToStudyPage();
    } else if (buttonKey == 'SNOOZE') {
      // Snooze
      await _snoozeReminder();
    } else {
      _navigateToStudyPage();
    }

    await AwesomeNotifications().dismiss(receivedAction.id!);
  }

  static void _navigateToStudyPage() {
    navigatorKey.currentState?.pushNamed('/login');
    print('Navigating to study page...');
  }

  static Future<void> _snoozeReminder() async {
    await stopLearningReminder();

    await Future.delayed(Duration(minutes: 5));
    await startLearningReminder();

    print('⏸ Reminder ditunda 5 menit');
  }

  @pragma('vm:entry-point')
  static Future<void> _onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    print('Notifikasi belajar dibuat: ${receivedNotification.id}');
  }

  @pragma('vm:entry-point')
  static Future<void> _onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    print(' Notifikasi belajar ditampilkan: ${receivedNotification.id}');
  }

  static Future<bool> isScheduledActive() async {
    final List<NotificationModel> activeSchedules = await AwesomeNotifications()
        .listScheduledNotifications();
    return activeSchedules.isNotEmpty;
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  print('Starting Quiz App');

  // Menjalankan Notifikasi dulu
  NotificationService.initialize().then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      navigatorKey: navigatorKey,
      routes: {'/login': (context) => const LoginPage()},
    );
  }
}
