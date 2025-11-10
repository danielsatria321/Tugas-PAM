import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class ScheduledNotificationService {
  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null, // menggunakan resource default
      [
        NotificationChannel(
          channelKey: 'scheduled_channel',
          channelName: 'Scheduled Notifications',
          channelDescription: 'Notification channel for scheduled reminders',
          defaultColor: Colors.green,
          ledColor: Colors.green,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          onlyAlertOnce: true,
          playSound: true,
        ),
      ],
    );

    // Request permission
    await AwesomeNotifications().isNotificationAllowed().then((
      isAllowed,
    ) async {
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    // Setup listeners
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onActionReceivedMethod,
      onNotificationCreatedMethod: _onNotificationCreatedMethod,
      onNotificationDisplayedMethod: _onNotificationDisplayedMethod,
    );
  }

  // Start scheduled notification every 15 seconds
  static Future<void> startLearningReminder() async {
    // Cancel any existing schedules first
    await AwesomeNotifications().cancelAllSchedules();

    // Create initial notification immediately
    await _showLearningNotification();

    // Schedule recurring notification every 15 seconds
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'scheduled_channel',
        title: 'Pengingat Belajar',
        body: 'Ayo belajar lagi!! 🎯',
        payload: {'type': 'learning_reminder'},
        notificationLayout: NotificationLayout.Default,
        autoDismissible: false,
        showWhen: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'STOP',
          label: 'Berhenti',
          autoDismissible: true,
        ),
        NotificationActionButton(
          key: 'LEARN',
          label: 'Ayo Belajar!',
          autoDismissible: true,
        ),
      ],
      schedule: NotificationInterval(
        interval: Duration(seconds: 15),
        preciseAlarm: true,
        repeats: true,
      ),
    );

    print('✅ Notifikasi belajar dijadwalkan setiap 15 detik');
  }

  // Stop all scheduled notifications
  static Future<void> stopLearningReminder() async {
    await AwesomeNotifications().cancelAllSchedules();
    await AwesomeNotifications().cancelAll();
    print('❌ Notifikasi belajar dihentikan');
  }

  // Show immediate learning notification
  static Future<void> _showLearningNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'scheduled_channel',
        title: 'Waktunya Belajar! 📚',
        body: 'Ayo belajar lagi!! Jangan menyerah! 💪',
        payload: {
          'type': 'learning_reminder',
          'time': DateTime.now().toString(),
        },
        notificationLayout: NotificationLayout.Default,
        autoDismissible: false,
        showWhen: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'LEARN_NOW',
          label: 'Mulai Belajar',
          autoDismissible: true,
        ),
      ],
    );
  }

  // Check if scheduled notification is active
  static Future<bool> isScheduledActive() async {
    final List<NotificationModel> activeSchedules = await AwesomeNotifications()
        .listScheduledNotifications();
    return activeSchedules.isNotEmpty;
  }

  // ===== Listeners =====

  @pragma('vm:entry-point')
  static Future<void> _onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    print('Action received: ${receivedAction.buttonKeyPressed}');

    final String buttonKey = receivedAction.buttonKeyPressed;
    final Map<String, String?> payload = receivedAction.payload ?? {};

    if (buttonKey == 'STOP') {
      await stopLearningReminder();
    } else if (buttonKey == 'LEARN' || buttonKey == 'LEARN_NOW') {
      // Aksi ketika user menekan tombol belajar
      await _handleLearnAction();
    } else {
      // Aksi ketika notifikasi di-tap (bukan tombol)
      await _handleNotificationTap(payload);
    }

    // Dismiss the notification
    await AwesomeNotifications().dismiss(receivedAction.id!);
  }

  static Future<void> _handleLearnAction() async {
    print('🎯 User memulai belajar!');
    // Tambahkan logika untuk membuka halaman belajar
    // atau aksi lainnya
  }

  static Future<void> _handleNotificationTap(
    Map<String, String?> payload,
  ) async {
    print('📌 Notifikasi di-tap: $payload');
    // Tambahkan logika ketika notifikasi di-tap
  }

  @pragma('vm:entry-point')
  static Future<void> _onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    print('📝 Notifikasi dibuat: ${receivedNotification.id}');
  }

  @pragma('vm:entry-point')
  static Future<void> _onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    print('🔔 Notifikasi ditampilkan: ${receivedNotification.id}');
  }
}
