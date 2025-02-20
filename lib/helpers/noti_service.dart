// credit: mitch koko
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../database/local_database.dart';

class NotiService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialised => _isInitialized;

  Future<void> initNotification() async {
    if (_isInitialized) return;

    // TODO: add custom icon
    const initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    // linux configured for debug purposes
    const initSettingsLinux = LinuxInitializationSettings(defaultActionName: 'Log Food');

    await notificationsPlugin.initialize(InitializationSettings(android: initSettingsAndroid, linux: initSettingsLinux));

    // request notification permissions
    await notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
          'reminder_channel_id',
          'Reminders',
          channelDescription: 'Reminder Notification Channel',
          importance: Importance.max,
          priority: Priority.high
      ),
      linux: LinuxNotificationDetails()
    );
  }
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body
  }) async {
    return notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails()
    );
  }
  static void scheduledNotification() async {

    print('got here');
    NotiService().initNotification();

    LocalDatabase db = LocalDatabase();

    // if no entries for todays date (checked at 5pm), send notification
    if (!db.foodEntriesToday(DateTime.now().toString())) {
      NotiService().showNotification(title: 'Add Foods!', body: "Don't forget to track your calories today!");
    }
  }
}